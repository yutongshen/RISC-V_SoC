`include "intf_define.h"
`include "axi_define.h"
`include "tlb_define.h"

module mmu (
    input                                    clk,
    input                                    rstn,
    
    // access type
    input                                    access_w,
    input                                    access_x,

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
    input        [    `SATP_PPN_WIDTH - 1:0] satp_ppn,
    input        [   `SATP_ASID_WIDTH - 1:0] satp_asid,
    input        [   `SATP_MODE_WIDTH - 1:0] satp_mode,
    input        [                      1:0] prv,
    input                                    sum,
    input                                    mprv,
    input        [                      1:0] mpp,

    // virtual address
    input                                    va_valid,
    input        [                     47:0] va,

    // Cache ctrl
    output logic                             cache_bypass,

    // physical address
    output logic                             pa_valid,
    output logic [                      1:0] pa_bad,
    output logic [                     55:0] pa,
    output logic                             pa_pre_vld,
    output logic                             pa_pre_wr,
    output logic                             pa_pre_rd,
    output logic [                     55:0] pa_pre,
    
    // AXI interface
    `AXI_INTF_MST_DEF(m, 10)
);

parameter [1:0] STATE_IDLE  = 2'b00,
                STATE_CHECK = 2'b01,
                STATE_MREQ  = 2'b10,
                STATE_PTE   = 2'b11;

logic [               1:0] cur_state;
logic [               1:0] nxt_state;

logic                      va_en;
logic [              55:0] va_latch;
logic                      last_hit;
logic                      last_va_en;
logic [              19:0] last_vpn;
logic                      last_spage;
logic [              19:0] vpn;
logic [              19:0] vpn_latch;
logic [              21:0] ppn_latch;
logic                      busy;
logic                      leaf;
logic                      sum_latch;
logic                      access_r_latch;
logic                      access_w_latch;
logic                      access_x_latch;
logic [              63:0] pte_latch;
logic [              21:0] pte_ppn, tlb_pte_ppn, last_pte_ppn;
logic [               1:0] pte_rsw, tlb_pte_rsw, last_pte_rsw;
logic                      pte_d,   tlb_pte_d  , last_pte_d  ;
logic                      pte_a,   tlb_pte_a  , last_pte_a  ;
logic                      pte_g,   tlb_pte_g  , last_pte_g  ;
logic                      pte_u,   tlb_pte_u  , last_pte_u  ;
logic                      pte_x,   tlb_pte_x  , last_pte_x  ;
logic                      pte_w,   tlb_pte_w  , last_pte_w  ;
logic                      pte_r,   tlb_pte_r  , last_pte_r  ;
logic                      pte_v,   tlb_pte_v  , last_pte_v  ;
logic                      tlb_data_sel;
logic [               1:0] level;
logic                      pmp_err;
logic                      pg_fault;
logic                      pg_fault_tlb;
logic                      pg_fault_pte;
logic                      bus_err;
logic                      ar_done;
logic [               1:0] prv_post;
logic [               1:0] prv_latch;

logic                      tlb_cs;
logic                      tlb_we;
logic                      tlb_hit;
logic [`TLB_VPN_WIDTH-1:0] tlb_vpn;
logic [`TLB_PTE_WIDTH-1:0] tlb_pte_in;
logic [`TLB_PTE_WIDTH-1:0] tlb_pte_out;
logic                      tlb_spage_in;
logic                      tlb_spage_out;

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
            nxt_state = m_rvalid && m_rresp[1] ? STATE_IDLE:
                        m_rvalid && m_rlast    ? STATE_PTE :
                                                 STATE_MREQ;
        end
        STATE_PTE  : begin
            nxt_state = leaf || pg_fault_pte ? STATE_IDLE:
                                               STATE_MREQ;
        end
    endcase
end

always_comb begin
    tlb_cs       = 1'b0;
    tlb_we       = 1'b0;
    pa_pre_vld   = 1'b0;
    pa_pre_wr    = access_w_latch;
    pa_pre_rd    = access_r_latch;
    busy         = 1'b0;
    m_arvalid    = 1'b0;
    tlb_data_sel = 1'b0;
    case (cur_state)
        STATE_IDLE : begin
            tlb_cs       = va_en;
            pa_pre_vld   = va_valid && (~va_en || last_hit);
            pa_pre_wr    = ~access_x &  access_w;
            pa_pre_rd    = ~access_x & ~access_w;
            busy         = 1'b0;
        end
        STATE_CHECK: begin
            pa_pre_vld   = tlb_hit;
            busy         = 1'b1;
            tlb_data_sel = 1'b1;
        end
        STATE_MREQ : begin
            pa_pre_vld   = m_rvalid && m_rresp[1];
            busy         = 1'b1;
            m_arvalid    = ~ar_done;
        end
        STATE_PTE  : begin
            pa_pre_vld   = leaf ||  pg_fault_pte;
            tlb_cs       = leaf && ~pg_fault_pte;
            tlb_we       = 1'b1;
            busy         = 1'b1;
        end
    endcase
end

assign prv_post     = ~access_x && mprv ? mpp : prv;
assign leaf         = pte_v && (pte_r || pte_x);
assign pg_fault_pte = !pte_v || (!pte_r && pte_w) ||
                      (~leaf && ~|level) ||
                      ( leaf && |level && |pte_ppn[9:0]) ||
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

assign pmp_err      = (!pmp_v && prv_latch != `PRV_M) ||
                      (( pmp_l || prv_latch != `PRV_M) &&
                      ((!pmp_x && access_x_latch) ||
                       (!pmp_w && access_w_latch) ||
                       (!pmp_r && access_r_latch)));
                    
assign tlb_spage_in = level[0];
assign tlb_vpn      = {16'b0, busy ? va_latch[12+:20] : va[12+:20]};
assign tlb_pte_in   = pte_latch;
assign {pte_ppn, pte_rsw, pte_d, pte_a, pte_g, pte_u, pte_x, pte_w, pte_r, pte_v} = pte_latch[31:0];
assign {tlb_pte_ppn, tlb_pte_rsw, tlb_pte_d, tlb_pte_a, tlb_pte_g,
        tlb_pte_u,   tlb_pte_x,   tlb_pte_w, tlb_pte_r, tlb_pte_v} = tlb_pte_out[31:0];

assign m_awid     = 10'b0;
assign m_awaddr   = 32'b0;
assign m_awburst  = `AXI_BURST_FIXED;
assign m_awsize   = 3'h0;
assign m_awlen    = 8'b0;
assign m_awvalid  = 1'b0;
assign m_wid      = 10'b0;
assign m_wstrb    = 4'b0;
assign m_wlast    = 1'b0;
assign m_wdata    = 32'b0;
assign m_wvalid   = 1'b0;
assign m_bready   = 1'b1;

assign m_arid     = 10'b0;
assign m_araddr   = {ppn_latch[19:0], vpn_latch[10+:10], 2'b0};
assign m_arburst  = `AXI_BURST_INCR;
assign m_arsize   = 3'h2;
assign m_arlen    = 8'h0;
assign m_rready   = 1'b1;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        level <= 2'b0;
    end
    else if (va_valid) begin
        level <= 2'd2;
    end
    else if (m_rvalid && m_rlast) begin
        level <= level - 2'd1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        ar_done <= 1'b0;
    end
    else if (cur_state == STATE_CHECK || cur_state == STATE_PTE) begin
        ar_done <= 1'b0;
    end
    else if (m_arready) begin
        ar_done <= 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        vpn_latch <= 20'b0;
    end
    else if (cur_state == STATE_CHECK) begin
        vpn_latch <= va_latch[12+:20];
    end
    else if (m_rvalid && m_rlast) begin
        vpn_latch <= {vpn_latch[9:0], 10'b0};
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
    else if (m_rvalid) begin
        pte_latch <= {pte_latch[31:0], m_rdata};
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)         va_latch <= 56'b0;
    else if (va_valid) va_latch <= {8'b0, va};
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)           pa <= 56'b0;
    else if (pa_pre_vld) pa <= pa_pre;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        prv_latch      <= 2'b0;
        sum_latch      <= 1'b0;
        access_r_latch <= 1'b0;
        access_w_latch <= 1'b0;
        access_x_latch <= 1'b0;
    end
    else if (va_valid) begin
        prv_latch      <= prv_post;
        sum_latch      <= sum;
        access_r_latch <= ~access_x & ~access_w;
        access_w_latch <= ~access_x &  access_w;
        access_x_latch <=  access_x;
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
        bus_err <= m_rvalid && m_rresp[1];
    end
end

assign cache_bypass = ~pma_c;
assign pa_bad       = {(bus_err | pmp_err) & ~pg_fault, pg_fault};

assign pa_pre       = ~va_en                  ? {8'b0, va}:
                      tlb_data_sel            ? {{22{tlb_pte_ppn[21]}}, tlb_pte_ppn, va_latch[11:0]}:
                      cur_state == STATE_IDLE ? {{22{last_pte_ppn[21]}}, last_pte_ppn[21:10], |last_spage ? va[21:12] : last_pte_ppn[9:0], va[11:0]}:
                                                {{22{pte_ppn[21]}}, pte_ppn[21:10], |level ? va_latch[21:12] : pte_ppn[9:0], va_latch[11:0]};

assign va_en        = prv_post < `PRV_M && satp_mode != `SATP_MODE_WIDTH'b0;
assign vpn          = va[12+:20];

assign last_hit     = (last_va_en && va_en && last_vpn == {vpn[19:10], vpn[9:0] & {10{~last_spage}}});

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
        last_vpn     <= 20'b0;
        last_spage   <= 1'b0;
        last_pte_ppn <= 22'b0;
        last_pte_rsw <= 2'b0;
        last_pte_d   <= 1'b0;
        last_pte_a   <= 1'b0;
        last_pte_g   <= 1'b0;
        last_pte_u   <= 1'b0;
        last_pte_x   <= 1'b0;
        last_pte_w   <= 1'b0;
        last_pte_r   <= 1'b0;
        last_pte_v   <= 1'b0;
    end
    else begin
        if (cur_state ==STATE_CHECK && tlb_hit) begin
            last_vpn     <= {va_latch[22+:10], va_latch[12+:10] & {10{~tlb_spage_out}}};
            last_spage   <= tlb_spage_out;
            last_pte_ppn <= tlb_pte_ppn;
            last_pte_rsw <= tlb_pte_rsw;
            last_pte_d   <= tlb_pte_d;
            last_pte_a   <= tlb_pte_a;
            last_pte_g   <= tlb_pte_g;
            last_pte_u   <= tlb_pte_u;
            last_pte_x   <= tlb_pte_x;
            last_pte_w   <= tlb_pte_w;
            last_pte_r   <= tlb_pte_r;
            last_pte_v   <= tlb_pte_v;
        end
        else if (cur_state ==STATE_PTE   && leaf && ~pg_fault_pte) begin
            last_vpn     <= {va_latch[22+:10], va_latch[12+:10] & {10{~tlb_spage_in}}};
            last_spage   <= tlb_spage_in;
            last_pte_ppn <= pte_ppn;
            last_pte_rsw <= pte_rsw;
            last_pte_d   <= pte_d;
            last_pte_a   <= pte_a;
            last_pte_g   <= pte_g;
            last_pte_u   <= pte_u;
            last_pte_x   <= pte_x;
            last_pte_w   <= pte_w;
            last_pte_r   <= pte_r;
            last_pte_v   <= pte_v;
        end
    end
end

tlb u_tlb(
    .clk                 ( clk                 ),
    .rstn                ( rstn                ),

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
