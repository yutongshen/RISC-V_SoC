interface apb_intf #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
);

logic                    psel;
logic                    penable;
logic [  ADDR_WIDTH-1:0] paddr;
logic                    pwrite;
logic [DATA_WIDTH/8-1:0] pstrb;
logic [             2:0] pprot;
logic [  DATA_WIDTH-1:0] pwdata;
logic [  DATA_WIDTH-1:0] prdata;
logic                    pslverr;
logic                    pready;

modport slave (
    input  psel,
    input  penable,
    input  paddr,
    input  pwrite,
    input  pstrb,
    input  pprot,
    input  pwdata,
    output prdata,
    output pslverr,
    output pready
);

modport master (
    output psel,
    output penable,
    output paddr,
    output pwrite,
    output pstrb,
    output pprot,
    output pwdata,
    input  prdata,
    input  pslverr,
    input  pready
);

endinterface
