module dbgapb (
    input                 pclk,
    input                 presetn,
    input                 psel,
    input                 penable,
    input        [ 31: 0] paddr,
    input                 pwrite,
    input        [  3: 0] pstrb,
    input        [ 31: 0] pwdata,
    output logic [ 31: 0] prdata,
    output logic          pslverr,
    output logic          pready,
);

endmodule
