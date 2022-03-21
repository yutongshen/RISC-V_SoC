interface axi_intf #(
    parameter ID_WIDTH   = 10,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
);

logic [    ID_WIDTH-1:0] awid;
logic [  ADDR_WIDTH-1:0] awaddr;
logic [             1:0] awburst;
logic [             2:0] awsize;
logic [             7:0] awlen;
logic [             1:0] awlock;
logic [             3:0] awcache;
logic [             2:0] awprot;
logic                    awvalid;
logic                    awready;
logic [    ID_WIDTH-1:0] wid;
logic [DATA_WIDTH/8-1:0] wstrb;
logic [  DATA_WIDTH-1:0] wdata;
logic                    wlast;
logic                    wvalid;
logic                    wready;
logic [    ID_WIDTH-1:0] bid;
logic [             1:0] bresp;
logic                    bvalid;
logic                    bready;
logic [    ID_WIDTH-1:0] arid;
logic [  ADDR_WIDTH-1:0] araddr;
logic [             1:0] arburst;
logic [             2:0] arsize;
logic [             7:0] arlen;
logic [             1:0] arlock;
logic [             3:0] arcache;
logic [             2:0] arprot;
logic                    arvalid;
logic                    arready;
logic [    ID_WIDTH-1:0] rid;
logic [  DATA_WIDTH-1:0] rdata;
logic [             1:0] rresp;
logic                    rlast;
logic                    rvalid;
logic                    rready;

modport slave (
    input  awid,
    input  awaddr,
    input  awburst,
    input  awsize,
    input  awlen,
    input  awlock,
    input  awcache,
    input  awprot,
    input  awvalid,
    output awready,
    input  wid,
    input  wstrb,
    input  wdata,
    input  wlast,
    input  wvalid,
    output wready,
    output bid,
    output bresp,
    output bvalid,
    input  bready,
    input  arid,
    input  araddr,
    input  arburst,
    input  arsize,
    input  arlen,
    input  arlock,
    input  arcache,
    input  arprot,
    input  arvalid,
    output arready,
    output rid,
    output rdata,
    output rresp,
    output rlast,
    output rvalid,
    input  rready
);

modport master (
    output awid,
    output awaddr,
    output awburst,
    output awsize,
    output awlen,
    output awlock,
    output awcache,
    output awprot,
    output awvalid,
    input  awready,
    output wid,
    output wstrb,
    output wdata,
    output wlast,
    output wvalid,
    input  wready,
    input  bid,
    input  bresp,
    input  bvalid,
    output bready,
    output arid,
    output araddr,
    output arburst,
    output arsize,
    output arlen,
    output arlock,
    output arcache,
    output arprot,
    output arvalid,
    input  arready,
    input  rid,
    input  rdata,
    input  rresp,
    input  rlast,
    input  rvalid,
    output rready
);

endinterface
