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

logic        ap_buf_rrstn;
logic        ap_buf_dpop;
logic [31:0] ap_buf_rdata;
logic        ap_buf_rpop;
logic [31:0] ap_buf_rresp;
logic        ap_buf_push;
logic [31:0] ap_buf_wdata;
logic [ 1:0] ap_buf_wresp;

logic [ 7:0] ap_sel_latch;

logic        apb_ap_upd;
logic [31:0] apb_ap_rdata;
logic        apb_ap_slverr;
logic        apb_ap_busy;

logic        apb_ap_buf_push;
logic [31:0] apb_ap_buf_wdata;
logic [ 1:0] apb_ap_buf_wresp;

logic        axi_ap_upd;
logic [31:0] axi_ap_rdata;
logic        axi_ap_slverr;
logic        axi_ap_busy;

logic        axi_ap_buf_push;
logic [31:0] axi_ap_buf_wdata;
logic [ 1:0] axi_ap_buf_wresp;


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

assign ap_buf_push  = axi_ap_buf_push;
assign ap_buf_wdata = axi_ap_buf_wdata;
assign ap_buf_wresp = axi_ap_buf_wresp;

jtag_dp u_jtag_dp (
    .tck          ( tck          ),
    .trstn        ( trstn        ),
    .tms          ( tms          ),
    .tdi          ( tdi          ),
    .tdo          ( tdo          ),
    
    .ap_upd       ( ap_upd       ),
    .ap_sel       ( ap_sel       ),
    .ap_wdata     ( ap_wdata     ),
    .ap_addr      ( ap_addr      ),
    .ap_rnw       ( ap_rnw       ),
    .ap_busy      ( ap_busy      ),
    .ap_rdata     ( ap_rdata     ),
    .ap_slverr    ( ap_slverr    ),
    .ap_ack       ( ap_ack       ),

    .ap_buf_rrstn ( ap_buf_rrstn ),
    .ap_buf_dpop  ( ap_buf_dpop  ),
    .ap_buf_rdata ( ap_buf_rdata ),
    .ap_buf_rpop  ( ap_buf_rpop  ),
    .ap_buf_rresp ( ap_buf_rresp ),

    .dbgrstn      ( dbgrstn      )
);

apb_ap u_apb_ap (
    .tck          ( tck              ),
    .dbgrstn      ( dbgrstn          ),

    .sysclk       ( clk              ),
    .sysrstn      ( rstn             ),

    .ap_upd       ( apb_ap_upd       ),
    .ap_wdata     ( ap_wdata         ),
    .ap_addr      ( ap_addr          ),
    .ap_rnw       ( ap_rnw           ),
    .ap_rdata     ( apb_ap_rdata     ),
    .ap_slverr    ( apb_ap_slverr    ),
    .ap_busy      ( apb_ap_busy      ),

    .ap_buf_push  ( apb_ap_buf_push  ),
    .ap_buf_wdata ( apb_ap_buf_wdata ),
    .ap_buf_wresp ( apb_ap_buf_wresp ),

    .spiden       ( apb_spiden       ),
    .deviceen     ( apb_deviceen     ),

    .m_apb_intf   ( m_apb_intf       )
);

axi_ap u_axi_ap (
    .tck          ( tck              ),
    .dbgrstn      ( dbgrstn          ),

    .sysclk       ( clk              ),
    .sysrstn      ( rstn             ),

    .ap_upd       ( axi_ap_upd       ),
    .ap_wdata     ( ap_wdata         ),
    .ap_addr      ( ap_addr          ),
    .ap_rnw       ( ap_rnw           ),
    .ap_rdata     ( axi_ap_rdata     ),
    .ap_slverr    ( axi_ap_slverr    ),
    .ap_busy      ( axi_ap_busy      ),

    .ap_buf_push  ( axi_ap_buf_push  ),
    .ap_buf_wdata ( axi_ap_buf_wdata ),
    .ap_buf_wresp ( axi_ap_buf_wresp ),

    .spiden       ( axi_spiden       ),
    .deviceen     ( axi_deviceen     ),

    .m_axi_intf   ( m_axi_intf       )
);

dap_fifo u_rdata_fifo (
    .rclk      ( tck          ),
    .wclk      ( clk          ),
    .rstn      ( dbgrstn      ),
    .rptr_rstn ( ap_buf_rrstn ),
    .push      ( ap_buf_push  ),
    .wdata     ( ap_buf_wdata ),
    .pop       ( ap_buf_dpop  ),
    .rdata     ( ap_buf_rdata )
);

dap_resp_fifo u_resp_fifo (
    .rclk      ( tck          ),
    .wclk      ( clk          ),
    .rstn      ( dbgrstn      ),
    .rptr_rstn ( ap_buf_rrstn ),
    .push      ( ap_buf_push  ),
    .wdata     ( ap_buf_wresp ),
    .pop       ( ap_buf_rpop  ),
    .rdata     ( ap_buf_rresp )
);

endmodule

module dap_fifo (
    input               rclk,
    input               wclk,
    input               rstn,
    input               rptr_rstn,
    input               push,
    input        [31:0] wdata,
    input               pop,
    output logic [31:0] rdata
);

logic [31:0] fifo [64];
logic [ 5:0] rptr;
logic [ 5:0] wptr;
logic        rrstn;
logic        wrstn;

resetn_synchronizer u_rst_sync_0(
    .clk        ( rclk            ),
    .rstn_async ( rstn & rptr_rstn),
    .rstn_sync  ( rrstn           )
);

resetn_synchronizer u_rst_sync_1(
    .clk        ( wclk  ),
    .rstn_async ( rstn  ),
    .rstn_sync  ( wrstn )
);

always_ff @(posedge rclk or negedge rrstn) begin: reg_rdata
    if (~rrstn) begin
        rdata <= 32'b0;
    end
    else begin
        rdata = fifo[rptr];
    end
end

always_ff @(posedge rclk or negedge rrstn) begin: reg_rptr
    if (~rrstn) rptr <= 6'b0;
    else        rptr <= rptr + {5'b0, pop};
end

always_ff @(posedge wclk or negedge wrstn) begin: reg_wptr
    if (~wrstn) wptr <= 6'b0;
    else        wptr <= wptr + {5'b0, push};
end

always_ff @(posedge wclk or negedge wrstn) begin: fifo_arr
    integer i;
    if (~wrstn) begin
        for (i = 0; i < 32; i = i + 1) begin
            fifo[i] <= 32'b0;
        end
    end
    else begin
        if (push) fifo[wptr] <= wdata;
    end
end

endmodule

module dap_resp_fifo (
    input               rclk,
    input               wclk,
    input               rstn,
    input               rptr_rstn,
    input               push,
    input        [ 1:0] wdata,
    input               pop,
    output logic [31:0] rdata
);

logic [127:0] fifo;
logic [  1:0] rptr;
logic [  5:0] wptr;
logic         rrstn;
logic         wrstn;

resetn_synchronizer u_rst_sync_0(
    .clk        ( rclk            ),
    .rstn_async ( rstn & rptr_rstn),
    .rstn_sync  ( rrstn           )
);

resetn_synchronizer u_rst_sync_1(
    .clk        ( wclk  ),
    .rstn_async ( rstn  ),
    .rstn_sync  ( wrstn )
);

always_ff @(posedge rclk or negedge rrstn) begin: reg_rdata
    if (~rrstn) begin
        rdata <= 32'b0;
    end
    else begin
        rdata = fifo[{rptr, 5'b0}+:32];
    end
end

always_ff @(posedge rclk or negedge rrstn) begin: reg_rptr
    if (~rrstn) rptr <= 2'b0;
    else        rptr <= rptr + {1'b0, pop};
end

always_ff @(posedge wclk or negedge wrstn) begin: reg_wptr
    if (~wrstn) wptr <= 6'b0;
    else        wptr <= wptr + {5'b0, push};
end

always_ff @(posedge wclk or negedge wrstn) begin: fifo_arr
    integer i;
    if (~wrstn) begin
        fifo <= 128'b0;
    end
    else begin
        if (push) fifo[{wptr, 1'b0}+:2] <= wdata;
    end
end

endmodule
