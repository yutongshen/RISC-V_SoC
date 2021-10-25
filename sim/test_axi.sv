module test_axi;

`define CYCLE 10

logic          aclk;
logic          aresetn;
logic [  1: 0] m0_awburst;
logic [  9: 0] m0_awid;
logic [ 31: 0] m0_awaddr;
logic [  2: 0] m0_awsize;
logic [  7: 0] m0_awlen;
logic          m0_awvalid;
logic          m0_awready;
logic [  3: 0] m0_wstrb;
logic [  9: 0] m0_wid;
logic [ 31: 0] m0_wdata;
logic          m0_wlast;
logic          m0_wvalid;
logic          m0_wready;
logic [  9: 0] m0_bid;
logic [  1: 0] m0_bresp;
logic          m0_bvalid;
logic          m0_bready;
logic [ 31: 0] m0_araddr;
logic [  1: 0] m0_arburst;
logic [  2: 0] m0_arsize;
logic [  9: 0] m0_arid;
logic [  7: 0] m0_arlen;
logic          m0_arvalid;
logic          m0_arready;
logic [ 31: 0] m0_rdata;
logic [  1: 0] m0_rresp;
logic [  9: 0] m0_rid;
logic          m0_rlast;
logic          m0_rvalid;
logic          m0_rready;
logic [  1: 0] s0_awburst;
logic [  9: 0] s0_awid;
logic [ 31: 0] s0_awaddr;
logic [  2: 0] s0_awsize;
logic [  7: 0] s0_awlen;
logic          s0_awvalid;
logic          s0_awready;
logic [  3: 0] s0_wstrb;
logic [  9: 0] s0_wid;
logic [ 31: 0] s0_wdata;
logic          s0_wlast;
logic          s0_wvalid;
logic          s0_wready;
logic [  9: 0] s0_bid;
logic [  1: 0] s0_bresp;
logic          s0_bvalid;
logic          s0_bready;
logic [ 31: 0] s0_araddr;
logic [  1: 0] s0_arburst;
logic [  2: 0] s0_arsize;
logic [  9: 0] s0_arid;
logic [  7: 0] s0_arlen;
logic          s0_arvalid;
logic          s0_arready;
logic [ 31: 0] s0_rdata;
logic [  1: 0] s0_rresp;
logic [  9: 0] s0_rid;
logic          s0_rlast;
logic          s0_rvalid;
logic          s0_rready;
logic [  1: 0] s1_awburst;
logic [  9: 0] s1_awid;
logic [ 31: 0] s1_awaddr;
logic [  2: 0] s1_awsize;
logic [  7: 0] s1_awlen;
logic          s1_awvalid;
logic          s1_awready;
logic [  3: 0] s1_wstrb;
logic [  9: 0] s1_wid;
logic [ 31: 0] s1_wdata;
logic          s1_wlast;
logic          s1_wvalid;
logic          s1_wready;
logic [  9: 0] s1_bid;
logic [  1: 0] s1_bresp;
logic          s1_bvalid;
logic          s1_bready;
logic [ 31: 0] s1_araddr;
logic [  1: 0] s1_arburst;
logic [  2: 0] s1_arsize;
logic [  9: 0] s1_arid;
logic [  7: 0] s1_arlen;
logic          s1_arvalid;
logic          s1_arready;
logic [ 31: 0] s1_rdata;
logic [  1: 0] s1_rresp;
logic [  9: 0] s1_rid;
logic          s1_rlast;
logic          s1_rvalid;
logic          s1_rready;

initial begin
    aclk    = 1'b0;
    aresetn = 1'b0;
    #(`CYCLE*10)
    aresetn = 1'b1;
    #(`CYCLE*1000)
    $finish;
end

always #(`CYCLE/2) aclk = ~aclk;

initial begin
    $fsdbDumpfile("axi.fsdb");
    $fsdbDumpvars(0, test_axi, "+struct", "+mda");
end

axi_1to2_dec DUT (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .s_awburst     ( m0_awburst ),
    .s_awid        ( m0_awid    ),
    .s_awaddr      ( m0_awaddr  ),
    .s_awsize      ( m0_awsize  ),
    .s_awlen       ( m0_awlen   ),
    .s_awvalid     ( m0_awvalid ),
    .s_awready     ( m0_awready ),
    .s_wstrb       ( m0_wstrb   ),
    .s_wid         ( m0_wid     ),
    .s_wdata       ( m0_wdata   ),
    .s_wlast       ( m0_wlast   ),
    .s_wvalid      ( m0_wvalid  ),
    .s_wready      ( m0_wready  ),
    .s_bid         ( m0_bid     ),
    .s_bresp       ( m0_bresp   ),
    .s_bvalid      ( m0_bvalid  ),
    .s_bready      ( m0_bready  ),
    .s_araddr      ( m0_araddr  ),
    .s_arburst     ( m0_arburst ),
    .s_arsize      ( m0_arsize  ),
    .s_arid        ( m0_arid    ),
    .s_arlen       ( m0_arlen   ),
    .s_arvalid     ( m0_arvalid ),
    .s_arready     ( m0_arready ),
    .s_rdata       ( m0_rdata   ),
    .s_rresp       ( m0_rresp   ),
    .s_rid         ( m0_rid     ),
    .s_rlast       ( m0_rlast   ),
    .s_rvalid      ( m0_rvalid  ),
    .s_rready      ( m0_rready  ),
    .m0_awburst    ( s0_awburst ),
    .m0_awid       ( s0_awid    ),
    .m0_awaddr     ( s0_awaddr  ),
    .m0_awsize     ( s0_awsize  ),
    .m0_awlen      ( s0_awlen   ),
    .m0_awvalid    ( s0_awvalid ),
    .m0_awready    ( s0_awready ),
    .m0_wstrb      ( s0_wstrb   ),
    .m0_wid        ( s0_wid     ),
    .m0_wdata      ( s0_wdata   ),
    .m0_wlast      ( s0_wlast   ),
    .m0_wvalid     ( s0_wvalid  ),
    .m0_wready     ( s0_wready  ),
    .m0_bid        ( s0_bid     ),
    .m0_bresp      ( s0_bresp   ),
    .m0_bvalid     ( s0_bvalid  ),
    .m0_bready     ( s0_bready  ),
    .m0_araddr     ( s0_araddr  ),
    .m0_arburst    ( s0_arburst ),
    .m0_arsize     ( s0_arsize  ),
    .m0_arid       ( s0_arid    ),
    .m0_arlen      ( s0_arlen   ),
    .m0_arvalid    ( s0_arvalid ),
    .m0_arready    ( s0_arready ),
    .m0_rdata      ( s0_rdata   ),
    .m0_rresp      ( s0_rresp   ),
    .m0_rid        ( s0_rid     ),
    .m0_rlast      ( s0_rlast   ),
    .m0_rvalid     ( s0_rvalid  ),
    .m0_rready     ( s0_rready  ),
    .m1_awburst    ( s1_awburst ),
    .m1_awid       ( s1_awid    ),
    .m1_awaddr     ( s1_awaddr  ),
    .m1_awsize     ( s1_awsize  ),
    .m1_awlen      ( s1_awlen   ),
    .m1_awvalid    ( s1_awvalid ),
    .m1_awready    ( s1_awready ),
    .m1_wstrb      ( s1_wstrb   ),
    .m1_wid        ( s1_wid     ),
    .m1_wdata      ( s1_wdata   ),
    .m1_wlast      ( s1_wlast   ),
    .m1_wvalid     ( s1_wvalid  ),
    .m1_wready     ( s1_wready  ),
    .m1_bid        ( s1_bid     ),
    .m1_bresp      ( s1_bresp   ),
    .m1_bvalid     ( s1_bvalid  ),
    .m1_bready     ( s1_bready  ),
    .m1_araddr     ( s1_araddr  ),
    .m1_arburst    ( s1_arburst ),
    .m1_arsize     ( s1_arsize  ),
    .m1_arid       ( s1_arid    ),
    .m1_arlen      ( s1_arlen   ),
    .m1_arvalid    ( s1_arvalid ),
    .m1_arready    ( s1_arready ),
    .m1_rdata      ( s1_rdata   ),
    .m1_rresp      ( s1_rresp   ),
    .m1_rid        ( s1_rid     ),
    .m1_rlast      ( s1_rlast   ),
    .m1_rvalid     ( s1_rvalid  ),
    .m1_rready     ( s1_rready  )
);


axi_1to2_mon u_mon (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .m0_awburst    ( m0_awburst ),
    .m0_awid       ( m0_awid    ),
    .m0_awaddr     ( m0_awaddr  ),
    .m0_awsize     ( m0_awsize  ),
    .m0_awlen      ( m0_awlen   ),
    .m0_awvalid    ( m0_awvalid ),
    .m0_awready    ( m0_awready ),
    .m0_wstrb      ( m0_wstrb   ),
    .m0_wid        ( m0_wid     ),
    .m0_wdata      ( m0_wdata   ),
    .m0_wlast      ( m0_wlast   ),
    .m0_wvalid     ( m0_wvalid  ),
    .m0_wready     ( m0_wready  ),
    .m0_bid        ( m0_bid     ),
    .m0_bresp      ( m0_bresp   ),
    .m0_bvalid     ( m0_bvalid  ),
    .m0_bready     ( m0_bready  ),
    .m0_araddr     ( m0_araddr  ),
    .m0_arburst    ( m0_arburst ),
    .m0_arsize     ( m0_arsize  ),
    .m0_arid       ( m0_arid    ),
    .m0_arlen      ( m0_arlen   ),
    .m0_arvalid    ( m0_arvalid ),
    .m0_arready    ( m0_arready ),
    .m0_rdata      ( m0_rdata   ),
    .m0_rresp      ( m0_rresp   ),
    .m0_rid        ( m0_rid     ),
    .m0_rlast      ( m0_rlast   ),
    .m0_rvalid     ( m0_rvalid  ),
    .m0_rready     ( m0_rready  ),
    .s0_awburst    ( s0_awburst ),
    .s0_awid       ( s0_awid    ),
    .s0_awaddr     ( s0_awaddr  ),
    .s0_awsize     ( s0_awsize  ),
    .s0_awlen      ( s0_awlen   ),
    .s0_awvalid    ( s0_awvalid ),
    .s0_awready    ( s0_awready ),
    .s0_wstrb      ( s0_wstrb   ),
    .s0_wid        ( s0_wid     ),
    .s0_wdata      ( s0_wdata   ),
    .s0_wlast      ( s0_wlast   ),
    .s0_wvalid     ( s0_wvalid  ),
    .s0_wready     ( s0_wready  ),
    .s0_bid        ( s0_bid     ),
    .s0_bresp      ( s0_bresp   ),
    .s0_bvalid     ( s0_bvalid  ),
    .s0_bready     ( s0_bready  ),
    .s0_araddr     ( s0_araddr  ),
    .s0_arburst    ( s0_arburst ),
    .s0_arsize     ( s0_arsize  ),
    .s0_arid       ( s0_arid    ),
    .s0_arlen      ( s0_arlen   ),
    .s0_arvalid    ( s0_arvalid ),
    .s0_arready    ( s0_arready ),
    .s0_rdata      ( s0_rdata   ),
    .s0_rresp      ( s0_rresp   ),
    .s0_rid        ( s0_rid     ),
    .s0_rlast      ( s0_rlast   ),
    .s0_rvalid     ( s0_rvalid  ),
    .s0_rready     ( s0_rready  ),
    .s1_awburst    ( s1_awburst ),
    .s1_awid       ( s1_awid    ),
    .s1_awaddr     ( s1_awaddr  ),
    .s1_awsize     ( s1_awsize  ),
    .s1_awlen      ( s1_awlen   ),
    .s1_awvalid    ( s1_awvalid ),
    .s1_awready    ( s1_awready ),
    .s1_wstrb      ( s1_wstrb   ),
    .s1_wid        ( s1_wid     ),
    .s1_wdata      ( s1_wdata   ),
    .s1_wlast      ( s1_wlast   ),
    .s1_wvalid     ( s1_wvalid  ),
    .s1_wready     ( s1_wready  ),
    .s1_bid        ( s1_bid     ),
    .s1_bresp      ( s1_bresp   ),
    .s1_bvalid     ( s1_bvalid  ),
    .s1_bready     ( s1_bready  ),
    .s1_araddr     ( s1_araddr  ),
    .s1_arburst    ( s1_arburst ),
    .s1_arsize     ( s1_arsize  ),
    .s1_arid       ( s1_arid    ),
    .s1_arlen      ( s1_arlen   ),
    .s1_arvalid    ( s1_arvalid ),
    .s1_arready    ( s1_arready ),
    .s1_rdata      ( s1_rdata   ),
    .s1_rresp      ( s1_rresp   ),
    .s1_rid        ( s1_rid     ),
    .s1_rlast      ( s1_rlast   ),
    .s1_rvalid     ( s1_rvalid  ),
    .s1_rready     ( s1_rready  )
);


axi_vip_master #(
    .ID            ( 0          ),
    .AXI_AXID_WIDTH ( 10         ),
    .AXI_AXADDR_WIDTH ( 32         ),
    .AXI_AXLEN_WIDTH ( 8          ),
    .AXI_AXSIZE_WIDTH ( 3          ),
    .AXI_AXBURST_WIDTH ( 2          ),
    .AXI_DATA_WIDTH ( 32         ),
    .AXI_RESP_WIDTH ( 2          )
) u_axi_vip_master0 (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .m_awburst     ( m0_awburst ),
    .m_awid        ( m0_awid    ),
    .m_awaddr      ( m0_awaddr  ),
    .m_awsize      ( m0_awsize  ),
    .m_awlen       ( m0_awlen   ),
    .m_awvalid     ( m0_awvalid ),
    .m_awready     ( m0_awready ),
    .m_wstrb       ( m0_wstrb   ),
    .m_wid         ( m0_wid     ),
    .m_wdata       ( m0_wdata   ),
    .m_wlast       ( m0_wlast   ),
    .m_wvalid      ( m0_wvalid  ),
    .m_wready      ( m0_wready  ),
    .m_bid         ( m0_bid     ),
    .m_bresp       ( m0_bresp   ),
    .m_bvalid      ( m0_bvalid  ),
    .m_bready      ( m0_bready  ),
    .m_araddr      ( m0_araddr  ),
    .m_arburst     ( m0_arburst ),
    .m_arsize      ( m0_arsize  ),
    .m_arid        ( m0_arid    ),
    .m_arlen       ( m0_arlen   ),
    .m_arvalid     ( m0_arvalid ),
    .m_arready     ( m0_arready ),
    .m_rdata       ( m0_rdata   ),
    .m_rresp       ( m0_rresp   ),
    .m_rid         ( m0_rid     ),
    .m_rlast       ( m0_rlast   ),
    .m_rvalid      ( m0_rvalid  ),
    .m_rready      ( m0_rready  )
);


axi_vip_slave #(
    .ID            ( 0          ),
    .AXI_AXID_WIDTH ( 10         ),
    .AXI_AXADDR_WIDTH ( 32         ),
    .AXI_AXLEN_WIDTH ( 8          ),
    .AXI_AXSIZE_WIDTH ( 3          ),
    .AXI_AXBURST_WIDTH ( 2          ),
    .AXI_DATA_WIDTH ( 32         ),
    .AXI_RESP_WIDTH ( 2          )
) u_axi_vip_slave0 (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .s_awburst     ( s0_awburst ),
    .s_awid        ( s0_awid    ),
    .s_awaddr      ( s0_awaddr  ),
    .s_awsize      ( s0_awsize  ),
    .s_awlen       ( s0_awlen   ),
    .s_awvalid     ( s0_awvalid ),
    .s_awready     ( s0_awready ),
    .s_wstrb       ( s0_wstrb   ),
    .s_wid         ( s0_wid     ),
    .s_wdata       ( s0_wdata   ),
    .s_wlast       ( s0_wlast   ),
    .s_wvalid      ( s0_wvalid  ),
    .s_wready      ( s0_wready  ),
    .s_bid         ( s0_bid     ),
    .s_bresp       ( s0_bresp   ),
    .s_bvalid      ( s0_bvalid  ),
    .s_bready      ( s0_bready  ),
    .s_araddr      ( s0_araddr  ),
    .s_arburst     ( s0_arburst ),
    .s_arsize      ( s0_arsize  ),
    .s_arid        ( s0_arid    ),
    .s_arlen       ( s0_arlen   ),
    .s_arvalid     ( s0_arvalid ),
    .s_arready     ( s0_arready ),
    .s_rdata       ( s0_rdata   ),
    .s_rresp       ( s0_rresp   ),
    .s_rid         ( s0_rid     ),
    .s_rlast       ( s0_rlast   ),
    .s_rvalid      ( s0_rvalid  ),
    .s_rready      ( s0_rready  )
);

axi_vip_slave #(
    .ID            ( 1          ),
    .AXI_AXID_WIDTH ( 10         ),
    .AXI_AXADDR_WIDTH ( 32         ),
    .AXI_AXLEN_WIDTH ( 8          ),
    .AXI_AXSIZE_WIDTH ( 3          ),
    .AXI_AXBURST_WIDTH ( 2          ),
    .AXI_DATA_WIDTH ( 32         ),
    .AXI_RESP_WIDTH ( 2          )
) u_axi_vip_slave1 (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .s_awburst     ( s1_awburst ),
    .s_awid        ( s1_awid    ),
    .s_awaddr      ( s1_awaddr  ),
    .s_awsize      ( s1_awsize  ),
    .s_awlen       ( s1_awlen   ),
    .s_awvalid     ( s1_awvalid ),
    .s_awready     ( s1_awready ),
    .s_wstrb       ( s1_wstrb   ),
    .s_wid         ( s1_wid     ),
    .s_wdata       ( s1_wdata   ),
    .s_wlast       ( s1_wlast   ),
    .s_wvalid      ( s1_wvalid  ),
    .s_wready      ( s1_wready  ),
    .s_bid         ( s1_bid     ),
    .s_bresp       ( s1_bresp   ),
    .s_bvalid      ( s1_bvalid  ),
    .s_bready      ( s1_bready  ),
    .s_araddr      ( s1_araddr  ),
    .s_arburst     ( s1_arburst ),
    .s_arsize      ( s1_arsize  ),
    .s_arid        ( s1_arid    ),
    .s_arlen       ( s1_arlen   ),
    .s_arvalid     ( s1_arvalid ),
    .s_arready     ( s1_arready ),
    .s_rdata       ( s1_rdata   ),
    .s_rresp       ( s1_rresp   ),
    .s_rid         ( s1_rid     ),
    .s_rlast       ( s1_rlast   ),
    .s_rvalid      ( s1_rvalid  ),
    .s_rready      ( s1_rready  )
);

endmodule
