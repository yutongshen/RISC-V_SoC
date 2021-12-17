module mul (
    input                      clk,
    input                      rstn,
    input                      trig,
    input                      flush,
    input                      signed1,
    input        [  `XLEN-1:0] src1,
    input                      signed2,
    input        [  `XLEN-1:0] src2,
    output logic [2*`XLEN-1:0] out,
    output logic               okay
);

logic [2*`XLEN-1:0] src1_ext;
logic [2*`XLEN-1:0] src2_ext;

assign src1_ext = {{`XLEN{signed1 & src1[`XLEN-1]}}, src1};
assign src2_ext = {{`XLEN{signed2 & src2[`XLEN-1]}}, src2};

assign out  = src1_ext * src2_ext;
assign okay = 1'b1;

endmodule
