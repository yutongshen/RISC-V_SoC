/*-----------------------------------------------------*/
// axi_5to1_mux.sv is generated by gen_axi_mux.sh
//
//                                         2022-03-06
//                                           20:59:48
/*-----------------------------------------------------*/

module axi_5to1_mux (
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
    output logic  [  1: 0] m_awburst,
    output logic  [  2: 0] m_awprot,
    output logic  [ 12: 0] m_awid,
    output logic  [  3: 0] m_awcache,
    output logic  [ 31: 0] m_awaddr,
    output logic  [  2: 0] m_awsize,
    output logic  [  1: 0] m_awlock,
    output logic  [  7: 0] m_awlen,
    output logic           m_awvalid,
    input                  m_awready,
    output logic  [  3: 0] m_wstrb,
    output logic  [ 12: 0] m_wid,
    output logic  [ 31: 0] m_wdata,
    output logic           m_wlast,
    output logic           m_wvalid,
    input                  m_wready,
    input         [ 12: 0] m_bid,
    input         [  1: 0] m_bresp,
    input                  m_bvalid,
    output logic           m_bready,
    output logic  [ 31: 0] m_araddr,
    output logic  [  1: 0] m_arburst,
    output logic  [  2: 0] m_arprot,
    output logic  [  3: 0] m_arcache,
    output logic  [  2: 0] m_arsize,
    output logic  [ 12: 0] m_arid,
    output logic  [  1: 0] m_arlock,
    output logic  [  7: 0] m_arlen,
    output logic           m_arvalid,
    input                  m_arready,
    input         [ 31: 0] m_rdata,
    input         [  1: 0] m_rresp,
    input         [ 12: 0] m_rid,
    input                  m_rlast,
    input                  m_rvalid,
    output logic           m_rready
);

logic [  1: 0] s_awburst  [0:   4];
logic [  2: 0] s_awprot   [0:   4];
logic [  9: 0] s_awid     [0:   4];
logic [  3: 0] s_awcache  [0:   4];
logic [ 31: 0] s_awaddr   [0:   4];
logic [  2: 0] s_awsize   [0:   4];
logic [  1: 0] s_awlock   [0:   4];
logic [  7: 0] s_awlen    [0:   4];
logic [  3: 0] s_wstrb    [0:   4];
logic [  9: 0] s_wid      [0:   4];
logic [ 31: 0] s_wdata    [0:   4];
logic [  9: 0] s_bid      [0:   4];
logic [  1: 0] s_bresp    [0:   4];
logic [ 31: 0] s_araddr   [0:   4];
logic [  1: 0] s_arburst  [0:   4];
logic [  2: 0] s_arprot   [0:   4];
logic [  3: 0] s_arcache  [0:   4];
logic [  2: 0] s_arsize   [0:   4];
logic [  9: 0] s_arid     [0:   4];
logic [  1: 0] s_arlock   [0:   4];
logic [  7: 0] s_arlen    [0:   4];
logic [ 31: 0] s_rdata    [0:   4];
logic [  1: 0] s_rresp    [0:   4];
logic [  9: 0] s_rid      [0:   4];

logic [  4: 0] s_arsel;
logic [  4: 0] s_awsel;
logic [  4: 0] s_wsel;

logic [  4: 0] s_arvalid;
logic [  4: 0] s_arready;
logic [  4: 0] s_rlast;
logic [  4: 0] s_rvalid;
logic [  4: 0] s_rready;
logic [  4: 0] s_awvalid;
logic [  4: 0] s_awready;
logic [  4: 0] s_wlast;
logic [  4: 0] s_wvalid;
logic [  4: 0] s_wready;
logic [  4: 0] s_bvalid;
logic [  4: 0] s_bready;

assign s_awburst [0] = s0_awburst;
assign s_awprot  [0] = s0_awprot;
assign s_awid    [0] = s0_awid;
assign s_awcache [0] = s0_awcache;
assign s_awaddr  [0] = s0_awaddr;
assign s_awsize  [0] = s0_awsize;
assign s_awlock  [0] = s0_awlock;
assign s_awlen   [0] = s0_awlen;
assign s_wstrb   [0] = s0_wstrb;
assign s_wid     [0] = s0_wid;
assign s_wdata   [0] = s0_wdata;
assign s_araddr  [0] = s0_araddr;
assign s_arburst [0] = s0_arburst;
assign s_arprot  [0] = s0_arprot;
assign s_arcache [0] = s0_arcache;
assign s_arsize  [0] = s0_arsize;
assign s_arid    [0] = s0_arid;
assign s_arlock  [0] = s0_arlock;
assign s_arlen   [0] = s0_arlen;
assign s_awburst [1] = s1_awburst;
assign s_awprot  [1] = s1_awprot;
assign s_awid    [1] = s1_awid;
assign s_awcache [1] = s1_awcache;
assign s_awaddr  [1] = s1_awaddr;
assign s_awsize  [1] = s1_awsize;
assign s_awlock  [1] = s1_awlock;
assign s_awlen   [1] = s1_awlen;
assign s_wstrb   [1] = s1_wstrb;
assign s_wid     [1] = s1_wid;
assign s_wdata   [1] = s1_wdata;
assign s_araddr  [1] = s1_araddr;
assign s_arburst [1] = s1_arburst;
assign s_arprot  [1] = s1_arprot;
assign s_arcache [1] = s1_arcache;
assign s_arsize  [1] = s1_arsize;
assign s_arid    [1] = s1_arid;
assign s_arlock  [1] = s1_arlock;
assign s_arlen   [1] = s1_arlen;
assign s_awburst [2] = s2_awburst;
assign s_awprot  [2] = s2_awprot;
assign s_awid    [2] = s2_awid;
assign s_awcache [2] = s2_awcache;
assign s_awaddr  [2] = s2_awaddr;
assign s_awsize  [2] = s2_awsize;
assign s_awlock  [2] = s2_awlock;
assign s_awlen   [2] = s2_awlen;
assign s_wstrb   [2] = s2_wstrb;
assign s_wid     [2] = s2_wid;
assign s_wdata   [2] = s2_wdata;
assign s_araddr  [2] = s2_araddr;
assign s_arburst [2] = s2_arburst;
assign s_arprot  [2] = s2_arprot;
assign s_arcache [2] = s2_arcache;
assign s_arsize  [2] = s2_arsize;
assign s_arid    [2] = s2_arid;
assign s_arlock  [2] = s2_arlock;
assign s_arlen   [2] = s2_arlen;
assign s_awburst [3] = s3_awburst;
assign s_awprot  [3] = s3_awprot;
assign s_awid    [3] = s3_awid;
assign s_awcache [3] = s3_awcache;
assign s_awaddr  [3] = s3_awaddr;
assign s_awsize  [3] = s3_awsize;
assign s_awlock  [3] = s3_awlock;
assign s_awlen   [3] = s3_awlen;
assign s_wstrb   [3] = s3_wstrb;
assign s_wid     [3] = s3_wid;
assign s_wdata   [3] = s3_wdata;
assign s_araddr  [3] = s3_araddr;
assign s_arburst [3] = s3_arburst;
assign s_arprot  [3] = s3_arprot;
assign s_arcache [3] = s3_arcache;
assign s_arsize  [3] = s3_arsize;
assign s_arid    [3] = s3_arid;
assign s_arlock  [3] = s3_arlock;
assign s_arlen   [3] = s3_arlen;
assign s_awburst [4] = s4_awburst;
assign s_awprot  [4] = s4_awprot;
assign s_awid    [4] = s4_awid;
assign s_awcache [4] = s4_awcache;
assign s_awaddr  [4] = s4_awaddr;
assign s_awsize  [4] = s4_awsize;
assign s_awlock  [4] = s4_awlock;
assign s_awlen   [4] = s4_awlen;
assign s_wstrb   [4] = s4_wstrb;
assign s_wid     [4] = s4_wid;
assign s_wdata   [4] = s4_wdata;
assign s_araddr  [4] = s4_araddr;
assign s_arburst [4] = s4_arburst;
assign s_arprot  [4] = s4_arprot;
assign s_arcache [4] = s4_arcache;
assign s_arsize  [4] = s4_arsize;
assign s_arid    [4] = s4_arid;
assign s_arlock  [4] = s4_arlock;
assign s_arlen   [4] = s4_arlen;

assign s0_bid     = s_bid     [0];
assign s0_bresp   = s_bresp   [0];
assign s0_rdata   = s_rdata   [0];
assign s0_rresp   = s_rresp   [0];
assign s0_rid     = s_rid     [0];
assign s1_bid     = s_bid     [1];
assign s1_bresp   = s_bresp   [1];
assign s1_rdata   = s_rdata   [1];
assign s1_rresp   = s_rresp   [1];
assign s1_rid     = s_rid     [1];
assign s2_bid     = s_bid     [2];
assign s2_bresp   = s_bresp   [2];
assign s2_rdata   = s_rdata   [2];
assign s2_rresp   = s_rresp   [2];
assign s2_rid     = s_rid     [2];
assign s3_bid     = s_bid     [3];
assign s3_bresp   = s_bresp   [3];
assign s3_rdata   = s_rdata   [3];
assign s3_rresp   = s_rresp   [3];
assign s3_rid     = s_rid     [3];
assign s4_bid     = s_bid     [4];
assign s4_bresp   = s_bresp   [4];
assign s4_rdata   = s_rdata   [4];
assign s4_rresp   = s_rresp   [4];
assign s4_rid     = s_rid     [4];

assign s_arvalid [0] = s0_arvalid;
assign s_awvalid [0] = s0_awvalid;
assign s_wvalid  [0] = s0_wvalid;
assign s_wlast   [0] = s0_wlast;
assign s_bready  [0] = s0_bready;
assign s_rready  [0] = s0_rready;
assign s_arvalid [1] = s1_arvalid;
assign s_awvalid [1] = s1_awvalid;
assign s_wvalid  [1] = s1_wvalid;
assign s_wlast   [1] = s1_wlast;
assign s_bready  [1] = s1_bready;
assign s_rready  [1] = s1_rready;
assign s_arvalid [2] = s2_arvalid;
assign s_awvalid [2] = s2_awvalid;
assign s_wvalid  [2] = s2_wvalid;
assign s_wlast   [2] = s2_wlast;
assign s_bready  [2] = s2_bready;
assign s_rready  [2] = s2_rready;
assign s_arvalid [3] = s3_arvalid;
assign s_awvalid [3] = s3_awvalid;
assign s_wvalid  [3] = s3_wvalid;
assign s_wlast   [3] = s3_wlast;
assign s_bready  [3] = s3_bready;
assign s_rready  [3] = s3_rready;
assign s_arvalid [4] = s4_arvalid;
assign s_awvalid [4] = s4_awvalid;
assign s_wvalid  [4] = s4_wvalid;
assign s_wlast   [4] = s4_wlast;
assign s_bready  [4] = s4_bready;
assign s_rready  [4] = s4_rready;

assign s0_arready = s_arready [0];
assign s0_awready = s_awready [0];
assign s0_wready  = s_wready  [0];
assign s0_bvalid  = s_bvalid  [0];
assign s0_rlast   = s_rlast   [0];
assign s0_rvalid  = s_rvalid  [0];
assign s1_arready = s_arready [1];
assign s1_awready = s_awready [1];
assign s1_wready  = s_wready  [1];
assign s1_bvalid  = s_bvalid  [1];
assign s1_rlast   = s_rlast   [1];
assign s1_rvalid  = s_rvalid  [1];
assign s2_arready = s_arready [2];
assign s2_awready = s_awready [2];
assign s2_wready  = s_wready  [2];
assign s2_bvalid  = s_bvalid  [2];
assign s2_rlast   = s_rlast   [2];
assign s2_rvalid  = s_rvalid  [2];
assign s3_arready = s_arready [3];
assign s3_awready = s_awready [3];
assign s3_wready  = s_wready  [3];
assign s3_bvalid  = s_bvalid  [3];
assign s3_rlast   = s_rlast   [3];
assign s3_rvalid  = s_rvalid  [3];
assign s4_arready = s_arready [4];
assign s4_awready = s_awready [4];
assign s4_wready  = s_wready  [4];
assign s4_bvalid  = s_bvalid  [4];
assign s4_rlast   = s_rlast   [4];
assign s4_rvalid  = s_rvalid  [4];

axi_arbitrator_5s u_axi_arbitrator (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .s_arsel       ( s_arsel    ),
    .s_awsel       ( s_awsel    ),
    .s_wsel        ( s_wsel     ),
    .s_arvalid     ( s_arvalid  ),
    .s_arready     ( s_arready  ),
    .s_awvalid     ( s_awvalid  ),
    .s_awready     ( s_awready  ),
    .s_wlast       ( s_wlast    ),
    .s_wvalid      ( s_wvalid   ),
    .s_wready      ( s_wready   ),
    .m_arvalid     ( m_arvalid  ),
    .m_arready     ( m_arready  ),
    .m_awvalid     ( m_awvalid  ),
    .m_awready     ( m_awready  ),
    .m_wlast       ( m_wlast    ),
    .m_wvalid      ( m_wvalid   ),
    .m_wready      ( m_wready   )
);

always_comb begin
    integer i;

    m_awburst  = {          2{1'b0}};
    m_awprot   = {          3{1'b0}};
    m_awid     = {( 10 +   3){1'b0}};
    m_awcache  = {          4{1'b0}};
    m_awaddr   = {         32{1'b0}};
    m_awsize   = {          3{1'b0}};
    m_awlock   = {          2{1'b0}};
    m_awlen    = {          8{1'b0}};
    for (i = 0; i < 5; i = i + 1) begin
        m_awburst            = m_awburst        | ({  2{s_awsel[i]}} & s_awburst [i]);
        m_awprot             = m_awprot         | ({  3{s_awsel[i]}} & s_awprot  [i]);
        m_awid    [  0+:  3] = m_awid[  0+:  3] | ({  3{s_awsel[i]}} & i[0+:3]      );
        m_awid    [  3+: 10] = m_awid[  3+: 10] | ({ 10{s_awsel[i]}} & s_awid    [i]);
        m_awcache            = m_awcache        | ({  4{s_awsel[i]}} & s_awcache [i]);
        m_awaddr             = m_awaddr         | ({ 32{s_awsel[i]}} & s_awaddr  [i]);
        m_awsize             = m_awsize         | ({  3{s_awsel[i]}} & s_awsize  [i]);
        m_awlock             = m_awlock         | ({  2{s_awsel[i]}} & s_awlock  [i]);
        m_awlen              = m_awlen          | ({  8{s_awsel[i]}} & s_awlen   [i]);
    end

    m_wstrb    = {          4{1'b0}};
    m_wid      = {( 10 +   3){1'b0}};
    m_wdata    = {         32{1'b0}};
    for (i = 0; i < 5; i = i + 1) begin
        m_wstrb              = m_wstrb          | ({  4{s_wsel[i]}} & s_wstrb   [i]);
        m_wid     [  0+:  3] = m_wid [  0+:  3] | ({  3{s_wsel[i]}} & i[0+:3]      );
        m_wid     [  3+: 10] = m_wid [  3+: 10] | ({ 10{s_wsel[i]}} & s_wid     [i]);
        m_wdata              = m_wdata          | ({ 32{s_wsel[i]}} & s_wdata   [i]);
    end

    m_araddr   = {         32{1'b0}};
    m_arburst  = {          2{1'b0}};
    m_arprot   = {          3{1'b0}};
    m_arcache  = {          4{1'b0}};
    m_arsize   = {          3{1'b0}};
    m_arid     = {( 10 +   3){1'b0}};
    m_arlock   = {          2{1'b0}};
    m_arlen    = {          8{1'b0}};
    for (i = 0; i < 5; i = i + 1) begin
        m_araddr             = m_araddr         | ({ 32{s_arsel[i]}} & s_araddr  [i]);
        m_arburst            = m_arburst        | ({  2{s_arsel[i]}} & s_arburst [i]);
        m_arprot             = m_arprot         | ({  3{s_arsel[i]}} & s_arprot  [i]);
        m_arcache            = m_arcache        | ({  4{s_arsel[i]}} & s_arcache [i]);
        m_arsize             = m_arsize         | ({  3{s_arsel[i]}} & s_arsize  [i]);
        m_arid    [  0+:  3] = m_arid[  0+:  3] | ({  3{s_arsel[i]}} & i[0+:3]      );
        m_arid    [  3+: 10] = m_arid[  3+: 10] | ({ 10{s_arsel[i]}} & s_arid    [i]);
        m_arlock             = m_arlock         | ({  2{s_arsel[i]}} & s_arlock  [i]);
        m_arlen              = m_arlen          | ({  8{s_arsel[i]}} & s_arlen   [i]);
    end
end

logic [  2: 0] bsel;
logic [  2: 0] rsel;

always_comb begin
    integer i;

    for (i = 0; i < 5; i = i + 1) begin
        s_bid     [i] = { 10{bsel == i[0+:  3]}} & m_bid[  3+: 10];
        s_bresp   [i] = {  2{bsel == i[0+:  3]}} & m_bresp;
        s_bvalid  [i] = {  1{bsel == i[0+:  3]}} & m_bvalid;

        s_rdata   [i] = { 32{rsel == i[0+:  3]}} & m_rdata;
        s_rresp   [i] = {  2{rsel == i[0+:  3]}} & m_rresp;
        s_rid     [i] = { 10{rsel == i[0+:  3]}} & m_rid[  3+: 10];
        s_rlast   [i] = {  1{rsel == i[0+:  3]}} & m_rlast;
        s_rvalid  [i] = {  1{rsel == i[0+:  3]}} & m_rvalid;
    end
end

assign bsel = m_bid[  0+:  3];
assign rsel = m_rid[  0+:  3];

assign m_bready = s_bready[bsel];
assign m_rready = s_rready[rsel];

endmodule

module axi_arbitrator_5s (
    input                  aclk,
    input                  aresetn,
    output logic  [  4: 0] s_arsel,
    output logic  [  4: 0] s_awsel,
    output logic  [  4: 0] s_wsel,
    input         [  4: 0] s_arvalid,
    output logic  [  4: 0] s_arready,
    input         [  4: 0] s_awvalid,
    output logic  [  4: 0] s_awready,
    input         [  4: 0] s_wlast,
    input         [  4: 0] s_wvalid,
    output logic  [  4: 0] s_wready,
    output logic           m_arvalid,
    input                  m_arready,
    output logic           m_awvalid,
    input                  m_awready,
    output logic           m_wlast,
    output logic           m_wvalid,
    input                  m_wready
);

parameter SLV_NUM = 5;

// AR arbitrator
logic [SLV_NUM - 1:0] ar_prior;
logic [SLV_NUM - 1:0] ar_prior_nxt;

assign ar_prior_nxt = {ar_prior[SLV_NUM - 2:0], ar_prior[SLV_NUM - 1]};

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        ar_prior <= {{(SLV_NUM-1){1'b0}}, 1'b1};
    end
    else begin
        if (m_arvalid & m_arready) begin
            ar_prior <= ar_prior_nxt;
        end
    end
end

logic [SLV_NUM - 1:0] ar_grant_matrix [0:SLV_NUM - 1];

always_comb begin
    integer i, j, k;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        ar_grant_matrix[i] = ar_prior;
        for (j = 0; j < SLV_NUM - 1; j = j + 1) begin
            for (k = 1; k < SLV_NUM - j; k = k + 1) begin
                ar_grant_matrix[i][(i + j + 1) % SLV_NUM] = ar_grant_matrix[i][(i + j + 1) % SLV_NUM] &
                                                            ~s_arvalid[(i - k + SLV_NUM) % SLV_NUM];
            end
        end
    end
end

always_comb begin
    integer i;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        s_arready[i]  = s_arvalid[i] & (|ar_grant_matrix[i]) & m_arready;
        s_arsel  [i]  = s_arvalid[i] & (|ar_grant_matrix[i]);
    end
end

assign m_arvalid = |s_arvalid;

// AW arbitrator
logic [SLV_NUM - 1:0] aw_prior;
logic [SLV_NUM - 1:0] aw_prior_nxt;

assign aw_prior_nxt = {aw_prior[SLV_NUM - 2:0], aw_prior[SLV_NUM - 1]};

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        aw_prior <= {{(SLV_NUM-1){1'b0}}, 1'b1};
    end
    else begin
        if (m_wlast & m_wvalid & m_wready) begin
            aw_prior <= aw_prior_nxt;
        end
    end
end
logic [SLV_NUM - 1:0] aw_grant_matrix [0:SLV_NUM - 1];

always_comb begin
    integer i, j, k;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        aw_grant_matrix[i] = aw_prior;
        for (j = 0; j < SLV_NUM - 1; j = j + 1) begin
            for (k = 1; k < SLV_NUM - j; k = k + 1) begin
                aw_grant_matrix[i][(i + j + 1) % SLV_NUM] =  aw_grant_matrix[i][(i + j + 1) % SLV_NUM] &
                                                            ~s_awvalid[(i - k + SLV_NUM) % SLV_NUM];
            end
        end
    end
end

always_comb begin
    integer i;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        s_awready[i]  = s_awvalid[i] & (|aw_grant_matrix[i]) & ~|s_wsel & m_awready;
        s_awsel  [i]  = s_awvalid[i] & (|aw_grant_matrix[i]);
    end
end

assign m_awvalid = |s_awvalid & ~|s_wsel;

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_wsel <= {SLV_NUM{1'b0}};
    end
    else begin
        if (m_wready & m_wvalid & m_wlast) begin
            s_wsel <= {SLV_NUM{1'b0}};
        end
        else if (~|s_wsel & m_awvalid & m_awready) begin
            s_wsel <= s_awready;
        end
    end
end

assign s_wready = s_wsel & {SLV_NUM{m_wready}};

assign m_wvalid = |(s_wsel & s_wvalid);
assign m_wlast  = |(s_wsel & s_wlast);

endmodule
