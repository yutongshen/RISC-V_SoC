`include "intf_define.h"
`include "axi_define.h"
`include "tlb_define.h"

module mmu (
    input                                    clk,
    input                                    rstn,
    
    // access type
    input                                    access_w,
    input                                    access_x,
    input                                    access_ex,

    // mpu csr
    input                                    pmp_v,
    input                                    pmp_l,
    input                                    pmp_x,
    input                                    pmp_w,
    input                                    pmp_r,

    input                                    pma_v,
    input                                    pma_l,
    input                                    pma_c,
    input                                    pma_e,

    // TLB control
    input                                    tlb_flush_req,
    input                                    tlb_flush_all_vaddr,
    input                                    tlb_flush_all_asid,
    input        [              `XLEN - 1:0] tlb_flush_vaddr,
    input        [              `XLEN - 1:0] tlb_flush_asid,

    // mmu csr
    input                                    rv64_mode,
    input        [    `SATP_PPN_WIDTH - 1:0] satp_ppn,
    input        [   `SATP_ASID_WIDTH - 1:0] satp_asid,
    input        [   `SATP_MODE_WIDTH - 1:0] satp_mode,
    input        [                      1:0] prv,
    input                                    sum,
    input                                    mprv,
    input        [                      1:0] mpp,

    // virtual address
    input                                    va_valid,
    input        [                     63:0] va,

    // Cache ctrl
    output logic                             cache_bypass,

    // physical address
    output logic                             pa_valid,
    output logic [                      1:0] pa_bad,
    output logic [                     55:0] pa,
    output logic                             pa_pre_vld,
    output logic                             pa_pre_wr,
    output logic                             pa_pre_rd,
    output logic                             pa_pre_ex,
    output logic [                     63:0] pa_pre,
    
    // AXI interface
    axi_intf.master                          m_axi_intf
);

parameter [1:0] STATE_IDLE  = 2'b00,
                STATE_CHECK = 2'b01,
                STATE_MREQ  = 2'b10,
                STATE_PTE   = 2'b11;

logic [                 1:0] cur_state;
logic [                 1:0] nxt_state;

logic                        va_en;
logic [                55:0] va_latch;
logic                        last_hit;
logic                        last_va_en;
logic [                35:0] last_vpn;
logic [                 2:0] last_spage;
logic [                35:0] vpn;
logic [                36:0] vpn_latch;
logic [                21:0] ppn_latch;
logic [`SATP_MODE_WIDTH-1:0] satp_mode_latch;
logic                        busy;
logic                        leaf;
logic                        sum_latch;
logic                        access_r_latch;
logic                        access_w_latch;
logic                        access_x_latch;
logic                        access_ex_latch;
logic [                63:0] pte_latch;
logic [                43:0] pte_ppn, tlb_pte_ppn, last_pte_ppn;
logic [                 1:0] pte_rsw, tlb_pte_rsw, last_pte_rsw;
logic                        pte_d,   tlb_pte_d  , last_pte_d  ;
logic                        pte_a,   tlb_pte_a  , last_pte_a  ;
logic                        pte_g,   tlb_pte_g  , last_pte_g  ;
logic                        pte_u,   tlb_pte_u  , last_pte_u  ;
logic                        pte_x,   tlb_pte_x  , last_pte_x  ;
logic                        pte_w,   tlb_pte_w  , last_pte_w  ;
logic                        pte_r,   tlb_pte_r  , last_pte_r  ;
logic                        pte_v,   tlb_pte_v  , last_pte_v  ;
logic                        tlb_data_sel;
logic [                 5:0] spage;
logic                        bus_boundary;
logic                        pmp_err;
logic                        pg_fault;
logic                        pg_fault_tlb;
logic                        pg_fault_pte;
logic                        bus_err;
logic                        ar_done;
logic [                 1:0] prv_post;
logic [                 1:0] prv_latch;

logic                        tlb_cs;
logic                        tlb_we;
logic                        tlb_hit;
logic [  `TLB_VPN_WIDTH-1:0] tlb_vpn;
logic [  `TLB_PTE_WIDTH-1:0] tlb_pte_in;
logic [  `TLB_PTE_WIDTH-1:0] tlb_pte_out;
logic [                 2:0] tlb_spage_in;
logic [                 2:0] tlb_spage_out;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cur_state <= STATE_IDLE;
    else       cur_state <= nxt_state;
end

always_comb begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE : begin
            nxt_state = (va_en && ~last_hit) && va_valid ? STATE_CHECK : STATE_IDLE;
        end
        STATE_CHECK: begin
            nxt_state = ~tlb_hit ? STATE_MREQ:
                                   STATE_IDLE;
        end
        STATE_MREQ : begin
            nxt_state = m_axi_intf.rvalid && m_axi_intf.rresp[1] ? STATE_IDLE:
                        m_axi_intf.rvalid && m_axi_intf.rlast    ? STATE_PTE :
                                                                   STATE_MREQ;
        end
        STATE_PTE  : begin
            nxt_state = leaf || pg_fault_pte ? STATE_IDLE:
                                               STATE_MREQ;
        end
    endcase
end

always_comb begin
    m_axi_intf.arvalid = 1'b0;
    tlb_cs             = 1'b0;
    tlb_we             = 1'b0;
    pa_pre_vld         = 1'b0;
    pa_pre_wr          = access_w_latch;
    pa_pre_rd          = access_r_latch;
    pa_pre_ex          = access_ex_latch;
    busy               = 1'b0;
    tlb_data_sel       = 1'b0;
    case (cur_state)
        STATE_IDLE : begin
            tlb_cs             = va_en;
            pa_pre_vld         = va_valid && (~va_en || last_hit);
            pa_pre_wr          = ~access_x &  access_w;
            pa_pre_rd          = ~access_x & ~access_w;
            pa_pre_ex          = access_ex;
            busy               = 1'b0;
        end
        STATE_CHECK: begin
            pa_pre_vld         = tlb_hit;
            busy               = 1'b1;
            tlb_data_sel       = 1'b1;
        end
        STATE_MREQ : begin
            m_axi_intf.arvalid = ~ar_done;
            pa_pre_vld         = m_axi_intf.rvalid && m_axi_intf.rresp[1];
            busy               = 1'b1;
        end
        STATE_PTE  : begin
            pa_pre_vld         = leaf ||  pg_fault_pte;
            tlb_cs             = leaf && ~pg_fault_pte;
            tlb_we             = 1'b1;
            busy               = 1'b1;
        end
    endcase
end

assign prv_post     = ~access_x && mprv ? mpp : prv;
assign leaf         = pte_v && (pte_r || pte_x);
assign pg_fault_pte = !pte_v || (!pte_r && pte_w) ||
                      (~leaf && ~spage[0]) ||
`ifdef RV32
                      ( leaf && spage[0] && |pte_ppn[9:0]) ||
`else
                      ( leaf && spage[0] && ~satp_mode_latch[3] && |pte_ppn[ 0+:10]) ||
                      ( leaf && spage[0] &&  satp_mode_latch[3] && |pte_ppn[ 0+: 9]) ||
                      ( leaf && spage[1] &&  satp_mode_latch[3] && |pte_ppn[ 9+: 9]) ||
                      ( leaf && spage[2] &&  satp_mode_latch[3] && |pte_ppn[18+: 9]) ||
`endif
                      ( leaf && access_x_latch      && ~pte_x) ||
                      ( leaf && access_r_latch      && ~pte_r) ||
                      ( leaf && access_w_latch      && ~pte_w) ||
                      ( leaf && prv_latch == `PRV_U && ~pte_u) ||
                      ( leaf && prv_latch == `PRV_S &&  pte_u && (~sum_latch || access_x_latch)) ||
                      ( leaf && access_w_latch      && ~pte_d) ||
                      ( leaf                        && ~pte_a);

assign pg_fault_tlb = (access_x_latch      && ~tlb_pte_x) ||
                      (access_r_latch      && ~tlb_pte_r) ||
                      (access_w_latch      && ~tlb_pte_w) ||
                      (prv_latch == `PRV_U && ~tlb_pte_u) ||
                      (prv_latch == `PRV_S &&  tlb_pte_u && (~sum_latch || access_x_latch)) ||
                      (access_w_latch      && ~tlb_pte_d) ||
                      (                       ~tlb_pte_a);

assign pg_fault_last = ( access_x              && ~last_pte_x) ||
                       (~access_w && ~access_x && ~last_pte_r) ||
                       ( access_w && ~access_x && ~last_pte_w) ||
                       ( prv_post == `PRV_U    && ~last_pte_u) ||
                       ( prv_post == `PRV_S    &&  last_pte_u && (~sum || access_x)) ||
                       ( access_w && ~access_x && ~last_pte_d) ||
                       (                          ~last_pte_a);

assign bus_boundary = |pa_pre[63:`BUS_WIDTH-1] & ~&pa_pre[63:`BUS_WIDTH-1];

assign pmp_err      = (!pmp_v && prv_latch != `PRV_M) ||
                      (( pmp_l || prv_latch != `PRV_M) &&
                      ((!pmp_x && access_x_latch) ||
                       (!pmp_w && access_w_latch) ||
                       (!pmp_r && access_r_latch)));
                    
assign tlb_spage_in = spage[2:0];
`ifdef RV32
assign tlb_vpn      = {16'b0, busy ? va_latch[12+:20] : va[12+:20]};
`else
assign tlb_vpn      = ({36{~satp_mode_latch[3]}} & {16'b0, busy ? va_latch[12+:20] : va[12+:20]}) |
                      ({36{ satp_mode_latch[3]}} & {       busy ? va_latch[12+:36] : va[12+:36]});
`endif
assign tlb_pte_in   = pte_latch;
assign {pte_ppn, pte_rsw, pte_d, pte_a, pte_g, pte_u, pte_x, pte_w, pte_r, pte_v} =
`ifdef RV32
       {22'b0, pte_latch[31:0]};
`else
       ({54{~satp_mode_latch[3]}} & {22'b0, pte_latch[31:0]}) |
       ({54{ satp_mode_latch[3]}} & {       pte_latch[53:0]});
`endif
assign {tlb_pte_ppn, tlb_pte_rsw, tlb_pte_d, tlb_pte_a, tlb_pte_g,
        tlb_pte_u,   tlb_pte_x,   tlb_pte_w, tlb_pte_r, tlb_pte_v} =
`ifdef RV32
       {22'b0, tlb_pte_out[31:0]};
`else
       ({54{~satp_mode_latch[3]}} & {22'b0, tlb_pte_out[31:0]}) |
       ({54{ satp_mode_latch[3]}} & {       tlb_pte_out[53:0]});
`endif

assign m_axi_intf.awid     = 10'b0;
assign m_axi_intf.awaddr   = 32'b0;
assign m_axi_intf.awburst  = `AXI_BURST_FIXED;
assign m_axi_intf.awsize   = 3'h0;
assign m_axi_intf.awlen    = 8'b0;
assign m_axi_intf.awlock   = 2'h0;
assign m_axi_intf.awcache  = 4'h0;
assign m_axi_intf.awprot   = 3'h0;
assign m_axi_intf.awvalid  = 1'b0;
assign m_axi_intf.wid      = 10'b0;
assign m_axi_intf.wstrb    = 4'b0;
assign m_axi_intf.wlast    = 1'b0;
assign m_axi_intf.wdata    = 32'b0;
assign m_axi_intf.wvalid   = 1'b0;
assign m_axi_intf.bready   = 1'b1;

assign m_axi_intf.arid     = 10'b0;
`ifdef RV32
assign m_axi_intf.araddr   = {ppn_latch[19:0], vpn_latch[9:0], 2'b0};
`else
assign m_axi_intf.araddr   = {ppn_latch[19:0], vpn_latch[9:1], vpn_latch[0] & ~satp_mode_latch[3], 2'b0};
`endif
assign m_axi_intf.arburst  = `AXI_BURST_INCR;
assign m_axi_intf.arsize   = 3'h2;
`ifdef RV32
assign m_axi_intf.arlen    = 8'h0;
`else
assign m_axi_intf.arlen    = {7'h0, satp_mode_latch[3]};
`endif
assign m_axi_intf.arlock   = 2'h0;
assign m_axi_intf.arcache  = 4'h0;
assign m_axi_intf.arprot   = 3'h0;
assign m_axi_intf.rready   = 1'b1;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        spage <= 6'b0;
    end
    else if (va_valid) begin
`ifdef RV32
        spage <= 6'b11;
`else
        spage <= ({3{satp_mode == `SATP_MODE_SV32}} & 6'b000011)|
                 ({3{satp_mode == `SATP_MODE_SV39}} & 6'b000111)|
                 ({3{satp_mode == `SATP_MODE_SV48}} & 6'b001111)|
                 ({3{satp_mode == `SATP_MODE_SV57}} & 6'b011111)|
                 ({3{satp_mode == `SATP_MODE_SV64}} & 6'b111111);
`endif
    end
    else if (m_axi_intf.rvalid && m_axi_intf.rlast) begin
        spage <= {1'b0, spage[5:1]};
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        ar_done <= 1'b0;
    end
    else if (cur_state == STATE_CHECK || cur_state == STATE_PTE) begin
        ar_done <= 1'b0;
    end
    else if (m_axi_intf.arready) begin
        ar_done <= 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        vpn_latch <= 37'b0;
    end
    else if (cur_state == STATE_CHECK) begin
`ifdef RV32
        vpn_latch[19:0] <= {va_latch[12+:10], va_latch[22+:10]};
`else
        vpn_latch <= ({37{satp_mode_latch == `SATP_MODE_SV32}} & {17'b0, va_latch[12+:10], va_latch[22+:10]}) |
                     ({37{satp_mode_latch == `SATP_MODE_SV39}} & {9'b0, va_latch[12+:9], va_latch[21+:9], va_latch[30+:9], 1'b0}) |
                     ({37{satp_mode_latch == `SATP_MODE_SV48}} & {va_latch[12+:9], va_latch[21+:9], va_latch[30+:9], va_latch[39+:9], 1'b0});
`endif
    end
    else if (m_axi_intf.rvalid && m_axi_intf.rlast) begin
`ifdef RV32
        vpn_latch[19:0] <= {10'b0, vpn_latch[10+:10]};
`else
        vpn_latch <= ({37{~satp_mode_latch[3]}} & {10'b0, vpn_latch[36:10]}) |
                     ({37{ satp_mode_latch[3]}} & { 9'b0, vpn_latch[36:10], 1'b0});
`endif
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        ppn_latch <= 22'b0;
    end
    else if (cur_state == STATE_IDLE) begin
        ppn_latch <= va[33:12];
    end
    else if (cur_state == STATE_CHECK) begin
        ppn_latch <= satp_ppn;
    end
    else if (cur_state == STATE_PTE) begin
        ppn_latch <= pte_ppn;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        pte_latch <= 64'b0;
    end
    else if (m_axi_intf.rvalid) begin
`ifdef RV32
        pte_latch[31:0] <= m_axi_intf.rdata;
`else
        if (satp_mode_latch[3] && m_axi_intf.rlast) begin
            pte_latch[63:32] <= m_axi_intf.rdata;
        end
        else begin
            pte_latch[31: 0] <= m_axi_intf.rdata;
        end
`endif
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)         va_latch <= 56'b0;
    else if (va_valid) va_latch <= {8'b0, va};
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)           pa <= 56'b0;
    else if (pa_pre_vld) pa <= pa_pre[55:0];
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        prv_latch       <= 2'b0;
        sum_latch       <= 1'b0;
        access_r_latch  <= 1'b0;
        access_w_latch  <= 1'b0;
        access_x_latch  <= 1'b0;
        access_ex_latch <= 1'b0;
        satp_mode_latch <= `SATP_MODE_WIDTH'b0;
    end
    else if (va_valid) begin
        prv_latch       <= prv_post;
        sum_latch       <= sum;
        access_r_latch  <= ~access_x & ~access_w;
        access_w_latch  <= ~access_x &  access_w;
        access_x_latch  <=  access_x;
        access_ex_latch <=  access_ex;
        satp_mode_latch <= satp_mode;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        pa_valid <= 1'b0;
    end
    else begin
        pa_valid <= pa_pre_vld;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        pg_fault <= 1'b0;
    end
    else if (cur_state == STATE_IDLE) begin
        pg_fault <= last_hit ? pg_fault_last : 1'b0;
    end
    else if (cur_state == STATE_PTE) begin
        pg_fault <= pg_fault_pte;
    end
    else if (tlb_hit) begin
        pg_fault <= pg_fault_tlb;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        bus_err <= 1'b0;
    end
    else begin
        bus_err <= (m_axi_intf.rvalid && m_axi_intf.rresp[1]) || bus_boundary;
    end
end

assign cache_bypass = ~pma_c;
assign pa_bad       = {(bus_err | pmp_err) & ~pg_fault, pg_fault};

assign pa_pre       = ~va_en                  ? {{32{rv64_mode}} & va[32+:32], va[0+:32]}:
                      tlb_data_sel            ? {{32{tlb_pte_ppn[21]}}, tlb_pte_ppn, va_latch[11:0]}:
`ifdef RV32
                      cur_state == STATE_IDLE ? {{32{last_pte_ppn[21]}}, last_pte_ppn[21:10], last_spage[0] ? va[21:12] : last_pte_ppn[9:0], va[11:0]}:
                                                {{32{pte_ppn[21]}}, pte_ppn[21:10], spage[0] ? va_latch[21:12] : pte_ppn[9:0], va_latch[11:0]};
`else
                      cur_state == STATE_IDLE ? (({64{~satp_mode[3]}} & {{32{last_pte_ppn[21]}}, last_pte_ppn[21:10], last_spage[0] ? va[12+:10] : last_pte_ppn[0+:10], va[11:0]})|
                                                 ({64{ satp_mode[3]}} & {{ 8{last_pte_ppn[43]}}, last_pte_ppn[43:27],
                                                                         last_spage[2] ? va[30+: 9] : last_pte_ppn[18+: 9],
                                                                         last_spage[1] ? va[21+: 9] : last_pte_ppn[ 9+: 9],
                                                                         last_spage[0] ? va[12+: 9] : last_pte_ppn[ 0+: 9], va[11:0]})):
                                                (({64{~satp_mode[3]}} & {{32{pte_ppn[21]}}, pte_ppn[21:10], spage[0] ? va_latch[21:12] : pte_ppn[9:0], va_latch[11:0]})|
                                                 ({64{ satp_mode[3]}} & {{ 8{pte_ppn[43]}}, pte_ppn[43:27],
                                                                         spage[2] ? va_latch[30+: 9] : pte_ppn[18+: 9],
                                                                         spage[1] ? va_latch[21+: 9] : pte_ppn[ 9+: 9],
                                                                         spage[0] ? va_latch[12+: 9] : pte_ppn[ 0+: 9], va_latch[11:0]}));
`endif

assign va_en        = (prv_post  < `PRV_M && satp_mode       != `SATP_MODE_NONE && cur_state == STATE_IDLE)|
                      (prv_latch < `PRV_M && satp_mode_latch != `SATP_MODE_NONE && cur_state != STATE_IDLE);

`ifdef RV32
assign vpn[19:0]    = va[12+:20];
assign last_hit     = last_va_en && va_en && last_vpn[19:0] == {vpn[19:10], vpn[9:0] & {10{~last_spage[0]}}};
`else
assign vpn          = va[12+:36];
assign last_hit     = last_va_en && va_en &&
                      ((~satp_mode[3] && last_vpn[19:0] == {vpn[19:10], vpn[9:0] & {10{~last_spage[0]}}}) ||
                       ( satp_mode[3] && last_vpn == {vpn[27+:9],
                                                      vpn[18+:9] & {9{~last_spage[2]}},
                                                      vpn[ 9+:9] & {9{~last_spage[1]}},
                                                      vpn[ 0+:9] & {9{~last_spage[0]}}}));
`endif

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        last_va_en <= 1'b0;
    end
    else begin
        if (tlb_flush_req) begin
            last_va_en <= 1'b0;
        end
        else if (va_valid) begin
            last_va_en <= last_hit;
        end
        else if (cur_state ==STATE_CHECK && tlb_hit) begin
            last_va_en <= 1'b1;
        end
        else if (cur_state ==STATE_PTE   && leaf && ~pg_fault_pte) begin
            last_va_en <= 1'b1;
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        last_vpn       <= 36'b0;
        last_spage     <= 3'b0;
        last_pte_ppn   <= 44'b0;
        last_pte_rsw   <= 2'b0;
        last_pte_d     <= 1'b0;
        last_pte_a     <= 1'b0;
        last_pte_g     <= 1'b0;
        last_pte_u     <= 1'b0;
        last_pte_x     <= 1'b0;
        last_pte_w     <= 1'b0;
        last_pte_r     <= 1'b0;
        last_pte_v     <= 1'b0;
    end
    else begin
        if (cur_state ==STATE_CHECK && tlb_hit) begin
`ifdef RV32
            last_vpn[19:0] <= {va_latch[22+:10], va_latch[12+:10] & {10{~tlb_spage_out[0]}}};
`else
            last_vpn       <= ({36{~satp_mode_latch[3]}} & {va_latch[22+:10], va_latch[12+:10] & {10{~tlb_spage_out[0]}}}) |
                              ({36{ satp_mode_latch[3]}} & {va_latch[39+:9],
                                                            va_latch[30+:9] & {9{~tlb_spage_out[2]}},
                                                            va_latch[21+:9] & {9{~tlb_spage_out[1]}},
                                                            va_latch[12+:9] & {9{~tlb_spage_out[0]}}});
`endif
            last_spage     <= tlb_spage_out;
            last_pte_ppn   <= tlb_pte_ppn;
            last_pte_rsw   <= tlb_pte_rsw;
            last_pte_d     <= tlb_pte_d;
            last_pte_a     <= tlb_pte_a;
            last_pte_g     <= tlb_pte_g;
            last_pte_u     <= tlb_pte_u;
            last_pte_x     <= tlb_pte_x;
            last_pte_w     <= tlb_pte_w;
            last_pte_r     <= tlb_pte_r;
            last_pte_v     <= tlb_pte_v;
        end
        else if (cur_state ==STATE_PTE   && leaf && ~pg_fault_pte) begin
`ifdef RV32
            last_vpn[19:0] <= {va_latch[22+:10], va_latch[12+:10] & {10{~tlb_spage_in[0]}}};
`else
            last_vpn       <= ({36{~satp_mode_latch[3]}} & {va_latch[22+:10], va_latch[12+:10] & {10{~tlb_spage_in[0]}}}) |
                              ({36{ satp_mode_latch[3]}} & {va_latch[39+:9],
                                                            va_latch[30+:9] & {9{~tlb_spage_in[2]}},
                                                            va_latch[21+:9] & {9{~tlb_spage_in[1]}},
                                                            va_latch[12+:9] & {9{~tlb_spage_in[0]}}});
`endif
            last_spage     <= tlb_spage_in;
            last_pte_ppn   <= pte_ppn;
            last_pte_rsw   <= pte_rsw;
            last_pte_d     <= pte_d;
            last_pte_a     <= pte_a;
            last_pte_g     <= pte_g;
            last_pte_u     <= pte_u;
            last_pte_x     <= pte_x;
            last_pte_w     <= pte_w;
            last_pte_r     <= pte_r;
            last_pte_v     <= pte_v;
        end
    end
end

tlb u_tlb(
    .clk                 ( clk                 ),
    .rstn                ( rstn                ),

`ifndef RV32
    .satp_mode           ( satp_mode           ),
`endif
    .cs                  ( tlb_cs              ),
    .vpn                 ( tlb_vpn             ),
    .we                  ( tlb_we              ),
    .pte_hit             ( tlb_hit             ),
    .spage_in            ( tlb_spage_in        ),
    .pte_in              ( tlb_pte_in          ),
    .spage_out           ( tlb_spage_out       ),
    .pte_out             ( tlb_pte_out         ),

    .tlb_flush_req       ( tlb_flush_req       ),
    .tlb_flush_all_vaddr ( tlb_flush_all_vaddr ),
    .tlb_flush_all_asid  ( tlb_flush_all_asid  ),
    .tlb_flush_vaddr     ( tlb_flush_vaddr     ),
    .tlb_flush_asid      ( tlb_flush_asid      )

);

endmodule
