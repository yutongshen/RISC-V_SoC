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

    // physical address
    output logic                             pa_valid,
    output logic [                      1:0] pa_bad,
    output logic [                     55:0] pa,
    output logic [                     55:0] pa_pre,
    
    // AXI interface
    `AXI_INTF_MST_DEF(m, 10)
);

parameter [2:0] STATE_IDLE  = 3'b000,
                STATE_CHECK = 3'b001,
                STATE_MREQ  = 3'b010,
                STATE_PTE   = 3'b011,
                STATE_PMP   = 3'b100;

logic [               2:0] cur_state;
logic [               2:0] nxt_state;

logic                      va_en;
logic [              55:0] va_latch;
logic [              55:0] pa_latch;
logic [              19:0] vpn_latch;
logic [              21:0] ppn_latch;
logic                      busy;
logic                      leaf;
logic                      access_r_latch;
logic                      access_w_latch;
logic                      access_x_latch;
logic [              63:0] pte_latch;
logic [              21:0] pte_ppn, tlb_pte_ppn;
logic [               1:0] pte_rsw, tlb_pte_rsw;
logic                      pte_d,   tlb_pte_d;
logic                      pte_a,   tlb_pte_a;
logic                      pte_g,   tlb_pte_g;
logic                      pte_u,   tlb_pte_u;
logic                      pte_x,   tlb_pte_x;
logic                      pte_w,   tlb_pte_w;
logic                      pte_r,   tlb_pte_r;
logic                      pte_v,   tlb_pte_v;
logic                      tlb_pmp_v;
logic                      tlb_pmp_l;
logic                      tlb_pmp_x;
logic                      tlb_pmp_w;
logic                      tlb_pmp_r;
logic                      tlb_data_sel;
logic [               1:0] level;
logic                      pa_valid_tmp;
logic                      pa_valid_tmp_latch;
logic                      pmp_err;
logic                      pmp_err_pte;
logic                      pmp_err_tlb;
logic                      pg_fault;
logic                      pg_fault_tlb;
logic                      pg_fault_pte;
logic                      pg_fault_pte_latch;
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

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cur_state <= STATE_IDLE;
    else       cur_state <= nxt_state;
end

always_comb begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE : begin
            nxt_state = va_en && va_valid ? STATE_CHECK : STATE_IDLE;
        end
        STATE_CHECK: begin
            nxt_state = ~tlb_hit            ? STATE_MREQ:
                        ~va_en || ~va_valid ? STATE_IDLE:
                                              STATE_CHECK;
        end
        STATE_MREQ : begin
            nxt_state = m_rvalid && m_rresp[1] ? STATE_IDLE:
                        m_rvalid && m_rlast    ? STATE_PTE :
                                                 STATE_MREQ;
        end
        STATE_PTE  : begin
            nxt_state = pg_fault_pte ? STATE_IDLE:
                        leaf         ? STATE_PMP :
                                       STATE_MREQ;
        end
        STATE_PMP  : begin
            nxt_state = STATE_IDLE;
        end
    endcase
end

always_comb begin
    tlb_cs       = 1'b0;
    tlb_we       = 1'b0;
    pa_valid_tmp = 1'b0;
    busy         = 1'b0;
    m_arvalid    = 1'b0;
    tlb_data_sel = 1'b0;
    case (cur_state)
        STATE_IDLE : begin
            tlb_cs       = va_valid &&  va_en;
            pa_valid_tmp = va_valid && ~va_en;
            busy         = 1'b0;
        end
        STATE_CHECK: begin
            tlb_cs       = tlb_hit && va_valid &&  va_en;
            busy         = ~tlb_hit;
            tlb_data_sel = tlb_hit;
        end
        STATE_MREQ : begin
            busy         = 1'b1;
            m_arvalid    = ~ar_done;
        end
        STATE_PTE  : begin
            pa_valid_tmp = leaf ||  pg_fault_pte;
            busy         = 1'b1;
        end
        STATE_PMP  : begin
            pa_valid_tmp = 1'b1;
            tlb_cs       = 1'b1;
            tlb_we       = 1'b1;
            busy         = 1'b1;
        end
    endcase
end

assign prv_post     = ~access_x && mprv ? mpp : prv;
assign leaf         = pte_v && (pte_r || pte_x);
assign pg_fault_pte = !pte_v || (!pte_r && pte_w) ||
                      (~leaf && ~|level) ||
                      ( leaf && |level && pte_ppn[9:0]) ||
                      ( leaf && access_x_latch      && ~pte_x) ||
                      ( leaf && access_r_latch      && ~pte_r) ||
                      ( leaf && access_w_latch      && ~pte_w) ||
                      ( leaf && prv_latch == `PRV_U && ~pte_u) ||
                      ( leaf && prv_latch == `PRV_S &&  pte_u && (~sum || access_x_latch)) ||
                      ( leaf && access_w_latch      && ~pte_d) ||
                      ( leaf                        && ~pte_a);

assign pg_fault_tlb = (access_x_latch      && ~tlb_pte_x) ||
                      (access_r_latch      && ~tlb_pte_r) ||
                      (access_w_latch      && ~tlb_pte_w) ||
                      (prv_latch == `PRV_U && ~tlb_pte_u) ||
                      (prv_latch == `PRV_S &&  tlb_pte_u && (~sum || access_x_latch)) ||
                      (access_w_latch      && ~tlb_pte_d) ||
                      (                       ~tlb_pte_a);

assign pmp_err_pte  = (!pmp_v && prv_latch != `PRV_M) ||
                      (( pmp_l || prv_latch != `PRV_M) &&
                      ((!pmp_x && access_x_latch) ||
                       (!pmp_w && access_w_latch) ||
                       (!pmp_r && access_r_latch)));
                    
assign pmp_err_tlb  = (!tlb_pmp_v && prv_latch != `PRV_M) ||
                      (( tlb_pmp_l || prv_latch != `PRV_M) &&
                      ((!tlb_pmp_x && access_x_latch) ||
                       (!tlb_pmp_w && access_w_latch) ||
                       (!tlb_pmp_r && access_r_latch)));
                    

assign tlb_vpn    = {16'b0, busy ? va_latch[12+:20] : va[12+:20]};
assign tlb_pte_in = pte_latch;
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
    if (~rstn)             pa_latch <= 56'b0;
    else if (pa_valid_tmp) pa_latch <= pa_pre;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        prv_latch      <= 2'b0;
        access_r_latch <= 1'b0;
        access_w_latch <= 1'b0;
        access_x_latch <= 1'b0;
    end
    else if (va_valid) begin
        prv_latch      <= prv_post;
        access_r_latch <= ~access_x & ~access_w;
        access_w_latch <= ~access_x &  access_w;
        access_x_latch <=  access_x;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        pa_valid_tmp_latch <= 1'b0;
    end
    else begin
        pa_valid_tmp_latch <= pa_valid_tmp && !(cur_state == STATE_PTE && !pg_fault_pte);
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        pg_fault_pte_latch <= 1'b0;
    end
    else if (cur_state == STATE_IDLE) begin
        pg_fault_pte_latch <= 1'b0;
    end
    else if (cur_state == STATE_PTE) begin
        pg_fault_pte_latch <= pg_fault_pte;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        bus_err <= 22'b0;
    end
    else begin
        bus_err <= m_rvalid && m_rresp[1];
    end
end

assign pa_valid = pa_valid_tmp_latch | tlb_data_sel;
assign pg_fault = pg_fault_pte_latch | (tlb_data_sel & pg_fault_tlb);
assign pmp_err  = tlb_data_sel ? pmp_err_tlb : pmp_err_pte;
assign pa       = ({56{pa_valid_tmp_latch}} & pa_latch) |
                  ({56{tlb_data_sel}}       & {{10{tlb_pte_ppn[21]}}, tlb_pte_ppn, va_latch[11:0]});
assign pa_bad   = {(bus_err | pmp_err) & ~pg_fault, pg_fault};

assign pa_pre   = va_en ? {{22{pte_ppn[21]}}, pte_ppn[21:10], level ? va_latch[21:12] : pte_ppn[9:0], va_latch[11:0]} :
                          {8'b0, va};

assign va_en    = prv_post < `PRV_M && satp_mode != `SATP_MODE_WIDTH'b0;

tlb u_tlb(
    .clk                 ( clk                 ),
    .rstn                ( rstn                ),

    .cs                  ( tlb_cs              ),
    .vpn                 ( tlb_vpn             ),
    .we                  ( tlb_we              ),
    .spage               ( level[0]            ),
    .pte_hit             ( tlb_hit             ),
    .pte_in              ( tlb_pte_in          ),
    .pmp_v_in            ( pmp_v               ),
    .pmp_l_in            ( pmp_l               ),
    .pmp_x_in            ( pmp_x               ),
    .pmp_w_in            ( pmp_w               ),
    .pmp_r_in            ( pmp_r               ),
    .pte_out             ( tlb_pte_out         ),
    .pmp_v_out           ( tlb_pmp_v           ),
    .pmp_l_out           ( tlb_pmp_l           ),
    .pmp_x_out           ( tlb_pmp_x           ),
    .pmp_w_out           ( tlb_pmp_w           ),
    .pmp_r_out           ( tlb_pmp_r           ),

    .tlb_flush_req       ( tlb_flush_req       ),
    .tlb_flush_all_vaddr ( tlb_flush_all_vaddr ),
    .tlb_flush_all_asid  ( tlb_flush_all_asid  ),
    .tlb_flush_vaddr     ( tlb_flush_vaddr     ),
    .tlb_flush_asid      ( tlb_flush_asid      )

);

endmodule