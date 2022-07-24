`define APB_AP_SEL  8'h00
`define AHB_AP_SEL  8'h01
`define AXI_AP_SEL  8'h02
`define JTAG_AP_SEL 8'h03

module dap (
    // clock and reset
    input        clk,
    input        rstn,

    // DP port
    input        tck,
    input        trstn,
    input        tms,
    input        tdi,
    output logic tdo,
    
    // other
    input        apb_spiden,
    input        apb_deviceen,
    input        axi_spiden,
    input        axi_deviceen,

    // APB_AP port
    apb_intf.master m_apb_intf,

    // AXI_AP port
    axi_intf.master m_axi_intf

);

logic        dbgrstn;

logic        ap_upd;
logic [ 7:0] ap_sel;
logic [31:0] ap_wdata;
logic [ 7:2] ap_addr;
logic        ap_rnw;
logic        ap_busy;
logic [31:0] ap_rdata;
logic        ap_slverr;
logic [ 2:0] ap_ack;

logic        ap_rbuf_rrstn;
logic        ap_rbuf_dpop;
logic [31:0] ap_rbuf_rdata;
logic        ap_rbuf_rpop;
logic [31:0] ap_rbuf_rresp;
logic        ap_rbuf_push;
logic [31:0] ap_rbuf_wdata;
logic [ 1:0] ap_rbuf_wresp;
logic        ap_wbuf_wrstn;
logic        ap_wbuf_push;
logic [31:0] ap_wbuf_wdata;
logic        ap_wbuf_pop;
logic [31:0] ap_wbuf_rdata;
logic [ 5:0] ap_wbuf_rsize;

logic [ 7:0] ap_sel_latch;

logic        apb_ap_upd;
logic [31:0] apb_ap_rdata;
logic        apb_ap_slverr;
logic        apb_ap_busy;

logic        apb_ap_rbuf_push;
logic [31:0] apb_ap_rbuf_wdata;
logic [ 1:0] apb_ap_rbuf_wresp;

logic        apb_ap_wbuf_pop;
logic [31:0] apb_ap_wbuf_rdata;
logic [ 5:0] apb_ap_wbuf_rsize;

logic        axi_ap_upd;
logic [31:0] axi_ap_rdata;
logic        axi_ap_slverr;
logic        axi_ap_busy;

logic        axi_ap_rbuf_push;
logic [31:0] axi_ap_rbuf_wdata;
logic [ 1:0] axi_ap_rbuf_wresp;

logic        axi_ap_wbuf_pop;
logic [31:0] axi_ap_wbuf_rdata;
logic [ 5:0] axi_ap_wbuf_rsize;


always_ff @(posedge tck or negedge dbgrstn) begin: reg_ap_rdata
    if (~dbgrstn)    ap_sel_latch <= 8'b0;
    else if (ap_upd) ap_sel_latch <= ap_sel;
end

assign ap_ack     = 3'h2;

assign ap_rdata   = ({32{ap_sel_latch == `APB_AP_SEL}} & apb_ap_rdata)|
                    ({32{ap_sel_latch == `AXI_AP_SEL}} & axi_ap_rdata);

assign ap_busy    = ((ap_sel_latch == `APB_AP_SEL) & apb_ap_busy)|
                    ((ap_sel_latch == `AXI_AP_SEL) & axi_ap_busy);

assign ap_slverr  = ((ap_sel_latch == `APB_AP_SEL) & apb_ap_slverr)|
                    ((ap_sel_latch == `AXI_AP_SEL) & axi_ap_slverr);

assign apb_ap_upd = (ap_sel == `APB_AP_SEL) & ap_upd;
assign axi_ap_upd = (ap_sel == `AXI_AP_SEL) & ap_upd;

assign ap_rbuf_push  = axi_ap_rbuf_push;
assign ap_rbuf_wdata = axi_ap_rbuf_wdata;
assign ap_rbuf_wresp = axi_ap_rbuf_wresp;

assign ap_wbuf_pop   = axi_ap_wbuf_pop;

assign axi_ap_wbuf_rdata = ap_wbuf_rdata;
assign axi_ap_wbuf_rsize = ap_wbuf_rsize;

assign apb_ap_wbuf_rdata = 32'b0;
assign apb_ap_wbuf_rsize = 6'b0;

jtag_dp u_jtag_dp (
    .tck           ( tck           ),
    .trstn         ( trstn         ),
    .tms           ( tms           ),
    .tdi           ( tdi           ),
    .tdo           ( tdo           ),
    
    .ap_upd        ( ap_upd        ),
    .ap_sel        ( ap_sel        ),
    .ap_wdata      ( ap_wdata      ),
    .ap_addr       ( ap_addr       ),
    .ap_rnw        ( ap_rnw        ),
    .ap_busy       ( ap_busy       ),
    .ap_rdata      ( ap_rdata      ),
    .ap_slverr     ( ap_slverr     ),
    .ap_ack        ( ap_ack        ),

    .ap_rbuf_rrstn ( ap_rbuf_rrstn ),
    .ap_rbuf_dpop  ( ap_rbuf_dpop  ),
    .ap_rbuf_rdata ( ap_rbuf_rdata ),
    .ap_rbuf_rpop  ( ap_rbuf_rpop  ),
    .ap_rbuf_rresp ( ap_rbuf_rresp ),

    .ap_wbuf_wrstn ( ap_wbuf_wrstn ),
    .ap_wbuf_push  ( ap_wbuf_push  ),
    .ap_wbuf_wdata ( ap_wbuf_wdata ),

    .dbgrstn       ( dbgrstn       )
);

apb_ap u_apb_ap (
    .tck           ( tck               ),
    .dbgrstn       ( dbgrstn           ),

    .sysclk        ( clk               ),
    .sysrstn       ( rstn              ),

    .ap_upd        ( apb_ap_upd        ),
    .ap_wdata      ( ap_wdata          ),
    .ap_addr       ( ap_addr           ),
    .ap_rnw        ( ap_rnw            ),
    .ap_rdata      ( apb_ap_rdata      ),
    .ap_slverr     ( apb_ap_slverr     ),
    .ap_busy       ( apb_ap_busy       ),

    .ap_rbuf_push  ( apb_ap_rbuf_push  ),
    .ap_rbuf_wdata ( apb_ap_rbuf_wdata ),
    .ap_rbuf_wresp ( apb_ap_rbuf_wresp ),

    .ap_wbuf_pop   ( apb_ap_wbuf_pop   ),
    .ap_wbuf_rdata ( apb_ap_wbuf_rdata ),
    .ap_wbuf_rsize ( apb_ap_wbuf_rsize ),

    .spiden        ( apb_spiden        ),
    .deviceen      ( apb_deviceen      ),

    .m_apb_intf    ( m_apb_intf        )
);

axi_ap u_axi_ap (
    .tck           ( tck               ),
    .dbgrstn       ( dbgrstn           ),

    .sysclk        ( clk               ),
    .sysrstn       ( rstn              ),

    .ap_upd        ( axi_ap_upd        ),
    .ap_wdata      ( ap_wdata          ),
    .ap_addr       ( ap_addr           ),
    .ap_rnw        ( ap_rnw            ),
    .ap_rdata      ( axi_ap_rdata      ),
    .ap_slverr     ( axi_ap_slverr     ),
    .ap_busy       ( axi_ap_busy       ),

    .ap_rbuf_push  ( axi_ap_rbuf_push  ),
    .ap_rbuf_wdata ( axi_ap_rbuf_wdata ),
    .ap_rbuf_wresp ( axi_ap_rbuf_wresp ),

    .ap_wbuf_pop   ( axi_ap_wbuf_pop   ),
    .ap_wbuf_rdata ( axi_ap_wbuf_rdata ),
    .ap_wbuf_rsize ( axi_ap_wbuf_rsize ),

    .spiden        ( axi_spiden        ),
    .deviceen      ( axi_deviceen      ),

    .m_axi_intf    ( m_axi_intf        )
);

dap_wdata_fifo u_wdata_fifo (
    .rclk      ( clk           ),
    .wclk      ( tck           ),
    .rrstn     ( dbgrstn       ),
    .wrstn     ( ap_wbuf_wrstn ),
    .push      ( ap_wbuf_push  ),
    .wdata     ( ap_wbuf_wdata ),
    .pop       ( ap_wbuf_pop   ),
    .rdata     ( ap_wbuf_rdata ),
    .rsize     ( ap_wbuf_rsize )
);

dap_rdata_fifo u_rdata_rdata_fifo (
    .rclk      ( tck           ),
    .wclk      ( clk           ),
    .rrstn     ( ap_rbuf_rrstn ),
    .wrstn     ( dbgrstn       ),
    .push      ( ap_rbuf_push  ),
    .wdata     ( ap_rbuf_wdata ),
    .pop       ( ap_rbuf_dpop  ),
    .rdata     ( ap_rbuf_rdata )
);

dap_resp_fifo u_resp_fifo (
    .rclk      ( tck           ),
    .wclk      ( clk           ),
    .rrstn     ( ap_rbuf_rrstn ),
    .wrstn     ( dbgrstn       ),
    .push      ( ap_rbuf_push  ),
    .wdata     ( ap_rbuf_wresp ),
    .pop       ( ap_rbuf_rpop  ),
    .rdata     ( ap_rbuf_rresp )
);

endmodule

module dap_wdata_fifo (
    input               rclk,
    input               wclk,
    input               rrstn,
    input               wrstn,
    input               push,
    input        [31:0] wdata,
    input               pop,
    output logic [31:0] rdata,
    output logic [ 5:0] rsize
);

logic [31:0] fifo [64];
logic [ 5:0] rptr;
logic [ 5:0] wptr;
logic        rrstn_sync;
logic        wrstn_sync;

resetn_synchronizer u_rst_sync_0 (
    .clk        ( rclk          ),
    .rstn_async ( wrstn & rrstn ),
    .rstn_sync  ( rrstn_sync    )
);

resetn_synchronizer u_rst_sync_1 (
    .clk        ( wclk          ),
    .rstn_async ( wrstn & rrstn ),
    .rstn_sync  ( wrstn_sync    )
);

/* ========================================= */
/*  The wptr always used when it is stable,  */
/*  so we bypass this signal to read clock   */
/*  domain without synchronizor.             */
/* ========================================= */
assign rsize = wptr;

assign rdata = fifo[rptr];
// always_ff @(posedge rclk or negedge rrstn_sync) begin: reg_rdata
//     if (~rrstn_sync) rdata <= 32'b0;
//     else             rdata = fifo[rptr];
// end

always_ff @(posedge rclk or negedge rrstn_sync) begin: reg_rptr
    if (~rrstn_sync) rptr <= 6'b0;
    else             rptr <= rptr + {5'b0, pop};
end

always_ff @(posedge wclk or negedge wrstn_sync) begin: reg_wptr
    if (~wrstn_sync) wptr <= 6'b0;
    else             wptr <= wptr + {5'b0, push};
end

always_ff @(posedge wclk) begin: fifo_arr
    if (push) fifo[wptr] <= wdata;
end

endmodule

module dap_rdata_fifo (
    input               rclk,
    input               wclk,
    input               rrstn,
    input               wrstn,
    input               push,
    input        [31:0] wdata,
    input               pop,
    output logic [31:0] rdata
);

logic [31:0] fifo [64];
logic [ 5:0] rptr;
logic [ 5:0] wptr;
logic        rrstn_sync;
logic        wrstn_sync;

resetn_synchronizer u_rst_sync_0 (
    .clk        ( rclk          ),
    .rstn_async ( wrstn & rrstn ),
    .rstn_sync  ( rrstn_sync    )
);

resetn_synchronizer u_rst_sync_1 (
    .clk        ( wclk          ),
    .rstn_async ( wrstn & rrstn ),
    .rstn_sync  ( wrstn_sync    )
);

always_ff @(posedge rclk) begin: reg_rdata
    rdata <= fifo[rptr];
end

always_ff @(posedge rclk or negedge rrstn_sync) begin: reg_rptr
    if (~rrstn_sync) rptr <= 6'b0;
    else             rptr <= rptr + {5'b0, pop};
end

always_ff @(posedge wclk or negedge wrstn_sync) begin: reg_wptr
    if (~wrstn_sync) wptr <= 6'b0;
    else             wptr <= wptr + {5'b0, push};
end

always_ff @(posedge wclk) begin: fifo_arr
    if (push) fifo[wptr] <= wdata;
end

endmodule

module dap_resp_fifo (
    input               rclk,
    input               wclk,
    input               wrstn,
    input               rrstn,
    input               push,
    input        [ 1:0] wdata,
    input               pop,
    output logic [31:0] rdata
);

logic [127:0] fifo;
logic [  1:0] rptr;
logic [  5:0] wptr;
logic         rrstn_sync;
logic         wrstn_sync;

resetn_synchronizer u_rst_sync_0 (
    .clk        ( rclk          ),
    .rstn_async ( wrstn & rrstn ),
    .rstn_sync  ( rrstn_sync    )
);

resetn_synchronizer u_rst_sync_1 (
    .clk        ( wclk          ),
    .rstn_async ( wrstn & rrstn ),
    .rstn_sync  ( wrstn_sync    )
);

always_ff @(posedge rclk) begin: reg_rdata
    rdata <= fifo[{rptr, 5'b0}+:32];
end

always_ff @(posedge rclk or negedge rrstn_sync) begin: reg_rptr
    if (~rrstn_sync) rptr <= 2'b0;
    else             rptr <= rptr + {1'b0, pop};
end

always_ff @(posedge wclk or negedge wrstn_sync) begin: reg_wptr
    if (~wrstn_sync) wptr <= 6'b0;
    else             wptr <= wptr + {5'b0, push};
end

always_ff @(posedge wclk) begin: fifo_arr
    if (push) fifo[{wptr, 1'b0}+:2] <= wdata;
end

endmodule
