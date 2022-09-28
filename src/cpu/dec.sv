`include "cpu_define.h"

module dec (
    input        [       `IM_DATA_LEN - 1:0] insn,
    input                                    insn_valid,

    // Extension flag
    input        [                      1:0] misa_mxl,
    input                                    misa_a_ext,
    input                                    misa_c_ext,
    input                                    misa_m_ext,

    // Data
    output logic [                      4:0] rs1_addr,
    output logic [                      4:0] rs2_addr,
    output logic [                      4:0] rd_addr,
    output logic                             amo_64,
    output logic                             len_64,

    output logic [              `XLEN - 1:0] imm,

    // Control
    output logic [                      1:0] prv_req,
    output logic                             ill_insn,
    output logic                             fence,
    output logic                             fence_i,
    output logic                             ecall,
    output logic                             ebreak,
    output logic                             wfi,
    output logic                             sret,
    output logic                             mret,
    output logic                             jump,
    output logic                             jump_alu,

    // EXE stage
    output logic                             rs1_rd,
    output logic                             rs2_rd,
    output logic                             mdu_sel,
    output logic [        `MDU_OP_LEN - 1:0] mdu_op,
    output logic [        `ALU_OP_LEN - 1:0] alu_op,
    output logic                             rs1_zero_sel,
    output logic                             rs2_imm_sel,
    output logic                             pc_imm_sel,
    output logic                             branch,
    output logic                             branch_zcmp,
    output logic [        `BPU_OP_LEN - 1:0] bpu_op,
    output logic [        `CSR_OP_LEN - 1:0] csr_op,
    output logic                             uimm_rs1_sel,
    output logic                             csr_rd,
    output logic                             csr_wr,

    // MEM stage
    output logic                             pc_alu_sel,
    output logic                             csr_alu_sel,
    output logic                             amo,
    output logic [        `AMO_OP_LEN - 1:0] amo_op,
    output logic                             mem_req,
    output logic                             mem_wr,
    output logic                             mem_ex,
    output logic [(`DM_DATA_LEN >> 3) - 1:0] mem_byte,
    output logic                             mem_sign_ext,
    output logic                             tlb_flush_req,
    output logic                             tlb_flush_all_vaddr,
    output logic                             tlb_flush_all_asid,

    // WB stage
    output logic                             mem_cal_sel,
    output logic                             reg_wr
);

`include "alu_op.sv"
`include "bpu_op.sv"
`include "mdu_op.sv"
`include "csr_op.sv"
`include "amo_op.sv"
`include "opcode.sv"
`include "funct.sv"

logic [`XLEN - 1:0] imm_i;
logic [`XLEN - 1:0] imm_s;
logic [`XLEN - 1:0] imm_b;
logic [`XLEN - 1:0] imm_u;
logic [`XLEN - 1:0] imm_j;

logic [`XLEN - 1:0] imm_ci_lwsp;
logic [`XLEN - 1:0] imm_ci_ldsp;
logic [`XLEN - 1:0] imm_ci_li;
logic [`XLEN - 1:0] imm_ci_lui;
logic [`XLEN - 1:0] imm_ci_addi16sp;
logic [`XLEN - 1:0] imm_css;
logic [`XLEN - 1:0] imm_css64;
logic [`XLEN - 1:0] imm_ciw;
logic [`XLEN - 1:0] imm_cl;
logic [`XLEN - 1:0] imm_cl64;
logic [`XLEN - 1:0] imm_cs;
logic [`XLEN - 1:0] imm_cb;
logic [`XLEN - 1:0] imm_cj;

assign imm_i     = {{(`XLEN-11){insn[31]}}, insn[30:25], insn[24:21], insn[20]};
assign imm_s     = {{(`XLEN-11){insn[31]}}, insn[30:25], insn[11:8],  insn[7]};
assign imm_b     = {{(`XLEN-12){insn[31]}}, insn[7],     insn[30:25], insn[11:8], 1'b0};
assign imm_u     = {{(`XLEN-31){insn[31]}}, insn[30:20], insn[19:12], 12'b0};
assign imm_j     = {{(`XLEN-20){insn[31]}}, insn[19:12], insn[20],    insn[30:25], insn[24:21], 1'b0};

assign imm_ci_lwsp     = {{(`XLEN-8){1'b0}},      insn[3:2], insn[12], insn[6:4], 2'b0};
assign imm_ci_ldsp     = {{(`XLEN-9){1'b0}},      insn[4:2], insn[12], insn[6:5], 3'b0};
assign imm_ci_li       = {{(`XLEN-5){insn[12]}},  insn[6:2]};
assign imm_ci_lui      = {{(`XLEN-17){insn[12]}}, insn[6:2], 12'b0};
assign imm_ci_addi16sp = {{(`XLEN-9){insn[12]}},  insn[4:3], insn[5], insn[2], insn[6], 4'b0};
assign imm_css         = {{(`XLEN-8){1'b0}},      insn[8:7], insn[12:9], 2'b0};
assign imm_css64       = {{(`XLEN-9){1'b0}},      insn[9:7], insn[12:10], 3'b0};
assign imm_ciw         = {{(`XLEN-10){1'b0}},     insn[10:7], insn[12:11], insn[5], insn[6], 2'b0};
assign imm_cl          = {{(`XLEN-7){1'b0}},      insn[5], insn[12:10], insn[6], 2'b0};
assign imm_cl64        = {{(`XLEN-8){1'b0}},      insn[6], insn[5], insn[12:10], 3'b0};
assign imm_cs          = {{(`XLEN-7){1'b0}},      insn[5], insn[12:10], insn[6], 2'b0};
assign imm_cb          = {{(`XLEN-8){insn[12]}},  insn[6:5], insn[2], insn[11:10], insn[4:3], 1'b0};
assign imm_cj          = {{(`XLEN-11){insn[12]}}, insn[8], insn[10:9], insn[6], insn[7], insn[2], insn[11], insn[5:3], 1'b0};

logic [        2: 0] funct3;
logic [        4: 0] funct5;
logic [        6: 0] funct7;

logic [       15:13] funct3_16;
logic [       15:13] funct2_16_op_imm;
logic [       15:13] funct2_16_op;

assign funct3           = insn[14:12];
assign funct5           = insn[31:27];
assign funct7           = insn[31:25];

assign funct3_16        = insn[15:13];
assign funct2_16_op_imm = insn[11:10];
assign funct2_16_op     = insn[ 6: 5];

logic [        6: 2] opcode_32;
logic [        1: 0] opcode_16;

assign opcode_16 = insn[1:0];
assign opcode_32 = insn[6:2];

always_comb begin
    amo_64              = 1'b0;
    len_64              = misa_mxl[1];
    rs1_rd              = 1'b0;
    rs2_rd              = 1'b0;
    rs1_addr            = insn[19:15];
    rs2_addr            = insn[24:20];
    rd_addr             = insn[11: 7];
    imm                 = `XLEN'b0;
    mdu_sel             = 1'b0;
    mdu_op              = `MDU_OP_LEN'b0;
    alu_op              = `ALU_OP_LEN'b0;
    rs1_zero_sel        = 1'b0;
    rs2_imm_sel         = 1'b0;
    pc_imm_sel          = 1'b0;
    branch              = 1'b0;
    branch_zcmp         = 1'b0;
    bpu_op              = `BPU_OP_LEN'b0;
    pc_alu_sel          = 1'b0;
    amo                 = 1'b0;
    amo_op              = `AMO_OP_LEN'b0;
    mem_req             = 1'b0;
    mem_wr              = 1'b0;
    mem_ex              = 1'b0;
    mem_byte            = {(`DM_DATA_LEN >> 3){1'b0}};
    mem_sign_ext        = 1'b0;
    mem_cal_sel         = 1'b0;
    reg_wr              = 1'b0;
    fence               = 1'b0;
    fence_i             = 1'b0;
    ecall               = 1'b0;
    ebreak              = 1'b0;
    wfi                 = 1'b0;
    sret                = 1'b0;
    mret                = 1'b0;
    jump                = 1'b0;
    jump_alu            = 1'b0;
    csr_op              = `CSR_OP_LEN'b0;
    uimm_rs1_sel        = 1'b0;
    csr_rd              = 1'b0;
    csr_wr              = 1'b0;
    csr_alu_sel         = 1'b0;
    ill_insn            = 1'b0;
    prv_req             = 2'b0;
    tlb_flush_req       = 1'b0;
    tlb_flush_all_vaddr = 1'b0;
    tlb_flush_all_asid  = 1'b0;
    if (insn_valid) begin
        case (opcode_16)
            OP16_C0: begin
                rs1_rd       = 1'b1;
                rs1_addr     = {2'b1, insn[ 9: 7]};
                rs2_addr     = {2'b1, insn[ 4: 2]};
                rd_addr      = {2'b1, insn[ 4: 2]};
                ill_insn     = ~misa_c_ext;
                case (funct3_16)
                    FUNCT3_C0_ADDI4SPN: begin
                        rs1_addr     = `GPR_SP_ADDR;
                        imm          = imm_ciw;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        alu_op       = ALU_ADD;
                        ill_insn     = ill_insn | ~|imm;
                    end
                    FUNCT3_C0_FLD     : begin
                        ill_insn     = 1'b1;
                    end
                    FUNCT3_C0_LW      : begin
                        imm          = imm_cl;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        mem_req      = 1'b1;
                        mem_wr       = 1'b0;
                        reg_wr       = |rd_addr;
                        mem_cal_sel  = 1'b1;
                        mem_byte     = {{((`DM_DATA_LEN >> 3) - 4){1'b0}}, 4'b1111};
                        mem_sign_ext = 1'b1;
                    end
                    FUNCT3_C0_FLW     : begin // RV32: FLW     RV64: LD
`ifndef RV32
                        case (misa_mxl)
                            `MISA_MXL_XLEN_32: begin
`endif
                                ill_insn     = 1'b1;
`ifndef RV32
                            end
                            `MISA_MXL_XLEN_64: begin
                                imm          = imm_cl64;
                                alu_op       = ALU_ADD;
                                rs1_zero_sel = 1'b1;
                                rs2_imm_sel  = 1'b0;
                                mem_req      = 1'b1;
                                mem_wr       = 1'b0;
                                reg_wr       = |rd_addr;
                                mem_cal_sel  = 1'b1;
                                mem_byte     = 8'hff;
                                mem_sign_ext = 1'b1;
                            end
                            default          : ill_insn     = 1'b1;
                        endcase
`endif
                    end
                    FUNCT3_C0_FSD     : begin
                        ill_insn     = 1'b1;
                    end
                    FUNCT3_C0_SW      : begin
                        rs2_rd       = 1'b1;
                        imm          = imm_cs;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        mem_req      = 1'b1;
                        mem_wr       = 1'b1;
                        reg_wr       = 1'b0;
                        mem_byte     = {{((`DM_DATA_LEN >> 3) - 4){1'b0}}, 4'b1111};
                    end
                    FUNCT3_C0_FSW     : begin // RV32: FSW     RV64: SD
`ifndef RV32
                        case (misa_mxl)
                            `MISA_MXL_XLEN_32: begin
`endif
                                ill_insn     = 1'b1;
`ifndef RV32
                            end
                            `MISA_MXL_XLEN_64: begin
                                rs2_rd       = 1'b1;
                                imm          = imm_cl64;
                                alu_op       = ALU_ADD;
                                rs1_zero_sel = 1'b1;
                                rs2_imm_sel  = 1'b0;
                                mem_req      = 1'b1;
                                mem_wr       = 1'b1;
                                reg_wr       = 1'b0;
                                mem_byte     = 8'hff;
                            end
                            default          : ill_insn     = 1'b1;
                        endcase
`endif
                    end
                    default           : begin
                        ill_insn     = 1'b1;
                    end
                endcase
            end
            OP16_C1: begin
                rs1_rd       = 1'b1;
                rs1_addr     = {2'b1, insn[ 9: 7]};
                rs2_addr     = {2'b1, insn[ 4: 2]};
                rd_addr      = {2'b1, insn[ 9: 7]};
                case (funct3_16)
                    FUNCT3_C1_ADDI: begin
                        rs1_addr     = insn[ 11: 7];
                        rd_addr      = insn[ 11: 7];
                        imm          = imm_ci_li;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        alu_op       = ALU_ADD;
                    end
                    FUNCT3_C1_JAL : begin // RV32: JAL     RV64: ADDIW
`ifndef RV32
                        case (misa_mxl)
                            `MISA_MXL_XLEN_32: begin
`endif
                                rs1_rd       = 1'b0;
                                rs2_rd       = 1'b0;
                                rd_addr      = `GPR_RA_ADDR;
                                imm          = imm_cj;
                                rs1_zero_sel = 1'b1;
                                rs2_imm_sel  = 1'b1;
                                pc_imm_sel   = 1'b0;
                                pc_alu_sel   = 1'b1;
                                mem_req      = 1'b0;
                                mem_wr       = 1'b0;
                                mem_cal_sel  = 1'b0;
                                reg_wr       = 1'b1;
                                jump         = 1'b1;
`ifndef RV32
                            end
                            `MISA_MXL_XLEN_64: begin
                                rs1_addr     = insn[ 11: 7];
                                rd_addr      = insn[ 11: 7];
                                len_64       = 1'b0;
                                rs1_rd       = 1'b1;
                                imm          = imm_ci_li;
                                rs1_zero_sel = 1'b1;
                                rs2_imm_sel  = 1'b0;
                                pc_alu_sel   = 1'b0;
                                mem_req      = 1'b0;
                                mem_wr       = 1'b0;
                                mem_cal_sel  = 1'b0;
                                reg_wr       = |rd_addr;
                                alu_op       = ALU_ADD;
                            end
                            default          : ill_insn     = 1'b1;
                        endcase
`endif
                    end
                    FUNCT3_C1_LI  : begin
                        rs1_addr     = `GPR_ZERO_ADDR;
                        rd_addr      = insn[ 11: 7];
                        imm          = imm_ci_li;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        alu_op       = ALU_ADD;
                    end
                    FUNCT3_C1_LUI : begin
                        rs1_addr     = insn[ 11: 7];
                        rd_addr      = insn[ 11: 7];
                        alu_op       = ALU_ADD;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        if (rd_addr == `GPR_SP_ADDR) begin
                            imm          = imm_ci_addi16sp;
                            rs1_zero_sel = 1'b1;
                        end
                        else begin
                            rs1_rd       = 1'b0;
                            rs2_rd       = 1'b0;
                            imm          = imm_ci_lui;
                            rs1_zero_sel = 1'b0;
                        end
                    end
                    FUNCT3_C1_OP  : begin
                        imm          = imm_ci_li;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = 1'b1;
                        case (funct2_16_op_imm)
                            FUNCT2_OP_IMM_C_SRLI: begin
                                alu_op       = ALU_SRL;
                                ill_insn     = ill_insn | (insn[12] & ~misa_mxl[1]);
                            end
                            FUNCT2_OP_IMM_C_SRAI: begin
                                alu_op       = ALU_SRA;
                                ill_insn     = ill_insn | (insn[12] & ~misa_mxl[1]);
                            end
                            FUNCT2_OP_IMM_C_ANDI: begin
                                alu_op       = ALU_AND;
                            end
                            FUNCT2_OP_IMM_C_OP  : begin
                                rs2_rd       = 1'b1;
                                rs2_imm_sel  = 1'b1;
                                if (insn[12] == 1'b0) begin
                                    case (funct2_16_op)
                                        FUNCT2_OP_C_SUB: begin
                                            alu_op       = ALU_SUB;
                                        end
                                        FUNCT2_OP_C_XOR: begin
                                            alu_op       = ALU_XOR;
                                        end
                                        FUNCT2_OP_C_OR : begin
                                            alu_op       = ALU_OR;
                                        end
                                        FUNCT2_OP_C_AND: begin
                                            alu_op       = ALU_AND;
                                        end
                                        default        : begin
                                            ill_insn     = 1'b1;
                                        end
                                    endcase
                                end
                                else begin
`ifndef RV32
                                    len_64       = 1'b0;
                                    case (funct2_16_op)
                                        FUNCT2_OP_C_SUBW: begin
                                            alu_op       = ALU_SUB;
                                        end
                                        FUNCT2_OP_C_ADDW: begin
                                            alu_op       = ALU_ADD;
                                        end
                                        default        : begin
`endif
                                            ill_insn     = 1'b1;
`ifndef RV32
                                        end
                                    endcase
`endif
                                end
                            end
                            default             : begin
                                ill_insn     = 1'b1;
                            end
                        endcase
                    end
                    FUNCT3_C1_J   : begin
                        rs1_rd       = 1'b0;
                        rs2_rd       = 1'b0;
                        rd_addr      = `GPR_ZERO_ADDR;
                        imm          = imm_cj;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b1;
                        pc_imm_sel   = 1'b0;
                        pc_alu_sel   = 1'b1;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = 1'b0;
                        jump         = 1'b1;
                    end
                    FUNCT3_C1_BEQZ: begin
                        rs2_rd       = 1'b1;
                        rs2_addr     = `GPR_ZERO_ADDR;
                        imm          = imm_cb;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b1;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        reg_wr       = 1'b0;
                        branch       = 1'b1;
                        alu_op       = ALU_SUB;
                        branch_zcmp  = 1'b1;
                    end
                    FUNCT3_C1_BNEZ: begin
                        rs2_rd       = 1'b1;
                        rs2_addr     = `GPR_ZERO_ADDR;
                        imm          = imm_cb;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b1;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        reg_wr       = 1'b0;
                        branch       = 1'b1;
                        alu_op       = ALU_SUB;
                        branch_zcmp  = 1'b0;
                    end
                    default       : begin
                        ill_insn     = 1'b1;
                    end
                endcase
            end
            OP16_C2: begin
                rs1_rd       = 1'b1;
                rs1_addr     = insn[11: 7];
                rs2_addr     = insn[ 6: 2];
                rd_addr      = insn[11: 7];
                case (funct3_16)
                    FUNCT3_C2_SLLI : begin
                        imm          = imm_ci_li;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        alu_op       = ALU_SLL;
                        ill_insn     = ill_insn | (insn[12] & ~misa_mxl[1]);
                    end
                    FUNCT3_C2_FLDSP: begin
                        ill_insn     = 1'b1;
                    end
                    FUNCT3_C2_LWSP : begin
                        rs1_addr     = `GPR_SP_ADDR;
                        imm          = imm_ci_lwsp;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        mem_req      = 1'b1;
                        mem_wr       = 1'b0;
                        reg_wr       = |rd_addr;
                        mem_cal_sel  = 1'b1;
                        mem_byte     = {{((`DM_DATA_LEN >> 3) - 4){1'b0}}, 4'b1111};
                        mem_sign_ext = 1'b1;
                        ill_insn     = ill_insn | ~|rd_addr;
                    end
                    FUNCT3_C2_FLWSP: begin // RV32: FLWSP     RV64: LDSP
`ifndef RV32
                        case (misa_mxl)
                            `MISA_MXL_XLEN_32: begin
`endif
                                ill_insn     = 1'b1;
`ifndef RV32
                            end
                            `MISA_MXL_XLEN_64: begin
                                rs1_addr     = `GPR_SP_ADDR;
                                imm          = imm_ci_ldsp;
                                alu_op       = ALU_ADD;
                                rs1_zero_sel = 1'b1;
                                rs2_imm_sel  = 1'b0;
                                mem_req      = 1'b1;
                                mem_wr       = 1'b0;
                                reg_wr       = |rd_addr;
                                mem_cal_sel  = 1'b1;
                                mem_byte     = 8'hff;
                                mem_sign_ext = 1'b1;
                                ill_insn     = ill_insn | ~|rd_addr;
                            end
                            default          : ill_insn     = 1'b1;
                        endcase
`endif
                    end
                    FUNCT3_C2_OP   : begin
                        if (~insn[12]) begin
                            if (rs2_addr == `GPR_ZERO_ADDR) begin
                                rd_addr      = `GPR_ZERO_ADDR;
                                imm          = `XLEN'b0;
                                alu_op       = ALU_ADD;
                                rs1_zero_sel = 1'b1;
                                rs2_imm_sel  = 1'b0;
                                pc_imm_sel   = 1'b0;
                                pc_alu_sel   = 1'b1;
                                mem_req      = 1'b0;
                                mem_wr       = 1'b0;
                                mem_cal_sel  = 1'b0;
                                reg_wr       = |rd_addr;
                                jump_alu     = 1'b1;
                                ill_insn     = ill_insn | ~|rs1_addr;
                            end
                            else begin
                                rs2_rd       = 1'b1;
                                rs1_addr     = `GPR_ZERO_ADDR;
                                rs1_zero_sel = 1'b1;
                                rs2_imm_sel  = 1'b1;
                                pc_alu_sel   = 1'b0;
                                mem_req      = 1'b0;
                                mem_wr       = 1'b0;
                                mem_cal_sel  = 1'b0;
                                reg_wr       = |rd_addr;
                                alu_op       = ALU_ADD;
                            end
                        end
                        else begin
                            if (rs2_addr == `GPR_ZERO_ADDR) begin
                                if (rs1_addr == `GPR_ZERO_ADDR) begin
                                    rs1_rd       = 1'b0;
                                    mem_req      = 1'b0;
                                    mem_wr       = 1'b0;
                                    reg_wr       = 1'b0;
                                    ebreak       = 1'b1;
                                end
                                else begin
                                    rd_addr      = `GPR_RA_ADDR;
                                    imm          = `XLEN'b0;
                                    alu_op       = ALU_ADD;
                                    rs1_zero_sel = 1'b1;
                                    rs2_imm_sel  = 1'b0;
                                    pc_imm_sel   = 1'b0;
                                    pc_alu_sel   = 1'b1;
                                    mem_req      = 1'b0;
                                    mem_wr       = 1'b0;
                                    mem_cal_sel  = 1'b0;
                                    reg_wr       = 1'b1;
                                    jump_alu     = 1'b1;
                                end
                            end
                            else begin
                                rs2_rd       = 1'b1;
                                rs1_zero_sel = 1'b1;
                                rs2_imm_sel  = 1'b1;
                                pc_alu_sel   = 1'b0;
                                mem_req      = 1'b0;
                                mem_wr       = 1'b0;
                                mem_cal_sel  = 1'b0;
                                reg_wr       = |rd_addr;
                                alu_op       = ALU_ADD;
                            end
                        end
                    end
                    FUNCT3_C2_FSDSP: begin
                        ill_insn     = 1'b1;
                    end
                    FUNCT3_C2_SWSP : begin
                        rs2_rd       = 1'b1;
                        rs1_addr     = `GPR_SP_ADDR;
                        imm          = imm_css;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        mem_req      = 1'b1;
                        mem_wr       = 1'b1;
                        reg_wr       = 1'b0;
                        mem_byte     = {{((`DM_DATA_LEN >> 3) - 4){1'b0}}, 4'b1111};
                    end
                    FUNCT3_C2_FSWSP: begin // RV32: FLWSP     RV64: LDSP
`ifndef RV32
                        case (misa_mxl)
                            `MISA_MXL_XLEN_32: begin
`endif
                                ill_insn     = 1'b1;
`ifndef RV32
                            end
                            `MISA_MXL_XLEN_64: begin
                                rs2_rd       = 1'b1;
                                rs1_addr     = `GPR_SP_ADDR;
                                imm          = imm_css64;
                                alu_op       = ALU_ADD;
                                rs1_zero_sel = 1'b1;
                                rs2_imm_sel  = 1'b0;
                                mem_req      = 1'b1;
                                mem_wr       = 1'b1;
                                reg_wr       = 1'b0;
                                mem_byte     = 8'hff;
                            end
                            default          : ill_insn     = 1'b1;
                        endcase
`endif
                    end
                    default        : begin
                        ill_insn     = 1'b1;
                    end
                endcase
            end
            default: begin
                rs1_addr            = insn[19:15];
                rs2_addr            = insn[24:20];
                rd_addr             = insn[11: 7];
                case (opcode_32)
                    OP_LOAD     : begin
                        rs1_rd       = 1'b1;
                        imm          = imm_i;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        mem_req      = 1'b1;
                        mem_wr       = 1'b0;
                        reg_wr       = |rd_addr;
                        mem_cal_sel  = 1'b1;
                        case (funct3)
                            FUNCT3_LB : begin
                                mem_byte     = {{((`DM_DATA_LEN/8) - 1){1'b0}}, 1'b1   };
                                mem_sign_ext = 1'b1;
                            end
                            FUNCT3_LH : begin
                                mem_byte     = {{((`DM_DATA_LEN/8) - 2){1'b0}}, 2'b11  };
                                mem_sign_ext = 1'b1;
                            end
                            FUNCT3_LW : begin
                                mem_byte     = {{((`DM_DATA_LEN/8) - 4){1'b0}}, 4'b1111};
                                mem_sign_ext = 1'b1;
                            end
                            FUNCT3_LBU: begin
                                mem_byte     = {{((`DM_DATA_LEN/8) - 1){1'b0}}, 1'b1   };
                                mem_sign_ext = 1'b0;
                            end
                            FUNCT3_LHU: begin
                                mem_byte     = {{((`DM_DATA_LEN/8) - 2){1'b0}}, 2'b11  };
                                mem_sign_ext = 1'b0;
                            end
`ifndef RV32
                            FUNCT3_LWU: begin
                                mem_byte     = {{((`DM_DATA_LEN/8) - 4){1'b0}}, 4'b1111};
                                mem_sign_ext = 1'b0;
                                ill_insn     = ill_insn | ~misa_mxl[1];
                            end
                            FUNCT3_LD : begin
                                mem_byte     = 8'hff;
                                mem_sign_ext = 1'b1;
                                ill_insn     = ill_insn | ~misa_mxl[1];
                            end
`endif
                            default   : begin
                                ill_insn     = 1'b1;
                            end
                        endcase
                    end
                    OP_LOAD_FP  : ill_insn     = 1'b1;
                    OP_CUST_0   : ill_insn     = 1'b1;
                    OP_MISC_MEM : begin
                        case ({funct3, insn[11:7], insn[19:15], insn[31:28]})
                            {FUNCT3_FENCE  , 5'b0, 5'b0, 4'b0}: begin
                                mem_req      = 1'b0;
                                mem_wr       = 1'b0;
                                reg_wr       = 1'b0;
                                fence        = 1'b1;
                            end
                            {FUNCT3_FENCE_I, 5'b0, 5'b0, 4'b0}: begin
                                if (insn[27:20] == 8'b0) begin
                                    mem_req      = 1'b0;
                                    mem_wr       = 1'b0;
                                    reg_wr       = 1'b0;
                                    fence_i      = 1'b1;
                                    pc_imm_sel   = 1'b0;
                                end
                                else ill_insn     = 1'b1;
                            end
                            default       : begin
                                ill_insn     = 1'b1;
                            end
                        endcase
                    end
                    OP_OP_IMM   : begin
                        rs1_rd       = 1'b1;
                        imm          = imm_i;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        case (funct3)
                            FUNCT3_ADDI : alu_op       = ALU_ADD;
                            FUNCT3_SLTI : alu_op       = ALU_SLT;
                            FUNCT3_SLTIU: alu_op       = ALU_SLTU;
                            FUNCT3_XORI : alu_op       = ALU_XOR;
                            FUNCT3_ORI  : alu_op       = ALU_OR;
                            FUNCT3_ANDI : alu_op       = ALU_AND;
                            FUNCT3_SLLI : begin
                                ill_insn     = ill_insn | (insn[25] & ~misa_mxl[1]);
                                case (funct7[6:1])
                                    FUNCT7_SLLI[6:1]: alu_op       = ALU_SLL;
                                    default         : ill_insn     = 1'b1;
                                endcase
                            end
                            FUNCT3_SRLI : begin
                                ill_insn     = ill_insn | (insn[25] & ~misa_mxl[1]);
                                case (funct7[6:1])
                                    FUNCT7_SRLI[6:1]: alu_op       = ALU_SRL;
                                    FUNCT7_SRAI[6:1]: alu_op       = ALU_SRA;
                                    default         : ill_insn     = 1'b1;
                                endcase
                            end
                            default     : ill_insn     = 1'b1;
                        endcase
                    end
                    OP_AUIPC    : begin
                        imm          = imm_u;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        pc_imm_sel   = 1'b1;
                        pc_alu_sel   = 1'b1;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                    end
                    OP_OP_IMM_32: begin
`ifdef RV32
                        ill_insn     = 1'b1;
`else
                        len_64       = 1'b0;
                        rs1_rd       = 1'b1;
                        imm          = imm_i;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        ill_insn     = ill_insn | ~misa_mxl[1];
                        case (funct3)
                            FUNCT3_ADDI : alu_op       = ALU_ADD;
                            FUNCT3_SLLI : begin
                                ill_insn     = ill_insn | insn[25];
                                case (funct7[6:1])
                                    FUNCT7_SLLI[6:1]: alu_op       = ALU_SLL;
                                    default         : ill_insn     = 1'b1;
                                endcase
                            end
                            FUNCT3_SRLI : begin
                                ill_insn     = ill_insn | insn[25];
                                case (funct7[6:1])
                                    FUNCT7_SRLI[6:1]: alu_op       = ALU_SRL;
                                    FUNCT7_SRAI[6:1]: alu_op       = ALU_SRA;
                                    default         : ill_insn     = 1'b1;
                                endcase
                            end
                            default     : ill_insn     = 1'b1;
                        endcase
`endif
                    end
                    OP_STORE    : begin
                        rs1_rd       = 1'b1;
                        rs2_rd       = 1'b1;
                        imm          = imm_s;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        mem_req      = 1'b1;
                        mem_wr       = 1'b1;
                        reg_wr       = 1'b0;
                        case (funct3)
                            FUNCT3_SB: begin
                                mem_byte     = {{((`DM_DATA_LEN >> 3) - 1){1'b0}}, 1'b1   };
                            end
                            FUNCT3_SH: begin
                                mem_byte     = {{((`DM_DATA_LEN >> 3) - 2){1'b0}}, 2'b11  };
                            end
                            FUNCT3_SW: begin
                                mem_byte     = {{((`DM_DATA_LEN >> 3) - 4){1'b0}}, 4'b1111};
                            end
`ifndef RV32
                            FUNCT3_SD: begin
                                mem_byte     = 8'hff;
                                ill_insn     = ill_insn | ~misa_mxl[1];
                            end
`endif
                            default  : begin
                                ill_insn     = 1'b1;
                            end
                        endcase
                    end
                    OP_STORE_FP : ill_insn     = 1'b1;
                    OP_CUST_1   : ill_insn     = 1'b1;
                    OP_AMO      : begin
                        amo_64       = funct3 == 3'b011;
                        amo          = 1'b1;
                        rs1_rd       = 1'b1;
                        rs2_rd       = 1'b1;
                        imm          = `XLEN'b0;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        mem_req      = 1'b1;
                        mem_wr       = 1'b0;
                        mem_ex       = 1'b1;
                        reg_wr       = |rd_addr;
                        mem_cal_sel  = 1'b1;
                        mem_sign_ext = 1'b1;
`ifdef RV32
                        mem_byte     = {{((`DM_DATA_LEN >> 3) - 4){1'b0}}, 4'b1111};
                        ill_insn     = ill_insn | ~misa_a_ext | (funct3 != 3'b010);
`else
                        mem_byte     = ({8{funct3 == 3'b010}} & 8'h0f)|
                                       ({8{funct3 == 3'b011}} & 8'hff);
                        ill_insn     = ill_insn | ~misa_a_ext | (funct3 != 3'b010 && funct3 != 3'b011) |
                                                                (funct3 == 3'b011 && ~misa_mxl[1]);
`endif
                        case (funct5)
                            FUNCT5_LR     : begin 
                                amo          = 1'b0;
                                rs2_rd       = 1'b0;
                                ill_insn     = ill_insn || rs2_addr != `GPR_ZERO_ADDR;
                            end
                            FUNCT5_SC     : begin
                                amo          = 1'b0;
                                mem_wr       = 1'b1;
                            end
                            FUNCT5_AMOSWAP: amo_op       = AMO_SWAP;
                            FUNCT5_AMOADD : amo_op       = AMO_ADD;
                            FUNCT5_AMOXOR : amo_op       = AMO_XOR;
                            FUNCT5_AMOAND : amo_op       = AMO_AND;
                            FUNCT5_AMOOR  : amo_op       = AMO_OR;
                            FUNCT5_AMOMIN : amo_op       = AMO_MIN;
                            FUNCT5_AMOMAX : amo_op       = AMO_MAX;
                            FUNCT5_AMOMINU: amo_op       = AMO_MINU;
                            FUNCT5_AMOMAXU: amo_op       = AMO_MAXU;
                            default       : ill_insn     = 1'b1;
                        endcase
                    end
                    OP_OP       : begin
                        rs1_rd       = 1'b1;
                        rs2_rd       = 1'b1;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b1;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        case (funct7)
                            FUNCT7_OP0   : begin
                                case (funct3)
                                    FUNCT3_ADD : alu_op       = ALU_ADD;
                                    FUNCT3_SLL : alu_op       = ALU_SLL;
                                    FUNCT3_SLT : alu_op       = ALU_SLT;
                                    FUNCT3_SLTU: alu_op       = ALU_SLTU;
                                    FUNCT3_XOR : alu_op       = ALU_XOR;
                                    FUNCT3_SRL : alu_op       = ALU_SRL;
                                    FUNCT3_OR  : alu_op       = ALU_OR;
                                    FUNCT3_AND : alu_op       = ALU_AND;
                                    default    : ill_insn     = 1'b1;
                                endcase
                            end
                            FUNCT7_OP1   : begin
                                case (funct3)
                                    FUNCT3_ADD : alu_op       = ALU_SUB;
                                    FUNCT3_SRL : alu_op       = ALU_SRA;
                                    default    : ill_insn     = 1'b1;
                                endcase
                            end
                            FUNCT7_MULDIV: begin
                                mdu_sel             = 1'b1;
                                ill_insn            = ill_insn | ~misa_m_ext;
                                case (funct3)
                                    FUNCT3_MUL   : mdu_op   = MDU_MUL;
                                    FUNCT3_MULH  : mdu_op   = MDU_MULH;
                                    FUNCT3_MULHSU: mdu_op   = MDU_MULHSU;
                                    FUNCT3_MULHU : mdu_op   = MDU_MULHU;
                                    FUNCT3_DIV   : mdu_op   = MDU_DIV;
                                    FUNCT3_DIVU  : mdu_op   = MDU_DIVU;
                                    FUNCT3_REM   : mdu_op   = MDU_REM;
                                    FUNCT3_REMU  : mdu_op   = MDU_REMU;
                                    default      : ill_insn = 1'b1;
                                endcase
                            end
                            default      : ill_insn     = 1'b1;
                        endcase
                    end
                    OP_LUI      : begin
                        imm          = imm_u;
                        alu_op       = ALU_OR;
                        rs1_zero_sel = 1'b0;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                    end
                    OP_OP_32    : begin
`ifdef RV32
                        ill_insn     = 1'b1;
`else
                        len_64       = 1'b0;
                        rs1_rd       = 1'b1;
                        rs2_rd       = 1'b1;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b1;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        ill_insn     = ill_insn | ~misa_mxl[1];
                        case (funct7)
                            FUNCT7_OP0   : begin
                                case (funct3)
                                    FUNCT3_ADD : alu_op       = ALU_ADD;
                                    FUNCT3_SLL : alu_op       = ALU_SLL;
                                    FUNCT3_SRL : alu_op       = ALU_SRL;
                                    default    : ill_insn     = 1'b1;
                                endcase
                            end
                            FUNCT7_OP1   : begin
                                case (funct3)
                                    FUNCT3_ADD : alu_op       = ALU_SUB;
                                    FUNCT3_SRL : alu_op       = ALU_SRA;
                                    default    : ill_insn     = 1'b1;
                                endcase
                            end
                            FUNCT7_MULDIV: begin
                                mdu_sel             = 1'b1;
                                ill_insn            = ill_insn | ~misa_m_ext;
                                case (funct3)
                                    FUNCT3_MUL : mdu_op   = MDU_MUL;
                                    FUNCT3_DIV : mdu_op   = MDU_DIV;
                                    FUNCT3_DIVU: mdu_op   = MDU_DIVU;
                                    FUNCT3_REM : mdu_op   = MDU_REM;
                                    FUNCT3_REMU: mdu_op   = MDU_REMU;
                                    default    : ill_insn = 1'b1;
                                endcase
                            end
                            default      : ill_insn     = 1'b1;
                        endcase
`endif
                    end
                    OP_MADD     : ill_insn     = 1'b1;
                    OP_MSUB     : ill_insn     = 1'b1;
                    OP_NMSUB    : ill_insn     = 1'b1;
                    OP_NMADD    : ill_insn     = 1'b1;
                    OP_OP_FP    : ill_insn     = 1'b1;
                    OP_CUST_2   : ill_insn     = 1'b1;
                    OP_BRANCH   : begin
                        rs1_rd       = 1'b1;
                        rs2_rd       = 1'b1;
                        imm          = imm_b;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b1;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        reg_wr       = 1'b0;
                        branch       = 1'b1;
                        case (funct3)
                            FUNCT3_BEQ : begin
                                alu_op       = ALU_SUB;
                                bpu_op       = BPU_EQ;
                                branch_zcmp  = 1'b1;
                            end
                            FUNCT3_BNE : begin
                                alu_op       = ALU_SUB;
                                bpu_op       = BPU_EQ;
                                branch_zcmp  = 1'b0;
                            end
                            FUNCT3_BLT : begin
                                alu_op       = ALU_SLT;
                                bpu_op       = BPU_LT;
                                branch_zcmp  = 1'b1;
                            end
                            FUNCT3_BGE : begin
                                alu_op       = ALU_SLT;
                                bpu_op       = BPU_LT;
                                branch_zcmp  = 1'b0;
                            end
                            FUNCT3_BLTU: begin
                                alu_op       = ALU_SLTU;
                                bpu_op       = BPU_LTU;
                                branch_zcmp  = 1'b1;
                            end
                            FUNCT3_BGEU: begin
                                alu_op       = ALU_SLTU;
                                bpu_op       = BPU_LTU;
                                branch_zcmp  = 1'b0;
                            end
                            default    : begin
                                ill_insn     = 1'b1;
                            end
                        endcase
                    end
                    OP_JALR     : begin
                        rs1_rd       = 1'b1;
                        imm          = imm_i;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        pc_imm_sel   = 1'b0;
                        pc_alu_sel   = 1'b1;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        jump_alu     = 1'b1;
                    end
                    OP_JAL      : begin
                        imm          = imm_j;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b1;
                        pc_imm_sel   = 1'b0;
                        pc_alu_sel   = 1'b1;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        jump         = 1'b1;
                    end
                    OP_SYSTEM   : begin
                        case (funct3)
                            FUNCT3_PRIV  : begin
                                if (funct7 == FUNCT7_SFENCE_VMA) begin
                                    rs1_rd       = 1'b1;
                                    rs2_rd       = 1'b1;
                                    tlb_flush_req       = 1'b1;
                                    tlb_flush_all_vaddr = ~|insn[19:15];
                                    tlb_flush_all_asid  = ~|insn[24:20];
                                    pc_imm_sel   = 1'b0;
                                end
                                else if ({insn[11:7], insn[19:15]} == {5'b0, 5'b0}) begin
                                    case (insn[31:20])
                                        FUNCT12_ECALL: begin
                                            mem_req      = 1'b0;
                                            mem_wr       = 1'b0;
                                            reg_wr       = 1'b0;
                                            ecall        = 1'b1;
                                        end
                                        FUNCT12_EBREAK: begin
                                            mem_req      = 1'b0;
                                            mem_wr       = 1'b0;
                                            reg_wr       = 1'b0;
                                            ebreak       = 1'b1;
                                        end
                                        FUNCT12_WFI   : begin
                                            wfi          = 1'b1;
                                        end
                                        FUNCT12_SRET  : begin
                                            sret         = 1'b1;
                                            prv_req      = insn[29:28];
                                        end
                                        FUNCT12_MRET  : begin
                                            mret         = 1'b1;
                                            prv_req      = insn[29:28];
                                        end
                                        default       : begin
                                            ill_insn     = 1'b1;
                                        end
                                    endcase
                                end
                                else begin
                                    ill_insn     = 1'b1;
                                end
                            end
                            FUNCT3_CSRRW : begin
                                rs1_rd       = 1'b1;
                                imm          = imm_i;
                                csr_op       = CSR_OP_NONE;
                                rs1_zero_sel = 1'b0;
                                rs2_imm_sel  = 1'b0;
                                pc_alu_sel   = 1'b0;
                                reg_wr       = |rd_addr;
                                uimm_rs1_sel = 1'b0;
                                csr_rd       = |rd_addr;
                                csr_wr       = 1'b1;
                                csr_alu_sel  = 1'b1;
                                prv_req      = insn[29:28];
                                ill_insn     = ill_insn | (csr_wr && insn[31:28] == 4'hc);
                            end
                            FUNCT3_CSRRS : begin
                                rs1_rd       = 1'b1;
                                imm          = imm_i;
                                csr_op       = CSR_OP_SET;
                                rs1_zero_sel = 1'b0;
                                rs2_imm_sel  = 1'b0;
                                pc_alu_sel   = 1'b0;
                                reg_wr       = |rd_addr;
                                uimm_rs1_sel = 1'b0;
                                csr_rd       = |rd_addr;
                                csr_wr       = |rs1_addr;
                                csr_alu_sel  = 1'b1;
                                prv_req      = insn[29:28];
                                ill_insn     = ill_insn | (csr_wr && insn[31:28] == 4'hc);
                            end
                            FUNCT3_CSRRC : begin
                                rs1_rd       = 1'b1;
                                imm          = imm_i;
                                csr_op       = CSR_OP_CLR;
                                rs1_zero_sel = 1'b0;
                                rs2_imm_sel  = 1'b0;
                                pc_alu_sel   = 1'b0;
                                reg_wr       = |rd_addr;
                                uimm_rs1_sel = 1'b0;
                                csr_rd       = |rd_addr;
                                csr_wr       = |rs1_addr;
                                csr_alu_sel  = 1'b1;
                                prv_req      = insn[29:28];
                                ill_insn     = ill_insn | (csr_wr && insn[31:28] == 4'hc);
                            end
                            FUNCT3_CSRRWI: begin
                                imm          = imm_i;
                                csr_op       = CSR_OP_NONE;
                                rs1_zero_sel = 1'b0;
                                rs2_imm_sel  = 1'b0;
                                pc_alu_sel   = 1'b0;
                                reg_wr       = |rd_addr;
                                uimm_rs1_sel = 1'b1;
                                csr_rd       = |rd_addr;
                                csr_wr       = 1'b1;
                                csr_alu_sel  = 1'b1;
                                prv_req      = insn[29:28];
                                ill_insn     = ill_insn | (csr_wr && insn[31:28] == 4'hc);
                            end
                            FUNCT3_CSRRSI: begin
                                imm          = imm_i;
                                csr_op       = CSR_OP_SET;
                                rs1_zero_sel = 1'b0;
                                rs2_imm_sel  = 1'b0;
                                pc_alu_sel   = 1'b0;
                                reg_wr       = |rd_addr;
                                uimm_rs1_sel = 1'b1;
                                csr_rd       = |rd_addr;
                                csr_wr       = |rs1_addr;
                                csr_alu_sel  = 1'b1;
                                prv_req      = insn[29:28];
                                ill_insn     = ill_insn | (csr_wr && insn[31:28] == 4'hc);
                            end
                            FUNCT3_CSRRCI: begin
                                imm          = imm_i;
                                csr_op       = CSR_OP_CLR;
                                rs1_zero_sel = 1'b0;
                                rs2_imm_sel  = 1'b0;
                                pc_alu_sel   = 1'b0;
                                reg_wr       = |rd_addr;
                                uimm_rs1_sel = 1'b1;
                                csr_rd       = |rd_addr;
                                csr_wr       = |rs1_addr;
                                csr_alu_sel  = 1'b1;
                                prv_req      = insn[29:28];
                                ill_insn     = ill_insn | (csr_wr && insn[31:28] == 4'hc);
                            end
                            default       : begin
                                ill_insn     = 1'b1;
                            end
                        endcase
                    end
                    OP_CUST_3   : ill_insn = 1'b1;
                    default     : ill_insn = 1'b1;
                endcase
            end
        endcase
    end
end

endmodule
