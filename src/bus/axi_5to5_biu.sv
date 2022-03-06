/*-----------------------------------------------------*/
// axi_5to5_biu.sv is generated by ../../script/gen_axi_biu.sh
//
//                                         2022-03-06
//                                           20:59:52
/*-----------------------------------------------------*/

module axi_5to5_biu (
    input                  aclk,
    input                  aresetn,
    input         [  1: 0] s0_awburst,
    input         [  2: 0] s0_awprot,
    input         [  9: 0] s0_awid,
    input         [  3: 0] s0_awcache,
    input         [ 31: 0] s0_awaddr,
    input         [  2: 0] s0_awsize,
    input         [  1: 0] s0_awlock,
    input         [  7: 0] s0_awlen,
    input                  s0_awvalid,
    output logic           s0_awready,
    input         [  3: 0] s0_wstrb,
    input         [  9: 0] s0_wid,
    input         [ 31: 0] s0_wdata,
    input                  s0_wlast,
    input                  s0_wvalid,
    output logic           s0_wready,
    output logic  [  9: 0] s0_bid,
    output logic  [  1: 0] s0_bresp,
    output logic           s0_bvalid,
    input                  s0_bready,
    input         [ 31: 0] s0_araddr,
    input         [  1: 0] s0_arburst,
    input         [  2: 0] s0_arprot,
    input         [  3: 0] s0_arcache,
    input         [  2: 0] s0_arsize,
    input         [  9: 0] s0_arid,
    input         [  1: 0] s0_arlock,
    input         [  7: 0] s0_arlen,
    input                  s0_arvalid,
    output logic           s0_arready,
    output logic  [ 31: 0] s0_rdata,
    output logic  [  1: 0] s0_rresp,
    output logic  [  9: 0] s0_rid,
    output logic           s0_rlast,
    output logic           s0_rvalid,
    input                  s0_rready,
    input         [  1: 0] s1_awburst,
    input         [  2: 0] s1_awprot,
    input         [  9: 0] s1_awid,
    input         [  3: 0] s1_awcache,
    input         [ 31: 0] s1_awaddr,
    input         [  2: 0] s1_awsize,
    input         [  1: 0] s1_awlock,
    input         [  7: 0] s1_awlen,
    input                  s1_awvalid,
    output logic           s1_awready,
    input         [  3: 0] s1_wstrb,
    input         [  9: 0] s1_wid,
    input         [ 31: 0] s1_wdata,
    input                  s1_wlast,
    input                  s1_wvalid,
    output logic           s1_wready,
    output logic  [  9: 0] s1_bid,
    output logic  [  1: 0] s1_bresp,
    output logic           s1_bvalid,
    input                  s1_bready,
    input         [ 31: 0] s1_araddr,
    input         [  1: 0] s1_arburst,
    input         [  2: 0] s1_arprot,
    input         [  3: 0] s1_arcache,
    input         [  2: 0] s1_arsize,
    input         [  9: 0] s1_arid,
    input         [  1: 0] s1_arlock,
    input         [  7: 0] s1_arlen,
    input                  s1_arvalid,
    output logic           s1_arready,
    output logic  [ 31: 0] s1_rdata,
    output logic  [  1: 0] s1_rresp,
    output logic  [  9: 0] s1_rid,
    output logic           s1_rlast,
    output logic           s1_rvalid,
    input                  s1_rready,
    input         [  1: 0] s2_awburst,
    input         [  2: 0] s2_awprot,
    input         [  9: 0] s2_awid,
    input         [  3: 0] s2_awcache,
    input         [ 31: 0] s2_awaddr,
    input         [  2: 0] s2_awsize,
    input         [  1: 0] s2_awlock,
    input         [  7: 0] s2_awlen,
    input                  s2_awvalid,
    output logic           s2_awready,
    input         [  3: 0] s2_wstrb,
    input         [  9: 0] s2_wid,
    input         [ 31: 0] s2_wdata,
    input                  s2_wlast,
    input                  s2_wvalid,
    output logic           s2_wready,
    output logic  [  9: 0] s2_bid,
    output logic  [  1: 0] s2_bresp,
    output logic           s2_bvalid,
    input                  s2_bready,
    input         [ 31: 0] s2_araddr,
    input         [  1: 0] s2_arburst,
    input         [  2: 0] s2_arprot,
    input         [  3: 0] s2_arcache,
    input         [  2: 0] s2_arsize,
    input         [  9: 0] s2_arid,
    input         [  1: 0] s2_arlock,
    input         [  7: 0] s2_arlen,
    input                  s2_arvalid,
    output logic           s2_arready,
    output logic  [ 31: 0] s2_rdata,
    output logic  [  1: 0] s2_rresp,
    output logic  [  9: 0] s2_rid,
    output logic           s2_rlast,
    output logic           s2_rvalid,
    input                  s2_rready,
    input         [  1: 0] s3_awburst,
    input         [  2: 0] s3_awprot,
    input         [  9: 0] s3_awid,
    input         [  3: 0] s3_awcache,
    input         [ 31: 0] s3_awaddr,
    input         [  2: 0] s3_awsize,
    input         [  1: 0] s3_awlock,
    input         [  7: 0] s3_awlen,
    input                  s3_awvalid,
    output logic           s3_awready,
    input         [  3: 0] s3_wstrb,
    input         [  9: 0] s3_wid,
    input         [ 31: 0] s3_wdata,
    input                  s3_wlast,
    input                  s3_wvalid,
    output logic           s3_wready,
    output logic  [  9: 0] s3_bid,
    output logic  [  1: 0] s3_bresp,
    output logic           s3_bvalid,
    input                  s3_bready,
    input         [ 31: 0] s3_araddr,
    input         [  1: 0] s3_arburst,
    input         [  2: 0] s3_arprot,
    input         [  3: 0] s3_arcache,
    input         [  2: 0] s3_arsize,
    input         [  9: 0] s3_arid,
    input         [  1: 0] s3_arlock,
    input         [  7: 0] s3_arlen,
    input                  s3_arvalid,
    output logic           s3_arready,
    output logic  [ 31: 0] s3_rdata,
    output logic  [  1: 0] s3_rresp,
    output logic  [  9: 0] s3_rid,
    output logic           s3_rlast,
    output logic           s3_rvalid,
    input                  s3_rready,
    input         [  1: 0] s4_awburst,
    input         [  2: 0] s4_awprot,
    input         [  9: 0] s4_awid,
    input         [  3: 0] s4_awcache,
    input         [ 31: 0] s4_awaddr,
    input         [  2: 0] s4_awsize,
    input         [  1: 0] s4_awlock,
    input         [  7: 0] s4_awlen,
    input                  s4_awvalid,
    output logic           s4_awready,
    input         [  3: 0] s4_wstrb,
    input         [  9: 0] s4_wid,
    input         [ 31: 0] s4_wdata,
    input                  s4_wlast,
    input                  s4_wvalid,
    output logic           s4_wready,
    output logic  [  9: 0] s4_bid,
    output logic  [  1: 0] s4_bresp,
    output logic           s4_bvalid,
    input                  s4_bready,
    input         [ 31: 0] s4_araddr,
    input         [  1: 0] s4_arburst,
    input         [  2: 0] s4_arprot,
    input         [  3: 0] s4_arcache,
    input         [  2: 0] s4_arsize,
    input         [  9: 0] s4_arid,
    input         [  1: 0] s4_arlock,
    input         [  7: 0] s4_arlen,
    input                  s4_arvalid,
    output logic           s4_arready,
    output logic  [ 31: 0] s4_rdata,
    output logic  [  1: 0] s4_rresp,
    output logic  [  9: 0] s4_rid,
    output logic           s4_rlast,
    output logic           s4_rvalid,
    input                  s4_rready,
    output logic  [  1: 0] m0_awburst,
    output logic  [  2: 0] m0_awprot,
    output logic  [ 12: 0] m0_awid,
    output logic  [  3: 0] m0_awcache,
    output logic  [ 31: 0] m0_awaddr,
    output logic  [  2: 0] m0_awsize,
    output logic  [  1: 0] m0_awlock,
    output logic  [  7: 0] m0_awlen,
    output logic           m0_awvalid,
    input                  m0_awready,
    output logic  [  3: 0] m0_wstrb,
    output logic  [ 12: 0] m0_wid,
    output logic  [ 31: 0] m0_wdata,
    output logic           m0_wlast,
    output logic           m0_wvalid,
    input                  m0_wready,
    input         [ 12: 0] m0_bid,
    input         [  1: 0] m0_bresp,
    input                  m0_bvalid,
    output logic           m0_bready,
    output logic  [ 31: 0] m0_araddr,
    output logic  [  1: 0] m0_arburst,
    output logic  [  2: 0] m0_arprot,
    output logic  [  3: 0] m0_arcache,
    output logic  [  2: 0] m0_arsize,
    output logic  [ 12: 0] m0_arid,
    output logic  [  1: 0] m0_arlock,
    output logic  [  7: 0] m0_arlen,
    output logic           m0_arvalid,
    input                  m0_arready,
    input         [ 31: 0] m0_rdata,
    input         [  1: 0] m0_rresp,
    input         [ 12: 0] m0_rid,
    input                  m0_rlast,
    input                  m0_rvalid,
    output logic           m0_rready,
    output logic  [  1: 0] m1_awburst,
    output logic  [  2: 0] m1_awprot,
    output logic  [ 12: 0] m1_awid,
    output logic  [  3: 0] m1_awcache,
    output logic  [ 31: 0] m1_awaddr,
    output logic  [  2: 0] m1_awsize,
    output logic  [  1: 0] m1_awlock,
    output logic  [  7: 0] m1_awlen,
    output logic           m1_awvalid,
    input                  m1_awready,
    output logic  [  3: 0] m1_wstrb,
    output logic  [ 12: 0] m1_wid,
    output logic  [ 31: 0] m1_wdata,
    output logic           m1_wlast,
    output logic           m1_wvalid,
    input                  m1_wready,
    input         [ 12: 0] m1_bid,
    input         [  1: 0] m1_bresp,
    input                  m1_bvalid,
    output logic           m1_bready,
    output logic  [ 31: 0] m1_araddr,
    output logic  [  1: 0] m1_arburst,
    output logic  [  2: 0] m1_arprot,
    output logic  [  3: 0] m1_arcache,
    output logic  [  2: 0] m1_arsize,
    output logic  [ 12: 0] m1_arid,
    output logic  [  1: 0] m1_arlock,
    output logic  [  7: 0] m1_arlen,
    output logic           m1_arvalid,
    input                  m1_arready,
    input         [ 31: 0] m1_rdata,
    input         [  1: 0] m1_rresp,
    input         [ 12: 0] m1_rid,
    input                  m1_rlast,
    input                  m1_rvalid,
    output logic           m1_rready,
    output logic  [  1: 0] m2_awburst,
    output logic  [  2: 0] m2_awprot,
    output logic  [ 12: 0] m2_awid,
    output logic  [  3: 0] m2_awcache,
    output logic  [ 31: 0] m2_awaddr,
    output logic  [  2: 0] m2_awsize,
    output logic  [  1: 0] m2_awlock,
    output logic  [  7: 0] m2_awlen,
    output logic           m2_awvalid,
    input                  m2_awready,
    output logic  [  3: 0] m2_wstrb,
    output logic  [ 12: 0] m2_wid,
    output logic  [ 31: 0] m2_wdata,
    output logic           m2_wlast,
    output logic           m2_wvalid,
    input                  m2_wready,
    input         [ 12: 0] m2_bid,
    input         [  1: 0] m2_bresp,
    input                  m2_bvalid,
    output logic           m2_bready,
    output logic  [ 31: 0] m2_araddr,
    output logic  [  1: 0] m2_arburst,
    output logic  [  2: 0] m2_arprot,
    output logic  [  3: 0] m2_arcache,
    output logic  [  2: 0] m2_arsize,
    output logic  [ 12: 0] m2_arid,
    output logic  [  1: 0] m2_arlock,
    output logic  [  7: 0] m2_arlen,
    output logic           m2_arvalid,
    input                  m2_arready,
    input         [ 31: 0] m2_rdata,
    input         [  1: 0] m2_rresp,
    input         [ 12: 0] m2_rid,
    input                  m2_rlast,
    input                  m2_rvalid,
    output logic           m2_rready,
    output logic  [  1: 0] m3_awburst,
    output logic  [  2: 0] m3_awprot,
    output logic  [ 12: 0] m3_awid,
    output logic  [  3: 0] m3_awcache,
    output logic  [ 31: 0] m3_awaddr,
    output logic  [  2: 0] m3_awsize,
    output logic  [  1: 0] m3_awlock,
    output logic  [  7: 0] m3_awlen,
    output logic           m3_awvalid,
    input                  m3_awready,
    output logic  [  3: 0] m3_wstrb,
    output logic  [ 12: 0] m3_wid,
    output logic  [ 31: 0] m3_wdata,
    output logic           m3_wlast,
    output logic           m3_wvalid,
    input                  m3_wready,
    input         [ 12: 0] m3_bid,
    input         [  1: 0] m3_bresp,
    input                  m3_bvalid,
    output logic           m3_bready,
    output logic  [ 31: 0] m3_araddr,
    output logic  [  1: 0] m3_arburst,
    output logic  [  2: 0] m3_arprot,
    output logic  [  3: 0] m3_arcache,
    output logic  [  2: 0] m3_arsize,
    output logic  [ 12: 0] m3_arid,
    output logic  [  1: 0] m3_arlock,
    output logic  [  7: 0] m3_arlen,
    output logic           m3_arvalid,
    input                  m3_arready,
    input         [ 31: 0] m3_rdata,
    input         [  1: 0] m3_rresp,
    input         [ 12: 0] m3_rid,
    input                  m3_rlast,
    input                  m3_rvalid,
    output logic           m3_rready,
    output logic  [  1: 0] m4_awburst,
    output logic  [  2: 0] m4_awprot,
    output logic  [ 12: 0] m4_awid,
    output logic  [  3: 0] m4_awcache,
    output logic  [ 31: 0] m4_awaddr,
    output logic  [  2: 0] m4_awsize,
    output logic  [  1: 0] m4_awlock,
    output logic  [  7: 0] m4_awlen,
    output logic           m4_awvalid,
    input                  m4_awready,
    output logic  [  3: 0] m4_wstrb,
    output logic  [ 12: 0] m4_wid,
    output logic  [ 31: 0] m4_wdata,
    output logic           m4_wlast,
    output logic           m4_wvalid,
    input                  m4_wready,
    input         [ 12: 0] m4_bid,
    input         [  1: 0] m4_bresp,
    input                  m4_bvalid,
    output logic           m4_bready,
    output logic  [ 31: 0] m4_araddr,
    output logic  [  1: 0] m4_arburst,
    output logic  [  2: 0] m4_arprot,
    output logic  [  3: 0] m4_arcache,
    output logic  [  2: 0] m4_arsize,
    output logic  [ 12: 0] m4_arid,
    output logic  [  1: 0] m4_arlock,
    output logic  [  7: 0] m4_arlen,
    output logic           m4_arvalid,
    input                  m4_arready,
    input         [ 31: 0] m4_rdata,
    input         [  1: 0] m4_rresp,
    input         [ 12: 0] m4_rid,
    input                  m4_rlast,
    input                  m4_rvalid,
    output logic           m4_rready
);

logic [  1: 0] i0_awburst;
logic [  2: 0] i0_awprot;
logic [ 12: 0] i0_awid;
logic [  3: 0] i0_awcache;
logic [ 31: 0] i0_awaddr;
logic [  2: 0] i0_awsize;
logic [  1: 0] i0_awlock;
logic [  7: 0] i0_awlen;
logic          i0_awvalid;
logic          i0_awready;
logic [  3: 0] i0_wstrb;
logic [ 12: 0] i0_wid;
logic [ 31: 0] i0_wdata;
logic          i0_wlast;
logic          i0_wvalid;
logic          i0_wready;
logic [ 12: 0] i0_bid;
logic [  1: 0] i0_bresp;
logic          i0_bvalid;
logic          i0_bready;
logic [ 31: 0] i0_araddr;
logic [  1: 0] i0_arburst;
logic [  2: 0] i0_arprot;
logic [  3: 0] i0_arcache;
logic [  2: 0] i0_arsize;
logic [ 12: 0] i0_arid;
logic [  1: 0] i0_arlock;
logic [  7: 0] i0_arlen;
logic          i0_arvalid;
logic          i0_arready;
logic [ 31: 0] i0_rdata;
logic [  1: 0] i0_rresp;
logic [ 12: 0] i0_rid;
logic          i0_rlast;
logic          i0_rvalid;
logic          i0_rready;
logic [  1: 0] i1_awburst;
logic [  2: 0] i1_awprot;
logic [ 12: 0] i1_awid;
logic [  3: 0] i1_awcache;
logic [ 31: 0] i1_awaddr;
logic [  2: 0] i1_awsize;
logic [  1: 0] i1_awlock;
logic [  7: 0] i1_awlen;
logic          i1_awvalid;
logic          i1_awready;
logic [  3: 0] i1_wstrb;
logic [ 12: 0] i1_wid;
logic [ 31: 0] i1_wdata;
logic          i1_wlast;
logic          i1_wvalid;
logic          i1_wready;
logic [ 12: 0] i1_bid;
logic [  1: 0] i1_bresp;
logic          i1_bvalid;
logic          i1_bready;
logic [ 31: 0] i1_araddr;
logic [  1: 0] i1_arburst;
logic [  2: 0] i1_arprot;
logic [  3: 0] i1_arcache;
logic [  2: 0] i1_arsize;
logic [ 12: 0] i1_arid;
logic [  1: 0] i1_arlock;
logic [  7: 0] i1_arlen;
logic          i1_arvalid;
logic          i1_arready;
logic [ 31: 0] i1_rdata;
logic [  1: 0] i1_rresp;
logic [ 12: 0] i1_rid;
logic          i1_rlast;
logic          i1_rvalid;
logic          i1_rready;

axi_5to1_mux u_mux (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .s0_awburst    ( s0_awburst ),
    .s0_awprot     ( s0_awprot  ),
    .s0_awid       ( s0_awid    ),
    .s0_awcache    ( s0_awcache ),
    .s0_awaddr     ( s0_awaddr  ),
    .s0_awsize     ( s0_awsize  ),
    .s0_awlock     ( s0_awlock  ),
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
    .s0_arprot     ( s0_arprot  ),
    .s0_arcache    ( s0_arcache ),
    .s0_arsize     ( s0_arsize  ),
    .s0_arid       ( s0_arid    ),
    .s0_arlock     ( s0_arlock  ),
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
    .s1_awprot     ( s1_awprot  ),
    .s1_awid       ( s1_awid    ),
    .s1_awcache    ( s1_awcache ),
    .s1_awaddr     ( s1_awaddr  ),
    .s1_awsize     ( s1_awsize  ),
    .s1_awlock     ( s1_awlock  ),
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
    .s1_arprot     ( s1_arprot  ),
    .s1_arcache    ( s1_arcache ),
    .s1_arsize     ( s1_arsize  ),
    .s1_arid       ( s1_arid    ),
    .s1_arlock     ( s1_arlock  ),
    .s1_arlen      ( s1_arlen   ),
    .s1_arvalid    ( s1_arvalid ),
    .s1_arready    ( s1_arready ),
    .s1_rdata      ( s1_rdata   ),
    .s1_rresp      ( s1_rresp   ),
    .s1_rid        ( s1_rid     ),
    .s1_rlast      ( s1_rlast   ),
    .s1_rvalid     ( s1_rvalid  ),
    .s1_rready     ( s1_rready  ),
    .s2_awburst    ( s2_awburst ),
    .s2_awprot     ( s2_awprot  ),
    .s2_awid       ( s2_awid    ),
    .s2_awcache    ( s2_awcache ),
    .s2_awaddr     ( s2_awaddr  ),
    .s2_awsize     ( s2_awsize  ),
    .s2_awlock     ( s2_awlock  ),
    .s2_awlen      ( s2_awlen   ),
    .s2_awvalid    ( s2_awvalid ),
    .s2_awready    ( s2_awready ),
    .s2_wstrb      ( s2_wstrb   ),
    .s2_wid        ( s2_wid     ),
    .s2_wdata      ( s2_wdata   ),
    .s2_wlast      ( s2_wlast   ),
    .s2_wvalid     ( s2_wvalid  ),
    .s2_wready     ( s2_wready  ),
    .s2_bid        ( s2_bid     ),
    .s2_bresp      ( s2_bresp   ),
    .s2_bvalid     ( s2_bvalid  ),
    .s2_bready     ( s2_bready  ),
    .s2_araddr     ( s2_araddr  ),
    .s2_arburst    ( s2_arburst ),
    .s2_arprot     ( s2_arprot  ),
    .s2_arcache    ( s2_arcache ),
    .s2_arsize     ( s2_arsize  ),
    .s2_arid       ( s2_arid    ),
    .s2_arlock     ( s2_arlock  ),
    .s2_arlen      ( s2_arlen   ),
    .s2_arvalid    ( s2_arvalid ),
    .s2_arready    ( s2_arready ),
    .s2_rdata      ( s2_rdata   ),
    .s2_rresp      ( s2_rresp   ),
    .s2_rid        ( s2_rid     ),
    .s2_rlast      ( s2_rlast   ),
    .s2_rvalid     ( s2_rvalid  ),
    .s2_rready     ( s2_rready  ),
    .s3_awburst    ( s3_awburst ),
    .s3_awprot     ( s3_awprot  ),
    .s3_awid       ( s3_awid    ),
    .s3_awcache    ( s3_awcache ),
    .s3_awaddr     ( s3_awaddr  ),
    .s3_awsize     ( s3_awsize  ),
    .s3_awlock     ( s3_awlock  ),
    .s3_awlen      ( s3_awlen   ),
    .s3_awvalid    ( s3_awvalid ),
    .s3_awready    ( s3_awready ),
    .s3_wstrb      ( s3_wstrb   ),
    .s3_wid        ( s3_wid     ),
    .s3_wdata      ( s3_wdata   ),
    .s3_wlast      ( s3_wlast   ),
    .s3_wvalid     ( s3_wvalid  ),
    .s3_wready     ( s3_wready  ),
    .s3_bid        ( s3_bid     ),
    .s3_bresp      ( s3_bresp   ),
    .s3_bvalid     ( s3_bvalid  ),
    .s3_bready     ( s3_bready  ),
    .s3_araddr     ( s3_araddr  ),
    .s3_arburst    ( s3_arburst ),
    .s3_arprot     ( s3_arprot  ),
    .s3_arcache    ( s3_arcache ),
    .s3_arsize     ( s3_arsize  ),
    .s3_arid       ( s3_arid    ),
    .s3_arlock     ( s3_arlock  ),
    .s3_arlen      ( s3_arlen   ),
    .s3_arvalid    ( s3_arvalid ),
    .s3_arready    ( s3_arready ),
    .s3_rdata      ( s3_rdata   ),
    .s3_rresp      ( s3_rresp   ),
    .s3_rid        ( s3_rid     ),
    .s3_rlast      ( s3_rlast   ),
    .s3_rvalid     ( s3_rvalid  ),
    .s3_rready     ( s3_rready  ),
    .s4_awburst    ( s4_awburst ),
    .s4_awprot     ( s4_awprot  ),
    .s4_awid       ( s4_awid    ),
    .s4_awcache    ( s4_awcache ),
    .s4_awaddr     ( s4_awaddr  ),
    .s4_awsize     ( s4_awsize  ),
    .s4_awlock     ( s4_awlock  ),
    .s4_awlen      ( s4_awlen   ),
    .s4_awvalid    ( s4_awvalid ),
    .s4_awready    ( s4_awready ),
    .s4_wstrb      ( s4_wstrb   ),
    .s4_wid        ( s4_wid     ),
    .s4_wdata      ( s4_wdata   ),
    .s4_wlast      ( s4_wlast   ),
    .s4_wvalid     ( s4_wvalid  ),
    .s4_wready     ( s4_wready  ),
    .s4_bid        ( s4_bid     ),
    .s4_bresp      ( s4_bresp   ),
    .s4_bvalid     ( s4_bvalid  ),
    .s4_bready     ( s4_bready  ),
    .s4_araddr     ( s4_araddr  ),
    .s4_arburst    ( s4_arburst ),
    .s4_arprot     ( s4_arprot  ),
    .s4_arcache    ( s4_arcache ),
    .s4_arsize     ( s4_arsize  ),
    .s4_arid       ( s4_arid    ),
    .s4_arlock     ( s4_arlock  ),
    .s4_arlen      ( s4_arlen   ),
    .s4_arvalid    ( s4_arvalid ),
    .s4_arready    ( s4_arready ),
    .s4_rdata      ( s4_rdata   ),
    .s4_rresp      ( s4_rresp   ),
    .s4_rid        ( s4_rid     ),
    .s4_rlast      ( s4_rlast   ),
    .s4_rvalid     ( s4_rvalid  ),
    .s4_rready     ( s4_rready  ),
    .m_awburst     ( i0_awburst ),
    .m_awprot      ( i0_awprot  ),
    .m_awid        ( i0_awid    ),
    .m_awcache     ( i0_awcache ),
    .m_awaddr      ( i0_awaddr  ),
    .m_awsize      ( i0_awsize  ),
    .m_awlock      ( i0_awlock  ),
    .m_awlen       ( i0_awlen   ),
    .m_awvalid     ( i0_awvalid ),
    .m_awready     ( i0_awready ),
    .m_wstrb       ( i0_wstrb   ),
    .m_wid         ( i0_wid     ),
    .m_wdata       ( i0_wdata   ),
    .m_wlast       ( i0_wlast   ),
    .m_wvalid      ( i0_wvalid  ),
    .m_wready      ( i0_wready  ),
    .m_bid         ( i0_bid     ),
    .m_bresp       ( i0_bresp   ),
    .m_bvalid      ( i0_bvalid  ),
    .m_bready      ( i0_bready  ),
    .m_araddr      ( i0_araddr  ),
    .m_arburst     ( i0_arburst ),
    .m_arprot      ( i0_arprot  ),
    .m_arcache     ( i0_arcache ),
    .m_arsize      ( i0_arsize  ),
    .m_arid        ( i0_arid    ),
    .m_arlock      ( i0_arlock  ),
    .m_arlen       ( i0_arlen   ),
    .m_arvalid     ( i0_arvalid ),
    .m_arready     ( i0_arready ),
    .m_rdata       ( i0_rdata   ),
    .m_rresp       ( i0_rresp   ),
    .m_rid         ( i0_rid     ),
    .m_rlast       ( i0_rlast   ),
    .m_rvalid      ( i0_rvalid  ),
    .m_rready      ( i0_rready  )
);

logic [ 66: 0] s_awpayload;
logic [ 49: 0] s_wpayload;
logic [ 14: 0] s_bpayload;
logic [ 66: 0] s_arpayload;
logic [ 47: 0] s_rpayload;
logic [ 66: 0] m_awpayload;
logic [ 49: 0] m_wpayload;
logic [ 14: 0] m_bpayload;
logic [ 66: 0] m_arpayload;
logic [ 47: 0] m_rpayload;

assign s_awpayload = {i0_awburst, i0_awprot, i0_awid, i0_awcache, i0_awaddr, i0_awsize, i0_awlock, i0_awlen};
assign s_wpayload  = {i0_wlast, i0_wstrb, i0_wid, i0_wdata};
assign {i0_bid, i0_bresp} = s_bpayload;
assign s_arpayload = {i0_araddr, i0_arburst, i0_arprot, i0_arcache, i0_arsize, i0_arid, i0_arlock, i0_arlen};
assign {i0_rlast, i0_rdata, i0_rresp, i0_rid} = s_rpayload;

assign {i1_awburst, i1_awprot, i1_awid, i1_awcache, i1_awaddr, i1_awsize, i1_awlock, i1_awlen} = m_awpayload;
assign {i1_wlast, i1_wstrb, i1_wid, i1_wdata} = m_wpayload;
assign m_bpayload = {i1_bid, i1_bresp};
assign {i1_araddr, i1_arburst, i1_arprot, i1_arcache, i1_arsize, i1_arid, i1_arlock, i1_arlen} = m_arpayload;
assign m_rpayload = {i1_rlast, i1_rdata, i1_rresp, i1_rid};

axi_slice u_axi_slice (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .s_awpayload   ( s_awpayload ),
    .s_awvalid     ( i0_awvalid ),
    .s_awready     ( i0_awready ),
    .s_wpayload    ( s_wpayload ),
    .s_wvalid      ( i0_wvalid  ),
    .s_wready      ( i0_wready  ),
    .s_bpayload    ( s_bpayload ),
    .s_bvalid      ( i0_bvalid  ),
    .s_bready      ( i0_bready  ),
    .s_arpayload   ( s_arpayload ),
    .s_arvalid     ( i0_arvalid ),
    .s_arready     ( i0_arready ),
    .s_rpayload    ( s_rpayload ),
    .s_rvalid      ( i0_rvalid  ),
    .s_rready      ( i0_rready  ),
    .m_awpayload   ( m_awpayload ),
    .m_awvalid     ( i1_awvalid ),
    .m_awready     ( i1_awready ),
    .m_wpayload    ( m_wpayload ),
    .m_wvalid      ( i1_wvalid  ),
    .m_wready      ( i1_wready  ),
    .m_bpayload    ( m_bpayload ),
    .m_bvalid      ( i1_bvalid  ),
    .m_bready      ( i1_bready  ),
    .m_arpayload   ( m_arpayload ),
    .m_arvalid     ( i1_arvalid ),
    .m_arready     ( i1_arready ),
    .m_rpayload    ( m_rpayload ),
    .m_rvalid      ( i1_rvalid  ),
    .m_rready      ( i1_rready  )
);

axi_1to5_dec u_dec (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .s_awburst     ( i1_awburst ),
    .s_awprot      ( i1_awprot  ),
    .s_awid        ( i1_awid    ),
    .s_awcache     ( i1_awcache ),
    .s_awaddr      ( i1_awaddr  ),
    .s_awsize      ( i1_awsize  ),
    .s_awlock      ( i1_awlock  ),
    .s_awlen       ( i1_awlen   ),
    .s_awvalid     ( i1_awvalid ),
    .s_awready     ( i1_awready ),
    .s_wstrb       ( i1_wstrb   ),
    .s_wid         ( i1_wid     ),
    .s_wdata       ( i1_wdata   ),
    .s_wlast       ( i1_wlast   ),
    .s_wvalid      ( i1_wvalid  ),
    .s_wready      ( i1_wready  ),
    .s_bid         ( i1_bid     ),
    .s_bresp       ( i1_bresp   ),
    .s_bvalid      ( i1_bvalid  ),
    .s_bready      ( i1_bready  ),
    .s_araddr      ( i1_araddr  ),
    .s_arburst     ( i1_arburst ),
    .s_arprot      ( i1_arprot  ),
    .s_arcache     ( i1_arcache ),
    .s_arsize      ( i1_arsize  ),
    .s_arid        ( i1_arid    ),
    .s_arlock      ( i1_arlock  ),
    .s_arlen       ( i1_arlen   ),
    .s_arvalid     ( i1_arvalid ),
    .s_arready     ( i1_arready ),
    .s_rdata       ( i1_rdata   ),
    .s_rresp       ( i1_rresp   ),
    .s_rid         ( i1_rid     ),
    .s_rlast       ( i1_rlast   ),
    .s_rvalid      ( i1_rvalid  ),
    .s_rready      ( i1_rready  ),
    .m0_awburst    ( m0_awburst ),
    .m0_awprot     ( m0_awprot  ),
    .m0_awid       ( m0_awid    ),
    .m0_awcache    ( m0_awcache ),
    .m0_awaddr     ( m0_awaddr  ),
    .m0_awsize     ( m0_awsize  ),
    .m0_awlock     ( m0_awlock  ),
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
    .m0_arprot     ( m0_arprot  ),
    .m0_arcache    ( m0_arcache ),
    .m0_arsize     ( m0_arsize  ),
    .m0_arid       ( m0_arid    ),
    .m0_arlock     ( m0_arlock  ),
    .m0_arlen      ( m0_arlen   ),
    .m0_arvalid    ( m0_arvalid ),
    .m0_arready    ( m0_arready ),
    .m0_rdata      ( m0_rdata   ),
    .m0_rresp      ( m0_rresp   ),
    .m0_rid        ( m0_rid     ),
    .m0_rlast      ( m0_rlast   ),
    .m0_rvalid     ( m0_rvalid  ),
    .m0_rready     ( m0_rready  ),
    .m1_awburst    ( m1_awburst ),
    .m1_awprot     ( m1_awprot  ),
    .m1_awid       ( m1_awid    ),
    .m1_awcache    ( m1_awcache ),
    .m1_awaddr     ( m1_awaddr  ),
    .m1_awsize     ( m1_awsize  ),
    .m1_awlock     ( m1_awlock  ),
    .m1_awlen      ( m1_awlen   ),
    .m1_awvalid    ( m1_awvalid ),
    .m1_awready    ( m1_awready ),
    .m1_wstrb      ( m1_wstrb   ),
    .m1_wid        ( m1_wid     ),
    .m1_wdata      ( m1_wdata   ),
    .m1_wlast      ( m1_wlast   ),
    .m1_wvalid     ( m1_wvalid  ),
    .m1_wready     ( m1_wready  ),
    .m1_bid        ( m1_bid     ),
    .m1_bresp      ( m1_bresp   ),
    .m1_bvalid     ( m1_bvalid  ),
    .m1_bready     ( m1_bready  ),
    .m1_araddr     ( m1_araddr  ),
    .m1_arburst    ( m1_arburst ),
    .m1_arprot     ( m1_arprot  ),
    .m1_arcache    ( m1_arcache ),
    .m1_arsize     ( m1_arsize  ),
    .m1_arid       ( m1_arid    ),
    .m1_arlock     ( m1_arlock  ),
    .m1_arlen      ( m1_arlen   ),
    .m1_arvalid    ( m1_arvalid ),
    .m1_arready    ( m1_arready ),
    .m1_rdata      ( m1_rdata   ),
    .m1_rresp      ( m1_rresp   ),
    .m1_rid        ( m1_rid     ),
    .m1_rlast      ( m1_rlast   ),
    .m1_rvalid     ( m1_rvalid  ),
    .m1_rready     ( m1_rready  ),
    .m2_awburst    ( m2_awburst ),
    .m2_awprot     ( m2_awprot  ),
    .m2_awid       ( m2_awid    ),
    .m2_awcache    ( m2_awcache ),
    .m2_awaddr     ( m2_awaddr  ),
    .m2_awsize     ( m2_awsize  ),
    .m2_awlock     ( m2_awlock  ),
    .m2_awlen      ( m2_awlen   ),
    .m2_awvalid    ( m2_awvalid ),
    .m2_awready    ( m2_awready ),
    .m2_wstrb      ( m2_wstrb   ),
    .m2_wid        ( m2_wid     ),
    .m2_wdata      ( m2_wdata   ),
    .m2_wlast      ( m2_wlast   ),
    .m2_wvalid     ( m2_wvalid  ),
    .m2_wready     ( m2_wready  ),
    .m2_bid        ( m2_bid     ),
    .m2_bresp      ( m2_bresp   ),
    .m2_bvalid     ( m2_bvalid  ),
    .m2_bready     ( m2_bready  ),
    .m2_araddr     ( m2_araddr  ),
    .m2_arburst    ( m2_arburst ),
    .m2_arprot     ( m2_arprot  ),
    .m2_arcache    ( m2_arcache ),
    .m2_arsize     ( m2_arsize  ),
    .m2_arid       ( m2_arid    ),
    .m2_arlock     ( m2_arlock  ),
    .m2_arlen      ( m2_arlen   ),
    .m2_arvalid    ( m2_arvalid ),
    .m2_arready    ( m2_arready ),
    .m2_rdata      ( m2_rdata   ),
    .m2_rresp      ( m2_rresp   ),
    .m2_rid        ( m2_rid     ),
    .m2_rlast      ( m2_rlast   ),
    .m2_rvalid     ( m2_rvalid  ),
    .m2_rready     ( m2_rready  ),
    .m3_awburst    ( m3_awburst ),
    .m3_awprot     ( m3_awprot  ),
    .m3_awid       ( m3_awid    ),
    .m3_awcache    ( m3_awcache ),
    .m3_awaddr     ( m3_awaddr  ),
    .m3_awsize     ( m3_awsize  ),
    .m3_awlock     ( m3_awlock  ),
    .m3_awlen      ( m3_awlen   ),
    .m3_awvalid    ( m3_awvalid ),
    .m3_awready    ( m3_awready ),
    .m3_wstrb      ( m3_wstrb   ),
    .m3_wid        ( m3_wid     ),
    .m3_wdata      ( m3_wdata   ),
    .m3_wlast      ( m3_wlast   ),
    .m3_wvalid     ( m3_wvalid  ),
    .m3_wready     ( m3_wready  ),
    .m3_bid        ( m3_bid     ),
    .m3_bresp      ( m3_bresp   ),
    .m3_bvalid     ( m3_bvalid  ),
    .m3_bready     ( m3_bready  ),
    .m3_araddr     ( m3_araddr  ),
    .m3_arburst    ( m3_arburst ),
    .m3_arprot     ( m3_arprot  ),
    .m3_arcache    ( m3_arcache ),
    .m3_arsize     ( m3_arsize  ),
    .m3_arid       ( m3_arid    ),
    .m3_arlock     ( m3_arlock  ),
    .m3_arlen      ( m3_arlen   ),
    .m3_arvalid    ( m3_arvalid ),
    .m3_arready    ( m3_arready ),
    .m3_rdata      ( m3_rdata   ),
    .m3_rresp      ( m3_rresp   ),
    .m3_rid        ( m3_rid     ),
    .m3_rlast      ( m3_rlast   ),
    .m3_rvalid     ( m3_rvalid  ),
    .m3_rready     ( m3_rready  ),
    .m4_awburst    ( m4_awburst ),
    .m4_awprot     ( m4_awprot  ),
    .m4_awid       ( m4_awid    ),
    .m4_awcache    ( m4_awcache ),
    .m4_awaddr     ( m4_awaddr  ),
    .m4_awsize     ( m4_awsize  ),
    .m4_awlock     ( m4_awlock  ),
    .m4_awlen      ( m4_awlen   ),
    .m4_awvalid    ( m4_awvalid ),
    .m4_awready    ( m4_awready ),
    .m4_wstrb      ( m4_wstrb   ),
    .m4_wid        ( m4_wid     ),
    .m4_wdata      ( m4_wdata   ),
    .m4_wlast      ( m4_wlast   ),
    .m4_wvalid     ( m4_wvalid  ),
    .m4_wready     ( m4_wready  ),
    .m4_bid        ( m4_bid     ),
    .m4_bresp      ( m4_bresp   ),
    .m4_bvalid     ( m4_bvalid  ),
    .m4_bready     ( m4_bready  ),
    .m4_araddr     ( m4_araddr  ),
    .m4_arburst    ( m4_arburst ),
    .m4_arprot     ( m4_arprot  ),
    .m4_arcache    ( m4_arcache ),
    .m4_arsize     ( m4_arsize  ),
    .m4_arid       ( m4_arid    ),
    .m4_arlock     ( m4_arlock  ),
    .m4_arlen      ( m4_arlen   ),
    .m4_arvalid    ( m4_arvalid ),
    .m4_arready    ( m4_arready ),
    .m4_rdata      ( m4_rdata   ),
    .m4_rresp      ( m4_rresp   ),
    .m4_rid        ( m4_rid     ),
    .m4_rlast      ( m4_rlast   ),
    .m4_rvalid     ( m4_rvalid  ),
    .m4_rready     ( m4_rready  )
);

endmodule
