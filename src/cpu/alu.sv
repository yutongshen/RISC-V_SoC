`include "cpu_define.h"

module alu (
    input        [`ALU_OP_LEN - 1:0] alu_op,
    input                            len_64,
    input        [      `XLEN - 1:0] src1,
    input        [      `XLEN - 1:0] src2,
    output logic [      `XLEN - 1:0] out,
    output logic                     zero_flag
);

`include "alu_op.sv"

logic signed [`XLEN - 1:0] signed_src1;
logic signed [`XLEN - 1:0] signed_src2;

assign signed_src1 = src1;
assign signed_src2 = src2;
assign zero_flag   = ~|out;

always_comb begin
    out = `XLEN'b0;
    case (alu_op)
        ALU_AND : out = src1 & src2;
        ALU_OR  : out = src1 | src2;
        ALU_XOR : out = src1 ^ src2;
        ALU_ADD : out = src1 + src2;
        ALU_SUB : out = src1 - src2;
        ALU_SLT : out = (signed_src1 < signed_src2) ? `XLEN'b1 : `XLEN'b0;
`ifdef RV32
        ALU_SLL : out = src1        <<  src2[$clog2(`XLEN) - 1:0];
        ALU_SRL : out = src1        >>  src2[$clog2(`XLEN) - 1:0];
        ALU_SRA : out = signed_src1 >>> src2[$clog2(`XLEN) - 1:0];
`else
        ALU_SLL : out = src1        <<  {src2[$clog2(`XLEN) - 1] & len_64, src2[$clog2(`XLEN) - 2:0]};
        ALU_SRL : out = {(src1[`XLEN-1:32] & {32{len_64}}), src1[31:0]} >> {src2[$clog2(`XLEN) - 1] & len_64, src2[$clog2(`XLEN) - 2:0]};
        ALU_SRA : out = signed_src1 >>> {src2[$clog2(`XLEN) - 1] & len_64, src2[$clog2(`XLEN) - 2:0]};
`endif
        ALU_SLTU: out = (src1 < src2) ? `XLEN'b1 : `XLEN'b0;
    endcase
end

endmodule
