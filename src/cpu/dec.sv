`include "cpu_define.h"

module dec (
    input        [       `IM_DATA_LEN - 1:0] inst,
    input                                    inst_valid,
    // Data
    output logic [              `XLEN - 1:0] imm,
    // Control
    output logic [                      1:0] prv_req,
    output logic                             ill_inst,
    output logic                             fense,
    output logic                             fense_i,
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

assign imm_i = {{(`XLEN-11){inst[31]}}, inst[30:25], inst[24:21], inst[20]};
assign imm_s = {{(`XLEN-11){inst[31]}}, inst[30:25], inst[11:8],  inst[7]};
assign imm_b = {{(`XLEN-12){inst[31]}}, inst[7],     inst[30:25], inst[11:8], 1'b0};
assign imm_u = {{(`XLEN-31){inst[31]}}, inst[30:20], inst[19:12], 12'b0};
assign imm_j = {{(`XLEN-20){inst[31]}}, inst[19:12], inst[20],    inst[30:25], inst[24:21], 1'b0};

logic [       14:12] funct3;
logic [       31:25] funct7;

assign funct3 = inst[14:12];
assign funct7 = inst[31:25];

logic [        6: 2] opcode;

assign opcode = inst[6:2];
always_comb begin
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
    fense               = 1'b0;
    fense_i             = 1'b0;
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
    ill_inst            = inst_valid & (inst[1:0] != 2'b11);
    prv_req             = 2'b0;
    tlb_flush_req       = 1'b0;
    tlb_flush_all_vaddr = 1'b0;
    tlb_flush_all_asid  = 1'b0;
    if (inst_valid) begin
        case (opcode)
            OP_LOAD     : begin
                imm          = imm_i;
                alu_op       = ALU_ADD;
                rs1_zero_sel = 1'b1;
                rs2_imm_sel  = 1'b0;
                mem_req      = 1'b1;
                mem_wr       = 1'b0;
                reg_wr       = 1'b1;
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
                        fense        = 1'b1;
                    end
                    {FUNCT3_FENCE_I, 5'b0, 5'b0, 4'b0}: begin
                        if (inst[27:20] == 8'b0) begin
                            mem_req      = 1'b0;
                            mem_wr       = 1'b0;
                            reg_wr       = 1'b0;
                            fense_i      = 1'b1;
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
                reg_wr       = 1'b1;
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
                reg_wr       = 1'b1;
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
                reg_wr       = 1'b1;
                case (funct3)
                    FUNCT3_ADD : begin
                        case (funct7)
                            FUNCT7_ADD: begin
                                alu_op       = ALU_ADD;
                            end
                            FUNCT7_SUB: begin
                                alu_op       = ALU_SUB;
                            end
                            default   : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    FUNCT3_SLL : begin
                        case (funct7)
                            FUNCT7_SLL: begin
                                alu_op       = ALU_SLL;
                            end
                            default   : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    FUNCT3_SLT : begin
                        case (funct7)
                            FUNCT7_SLT: begin
                                alu_op       = ALU_SLT;
                            end
                            default   : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    FUNCT3_SLTU: begin
                        case (funct7)
                            FUNCT7_SLTU: begin
                                alu_op       = ALU_SLTU;
                            end
                            default    : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    FUNCT3_XOR : begin
                        case (funct7)
                            FUNCT7_XOR: begin
                                alu_op       = ALU_XOR;
                            end
                            default   : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    FUNCT3_SRL : begin
                        case (funct7)
                            FUNCT7_SRL: begin
                                alu_op       = ALU_SRL;
                            end
                            FUNCT7_SRA: begin
                                alu_op       = ALU_SRA;
                            end
                            default   : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    FUNCT3_OR  : begin
                        case (funct7)
                            FUNCT7_OR: begin
                                alu_op       = ALU_OR;
                            end
                            default  : begin
                                ill_inst     = 1'b1;
                            end
                        endcase
                    end
                    FUNCT3_AND : begin
                        case (funct7)
                            FUNCT7_AND: begin
                                alu_op       = ALU_AND;
                            end
                            default    : begin
                                ill_inst     = 1'b1;
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
                reg_wr       = 1'b1;
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
                reg_wr       = 1'b1;
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
                reg_wr       = 1'b1;
                jump         = 1'b1;
            end
            OP_SYSTEM   : begin
                case (funct3)
                    FUNCT3_PRIV  : begin
                        if (funct7 == FUNCT7_SFENCE_VMA) begin
                            tlb_flush_req       = 1'b1;
                            tlb_flush_all_vaddr = ~|inst[19:15];
                            tlb_flush_all_asid  = ~|inst[24:20];
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
                        reg_wr       = 1'b1;
                        uimm_rs1_sel = 1'b0;
                        csr_rd       = |inst[11: 7];
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
                        reg_wr       = 1'b1;
                        uimm_rs1_sel = 1'b0;
                        csr_rd       = |inst[11: 7];
                        csr_wr       = 1'b1;
                        csr_alu_sel  = 1'b1;
                        prv_req      = inst[29:28];
                    end
                    FUNCT3_CSRRC : begin
                        imm          = imm_i;
                        csr_op       = CSR_OP_CLR;
                        rs1_zero_sel = 1'b0;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        reg_wr       = 1'b1;
                        uimm_rs1_sel = 1'b0;
                        csr_rd       = |inst[11: 7];
                        csr_wr       = 1'b1;
                        csr_alu_sel  = 1'b1;
                        prv_req      = inst[29:28];
                    end
                    FUNCT3_CSRRWI: begin
                        imm          = imm_i;
                        csr_op       = CSR_OP_NONE;
                        rs1_zero_sel = 1'b0;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        reg_wr       = 1'b1;
                        uimm_rs1_sel = 1'b1;
                        csr_rd       = |inst[11: 7];
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
                        reg_wr       = 1'b1;
                        uimm_rs1_sel = 1'b1;
                        csr_rd       = |inst[11: 7];
                        csr_wr       = 1'b1;
                        csr_alu_sel  = 1'b1;
                        prv_req      = inst[29:28];
                    end
                    FUNCT3_CSRRCI: begin
                        imm          = imm_i;
                        csr_op       = CSR_OP_CLR;
                        rs1_zero_sel = 1'b0;
                        rs2_imm_sel  = 1'b0;
                        pc_alu_sel   = 1'b0;
                        reg_wr       = 1'b1;
                        uimm_rs1_sel = 1'b1;
                        csr_rd       = |inst[11: 7];
                        csr_wr       = 1'b1;
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
end

endmodule
