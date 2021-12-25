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

logic        [`XLEN - 1:0] out_pre;
logic        [`XLEN - 1:0] src1_zext;
logic        [`XLEN - 1:0] src1_post;
logic        [`XLEN - 1:0] src2_post;
logic signed [`XLEN - 1:0] signed_src1;
logic signed [`XLEN - 1:0] signed_src2;
logic        [        5:0] shamt;


assign signed_src1 = src1_post;
assign signed_src2 = src2_post;
assign zero_flag   = ~|out;

`ifdef RV32
assign out       = out_pre;
assign src1_zext = src1;
assign src1_post = src1;
assign src2_post = src2;
assign shamt     = {1'b0, src2[4:0]};
`else
assign out       = len_64 ? out_pre : {{32{out_pre[31]}}, out_pre[31:0]};
assign src1_zext = {{32{len_64}} & src1[`XLEN-1:32], src1[31:0]};
assign src1_post = len_64 ? src1    : {{32{src1   [31]}}, src1   [31:0]};
assign src2_post = len_64 ? src2    : {{32{src2   [31]}}, src2   [31:0]};
assign shamt     = {src2[5] & len_64, src2[4:0]};
`endif

always_comb begin
    out_pre = `XLEN'b0;
    case (alu_op)
        ALU_AND : out_pre = src1 & src2;
        ALU_OR  : out_pre = src1 | src2;
        ALU_XOR : out_pre = src1 ^ src2;
        ALU_ADD : out_pre = src1 + src2;
        ALU_SUB : out_pre = src1 - src2;
        ALU_SLT : out_pre = (signed_src1 < signed_src2) ? `XLEN'b1 : `XLEN'b0;
        ALU_SLTU: out_pre = (src1_post   < src2_post  ) ? `XLEN'b1 : `XLEN'b0;
        ALU_SLL : out_pre = src1        <<  shamt;
        ALU_SRL : out_pre = src1_zext   >>  shamt;
        ALU_SRA : out_pre = signed_src1 >>> shamt;
    endcase
end

endmodule
