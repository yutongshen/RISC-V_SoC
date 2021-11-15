`include "cpu_define.h"

module idu (
    input                                    clk,
    input                                    rstn,
    input        [       `IM_DATA_LEN - 1:0] inst,
    input                                    inst_valid,
    input        [       `IM_ADDR_LEN - 1:0] pc,
    input                                    rd_wr_i,
    input        [                      4:0] rd_addr_i,
    input        [              `XLEN - 1:0] rd_data,
    output       [                      4:0] rd_addr_o,
    output logic [                      4:0] rs1_addr,
    output logic [                      4:0] rs2_addr,
    output logic [                     11:0] csr_addr,
    output logic [              `XLEN - 1:0] rs1_data,
    output logic [              `XLEN - 1:0] rs2_data,
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
    output logic                             rd_wr_o
);

assign rd_addr_o = inst[11: 7];
assign rs1_addr  = inst[19:15];
assign rs2_addr  = inst[24:20];
assign csr_addr  = inst[31:20];

rfu u_rfu (
    .clk      ( ~clk      ),
    .rstn     ( rstn      ),
    .rs1_addr ( rs1_addr  ),
    .rs2_addr ( rs2_addr  ),
    .rs1_data ( rs1_data  ),
    .rs2_data ( rs2_data  ),
    .wen      ( rd_wr_i   ),
    .rd_addr  ( rd_addr_i ),
    .rd_data  ( rd_data   )
);

dec u_dec (
    .inst                ( inst                ),
    .inst_valid          ( inst_valid          ),
    // Date
    .imm                 ( imm                 ),
    // Control
    .prv_req             ( prv_req             ),
    .ill_inst            ( ill_inst            ),
    .fense               ( fense               ),
    .fense_i             ( fense_i             ),
    .ecall               ( ecall               ),
    .ebreak              ( ebreak              ),
    .wfi                 ( wfi                 ),
    .sret                ( sret                ),
    .mret                ( mret                ),
    .jump                ( jump                ),
    .jump_alu            ( jump_alu            ),
    // EXE stage
    .alu_op              ( alu_op              ),
    .rs1_zero_sel        ( rs1_zero_sel        ),
    .rs2_imm_sel         ( rs2_imm_sel         ),
    .pc_imm_sel          ( pc_imm_sel          ),
    .branch              ( branch              ),
    .branch_zcmp         ( branch_zcmp         ),
    .csr_op              ( csr_op              ),
    .uimm_rs1_sel        ( uimm_rs1_sel        ),
    .csr_rd              ( csr_rd              ),
    .csr_wr              ( csr_wr              ),
    // MEM stage
    .pc_alu_sel          ( pc_alu_sel          ),
    .csr_alu_sel         ( csr_alu_sel         ),
    .mem_req             ( mem_req             ),
    .mem_wr              ( mem_wr              ),
    .mem_byte            ( mem_byte            ),
    .mem_sign_ext        ( mem_sign_ext        ),
    .tlb_flush_req       ( tlb_flush_req       ),
    .tlb_flush_all_vaddr ( tlb_flush_all_vaddr ),
    .tlb_flush_all_asid  ( tlb_flush_all_asid  ),
    // WB stage
    .mem_cal_sel         ( mem_cal_sel         ),
    .reg_wr              ( rd_wr_o             )
);

endmodule
