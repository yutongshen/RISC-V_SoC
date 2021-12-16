`include "cpu_define.h"

module dec (
    input        [       `IM_DATA_LEN - 1:0] inst,
    input                                    inst_valid,

    // Extension flag
    input                                    misa_c_ext,
    input                                    misa_m_ext,

    // Data
    output logic [                      4:0] rs1_addr,
    output logic [                      4:0] rs2_addr,
    output logic [                      4:0] rd_addr,

    output logic [              `XLEN - 1:0] imm,

    // Control
    output logic [                      1:0] prv_req,
    output logic                             ill_inst,
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
    output logic [        `ALU_OP_LEN - 1:0] alu_op,
    output logic                             rs1_zero_sel,
    output logic                             rs2_imm_sel,
    output logic                             pc_imm_sel,
    output logic                             branch,
    output logic                             branch_zcmp,
    output logic [        `CSR_OP_LEN - 1:0] csr_op,
    output logic                             uimm_rs1_sel,
    output logic                             csr_rd,
    output logic                             csr_wr,

    // MEM stage
    output logic                             pc_alu_sel,
    output logic                             csr_alu_sel,
    output logic                             mem_req,
    output logic                             mem_wr,
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
`include "csr_op.sv"
`include "opcode.sv"
`include "funct.sv"

logic [`XLEN - 1:0] imm_i;
logic [`XLEN - 1:0] imm_s;
logic [`XLEN - 1:0] imm_b;
logic [`XLEN - 1:0] imm_u;
logic [`XLEN - 1:0] imm_j;

logic [`XLEN - 1:0] imm_ci_lsp;
logic [`XLEN - 1:0] imm_ci_li;
logic [`XLEN - 1:0] imm_ci_lui;
logic [`XLEN - 1:0] imm_ci_addi16sp;
logic [`XLEN - 1:0] imm_css;
logic [`XLEN - 1:0] imm_ciw;
logic [`XLEN - 1:0] imm_cl;
logic [`XLEN - 1:0] imm_cs;
logic [`XLEN - 1:0] imm_cb;
logic [`XLEN - 1:0] imm_cj;

assign imm_i     = {{(`XLEN-11){inst[31]}}, inst[30:25], inst[24:21], inst[20]};
assign imm_s     = {{(`XLEN-11){inst[31]}}, inst[30:25], inst[11:8],  inst[7]};
assign imm_b     = {{(`XLEN-12){inst[31]}}, inst[7],     inst[30:25], inst[11:8], 1'b0};
assign imm_u     = {{(`XLEN-31){inst[31]}}, inst[30:20], inst[19:12], 12'b0};
assign imm_j     = {{(`XLEN-20){inst[31]}}, inst[19:12], inst[20],    inst[30:25], inst[24:21], 1'b0};

assign imm_ci_lsp      = {{(`XLEN-8){1'b0}},      inst[3:2], inst[12], inst[6:4], 2'b0};
assign imm_ci_li       = {{(`XLEN-5){inst[12]}},  inst[6:2]};
assign imm_ci_lui      = {{(`XLEN-17){inst[12]}}, inst[6:2], 12'b0};
assign imm_ci_addi16sp = {{(`XLEN-9){inst[12]}},  inst[4:3], inst[5], inst[2], inst[6], 4'b0};
assign imm_css         = {{(`XLEN-8){1'b0}},      inst[8:7], inst[12:9], 2'b0};
assign imm_ciw         = {{(`XLEN-10){1'b0}},     inst[10:7], inst[12:11], inst[5], inst[6], 2'b0};
assign imm_cl          = {{(`XLEN-7){1'b0}},      inst[5], inst[12:10], inst[6], 2'b0};
assign imm_cs          = {{(`XLEN-7){1'b0}},      inst[5], inst[12:10], inst[6], 2'b0};
assign imm_cb          = {{(`XLEN-8){inst[12]}},  inst[6:5], inst[2], inst[11:10], inst[4:3], 1'b0};
assign imm_cj          = {{(`XLEN-11){inst[12]}}, inst[8], inst[10:9], inst[6], inst[7], inst[2], inst[11], inst[5:3], 1'b0};

logic [       14:12] funct3;
logic [       31:25] funct7;

logic [       15:13] funct3_16;
logic [       15:13] funct2_16_op_imm;
logic [       15:13] funct2_16_op;

assign funct3           = inst[14:12];
assign funct7           = inst[31:25];

assign funct3_16        = inst[15:13];
assign funct2_16_op_imm = inst[11:10];
assign funct2_16_op     = inst[ 6: 5];

logic [        6: 2] opcode_32;
logic [        1: 0] opcode_16;

assign opcode_16 = inst[1:0];
assign opcode_32 = inst[6:2];

always_comb begin
    rs1_addr            = inst[19:15];
    rs2_addr            = inst[24:20];
    rd_addr             = inst[11: 7];
    imm                 = `XLEN'b0;
    alu_op              = `ALU_OP_LEN'b0;
    rs1_zero_sel        = 1'b0;
    rs2_imm_sel         = 1'b0;
    pc_imm_sel          = 1'b0;
    branch              = 1'b0;
    branch_zcmp         = 1'b0;
    pc_alu_sel          = 1'b0;
    mem_req             = 1'b0;
    mem_wr              = 1'b0;
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
    ill_inst            = inst_valid & ~misa_c_ext & (inst[1:0] != 2'b11);
    prv_req             = 2'b0;
    tlb_flush_req       = 1'b0;
    tlb_flush_all_vaddr = 1'b0;
    tlb_flush_all_asid  = 1'b0;
    if (inst_valid) begin
        case (opcode_16)
            OP16_C0: begin
                rs1_addr            = {2'b1, inst[ 9: 7]};
                rs2_addr            = {2'b1, inst[ 4: 2]};
                rd_addr             = {2'b1, inst[ 4: 2]};
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
                        ill_inst     = ~|imm;
                    end
                    FUNCT3_C0_FLD     : begin
                        ill_inst     = 1'b1;
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
                    FUNCT3_C0_FLW     : begin
                        ill_inst     = 1'b1;
                    end
                    FUNCT3_C0_FSD     : begin
                        ill_inst     = 1'b1;
                    end
                    FUNCT3_C0_SW      : begin
                        imm          = imm_cs;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        mem_req      = 1'b1;
                        mem_wr       = 1'b1;
                        reg_wr       = 1'b0;
                        mem_byte     = {{((`DM_DATA_LEN >> 3) - 4){1'b0}}, 4'b1111};
                    end
                    FUNCT3_C0_FSW     : begin
                        ill_inst     = 1'b1;
                    end
                    default           : begin
                        ill_inst     = 1'b1;
                    end
                endcase
            end
            OP16_C1: begin
                rs1_addr            = {2'b1, inst[ 9: 7]};
                rs2_addr            = {2'b1, inst[ 4: 2]};
                rd_addr             = {2'b1, inst[ 9: 7]};
                case (funct3_16)
                    FUNCT3_C1_ADDI: begin
                        rs1_addr     = inst[ 11: 7];
                        rd_addr      = inst[ 11: 7];
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
                    FUNCT3_C1_JAL : begin
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
                    end
                    FUNCT3_C1_LI  : begin
                        rs1_addr     = `GPR_ZERO_ADDR;
                        rd_addr      = inst[ 11: 7];
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
                        rs1_addr     = inst[ 11: 7];
                        rd_addr      = inst[ 11: 7];
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
                                ill_inst     = inst[12];
                            end
                            FUNCT2_OP_IMM_C_SRAI: begin
                                alu_op       = ALU_SRA;
                                ill_inst     = inst[12];
                            end
                            FUNCT2_OP_IMM_C_ANDI: begin
                                alu_op       = ALU_AND;
                            end
                            FUNCT2_OP_IMM_C_OP  : begin
                                rs2_imm_sel  = 1'b1;
                                if (inst[12] == 1'b0) begin
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
                                            ill_inst     = 1'b1;
                                        end
                                    endcase
                                end
                                else begin
                                    ill_inst     = 1'b1;
                                end
                            end
                            default             : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    FUNCT3_C1_J   : begin
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
                        ill_inst     = 1'b1;
                    end
                endcase
            end
            OP16_C2: begin
                rs1_addr            = inst[11: 7];
                rs2_addr            = inst[ 6: 2];
                rd_addr             = inst[11: 7];
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
                        ill_inst     = inst[12];
                    end
                    FUNCT3_C2_FLDSP: begin
                        ill_inst     = 1'b1;
                    end
                    FUNCT3_C2_LWSP : begin
                        rs1_addr     = `GPR_SP_ADDR;
                        imm          = imm_ci_lsp;
                        alu_op       = ALU_ADD;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        mem_req      = 1'b1;
                        mem_wr       = 1'b0;
                        reg_wr       = |rd_addr;
                        mem_cal_sel  = 1'b1;
                        mem_byte     = {{((`DM_DATA_LEN >> 3) - 4){1'b0}}, 4'b1111};
                        mem_sign_ext = 1'b1;
                        ill_inst     = ~|rd_addr;
                    end
                    FUNCT3_C2_FLWSP: begin
                        ill_inst     = 1'b1;
                    end
                    FUNCT3_C2_OP   : begin
                        if (~inst[12]) begin
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
                                ill_inst     = ~|rs1_addr;
                            end
                            else begin
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
                        ill_inst     = 1'b1;
                    end
                    FUNCT3_C2_SWSP : begin
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
                    FUNCT3_C2_FSWSP: begin
                        ill_inst     = 1'b1;
                    end
                    default        : begin
                        ill_inst     = 1'b1;
                    end
                endcase
            end
            default: begin
                rs1_addr            = inst[19:15];
                rs2_addr            = inst[24:20];
                rd_addr             = inst[11: 7];
                case (opcode_32)
                    OP_LOAD     : begin
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
                                mem_byte     = {{((`DM_DATA_LEN >> 3) - 1){1'b0}}, 1'b1   };
                                mem_sign_ext = 1'b1;
                            end
                            FUNCT3_LH : begin
                                mem_byte     = {{((`DM_DATA_LEN >> 3) - 2){1'b0}}, 2'b11  };
                                mem_sign_ext = 1'b1;
                            end
                            FUNCT3_LW : begin
                                mem_byte     = {{((`DM_DATA_LEN >> 3) - 4){1'b0}}, 4'b1111};
                                mem_sign_ext = 1'b1;
                            end
                            FUNCT3_LBU: begin
                                mem_byte     = {{((`DM_DATA_LEN >> 3) - 1){1'b0}}, 1'b1   };
                                mem_sign_ext = 1'b0;
                            end
                            FUNCT3_LHU: begin
                                mem_byte     = {{((`DM_DATA_LEN >> 3) - 2){1'b0}}, 2'b11  };
                                mem_sign_ext = 1'b0;
                            end
                            default   : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    OP_LOAD_FP  : begin
                    end
                    OP_CUST_0   : begin
                    end
                    OP_MISC_MEM : begin
                        case ({funct3, inst[11:7], inst[19:15], inst[31:28]})
                            {FUNCT3_FENCE  , 5'b0, 5'b0, 4'b0}: begin
                                mem_req      = 1'b0;
                                mem_wr       = 1'b0;
                                reg_wr       = 1'b0;
                                fence        = 1'b1;
                            end
                            {FUNCT3_FENCE_I, 5'b0, 5'b0, 4'b0}: begin
                                if (inst[27:20] == 8'b0) begin
                                    mem_req      = 1'b0;
                                    mem_wr       = 1'b0;
                                    reg_wr       = 1'b0;
                                    fence_i      = 1'b1;
                                    pc_imm_sel   = 1'b0;
                                end
                                else ill_inst     = 1'b1;
                            end
                            default       : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    OP_OP_IMM   : begin
                        imm          = imm_i;
                        rs1_zero_sel = 1'b1;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        mem_req      = 1'b0;
                        mem_wr       = 1'b0;
                        mem_cal_sel  = 1'b0;
                        reg_wr       = |rd_addr;
                        case (funct3)
                            FUNCT3_ADDI : begin
                                alu_op       = ALU_ADD;
                            end
                            FUNCT3_SLTI : begin
                                alu_op       = ALU_SLT;
                            end
                            FUNCT3_SLTIU: begin
                                alu_op       = ALU_SLTU;
                            end
                            FUNCT3_XORI : begin
                                alu_op       = ALU_XOR;
                            end
                            FUNCT3_ORI  : begin
                                alu_op       = ALU_OR;
                            end
                            FUNCT3_ANDI : begin
                                alu_op       = ALU_AND;
                            end
                            FUNCT3_SLLI : begin
                                case (funct7)
                                    FUNCT7_SLLI: begin
                                        alu_op       = ALU_SLL;
                                    end
                                    default    : begin
                                        ill_inst     = 1'b1;
                                    end
                                endcase
                            end
                            FUNCT3_SRLI : begin
                                case (funct7)
                                    FUNCT7_SRLI: begin
                                        alu_op       = ALU_SRL;
                                    end
                                    FUNCT7_SRAI: begin
                                        alu_op       = ALU_SRA;
                                    end
                                    default    : begin
                                        ill_inst     = 1'b1;
                                    end
                                endcase
                            end
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
                    end
                    OP_STORE    : begin
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
                            default  : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    OP_STORE_FP : begin
                    end
                    OP_CUST_1   : begin
                    end
                    OP_AMO      : begin
                    end
                    OP_OP       : begin
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
                                    default    : ill_inst     = 1'b1;
                                endcase
                            end
                            FUNCT7_OP1   : begin
                                case (funct3)
                                    FUNCT3_ADD : alu_op       = ALU_SUB;
                                    FUNCT3_SRL : alu_op       = ALU_SRA;
                                    default    : ill_inst     = 1'b1;
                                endcase
                            end
                            FUNCT7_MULDIV: begin
                                ill_inst = misa_m_ext;
                                case (funct3)
                                    FUNCT3_MUL   : begin
                                        // mul_op = MUL_MLU
                                    end
                                    FUNCT3_MULH  : begin
                                    end
                                    FUNCT3_MULHSU: begin
                                    end
                                    FUNCT3_MULHU : begin
                                    end
                                    FUNCT3_DIV   : begin
                                    end
                                    FUNCT3_DIVU  : begin
                                    end
                                    FUNCT3_REM   : begin
                                    end
                                    FUNCT3_REMU  : begin
                                    end
                                endcase
                            end
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
                    end
                    OP_MADD     : begin
                    end
                    OP_MSUB     : begin
                    end
                    OP_NMSUB    : begin
                    end
                    OP_NMADD    : begin
                    end
                    OP_OP_FP    : begin
                    end
                    OP_CUST_2   : begin
                    end
                    OP_BRANCH   : begin
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
                                branch_zcmp  = 1'b1;
                            end
                            FUNCT3_BNE : begin
                                alu_op       = ALU_SUB;
                                branch_zcmp  = 1'b0;
                            end
                            FUNCT3_BLT : begin
                                alu_op       = ALU_SLT;
                                branch_zcmp  = 1'b0;
                            end
                            FUNCT3_BGE : begin
                                alu_op       = ALU_SLT;
                                branch_zcmp  = 1'b1;
                            end
                            FUNCT3_BLTU: begin
                                alu_op       = ALU_SLTU;
                                branch_zcmp  = 1'b0;
                            end
                            FUNCT3_BGEU: begin
                                alu_op       = ALU_SLTU;
                                branch_zcmp  = 1'b1;
                            end
                            default    : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    OP_JALR     : begin
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
                                    tlb_flush_req       = 1'b1;
                                    tlb_flush_all_vaddr = ~|inst[19:15];
                                    tlb_flush_all_asid  = ~|inst[24:20];
                                    pc_imm_sel   = 1'b0;
                                end
                                else if ({inst[11:7], inst[19:15]} == {5'b0, 5'b0}) begin
                                    case (inst[31:20])
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
                                            prv_req      = inst[29:28];
                                        end
                                        FUNCT12_MRET  : begin
                                            mret         = 1'b1;
                                            prv_req      = inst[29:28];
                                        end
                                        default       : begin
                                            ill_inst     = 1'b1;
                                        end
                                    endcase
                                end
                                else begin
                                    ill_inst     = 1'b1;
                                end
                            end
                            FUNCT3_CSRRW : begin
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
                                prv_req      = inst[29:28];
                            end
                            FUNCT3_CSRRS : begin
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
                                prv_req      = inst[29:28];
                            end
                            FUNCT3_CSRRC : begin
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
                                prv_req      = inst[29:28];
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
                                prv_req      = inst[29:28];
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
                                prv_req      = inst[29:28];
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
                                prv_req      = inst[29:28];
                            end
                            default       : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    OP_CUST_3   : begin
                    end
                    default     : begin
                        ill_inst = 1'b1;
                    end
                endcase
            end
        endcase
    end
end

endmodule
