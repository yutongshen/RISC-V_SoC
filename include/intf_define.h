`ifndef __INTF_DEFINE__
`define __INTF_DEFINE__

`define AXI_INTF_CONNECT(PORT, WIRE) \
    .``PORT``_awburst ( WIRE``_awburst ), \
    .``PORT``_awid    ( WIRE``_awid    ), \
    .``PORT``_awaddr  ( WIRE``_awaddr  ), \
    .``PORT``_awsize  ( WIRE``_awsize  ), \
    .``PORT``_awlen   ( WIRE``_awlen   ), \
    .``PORT``_awlock  ( WIRE``_awlock  ), \
    .``PORT``_awcache ( WIRE``_awcache ), \
    .``PORT``_awprot  ( WIRE``_awprot  ), \
    .``PORT``_awvalid ( WIRE``_awvalid ), \
    .``PORT``_awready ( WIRE``_awready ), \
    .``PORT``_wstrb   ( WIRE``_wstrb   ), \
    .``PORT``_wid     ( WIRE``_wid     ), \
    .``PORT``_wdata   ( WIRE``_wdata   ), \
    .``PORT``_wlast   ( WIRE``_wlast   ), \
    .``PORT``_wvalid  ( WIRE``_wvalid  ), \
    .``PORT``_wready  ( WIRE``_wready  ), \
    .``PORT``_bid     ( WIRE``_bid     ), \
    .``PORT``_bresp   ( WIRE``_bresp   ), \
    .``PORT``_bvalid  ( WIRE``_bvalid  ), \
    .``PORT``_bready  ( WIRE``_bready  ), \
    .``PORT``_araddr  ( WIRE``_araddr  ), \
    .``PORT``_arburst ( WIRE``_arburst ), \
    .``PORT``_arsize  ( WIRE``_arsize  ), \
    .``PORT``_arid    ( WIRE``_arid    ), \
    .``PORT``_arlen   ( WIRE``_arlen   ), \
    .``PORT``_arlock  ( WIRE``_arlock  ), \
    .``PORT``_arcache ( WIRE``_arcache ), \
    .``PORT``_arprot  ( WIRE``_arprot  ), \
    .``PORT``_arvalid ( WIRE``_arvalid ), \
    .``PORT``_arready ( WIRE``_arready ), \
    .``PORT``_rdata   ( WIRE``_rdata   ), \
    .``PORT``_rresp   ( WIRE``_rresp   ), \
    .``PORT``_rid     ( WIRE``_rid     ), \
    .``PORT``_rlast   ( WIRE``_rlast   ), \
    .``PORT``_rvalid  ( WIRE``_rvalid  ), \
    .``PORT``_rready  ( WIRE``_rready  )

`define AXI_INTF_SLV_DEF(NAME, ID) \
    input         [     1: 0] NAME``_awburst, \
    input         [ID - 1: 0] NAME``_awid,    \
    input         [    31: 0] NAME``_awaddr,  \
    input         [     2: 0] NAME``_awsize,  \
    input         [     7: 0] NAME``_awlen,   \
    input         [     1: 0] NAME``_awlock,  \
    input         [     3: 0] NAME``_awcache, \
    input         [     2: 0] NAME``_awprot,  \
    input                     NAME``_awvalid, \
    output logic              NAME``_awready, \
    input         [     3: 0] NAME``_wstrb,   \
    input         [ID - 1: 0] NAME``_wid,     \
    input         [    31: 0] NAME``_wdata,   \
    input                     NAME``_wlast,   \
    input                     NAME``_wvalid,  \
    output logic              NAME``_wready,  \
    output logic  [ID - 1: 0] NAME``_bid,     \
    output logic  [     1: 0] NAME``_bresp,   \
    output logic              NAME``_bvalid,  \
    input                     NAME``_bready,  \
    input         [    31: 0] NAME``_araddr,  \
    input         [     1: 0] NAME``_arburst, \
    input         [     2: 0] NAME``_arsize,  \
    input         [ID - 1: 0] NAME``_arid,    \
    input         [     7: 0] NAME``_arlen,   \
    input         [     1: 0] NAME``_arlock,  \
    input         [     3: 0] NAME``_arcache, \
    input         [     2: 0] NAME``_arprot,  \
    input                     NAME``_arvalid, \
    output logic              NAME``_arready, \
    output logic  [    31: 0] NAME``_rdata,   \
    output logic  [     1: 0] NAME``_rresp,   \
    output logic  [ID - 1: 0] NAME``_rid,     \
    output logic              NAME``_rlast,   \
    output logic              NAME``_rvalid,  \
    input                     NAME``_rready

`define AXI_INTF_MST_DEF(NAME, ID) \
    output logic  [     1: 0] NAME``_awburst, \
    output logic  [ID - 1: 0] NAME``_awid,    \
    output logic  [    31: 0] NAME``_awaddr,  \
    output logic  [     2: 0] NAME``_awsize,  \
    output logic  [     7: 0] NAME``_awlen,   \
    output logic  [     1: 0] NAME``_awlock,  \
    output logic  [     3: 0] NAME``_awcache, \
    output logic  [     2: 0] NAME``_awprot,  \
    output logic              NAME``_awvalid, \
    input                     NAME``_awready, \
    output logic  [     3: 0] NAME``_wstrb,   \
    output logic  [ID - 1: 0] NAME``_wid,     \
    output logic  [    31: 0] NAME``_wdata,   \
    output logic              NAME``_wlast,   \
    output logic              NAME``_wvalid,  \
    input                     NAME``_wready,  \
    input         [ID - 1: 0] NAME``_bid,     \
    input         [     1: 0] NAME``_bresp,   \
    input                     NAME``_bvalid,  \
    output logic              NAME``_bready,  \
    output logic  [    31: 0] NAME``_araddr,  \
    output logic  [     1: 0] NAME``_arburst, \
    output logic  [     2: 0] NAME``_arsize,  \
    output logic  [ID - 1: 0] NAME``_arid,    \
    output logic  [     7: 0] NAME``_arlen,   \
    output logic  [     1: 0] NAME``_arlock,  \
    output logic  [     3: 0] NAME``_arcache, \
    output logic  [     2: 0] NAME``_arprot,  \
    output logic              NAME``_arvalid, \
    input                     NAME``_arready, \
    input         [    31: 0] NAME``_rdata,   \
    input         [     1: 0] NAME``_rresp,   \
    input         [ID - 1: 0] NAME``_rid,     \
    input                     NAME``_rlast,   \
    input                     NAME``_rvalid,  \
    output logic              NAME``_rready

`define AXI_INTF_DEF(NAME, ID) \
    logic  [     1: 0] NAME``_awburst; \
    logic  [ID - 1: 0] NAME``_awid;    \
    logic  [    31: 0] NAME``_awaddr;  \
    logic  [     2: 0] NAME``_awsize;  \
    logic  [     7: 0] NAME``_awlen;   \
    logic  [     1: 0] NAME``_awlock;  \
    logic  [     3: 0] NAME``_awcache; \
    logic  [     2: 0] NAME``_awprot;  \
    logic              NAME``_awvalid; \
    logic              NAME``_awready; \
    logic  [     3: 0] NAME``_wstrb;   \
    logic  [ID - 1: 0] NAME``_wid;     \
    logic  [    31: 0] NAME``_wdata;   \
    logic              NAME``_wlast;   \
    logic              NAME``_wvalid;  \
    logic              NAME``_wready;  \
    logic  [ID - 1: 0] NAME``_bid;     \
    logic  [     1: 0] NAME``_bresp;   \
    logic              NAME``_bvalid;  \
    logic              NAME``_bready;  \
    logic  [    31: 0] NAME``_araddr;  \
    logic  [     1: 0] NAME``_arburst; \
    logic  [     2: 0] NAME``_arsize;  \
    logic  [ID - 1: 0] NAME``_arid;    \
    logic  [     7: 0] NAME``_arlen;   \
    logic  [     1: 0] NAME``_arlock;  \
    logic  [     3: 0] NAME``_arcache; \
    logic  [     2: 0] NAME``_arprot;  \
    logic              NAME``_arvalid; \
    logic              NAME``_arready; \
    logic  [    31: 0] NAME``_rdata;   \
    logic  [     1: 0] NAME``_rresp;   \
    logic  [ID - 1: 0] NAME``_rid;     \
    logic              NAME``_rlast;   \
    logic              NAME``_rvalid;  \
    logic              NAME``_rready;

`define APB_MST_PORT_TO_INTF(PORT, INTF)    \
    assign INTF``.psel    = PORT``_psel;    \
    assign INTF``.penable = PORT``_penable; \
    assign INTF``.paddr   = PORT``_paddr;   \
    assign INTF``.pwrite  = PORT``_pwrite;  \
    assign INTF``.pstrb   = PORT``_pstrb;   \
    assign INTF``.pprot   = PORT``_pprot;   \
    assign INTF``.pwdata  = PORT``_pwdata;  \
    assign PORT``_prdata  = INTF``.prdata;  \
    assign PORT``_pslverr = INTF``.pslverr; \
    assign PORT``_pready  = INTF``.pready;

`define APB_MST_INTF_TO_PORT(INTF, PORT)    \
    assign PORT``_psel    = INTF``.psel;    \
    assign PORT``_penable = INTF``.penable; \
    assign PORT``_paddr   = INTF``.paddr;   \
    assign PORT``_pwrite  = INTF``.pwrite;  \
    assign PORT``_pstrb   = INTF``.pstrb;   \
    assign PORT``_pprot   = INTF``.pprot;   \
    assign PORT``_pwdata  = INTF``.pwdata;  \
    assign INTF``.prdata  = PORT``_prdata;  \
    assign INTF``.pslverr = PORT``_pslverr; \
    assign INTF``.pready  = PORT``_pready;

`define AXI_MST_PORT_TO_INTF(PORT, INTF)    \
    assign INTF``.awid    = PORT``_awid;    \
    assign INTF``.awaddr  = PORT``_awaddr;  \
    assign INTF``.awburst = PORT``_awburst; \
    assign INTF``.awsize  = PORT``_awsize;  \
    assign INTF``.awlen   = PORT``_awlen;   \
    assign INTF``.awlock  = PORT``_awlock;  \
    assign INTF``.awcache = PORT``_awcache; \
    assign INTF``.awprot  = PORT``_awprot;  \
    assign INTF``.awvalid = PORT``_awvalid; \
    assign PORT``_awready = INTF``.awready; \
    assign INTF``.wid     = PORT``_wid;     \
    assign INTF``.wstrb   = PORT``_wstrb;   \
    assign INTF``.wdata   = PORT``_wdata;   \
    assign INTF``.wlast   = PORT``_wlast;   \
    assign INTF``.wvalid  = PORT``_wvalid;  \
    assign PORT``_wready  = INTF``.wready;  \
    assign PORT``_bid     = INTF``.bid;     \
    assign PORT``_bresp   = INTF``.bresp;   \
    assign PORT``_bvalid  = INTF``.bvalid;  \
    assign INTF``.bready  = PORT``_bready;  \
    assign INTF``.arid    = PORT``_arid;    \
    assign INTF``.araddr  = PORT``_araddr;  \
    assign INTF``.arburst = PORT``_arburst; \
    assign INTF``.arsize  = PORT``_arsize;  \
    assign INTF``.arlen   = PORT``_arlen;   \
    assign INTF``.arlock  = PORT``_arlock;  \
    assign INTF``.arcache = PORT``_arcache; \
    assign INTF``.arprot  = PORT``_arprot;  \
    assign INTF``.arvalid = PORT``_arvalid; \
    assign PORT``_arready = INTF``.arready; \
    assign PORT``_rid     = INTF``.rid;     \
    assign PORT``_rdata   = INTF``.rdata;   \
    assign PORT``_rresp   = INTF``.rresp;   \
    assign PORT``_rlast   = INTF``.rlast;   \
    assign PORT``_rvalid  = INTF``.rvalid;  \
    assign INTF``.rready  = PORT``_rready;


`define AXI_MST_INTF_TO_PORT(INTF, PORT)    \
    assign PORT``_awid    = INTF``.awid;    \
    assign PORT``_awaddr  = INTF``.awaddr;  \
    assign PORT``_awburst = INTF``.awburst; \
    assign PORT``_awsize  = INTF``.awsize;  \
    assign PORT``_awlen   = INTF``.awlen;   \
    assign PORT``_awlock  = INTF``.awlock;  \
    assign PORT``_awcache = INTF``.awcache; \
    assign PORT``_awprot  = INTF``.awprot;  \
    assign PORT``_awvalid = INTF``.awvalid; \
    assign INTF``.awready = PORT``_awready; \
    assign PORT``_wid     = INTF``.wid;     \
    assign PORT``_wstrb   = INTF``.wstrb;   \
    assign PORT``_wdata   = INTF``.wdata;   \
    assign PORT``_wlast   = INTF``.wlast;   \
    assign PORT``_wvalid  = INTF``.wvalid;  \
    assign INTF``.wready  = PORT``_wready;  \
    assign INTF``.bid     = PORT``_bid;     \
    assign INTF``.bresp   = PORT``_bresp;   \
    assign INTF``.bvalid  = PORT``_bvalid;  \
    assign PORT``_bready  = INTF``.bready;  \
    assign PORT``_arid    = INTF``.arid;    \
    assign PORT``_araddr  = INTF``.araddr;  \
    assign PORT``_arburst = INTF``.arburst; \
    assign PORT``_arsize  = INTF``.arsize;  \
    assign PORT``_arlen   = INTF``.arlen;   \
    assign PORT``_arlock  = INTF``.arlock;  \
    assign PORT``_arcache = INTF``.arcache; \
    assign PORT``_arprot  = INTF``.arprot;  \
    assign PORT``_arvalid = INTF``.arvalid; \
    assign INTF``.arready = PORT``_arready; \
    assign INTF``.rid     = PORT``_rid;     \
    assign INTF``.rdata   = PORT``_rdata;   \
    assign INTF``.rresp   = PORT``_rresp;   \
    assign INTF``.rlast   = PORT``_rlast;   \
    assign INTF``.rvalid  = PORT``_rvalid;  \
    assign PORT``_rready  = INTF``.rready;

`endif
