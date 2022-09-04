module bpu (
    input        [`BPU_OP_LEN - 1:0] bpu_op,
    input                            jump,
    input                            branch,
    input                            cmp_flag,
    input        [      `XLEN - 1:0] src1,
    input        [      `XLEN - 1:0] src2,
    input        [      `XLEN - 1:0] pc,
    input        [      `XLEN - 1:0] imm,
    output logic                     valid,
    output logic [      `XLEN - 1:0] out
);

`include "bpu_op.sv"

logic                      flag;
logic        [`XLEN - 1:0] pc_imm;
logic        [`XLEN - 1:0] src1_imm;
logic signed [`XLEN - 1:0] signed_src1;
logic signed [`XLEN - 1:0] signed_src2;
logic                      jump_en;
logic                      branch_en;


assign signed_src1 = src1;
assign signed_src2 = src2;
assign pc_imm      = pc + imm;
assign src1_imm    = src1 + imm;

assign jump_en   = jump;
assign branch_en = branch && (~cmp_flag ^ flag);

assign valid = jump_en || branch_en;
assign out   = ({`XLEN{jump_en  }} & src1_imm)|
               ({`XLEN{branch_en}} & pc_imm  );

always_comb begin
    flag = 1'b0;
    case (bpu_op)
        BPU_EQ : flag = src1 == src2;
        BPU_LT : flag = signed_src1 < signed_src2;
        BPU_LTU: flag = src1        < src2       ;
    endcase
end

endmodule
