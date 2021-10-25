`include "cpu_define.h"

module alu (
    input        [`ALU_OP_LEN - 1:0] alu_op,
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
        ALU_AND : begin
            out = src1 & src2;
        end
        ALU_OR  : begin
            out = src1 | src2;
        end
        ALU_XOR : begin
            out = src1 ^ src2;
        end
        ALU_ADD : begin
            out = src1 + src2;
        end
        ALU_SUB : begin
            out = src1 - src2;
        end
        ALU_SLT : begin
            out = (signed_src1 < signed_src2) ? `XLEN'b1 : `XLEN'b0;
        end
        ALU_SLL : begin
            out = src1 << src2[$clog2(`XLEN) - 1:0];
        end
        ALU_SRL : begin
            out = src1 >> src2[$clog2(`XLEN) - 1:0];
        end
        ALU_SLTU: begin
            out = (src1 < src2) ? `XLEN'b1 : `XLEN'b0;
        end
        ALU_SRA : begin
            out = signed_src1 >>> src2[$clog2(`XLEN) - 1:0];
        end
    endcase
end

endmodule
