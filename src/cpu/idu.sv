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
    output logic                             len_64_o,
    input                                    len_64_i,
    output logic [              `XLEN - 1:0] imm,

    // Extension flag
    input        [                      1:0] misa_mxl,
    input                                    misa_a_ext,
    input                                    misa_c_ext,
    input                                    misa_m_ext,

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
    output logic                             rd_wr_o,
    
    input                                    halted,
    input        [                     11:0] dbg_addr,
    input        [                     31:0] dbg_wdata,
    input                                    dbg_gpr_rd,
    input                                    dbg_gpr_wr,
    output logic [                     31:0] dbg_gpr_out,
    input                                    dbg_csr_rd,
    input                                    dbg_csr_wr
);

logic             csr_rd_tmp;
logic             csr_wr_tmp;
logic [`XLEN-1:0] rs1_data_pre;
logic [`XLEN-1:0] rs2_data_pre;
logic [`XLEN-1:0] rd_data_post;

assign csr_addr  = (halted && (dbg_csr_rd || dbg_csr_wr)) ? dbg_addr : inst[31:20];

assign csr_rd    = csr_rd_tmp || (halted && dbg_csr_rd);
assign csr_wr    = csr_wr_tmp || (halted && dbg_csr_wr);

`ifdef RV32
assign rs1_data     = rs1_data_pre;
assign rs2_data     = rs2_data_pre;
assign rd_data_post = rd_data;
`else
assign rs1_data     = len_64_o ? rs1_data_pre : {{32{rs1_data_pre[31]}}, rs1_data_pre[31:0]};
assign rs2_data     = len_64_o ? rs2_data_pre : {{32{rs2_data_pre[31]}}, rs2_data_pre[31:0]};
assign rd_data_post = len_64_i ? rd_data      : {{32{rd_data     [31]}}, rd_data     [31:0]};
`endif

rfu u_rfu (
    .clk          ( clk           ),
    .rstn         ( rstn          ),
    .rs1_addr     ( rs1_addr      ),
    .rs2_addr     ( rs2_addr      ),
    .rs1_data     ( rs1_data_pre  ),
    .rs2_data     ( rs2_data_pre  ),
    .wen          ( rd_wr_i       ),
    .rd_addr      ( rd_addr_i     ),
    .rd_data      ( rd_data_post  ),
    .halted       ( halted        ),
    .dbg_gpr_addr ( dbg_addr[4:0] ),
    .dbg_gpr_in   ( dbg_wdata     ),
    .dbg_gpr_rd   ( dbg_gpr_rd    ),
    .dbg_gpr_wr   ( dbg_gpr_wr    ),
    .dbg_gpr_out  ( dbg_gpr_out   )
);

dec u_dec (
    .inst                ( inst                ),
    .inst_valid          ( inst_valid          ),

    // Extension
    .misa_mxl            ( misa_mxl            ),
    .misa_a_ext          ( misa_a_ext          ),
    .misa_c_ext          ( misa_c_ext          ),
    .misa_m_ext          ( misa_m_ext          ),

    // Date
    .rs1_addr            ( rs1_addr            ),
    .rs2_addr            ( rs2_addr            ),
    .rd_addr             ( rd_addr_o           ),
    .len_64              ( len_64_o            ),
    .imm                 ( imm                 ),

    // Control
    .prv_req             ( prv_req             ),
    .ill_inst            ( ill_inst            ),
    .fence               ( fence               ),
    .fence_i             ( fence_i             ),
    .ecall               ( ecall               ),
    .ebreak              ( ebreak              ),
    .wfi                 ( wfi                 ),
    .sret                ( sret                ),
    .mret                ( mret                ),
    .jump                ( jump                ),
    .jump_alu            ( jump_alu            ),

    // EXE stage
    .rs1_rd              ( rs1_rd              ),
    .rs2_rd              ( rs2_rd              ),
    .mdu_sel             ( mdu_sel             ),
    .mdu_op              ( mdu_op              ),
    .alu_op              ( alu_op              ),
    .rs1_zero_sel        ( rs1_zero_sel        ),
    .rs2_imm_sel         ( rs2_imm_sel         ),
    .pc_imm_sel          ( pc_imm_sel          ),
    .branch              ( branch              ),
    .branch_zcmp         ( branch_zcmp         ),
    .csr_op              ( csr_op              ),
    .uimm_rs1_sel        ( uimm_rs1_sel        ),
    .csr_rd              ( csr_rd_tmp          ),
    .csr_wr              ( csr_wr_tmp          ),

    // MEM stage
    .pc_alu_sel          ( pc_alu_sel          ),
    .csr_alu_sel         ( csr_alu_sel         ),
    .amo                 ( amo                 ),
    .amo_op              ( amo_op              ),
    .mem_req             ( mem_req             ),
    .mem_wr              ( mem_wr              ),
    .mem_ex              ( mem_ex              ),
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
