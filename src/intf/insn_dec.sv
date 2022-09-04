`ifndef __INSN_DEC__
`define __INSN_DEC__
typedef struct packed {
    // Control
    logic [                      1:0] prv_req;
    logic                             ill_inst;
    logic                             fence;
    logic                             fence_i;
    logic                             ecall;
    logic                             ebreak;
    logic                             wfi;
    logic                             sret;
    logic                             mret;
    logic                             jump;
    logic                             jump_alu;

    // EXE stage
    logic                             rs1_rd;
    logic                             rs2_rd;
    logic                             mdu_sel;
    logic [        `MDU_OP_LEN - 1:0] mdu_op;
    logic [        `ALU_OP_LEN - 1:0] alu_op;
    logic                             rs1_zero_sel;
    logic                             rs2_imm_sel;
    logic                             pc_imm_sel;
    logic                             branch;
    logic                             branch_zcmp;
    logic [        `BPU_OP_LEN - 1:0] bpu_op;
    logic [        `CSR_OP_LEN - 1:0] csr_op;
    logic                             uimm_rs1_sel;
    logic                             csr_rd;
    logic                             csr_wr;

    // MEM stage
    logic                             pc_alu_sel;
    logic                             csr_alu_sel;
    logic                             amo;
    logic [        `AMO_OP_LEN - 1:0] amo_op;
    logic                             mem_req;
    logic                             mem_wr;
    logic                             mem_ex;
    logic [(`DM_DATA_LEN >> 3) - 1:0] mem_byte;
    logic                             mem_sign_ext;
    logic                             tlb_flush_req;
    logic                             tlb_flush_all_vaddr;
    logic                             tlb_flush_all_asid;

    // WB stage
    logic                             mem_cal_sel;
    logic                             reg_wr;
} insn_dec ;
`endif
