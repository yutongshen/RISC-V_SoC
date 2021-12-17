module mdu (
    input                          clk,
    input                          rstn,
    input                          trig,
    input        [`MDU_OP_LEN-1:0] mdu_op,
    input                          flush,
    input        [      `XLEN-1:0] src1,
    input        [      `XLEN-1:0] src2,
    output logic [      `XLEN-1:0] out,
    output logic                   okay
);

`include "mdu_op.sv"

logic               sel;
logic               rdh;
logic               signed1;
logic               signed2;
logic               mul_trig;
logic               div_trig;
logic [2*`XLEN-1:0] mul_out;
logic [2*`XLEN-1:0] div_out;
logic               mul_okay;
logic               div_okay;

assign {sel, signed2, signed1, rdh} = mdu_op;

assign mul_trig = ~sel & trig;
assign div_trig =  sel & trig;
assign out      = ({`XLEN{~sel & ~rdh}} & mul_out[    0+:`XLEN]) |
                  ({`XLEN{~sel &  rdh}} & mul_out[`XLEN+:`XLEN]) |
                  ({`XLEN{ sel & ~rdh}} & div_out[    0+:`XLEN]) |
                  ({`XLEN{ sel &  rdh}} & div_out[`XLEN+:`XLEN]);
assign okay     = (~sel & mul_okay) | (sel & div_okay);

mul u_mul (
    .clk     ( clk      ),
    .rstn    ( rstn     ),
    .trig    ( mul_trig ),
    .flush   ( flush    ),
    .signed1 ( signed1  ),
    .src1    ( src1     ),
    .signed2 ( signed2  ),
    .src2    ( src2     ),
    .out     ( mul_out  ),
    .okay    ( mul_okay )
);

div u_div (
    .clk     ( clk      ),
    .rstn    ( rstn     ),
    .trig    ( div_trig ),
    .flush   ( flush    ),
    .signed1 ( signed1  ),
    .src1    ( src1     ),
    .signed2 ( signed2  ),
    .src2    ( src2     ),
    .out     ( div_out  ),
    .okay    ( div_okay )
);

endmodule
