module mdu (
    input                          clk,
    input                          rstn,
    input                          trig,
    input                          len_64,
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
logic [  `XLEN-1:0] src1_post;
logic [  `XLEN-1:0] src2_post;

assign {sel, signed2, signed1, rdh} = mdu_op;

assign mul_trig = ~sel & trig;
assign div_trig =  sel & trig;
assign out      = ({`XLEN{~sel & ~rdh}} & mul_out[    0+:`XLEN]) |
`ifdef RV32
                  ({`XLEN{~sel &  rdh}} & mul_out[`XLEN+:`XLEN]) |
`else
                  ({`XLEN{~sel &  rdh & ~len_64}} & mul_out[   32+:`XLEN]) |
                  ({`XLEN{~sel &  rdh &  len_64}} & mul_out[`XLEN+:`XLEN]) |
`endif
                  ({`XLEN{ sel & ~rdh}} & div_out[    0+:`XLEN]) |
                  ({`XLEN{ sel &  rdh}} & div_out[`XLEN+:`XLEN]);
assign okay     = (~sel & mul_okay) | (sel & div_okay);

assign src1_post = len_64 ? src1 : {{32{src1[31] & signed1}}, src1[31:0]};
assign src2_post = len_64 ? src2 : {{32{src2[31] & signed2}}, src2[31:0]};

mul u_mul (
    .clk     ( clk       ),
    .rstn    ( rstn      ),
    .trig    ( mul_trig  ),
    .flush   ( flush     ),
    .signed1 ( signed1   ),
    .src1    ( src1_post ),
    .signed2 ( signed2   ),
    .src2    ( src2_post ),
    .out     ( mul_out   ),
    .okay    ( mul_okay  )
);

div u_div (
    .clk     ( clk       ),
    .rstn    ( rstn      ),
    .trig    ( div_trig  ),
    .flush   ( flush     ),
    .signed1 ( signed1   ),
    .src1    ( src1_post ),
    .signed2 ( signed2   ),
    .src2    ( src2_post ),
    .out     ( div_out   ),
    .okay    ( div_okay  )
);

endmodule
