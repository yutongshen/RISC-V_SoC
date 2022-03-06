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

logic [ 7:0] ap_sel_latch;

logic        apb_ap_upd;
logic [31:0] apb_ap_rdata;
logic        apb_ap_slverr;
logic        apb_ap_busy;

logic        axi_ap_upd;
logic [31:0] axi_ap_rdata;
logic        axi_ap_slverr;
logic        axi_ap_busy;


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

jtag_dp u_jtag_dp (
    .tck       ( tck       ),
    .trstn     ( trstn     ),
    .tms       ( tms       ),
    .tdi       ( tdi       ),
    .tdo       ( tdo       ),
    
    .ap_upd    ( ap_upd    ),
    .ap_sel    ( ap_sel    ),
    .ap_wdata  ( ap_wdata  ),
    .ap_addr   ( ap_addr   ),
    .ap_rnw    ( ap_rnw    ),
    .ap_busy   ( ap_busy   ),
    .ap_rdata  ( ap_rdata  ),
    .ap_slverr ( ap_slverr ),
    .ap_ack    ( ap_ack    ),

    .dbgrstn   ( dbgrstn   )
);

apb_ap u_apb_ap (
    .tck        ( tck           ),
    .dbgrstn    ( dbgrstn       ),

    .sysclk     ( clk           ),
    .sysrstn    ( rstn          ),

    .ap_upd     ( apb_ap_upd    ),
    .ap_wdata   ( ap_wdata      ),
    .ap_addr    ( ap_addr       ),
    .ap_rnw     ( ap_rnw        ),
    .ap_rdata   ( apb_ap_rdata  ),
    .ap_slverr  ( apb_ap_slverr ),
    .ap_busy    ( apb_ap_busy   ),

    .spiden     ( apb_spiden    ),
    .deviceen   ( apb_deviceen  ),

    .m_apb_intf ( m_apb_intf    )
);

axi_ap u_axi_ap (
    .tck        ( tck           ),
    .dbgrstn    ( dbgrstn       ),

    .sysclk     ( clk           ),
    .sysrstn    ( rstn          ),

    .ap_upd     ( axi_ap_upd    ),
    .ap_wdata   ( ap_wdata      ),
    .ap_addr    ( ap_addr       ),
    .ap_rnw     ( ap_rnw        ),
    .ap_rdata   ( axi_ap_rdata  ),
    .ap_slverr  ( axi_ap_slverr ),
    .ap_busy    ( axi_ap_busy   ),

    .spiden     ( axi_spiden    ),
    .deviceen   ( axi_deviceen  ),

    .m_axi_intf ( m_axi_intf    )
);

endmodule
