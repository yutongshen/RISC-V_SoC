`ifndef __INTF_DEFINE__
`define __INTF_DEFINE__

`define AXI_INTF_CONNECT(PORT, WIRE) \
    .``PORT``_awburst ( WIRE``_awburst ), \
    .``PORT``_awid    ( WIRE``_awid    ), \
    .``PORT``_awaddr  ( WIRE``_awaddr  ), \
    .``PORT``_awsize  ( WIRE``_awsize  ), \
    .``PORT``_awlen   ( WIRE``_awlen   ), \
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
    logic              NAME``_arvalid; \
    logic              NAME``_arready; \
    logic  [    31: 0] NAME``_rdata;   \
    logic  [     1: 0] NAME``_rresp;   \
    logic  [ID - 1: 0] NAME``_rid;     \
    logic              NAME``_rlast;   \
    logic              NAME``_rvalid;  \
    logic              NAME``_rready;

`endif
