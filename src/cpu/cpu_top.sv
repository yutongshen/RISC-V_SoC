`include "cpu_define.h"

module cpu_top (
    input                                    clk,
    input                                    rstn,
    input        [              `XLEN - 1:0] cpu_id,
    input        [              `XLEN - 1:0] bootvec,

    // mpu csr
    output logic [                  8 - 1:0] pmpcfg  [16],
    output logic [              `XLEN - 1:0] pmpaddr [16],
    output logic [                  8 - 1:0] pmacfg  [16],
    output logic [              `XLEN - 1:0] pmaaddr [16],

    // mmu csr
    output logic [    `SATP_PPN_WIDTH - 1:0] satp_ppn,
    output logic [   `SATP_ASID_WIDTH - 1:0] satp_asid,
    output logic [   `SATP_MODE_WIDTH - 1:0] satp_mode,
    output logic [                      1:0] prv,
    output logic                             sum,
    output logic                             mprv,
    output logic [                      1:0] mpp,

    // TLB control
    output logic                             tlb_flush_req,
    output logic                             tlb_flush_all_vaddr,
    output logic                             tlb_flush_all_asid,
    output logic [              `XLEN - 1:0] tlb_flush_vaddr,
    output logic [              `XLEN - 1:0] tlb_flush_asid,

    // interrupt interface
    input                                    msip,
    input                                    mtip,
    input                                    meip,

    // inst interface
    output logic                             imem_en,
    output logic [       `IM_ADDR_LEN - 1:0] imem_addr,
    input        [       `IM_DATA_LEN - 1:0] imem_rdata,
    input        [                      1:0] imem_bad,
    input                                    imem_busy,
    output logic                             ic_flush,

    // data interface                             
    output logic                             dmem_en,
    output logic [       `IM_ADDR_LEN - 1:0] dmem_addr,
    output logic                             dmem_write,
    output logic                             dmem_ex,
    output logic [(`IM_DATA_LEN >> 3) - 1:0] dmem_strb,
    output logic [       `IM_DATA_LEN - 1:0] dmem_wdata,
    input        [       `IM_DATA_LEN - 1:0] dmem_rdata,
    input        [                      1:0] dmem_bad,
    input                                    dmem_xstate,
    input                                    dmem_busy,

    // debug intface
    input        [                     11:0] dbg_addr,
    input        [                     31:0] dbg_wdata,
    input                                    dbg_gpr_rd,
    input                                    dbg_gpr_wr,
    output logic [                     31:0] dbg_gpr_out,
    input                                    dbg_csr_rd,
    input                                    dbg_csr_wr,
    output logic [                     31:0] dbg_csr_out,
    output logic [       `IM_ADDR_LEN - 1:0] dbg_pc_out,
    input                                    dbg_exec,
    input        [       `IM_ADDR_LEN - 1:0] dbg_inst,
    input                                    attach,
    output logic                             halted
);

logic                             rstn_sync;
logic                             wakeup_event;
logic                             sleep;
logic                             stall_wfi;
logic [                      5:0] inst_valid;
logic [       `IM_ADDR_LEN - 1:0] irq_vec;
logic [       `IM_ADDR_LEN - 1:0] ret_epc;

// Hazard Control Unit
logic                             if_stall;
logic                             id_stall;
logic                             exe_stall;
logic                             ma_stall;
logic                             mr_stall;
logic                             wb_stall;
logic                             if_flush;
logic                             id_flush;
logic                             exe_flush;
logic                             ma_flush;
logic                             mr_flush;
logic                             wb_flush;
logic                             if_flush_force;
logic                             id_flush_force;
logic                             exe_flush_force;
logic                             ma_flush_force;
logic                             mr_flush_force;
logic                             wb_flush_force;

// IF stage
logic                             if_pc_jump_en;
logic [       `IM_ADDR_LEN - 1:0] if_pc_jump;
logic                             if_pc_alu_en;
logic [       `IM_ADDR_LEN - 1:0] if_pc_alu;
logic                             if_jump_token;
logic [       `IM_ADDR_LEN - 1:0] if_pc;
logic [       `IM_DATA_LEN - 1:0] if_inst;
logic                             if_inst_valid;
logic [       `IM_ADDR_LEN - 1:0] if_inst_misaligned_epc;
logic                             if_inst_misaligned;
logic                             if_inst_page_fault;
logic                             if_inst_xes_fault;
logic [       `IM_ADDR_LEN - 1:0] if_inst_badaddr;

// IF/ID pipeline
logic [       `IM_DATA_LEN - 1:0] if2id_inst;
logic                             if2id_inst_valid;
logic [       `IM_ADDR_LEN - 1:0] if2id_inst_misaligned_epc;
logic                             if2id_inst_misaligned;
logic                             if2id_inst_page_fault;
logic                             if2id_inst_xes_fault;
logic [       `IM_ADDR_LEN - 1:0] if2id_inst_badaddr;
logic [       `IM_ADDR_LEN - 1:0] if2id_pc;
logic                             if2id_jump_token;
logic                             if2id_attach;
logic                             if2id_stall_flag;

// ID stage
logic [                      4:0] id_rd_addr;
logic [                      4:0] id_rs1_addr;
logic [                      4:0] id_rs2_addr;
logic [              `XLEN - 1:0] id_gpr_rs1_data;
logic [              `XLEN - 1:0] id_gpr_rs2_data;
logic [              `XLEN - 1:0] id_rs1_data;
logic [              `XLEN - 1:0] id_rs2_data;
logic [                     11:0] id_csr_addr;
logic                             id_len_64;
logic [              `XLEN - 1:0] id_imm;

logic [                      1:0] id_prv_req;
logic                             id_ill_inst;
logic                             id_fence;
logic                             id_fence_i;
logic                             id_ecall;
logic                             id_ebreak;
logic                             id_wfi;
logic                             id_sret;
logic                             id_mret;
logic                             id_jump;
logic                             id_jump_alu;
logic                             id_jump_fault;

logic                             id_rs1_rd;
logic                             id_rs2_rd;
logic                             id_mdu_sel;
logic [        `MDU_OP_LEN - 1:0] id_mdu_op;
logic [        `ALU_OP_LEN - 1:0] id_alu_op;
logic                             id_rs1_zero_sel;
logic                             id_rs2_imm_sel;
logic                             id_pc_imm_sel;
logic                             id_branch;
logic                             id_branch_zcmp;
logic [        `CSR_OP_LEN - 1:0] id_csr_op;
logic                             id_uimm_rs1_sel;
logic                             id_pc_alu_sel;
logic                             id_csr_alu_sel;
logic                             id_amo;
logic [        `AMO_OP_LEN - 1:0] id_amo_op;
logic                             id_mem_req;
logic                             id_mem_wr;
logic                             id_mem_ex;
logic [(`DM_DATA_LEN >> 3) - 1:0] id_mem_byte;
logic                             id_mem_sign_ext;
logic                             id_tlb_flush_req;
logic                             id_tlb_flush_all_vaddr;
logic                             id_tlb_flush_all_asid;

logic                             id_mem_cal_sel;
logic                             id_rd_wr;

logic                             id_hazard;
logic                             id_csr_rd;
logic                             id_csr_wr;
logic                             id_pmu_csr_wr;
logic                             id_fpu_csr_wr;
logic                             id_dbg_csr_wr;
logic                             id_mmu_csr_wr;
logic                             id_mpu_csr_wr;
logic                             id_sru_csr_wr;
logic [              `XLEN - 1:0] id_csr_rdata;
logic [              `XLEN - 1:0] id_pmu_csr_rdata;
logic [              `XLEN - 1:0] id_fpu_csr_rdata;
logic [              `XLEN - 1:0] id_dbg_csr_rdata;
logic [              `XLEN - 1:0] id_mmu_csr_rdata;
logic [              `XLEN - 1:0] id_mpu_csr_rdata;
logic [              `XLEN - 1:0] id_sru_csr_rdata;

// ID/EXE pipeline
logic [       `IM_ADDR_LEN - 1:0] id2exe_pc;
logic [       `IM_DATA_LEN - 1:0] id2exe_inst;
logic                             id2exe_inst_valid;
logic [                      4:0] id2exe_rd_addr;
logic [                      4:0] id2exe_rs1_addr;
logic [                      4:0] id2exe_rs2_addr;
logic [              `XLEN - 1:0] id2exe_rs1_data;
logic [              `XLEN - 1:0] id2exe_rs2_data;
logic [                     11:0] id2exe_csr_waddr;
logic [              `XLEN - 1:0] id2exe_csr_rdata;
logic                             id2exe_len_64;
logic [              `XLEN - 1:0] id2exe_imm;

logic                             id2exe_rs1_rd;
logic                             id2exe_rs2_rd;
logic                             id2exe_mdu_sel;
logic [        `MDU_OP_LEN - 1:0] id2exe_mdu_op;
logic [        `ALU_OP_LEN - 1:0] id2exe_alu_op;
logic                             id2exe_rs1_zero_sel;
logic                             id2exe_rs2_imm_sel;
logic                             id2exe_pc_imm_sel;
logic                             id2exe_jump_alu;
logic                             id2exe_branch;
logic                             id2exe_branch_zcmp;
logic [        `CSR_OP_LEN - 1:0] id2exe_csr_op;
logic                             id2exe_uimm_rs1_sel;
logic                             id2exe_csr_rd;
logic                             id2exe_pmu_csr_wr;
logic                             id2exe_fpu_csr_wr;
logic                             id2exe_dbg_csr_wr;
logic                             id2exe_mmu_csr_wr;
logic                             id2exe_mpu_csr_wr;
logic                             id2exe_sru_csr_wr;

logic                             id2exe_pc_alu_sel;
logic                             id2exe_csr_alu_sel;
logic                             id2exe_amo;
logic [        `AMO_OP_LEN - 1:0] id2exe_amo_op;
logic                             id2exe_mem_req;
logic                             id2exe_mem_wr;
logic                             id2exe_mem_ex;
logic [(`DM_DATA_LEN >> 3) - 1:0] id2exe_mem_byte;
logic                             id2exe_mem_sign_ext;

logic                             id2exe_mem_cal_sel;
logic                             id2exe_rd_wr;
logic                             id2exe_wfi;
logic                             id2exe_ecall;
logic                             id2exe_ebreak;
logic                             id2exe_sret;
logic                             id2exe_mret;
logic                             id2exe_ill_inst;
logic [                      1:0] id2exe_prv_req;
logic [       `IM_ADDR_LEN - 1:0] id2exe_inst_misaligned_epc;
logic                             id2exe_inst_misaligned;
logic                             id2exe_inst_page_fault;
logic                             id2exe_inst_xes_fault;
logic [       `IM_ADDR_LEN - 1:0] id2exe_inst_badaddr;
logic                             id2exe_tlb_flush_req;
logic                             id2exe_tlb_flush_all_vaddr;
logic                             id2exe_tlb_flush_all_asid;
logic                             id2exe_fence_i;
logic                             id2exe_attach;
logic                             id2exe_ext_csr_wr;
logic [              `XLEN - 1:0] id2exe_ext_csr_wdata;

// EXE stage
logic                             exe_alu_zero;
logic                             exe_branch_match;
logic                             exe_jump_fault;
logic [              `XLEN - 1:0] exe_pc_imm;
logic [              `XLEN - 1:0] exe_pc_add_4;
logic [              `XLEN - 1:0] exe_rs1_data;
logic [              `XLEN - 1:0] exe_rs2_data;
logic [              `XLEN - 1:0] exe_alu_src1;
logic [              `XLEN - 1:0] exe_alu_src2;
logic [              `XLEN - 1:0] exe_alu_out;
logic [              `XLEN - 1:0] exe_mdu_out;
logic                             exe_mdu_okay;
logic [              `XLEN - 1:0] exe_rd_data;
logic [              `XLEN - 1:0] exe_pc2rd;
logic                             exe_gpr_hazard;
logic                             exe_csr_hazard;
logic                             exe_hazard;
logic [              `XLEN - 1:0] exe_csr_src1;
logic [              `XLEN - 1:0] exe_csr_src2;
logic [              `XLEN - 1:0] exe_csr_alu_out;
logic [              `XLEN - 1:0] exe_csr_wdata_pre;
logic [              `XLEN - 1:0] exe_csr_wdata;
logic                             exe_pmu_csr_wr;
logic                             exe_fpu_csr_wr;
logic                             exe_dbg_csr_wr;
logic                             exe_mmu_csr_wr;
logic                             exe_mpu_csr_wr;
logic                             exe_sru_csr_wr;
logic                             exe_sret;
logic                             exe_mret;
logic                             exe_eret_en;
logic [                      1:0] exe_misa_mxl;
logic                             exe_misa_a_ext;
logic                             exe_misa_c_ext;
logic                             exe_misa_m_ext;
logic                             exe_satp_upd;
logic                             exe_misa_upd;
logic                             exe_inst_misaligned;
logic [              `XLEN - 1:0] exe_inst_misaligned_badaddr;
logic                             exe_mstatus_tsr;
logic                             exe_mstatus_tvm;
logic                             exe_irq_en;
logic [                      1:0] exe_prv;
logic                             exe_trap_en;
logic [       `IM_ADDR_LEN - 1:0] exe_trap_epc;
logic [              `XLEN - 1:0] exe_trap_cause;
logic [              `XLEN - 1:0] exe_trap_val;
logic [              `XLEN - 1:0] exe_cause;
logic [              `XLEN - 1:0] exe_tval;
logic [    `SATP_PPN_WIDTH - 1:0] exe_satp_ppn;
logic [   `SATP_ASID_WIDTH - 1:0] exe_satp_asid;
logic [   `SATP_MODE_WIDTH - 1:0] exe_satp_mode;
logic [                     31:0] exe_fwd_table;
logic [                     31:0] exe_hz_table;

// EXE/MEM pipeline
logic [       `IM_ADDR_LEN - 1:0] exe2ma_pc;
logic [       `IM_DATA_LEN - 1:0] exe2ma_inst;
logic                             exe2ma_inst_valid;
logic                             exe2ma_amo;
logic [        `AMO_OP_LEN - 1:0] exe2ma_amo_op;
logic                             exe2ma_mem_req;
logic                             exe2ma_mem_wr;
logic                             exe2ma_mem_ex;
logic [(`DM_DATA_LEN >> 3) - 1:0] exe2ma_mem_byte;
logic                             exe2ma_mem_sign_ext;
logic                             exe2ma_len_64;
logic [              `XLEN - 1:0] exe2ma_csr_rdata;
logic                             exe2ma_pc_alu_sel;
logic                             exe2ma_csr_alu_sel;
logic                             exe2ma_mem_cal_sel;
logic                             exe2ma_rd_wr;
logic [                      4:0] exe2ma_rd_addr;
logic [                      4:0] exe2ma_rs1_addr;
logic [                      4:0] exe2ma_rs2_addr;
logic [              `XLEN - 1:0] exe2ma_rd_data;
logic [              `XLEN - 1:0] exe2ma_pc2rd;
logic [              `XLEN - 1:0] exe2ma_rs1_data;
logic [              `XLEN - 1:0] exe2ma_rs2_data;
logic                             exe2ma_csr_wr;
logic [                     11:0] exe2ma_csr_waddr;
logic [              `XLEN - 1:0] exe2ma_csr_wdata;
logic                             exe2ma_wfi;
logic [                      1:0] exe2ma_prv;
logic                             exe2ma_trap_en;
logic [              `XLEN - 1:0] exe2ma_cause;
logic [              `XLEN - 1:0] exe2ma_tval;
logic [       `IM_ADDR_LEN - 1:0] exe2ma_epc;
logic                             exe2ma_tlb_flush_req;
logic                             exe2ma_tlb_flush_all_vaddr;
logic                             exe2ma_tlb_flush_all_asid;
logic                             exe2ma_fence_i;
logic                             exe2ma_attach;
logic                             exe2ma_pipe_restart;
logic [                     31:0] exe2ma_fwd_table;
logic [                     31:0] exe2ma_hz_table;

// MA stage
logic [              `XLEN - 1:0] ma_rd_data;

logic [              `XLEN - 1:0] ma_rs1_data;
logic                             ma_dpu_req;
logic                             ma_dpu_wr;
logic                             ma_dpu_ex;
logic [(`DM_DATA_LEN >> 3) - 1:0] ma_dpu_byte;
logic [       `DM_ADDR_LEN - 1:0] ma_dpu_addr;
logic [       `DM_DATA_LEN - 1:0] ma_dpu_wdata;

logic [       `DM_DATA_LEN - 1:0] ma_dpu_amo_wdata;

logic                             ma_pipe_restart;
logic [                     31:0] ma_fwd_table;
logic [                     31:0] ma_hz_table;

// MA/MR pipeline
logic [       `IM_ADDR_LEN - 1:0] ma2mr_pc;
logic [       `IM_DATA_LEN - 1:0] ma2mr_inst;
logic                             ma2mr_inst_valid;
logic [                      4:0] ma2mr_rd_addr;
logic                             ma2mr_rd_wr;
logic [(`DM_DATA_LEN >> 3) - 1:0] ma2mr_mem_byte;
logic                             ma2mr_mem_sign_ext;
logic                             ma2mr_mem_cal_sel;
logic                             ma2mr_len_64;
logic [              `XLEN - 1:0] ma2mr_rd_data;
logic [              `XLEN - 1:0] ma2mr_pc2rd;
logic [       `DM_ADDR_LEN - 1:0] ma2mr_mem_addr;
logic [       `DM_DATA_LEN - 1:0] ma2mr_mem_wdata;
logic                             ma2mr_mem_req;
logic                             ma2mr_mem_wr;
logic                             ma2mr_csr_wr;
logic [                     11:0] ma2mr_csr_waddr;
logic [              `XLEN - 1:0] ma2mr_csr_wdata;
logic                             ma2mr_wfi;
logic [                      1:0] ma2mr_prv;
logic                             ma2mr_trap_en;
logic [              `XLEN - 1:0] ma2mr_cause;
logic [              `XLEN - 1:0] ma2mr_tval;
logic [       `IM_ADDR_LEN - 1:0] ma2mr_epc;
logic                             ma2mr_attach;
logic                             ma2mr_tlb_flush_req;
logic                             ma2mr_tlb_flush_all_vaddr;
logic                             ma2mr_tlb_flush_all_asid;
logic [              `XLEN - 1:0] ma2mr_tlb_flush_vaddr;
logic [              `XLEN - 1:0] ma2mr_tlb_flush_asid;
logic                             ma2mr_fence_i;
logic                             ma2mr_pipe_restart;
logic [                     31:0] ma2mr_fwd_table;
logic [                     31:0] ma2mr_hz_table;

// MR stage
logic                             mr_amo_wr;
logic [       `DM_DATA_LEN - 1:0] mr_dpu_rdata;
logic                             mr_dpu_hazard;
logic                             mr_dpu_fault;
logic                             mr_load_misaligned;
logic                             mr_load_page_fault;
logic                             mr_load_xes_fault;
logic                             mr_store_misaligned;
logic                             mr_store_page_fault;
logic                             mr_store_xes_fault;

logic [              `XLEN - 1:0] mr_rd_data;
logic                             mr_pipe_restart;
logic [                     31:0] mr_fwd_table;
logic [                     31:0] all_fwd_table;

// MR/WB pipeline
logic [       `IM_ADDR_LEN - 1:0] mr2wb_pc;
logic [       `IM_DATA_LEN - 1:0] mr2wb_inst;
logic                             mr2wb_inst_valid;
logic [                      4:0] mr2wb_rd_addr;
logic                             mr2wb_rd_wr;
logic [(`DM_DATA_LEN >> 3) - 1:0] mr2wb_mem_byte;
logic                             mr2wb_mem_sign_ext;
logic                             mr2wb_len_64;
logic [              `XLEN - 1:0] mr2wb_rd_data;
logic [       `DM_ADDR_LEN - 1:0] mr2wb_mem_addr;
logic [       `DM_DATA_LEN - 1:0] mr2wb_mem_wdata;
logic                             mr2wb_mem_req;
logic                             mr2wb_mem_wr;
logic                             mr2wb_dpu_fault;
logic                             mr2wb_load_misaligned;
logic                             mr2wb_load_page_fault;
logic                             mr2wb_load_xes_fault;
logic                             mr2wb_store_misaligned;
logic                             mr2wb_store_page_fault;
logic                             mr2wb_store_xes_fault;
logic                             mr2wb_csr_wr;
logic [                     11:0] mr2wb_csr_waddr;
logic [              `XLEN - 1:0] mr2wb_csr_wdata;
logic                             mr2wb_wfi;
logic [                      1:0] mr2wb_prv;
logic                             mr2wb_trap_en;
logic [              `XLEN - 1:0] mr2wb_cause;
logic [              `XLEN - 1:0] mr2wb_tval;
logic [       `IM_ADDR_LEN - 1:0] mr2wb_epc;
logic [                     31:0] mr2wb_fwd_table;
logic                             mr2wb_attach;

// WB stage
logic [              `XLEN - 1:0] wb_rd_data;
logic                             wb_rd_wr;
logic                             wb_inst_valid;
logic                             wb_wfi;

// Forward
logic                             fwd_wb2id_rd_rs1;
logic                             fwd_wb2id_rd_rs2;

resetn_synchronizer u_sync (
    .clk        ( clk       ),
    .rstn_async ( rstn      ),
    .rstn_sync  ( rstn_sync )
);

assign stall_wfi  = (exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event;
assign inst_valid = {1'b1, if2id_inst_valid, id2exe_inst_valid, exe2ma_inst_valid, ma2mr_inst_valid, mr2wb_inst_valid};

clkmnt u_clkmnt (
    .clk_free ( clk          ),
    .rstn     ( rstn_sync    ),
    .wfi      ( wb_wfi       ),
    .wakeup   ( wakeup_event ),
    .clk_ret  ( clk_wfi      ),
    .sleep    ( sleep        )
);

hzu u_hzu (
    .inst_valid      ( inst_valid      ),
    .pc_jump_en      ( if_pc_jump_en   ),
    .pc_alu_en       ( if_pc_alu_en    ),
    .irq_en          ( exe_irq_en      ),
    .trap_en         ( exe_trap_en     ),
    .eret_en         ( exe_eret_en     ),
    .pipe_restart_en ( mr_pipe_restart ),
    .id_hazard       ( id_hazard       ),
    .exe_hazard      ( exe_hazard      ),
    .dpu_hazard      ( mr_dpu_hazard   ),
    .dpu_fault       ( mr2wb_dpu_fault ),
    .id_jump_fault   ( id_jump_fault   ),
    .exe_jump_fault  ( exe_jump_fault  ),
    .if_stall        ( if_stall        ),
    .id_stall        ( id_stall        ),
    .exe_stall       ( exe_stall       ),
    .ma_stall        ( ma_stall        ),
    .mr_stall        ( mr_stall        ),
    .wb_stall        ( wb_stall        ),
    .if_flush        ( if_flush        ),
    .id_flush        ( id_flush        ),
    .exe_flush       ( exe_flush       ),
    .ma_flush        ( ma_flush        ),
    .mr_flush        ( mr_flush        ),
    .wb_flush        ( wb_flush        ),
    .if_flush_force  ( if_flush_force  ),
    .id_flush_force  ( id_flush_force  ),
    .exe_flush_force ( exe_flush_force ),
    .ma_flush_force  ( ma_flush_force  ),
    .mr_flush_force  ( mr_flush_force  ),
    .wb_flush_force  ( wb_flush_force  )
);

// IF stage
ifu u_ifu (
    .clk             ( clk                          ),
    .rstn            ( rstn_sync                    ),
    .bootvec         ( bootvec                      ),
    .ic_flush        ( ic_flush                     ),
    .misa_c_ext      ( exe_misa_c_ext               ),
    .irq_en          ( exe_irq_en | exe_trap_en     ),
    .irq_vec         ( irq_vec                      ),
    .eret_en         ( exe_eret_en                  ),
    .ret_epc         ( ret_epc                      ),
    .pc_jump_en      ( if_pc_jump_en                ),
    .pc_jump         ( if_pc_jump                   ),
    .pc_alu_en       ( if_pc_alu_en                 ),
    .pc_alu          ( if_pc_alu                    ),
    .pipe_restart_en ( mr_pipe_restart              ),
    .pipe_restart    ( ma2mr_pc2rd                  ),
    .id_jump_fault   ( id_jump_fault                ),
    .exe_jump_fault  ( exe_jump_fault               ),
    .jump_token      ( if_jump_token                ),
    .imem_req        ( imem_en                      ),
    .imem_addr       ( imem_addr                    ),
    .imem_rdata      ( imem_rdata                   ),
    .imem_bad        ( imem_bad                     ),
    .imem_busy       ( imem_busy                    ),
    .id_pc           ( if2id_pc                     ),
    .exe_pc          ( id2exe_pc                    ),
    .pc              ( if_pc                        ),
    .inst            ( if_inst                      ),
    .inst_valid      ( if_inst_valid                ),
    .misaligned_epc  ( if_inst_misaligned_epc       ),
    .misaligned      ( if_inst_misaligned           ),
    .page_fault      ( if_inst_page_fault           ),
    .xes_fault       ( if_inst_xes_fault            ),
    .badaddr         ( if_inst_badaddr              ),
    .flush           ( if_flush                     ),
    .stall           ( if_stall | stall_wfi | sleep ),
    .attach          ( attach                       ),
    .dbg_exec        ( dbg_exec                     ),
    .dbg_inst        ( dbg_inst                     )
);

assign exe_branch_match = id2exe_branch & ~exe_hazard & (id2exe_branch_zcmp == exe_alu_zero);

assign if_pc_jump_en = id_jump & ~if2id_stall_flag & ~if2id_jump_token & if2id_inst_valid;
assign if_pc_jump    = id_imm + if2id_pc;
assign if_pc_alu_en  = (id2exe_jump_alu | exe_branch_match);
assign if_pc_alu     = ({`IM_ADDR_LEN{id2exe_jump_alu}}  & exe_alu_out) |
                       ({`IM_ADDR_LEN{exe_branch_match}} & exe_pc_imm[`IM_ADDR_LEN - 1:0] );

// IF/ID pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
    if (~rstn_sync) begin
        if2id_pc                  <= `IM_ADDR_LEN'b0;
        if2id_inst                <= `IM_DATA_LEN'b0;
        if2id_inst_valid          <= 1'b0;
        if2id_inst_misaligned_epc <= `IM_ADDR_LEN'b0;
        if2id_inst_misaligned     <= 1'b0;
        if2id_inst_page_fault     <= 1'b0;
        if2id_inst_xes_fault      <= 1'b0;
        if2id_inst_badaddr        <= `IM_ADDR_LEN'b0;
        if2id_jump_token          <= 1'b0;
        if2id_attach              <= 1'b0;
        if2id_stall_flag          <= 1'b0;
    end
    else begin
        if ((~id_stall & ~stall_wfi) | if_flush_force) begin
            if2id_pc                  <= if_pc;
            if2id_inst                <= {`IM_DATA_LEN{if_inst_valid}} & if_inst;
            if2id_inst_valid          <= ~if_flush & if_inst_valid;
            if2id_inst_misaligned_epc <= if_inst_misaligned_epc;
            if2id_inst_misaligned     <= if_inst_misaligned;
            if2id_inst_page_fault     <= if_inst_page_fault;
            if2id_inst_xes_fault      <= if_inst_xes_fault;
            if2id_inst_badaddr        <= if_inst_badaddr;
            if2id_jump_token          <= if_jump_token;
            if2id_attach              <= attach;
            if2id_stall_flag          <= 1'b0;
        end
        else begin
            if2id_inst_valid          <= ~id_jump_fault & if2id_inst_valid;
            if2id_stall_flag          <= 1'b1;
        end
    end
end

// ID stage
idu u_idu (
    .clk                 ( clk_wfi                ),
    .rstn                ( rstn_sync              ),
    .inst                ( if2id_inst             ),
    .inst_valid          ( if2id_inst_valid       ),
    .misa_mxl            ( exe_misa_mxl           ),
    .misa_a_ext          ( exe_misa_a_ext         ),
    .misa_c_ext          ( exe_misa_c_ext         ),
    .misa_m_ext          ( exe_misa_m_ext         ),
    .pc                  ( if2id_pc               ),
    .rd_wr_i             ( wb_rd_wr               ),
    .rd_addr_i           ( mr2wb_rd_addr          ),
    .rd_data             ( wb_rd_data             ),
    .rd_addr_o           ( id_rd_addr             ),
    .rs1_addr            ( id_rs1_addr            ),
    .rs2_addr            ( id_rs2_addr            ),
    .rs1_data            ( id_gpr_rs1_data        ),
    .rs2_data            ( id_gpr_rs2_data        ),
    .csr_addr            ( id_csr_addr            ),
    .len_64_o            ( id_len_64              ),
    .len_64_i            ( mr2wb_len_64           ),
    .imm                 ( id_imm                 ),

    // Control
    .prv_req             ( id_prv_req             ),
    .ill_inst            ( id_ill_inst            ),
    .fence               ( id_fence               ),
    .fence_i             ( id_fence_i             ),
    .ecall               ( id_ecall               ),
    .ebreak              ( id_ebreak              ),
    .wfi                 ( id_wfi                 ),
    .sret                ( id_sret                ),
    .mret                ( id_mret                ),
    .jump                ( id_jump                ),
    .jump_alu            ( id_jump_alu            ),

    // For EXE stage
    .rs1_rd              ( id_rs1_rd              ),
    .rs2_rd              ( id_rs2_rd              ),
    .mdu_sel             ( id_mdu_sel             ),
    .mdu_op              ( id_mdu_op              ),
    .alu_op              ( id_alu_op              ),
    .rs1_zero_sel        ( id_rs1_zero_sel        ),
    .rs2_imm_sel         ( id_rs2_imm_sel         ),
    .pc_imm_sel          ( id_pc_imm_sel          ),
    .branch              ( id_branch              ),
    .branch_zcmp         ( id_branch_zcmp         ),
    .csr_op              ( id_csr_op              ),
    .uimm_rs1_sel        ( id_uimm_rs1_sel        ),
    .csr_rd              ( id_csr_rd              ),
    .csr_wr              ( id_csr_wr              ),

    // For MEM stage
    .pc_alu_sel          ( id_pc_alu_sel          ),
    .csr_alu_sel         ( id_csr_alu_sel         ),
    .amo                 ( id_amo                 ),
    .amo_op              ( id_amo_op              ),
    .mem_req             ( id_mem_req             ),
    .mem_wr              ( id_mem_wr              ),
    .mem_ex              ( id_mem_ex              ),
    .mem_byte            ( id_mem_byte            ),
    .mem_sign_ext        ( id_mem_sign_ext        ),
    .tlb_flush_req       ( id_tlb_flush_req       ),
    .tlb_flush_all_vaddr ( id_tlb_flush_all_vaddr ),
    .tlb_flush_all_asid  ( id_tlb_flush_all_asid  ),

    // For WB stage
    .mem_cal_sel         ( id_mem_cal_sel         ),
    .rd_wr_o             ( id_rd_wr               ),

    .halted              ( halted                 ),
    .dbg_addr            ( dbg_addr               ),
    .dbg_wdata           ( dbg_wdata              ),
    .dbg_gpr_rd          ( dbg_gpr_rd             ),
    .dbg_gpr_wr          ( dbg_gpr_wr             ),
    .dbg_gpr_out         ( dbg_gpr_out            ),
    .dbg_csr_rd          ( dbg_csr_rd             ),
    .dbg_csr_wr          ( dbg_csr_wr             )
);

assign id_fpu_csr_rdata = `XLEN'b0;
assign id_dbg_csr_rdata = `XLEN'b0;

csr u_csr (
    .clk           ( clk_wfi          ),
    .rstn          ( rstn_sync        ),
    .misa_mxl      ( exe_misa_mxl     ),
    .rd            ( id_csr_rd        ),
    .wr            ( id_csr_wr        ),
    .raddr         ( id_csr_addr      ),
    .rdata         ( id_csr_rdata     ),
    .pmu_csr_wr    ( id_pmu_csr_wr    ),
    .fpu_csr_wr    ( id_fpu_csr_wr    ),
    .dbg_csr_wr    ( id_dbg_csr_wr    ),
    .mmu_csr_wr    ( id_mmu_csr_wr    ),
    .mpu_csr_wr    ( id_mpu_csr_wr    ),
    .sru_csr_wr    ( id_sru_csr_wr    ),
    .pmu_csr_rdata ( id_pmu_csr_rdata ),
    .fpu_csr_rdata ( id_fpu_csr_rdata ),
    .dbg_csr_rdata ( id_dbg_csr_rdata ),
    .mmu_csr_rdata ( id_mmu_csr_rdata ),
    .mpu_csr_rdata ( id_mpu_csr_rdata ),
    .sru_csr_rdata ( id_sru_csr_rdata )
);

assign dbg_csr_out = id_csr_rdata;

// ID forward
assign fwd_wb2id_rd_rs1 = mr2wb_rd_wr & (id_rs1_addr == mr2wb_rd_addr );
assign fwd_wb2id_rd_rs2 = mr2wb_rd_wr & (id_rs2_addr == mr2wb_rd_addr );

assign id_rs1_data = fwd_wb2id_rd_rs1 ? mr2wb_rd_data :
                                        id_gpr_rs1_data;
assign id_rs2_data = fwd_wb2id_rd_rs2 ? mr2wb_rd_data :
                                        id_gpr_rs2_data;

// ID Hazard
assign id_hazard = (id_csr_rd &&
                    (exe_pmu_csr_wr | exe_fpu_csr_wr | exe_dbg_csr_wr |
                     exe_mmu_csr_wr | exe_mpu_csr_wr | exe_sru_csr_wr) &&
                    (id_csr_addr == id2exe_csr_waddr));


// ID/EXE pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
    if (~rstn_sync) begin
        id2exe_pc                  <= `IM_ADDR_LEN'b0;
        id2exe_inst                <= `IM_DATA_LEN'b0;
        id2exe_inst_valid          <= 1'b0;
        id2exe_rd_addr             <= 5'b0;
        id2exe_rs1_addr            <= 5'b0;
        id2exe_rs2_addr            <= 5'b0;
        id2exe_rs1_data            <= `XLEN'b0;
        id2exe_rs2_data            <= `XLEN'b0;
        id2exe_csr_waddr           <= 12'b0;
        id2exe_csr_rdata           <= `XLEN'b0;
        id2exe_len_64              <= 1'b0;
        id2exe_imm                 <= `XLEN'b0;
        id2exe_rs1_rd              <= 1'b0;
        id2exe_rs2_rd              <= 1'b0;
        id2exe_mdu_sel             <= 1'b0;
        id2exe_mdu_op              <= `MDU_OP_LEN'b0;
        id2exe_alu_op              <= `ALU_OP_LEN'b0;
        id2exe_rs1_zero_sel        <= 1'b0;
        id2exe_rs2_imm_sel         <= 1'b0;
        id2exe_pc_imm_sel          <= 1'b0;
        id2exe_jump_alu            <= 1'b0;
        id2exe_branch              <= 1'b0;
        id2exe_branch_zcmp         <= 1'b0;
        id2exe_csr_op              <= `CSR_OP_LEN'b0;
        id2exe_uimm_rs1_sel        <= 1'b0;
        id2exe_csr_rd              <= 1'b0;
        id2exe_pmu_csr_wr          <= 1'b0;
        id2exe_fpu_csr_wr          <= 1'b0;
        id2exe_dbg_csr_wr          <= 1'b0;
        id2exe_mmu_csr_wr          <= 1'b0;
        id2exe_mpu_csr_wr          <= 1'b0;
        id2exe_sru_csr_wr          <= 1'b0;
        id2exe_pc_alu_sel          <= 1'b0;
        id2exe_csr_alu_sel         <= 1'b0;
        id2exe_amo                 <= 1'b0;
        id2exe_amo_op              <= `AMO_OP_LEN'b0;
        id2exe_mem_req             <= 1'b0;
        id2exe_mem_wr              <= 1'b0;
        id2exe_mem_ex              <= 1'b0;
        id2exe_mem_byte            <= {(`DM_DATA_LEN >> 3){1'b0}};
        id2exe_mem_sign_ext        <= 1'b0;
        id2exe_mem_cal_sel         <= 1'b0;
        id2exe_rd_wr               <= 1'b0;
        id2exe_wfi                 <= 1'b0;
        id2exe_ecall               <= 1'b0;
        id2exe_ebreak              <= 1'b0;
        id2exe_sret                <= 1'b0;
        id2exe_mret                <= 1'b0;
        id2exe_ill_inst            <= 1'b0;
        id2exe_prv_req             <= 2'b0;
        id2exe_inst_misaligned_epc <= `IM_ADDR_LEN'b0;
        id2exe_inst_misaligned     <= 1'b0;
        id2exe_inst_page_fault     <= 1'b0;
        id2exe_inst_xes_fault      <= 1'b0;
        id2exe_inst_badaddr        <= `IM_ADDR_LEN'b0;
        id2exe_tlb_flush_req       <= 1'b0;
        id2exe_tlb_flush_all_vaddr <= 1'b0;
        id2exe_tlb_flush_all_asid  <= 1'b0;
        id2exe_fence_i             <= 1'b0;
        id2exe_attach              <= 1'b0;
        id2exe_ext_csr_wr          <= 1'b0;
        id2exe_ext_csr_wdata       <= 32'b0;
    end
    else begin
        if ((~exe_stall & ~stall_wfi) | id_flush_force) begin
            id2exe_pc                  <= if2id_pc;
            id2exe_inst                <= if2id_inst;
            id2exe_inst_valid          <= ~id_flush & ~id_jump_fault & if2id_inst_valid;
            id2exe_rd_addr             <= id_rd_addr;
            id2exe_rs1_addr            <= id_rs1_addr;
            id2exe_rs2_addr            <= id_rs2_addr;
            id2exe_rs1_data            <= id_rs1_data;
            id2exe_rs2_data            <= id_rs2_data;
            id2exe_csr_waddr           <= id_csr_addr;
            id2exe_csr_rdata           <= id_csr_rdata;
            id2exe_len_64              <= id_len_64;
            id2exe_imm                 <= id_imm;
            id2exe_rs1_rd              <= id_rs1_rd;
            id2exe_rs2_rd              <= id_rs2_rd;
            id2exe_mdu_sel             <= id_mdu_sel;
            id2exe_mdu_op              <= id_mdu_op;
            id2exe_alu_op              <= id_alu_op;
            id2exe_rs1_zero_sel        <= id_rs1_zero_sel;
            id2exe_rs2_imm_sel         <= id_rs2_imm_sel;
            id2exe_pc_imm_sel          <= id_pc_imm_sel;
            id2exe_jump_alu            <= ~id_flush & ~id_jump_fault &id_jump_alu;
            id2exe_branch              <= ~id_flush & ~id_jump_fault &id_branch;
            id2exe_branch_zcmp         <= id_branch_zcmp;
            id2exe_csr_op              <= id_csr_op;
            id2exe_uimm_rs1_sel        <= id_uimm_rs1_sel;
            id2exe_csr_rd              <= ~id_flush & ~id_jump_fault & id_csr_rd;
            id2exe_pmu_csr_wr          <= ~id_flush & ~id_jump_fault & id_pmu_csr_wr;
            id2exe_fpu_csr_wr          <= ~id_flush & ~id_jump_fault & id_fpu_csr_wr;
            id2exe_dbg_csr_wr          <= ~id_flush & ~id_jump_fault & id_dbg_csr_wr;
            id2exe_mmu_csr_wr          <= ~id_flush & ~id_jump_fault & id_mmu_csr_wr;
            id2exe_mpu_csr_wr          <= ~id_flush & ~id_jump_fault & id_mpu_csr_wr;
            id2exe_sru_csr_wr          <= ~id_flush & ~id_jump_fault & id_sru_csr_wr;
            id2exe_pc_alu_sel          <= id_pc_alu_sel;
            id2exe_csr_alu_sel         <= id_csr_alu_sel;
            id2exe_amo                 <= id_amo;
            id2exe_amo_op              <= id_amo_op;
            id2exe_mem_req             <= ~id_flush & ~id_jump_fault & id_mem_req;
            id2exe_mem_wr              <= ~id_flush & ~id_jump_fault & id_mem_wr;
            id2exe_mem_ex              <= id_mem_ex;
            id2exe_mem_byte            <= id_mem_byte;
            id2exe_mem_sign_ext        <= id_mem_sign_ext;
            id2exe_mem_cal_sel         <= id_mem_cal_sel;
            id2exe_rd_wr               <= ~id_flush & ~id_jump_fault & id_rd_wr;
            id2exe_wfi                 <= ~id_flush & ~id_jump_fault & id_wfi;
            id2exe_ecall               <= ~id_flush & ~id_jump_fault & id_ecall;
            id2exe_ebreak              <= ~id_flush & ~id_jump_fault & id_ebreak;
            id2exe_sret                <= ~id_flush & ~id_jump_fault & id_sret;
            id2exe_mret                <= ~id_flush & ~id_jump_fault & id_mret;
            id2exe_ill_inst            <= ~id_flush & ~id_jump_fault & id_ill_inst;
            id2exe_prv_req             <= id_prv_req;
            id2exe_inst_misaligned_epc <= if2id_inst_misaligned_epc;
            id2exe_inst_misaligned     <= if2id_inst_misaligned;
            id2exe_inst_page_fault     <= if2id_inst_page_fault;
            id2exe_inst_xes_fault      <= if2id_inst_xes_fault;
            id2exe_inst_badaddr        <= if2id_inst_badaddr;
            id2exe_tlb_flush_req       <= ~id_flush & ~id_jump_fault & id_tlb_flush_req;
            id2exe_tlb_flush_all_vaddr <= id_tlb_flush_all_vaddr;
            id2exe_tlb_flush_all_asid  <= id_tlb_flush_all_asid;
            id2exe_fence_i             <= ~id_flush & ~id_jump_fault & id_fence_i;
            id2exe_attach              <= if2id_attach;
            id2exe_ext_csr_wr          <= dbg_csr_wr;
            id2exe_ext_csr_wdata       <= dbg_wdata;
        end
        else begin
            id2exe_inst_valid          <= ~exe_jump_fault & id2exe_inst_valid;
            id2exe_rs1_data            <= exe_rs1_data;
            id2exe_rs2_data            <= exe_rs2_data;
            id2exe_branch              <= exe_hazard & id2exe_branch;
            id2exe_jump_alu            <= 1'b0;
        end
    end
end

// EXE stage
assign exe_fwd_table = {31'b0, (id2exe_rd_wr & ~id2exe_mem_req)} << id2exe_rd_addr;
assign exe_hz_table  = {31'b0, (id2exe_rd_wr &  id2exe_mem_req)} << id2exe_rd_addr;
// RS1 Forward
assign exe_rs1_data  = ({`XLEN{ exe2ma_fwd_table   [id2exe_rs1_addr]}} & ma_rd_data     ) |
                       ({`XLEN{ ma2mr_fwd_table    [id2exe_rs1_addr]}} & ma2mr_rd_data  ) |
                       ({`XLEN{ mr2wb_fwd_table    [id2exe_rs1_addr]}} & wb_rd_data     ) |
                       ({`XLEN{~exe2ma_fwd_table   [id2exe_rs1_addr]&
                               ~ma2mr_fwd_table    [id2exe_rs1_addr]&
                               ~mr2wb_fwd_table    [id2exe_rs1_addr]}} & id2exe_rs1_data);

// RS2 Forward
assign exe_rs2_data  = ({`XLEN{ exe2ma_fwd_table   [id2exe_rs2_addr]}} & ma_rd_data     ) |
                       ({`XLEN{ ma2mr_fwd_table    [id2exe_rs2_addr]}} & ma2mr_rd_data  ) |
                       ({`XLEN{ mr2wb_fwd_table    [id2exe_rs2_addr]}} & wb_rd_data     ) |
                       ({`XLEN{~exe2ma_fwd_table   [id2exe_rs2_addr]&
                               ~ma2mr_fwd_table    [id2exe_rs2_addr]&
                               ~mr2wb_fwd_table    [id2exe_rs2_addr]}} & id2exe_rs2_data);

assign exe_gpr_hazard = (id2exe_rs1_rd && (exe2ma_hz_table[id2exe_rs1_addr] || ma2mr_hz_table[id2exe_rs1_addr])) ||
                        (id2exe_rs2_rd && (exe2ma_hz_table[id2exe_rs2_addr] || ma2mr_hz_table[id2exe_rs2_addr])) ||
                        ma_pipe_restart || exe2ma_amo || (id2exe_mdu_sel && ~exe_mdu_okay);
assign exe_csr_hazard = exe2ma_mem_req   & (id2exe_pmu_csr_wr | id2exe_fpu_csr_wr | id2exe_dbg_csr_wr | 
                        id2exe_mmu_csr_wr | id2exe_mpu_csr_wr | id2exe_sru_csr_wr | id2exe_sret | id2exe_mret);

assign exe_hazard = exe_gpr_hazard | exe_csr_hazard;


assign exe_pc_imm   = {{(`XLEN - `IM_ADDR_LEN){id2exe_pc[`IM_ADDR_LEN - 1]}}, id2exe_pc} + id2exe_imm;
assign exe_pc_add_4 = {{(`XLEN - `IM_ADDR_LEN){id2exe_pc[`IM_ADDR_LEN - 1]}}, id2exe_pc} + (id2exe_inst[1:0] == 2'b11 ? `XLEN'h4 : `XLEN'h2);
assign exe_pc2rd    = id2exe_pc_imm_sel   ? exe_pc_imm : exe_pc_add_4;

assign exe_alu_src1 = id2exe_rs1_zero_sel ? exe_rs1_data : `XLEN'b0;
assign exe_alu_src2 = id2exe_rs2_imm_sel  ? exe_rs2_data : id2exe_imm;

alu u_alu (
   .alu_op    ( id2exe_alu_op ),
   .len_64    ( id2exe_len_64 ),
   .src1      ( exe_alu_src1  ),
   .src2      ( exe_alu_src2  ),
   .out       ( exe_alu_out   ),
   .zero_flag ( exe_alu_zero  )
);

mdu u_mdu(
    .clk    ( clk_wfi         ),
    .rstn   ( rstn_sync       ),
    .len_64 ( id2exe_len_64   ),
    .trig   ( id2exe_mdu_sel  ),
    .mdu_op ( id2exe_mdu_op   ),
    .flush  ( exe_flush_force ),
    .src1   ( exe_alu_src1    ),
    .src2   ( exe_alu_src2    ),
    .out    ( exe_mdu_out     ),
    .okay   ( exe_mdu_okay    )
);

assign exe_rd_data = ({`XLEN{ id2exe_mdu_sel}} & exe_mdu_out) |
                     ({`XLEN{~id2exe_mdu_sel}} & exe_alu_out);

assign exe_pmu_csr_wr = id2exe_pmu_csr_wr & ~exe_flush_force & ~exe_hazard & ~exe_trap_en & ~stall_wfi;
assign exe_fpu_csr_wr = id2exe_fpu_csr_wr & ~exe_flush_force & ~exe_hazard & ~exe_trap_en & ~stall_wfi;
assign exe_dbg_csr_wr = id2exe_dbg_csr_wr & ~exe_flush_force & ~exe_hazard & ~exe_trap_en & ~stall_wfi;
assign exe_mmu_csr_wr = id2exe_mmu_csr_wr & ~exe_flush_force & ~exe_hazard & ~exe_trap_en & ~stall_wfi;
assign exe_mpu_csr_wr = id2exe_mpu_csr_wr & ~exe_flush_force & ~exe_hazard & ~exe_trap_en & ~stall_wfi;
assign exe_sru_csr_wr = id2exe_sru_csr_wr & ~exe_flush_force & ~exe_hazard & ~exe_trap_en & ~stall_wfi;
assign exe_sret       = id2exe_sret       & ~exe_flush_force & ~exe_hazard & ~exe_trap_en & ~stall_wfi;
assign exe_mret       = id2exe_mret       & ~exe_flush_force & ~exe_hazard & ~exe_trap_en & ~stall_wfi;

assign exe_csr_src1 = id2exe_csr_rdata;
assign exe_csr_src2 = id2exe_uimm_rs1_sel ? {{(`XLEN-5){1'b0}}, id2exe_rs1_addr} : exe_rs1_data;

sru u_sru (
    .clk         ( clk_wfi           ),
    .clk_free    ( clk               ),
    .rstn        ( rstn_sync         ),
    .sleep       ( sleep             ),
    .misaligned  ( id2exe_pc[1]      ),
    .prv         ( exe_prv           ),
    .tvm         ( exe_mstatus_tvm   ),
    .tsr         ( exe_mstatus_tsr   ),
    .sum         ( sum               ),
    .mprv        ( mprv              ),
    .mpp         ( mpp               ),

    // IRQ signal
    .ext_msip    ( msip              ),
    .ext_mtip    ( mtip              ),
    .ext_meip    ( meip              ),
    .wakeup      ( wakeup_event      ),
    .irq_trigger ( exe_irq_en        ),
    .cause       ( exe_cause         ),
    .tval        ( exe_tval          ),

    // PC control
    .trap_vec    ( irq_vec           ),
    .ret_epc     ( ret_epc           ),

    // Trap signal
    .trap_epc    ( exe_trap_epc      ),
    .trap_en     ( exe_trap_en       ),
    .trap_cause  ( exe_trap_cause    ),
    .trap_val    ( exe_trap_val      ),
    .sret        ( exe_sret          ),
    .mret        ( exe_mret          ),
    .eret_en     ( exe_eret_en       ),

    // Extension flag
    .misa_mxl    ( exe_misa_mxl      ),
    .misa_a_ext  ( exe_misa_a_ext    ),
    .misa_c_ext  ( exe_misa_c_ext    ),
    .misa_m_ext  ( exe_misa_m_ext    ),
    
    // CSR interface
    .csr_wr      ( exe_sru_csr_wr    ),
    .csr_waddr   ( id2exe_csr_waddr  ),
    .csr_raddr   ( id_csr_addr       ),
    .csr_wdata   ( exe_csr_wdata     ),
    .csr_rdata   ( id_sru_csr_rdata  )
);

mmu_csr u_mmu_csr (
    .clk       ( clk_wfi          ),
    .rstn      ( rstn_sync        ),

    .misa_mxl  ( exe_misa_mxl     ),

    .satp_ppn  ( exe_satp_ppn     ),
    .satp_asid ( exe_satp_asid    ),
    .satp_mode ( exe_satp_mode    ),

    // CSR interface
    .csr_wr    ( exe_mmu_csr_wr   ),
    .csr_waddr ( id2exe_csr_waddr ),
    .csr_raddr ( id_csr_addr      ),
    .csr_wdata ( exe_csr_wdata    ),
    .csr_rdata ( id_mmu_csr_rdata )
);

mpu_csr u_mpu_csr (
    .clk       ( clk_wfi          ),
    .rstn      ( rstn_sync        ),
    .misa_mxl  ( exe_misa_mxl     ),
    .pmpcfg    ( pmpcfg           ),
    .pmpaddr   ( pmpaddr          ),
    .pmacfg    ( pmacfg           ),
    .pmaaddr   ( pmaaddr          ),

    // CSR interface
    .csr_wr    ( exe_mpu_csr_wr   ),
    .csr_waddr ( id2exe_csr_waddr ),
    .csr_raddr ( id_csr_addr      ),
    .csr_wdata ( exe_csr_wdata    ),
    .csr_rdata ( id_mpu_csr_rdata )

);
assign exe_satp_upd = (id2exe_mmu_csr_wr | id2exe_csr_rd) &
                      ~exe_csr_hazard & ~stall_wfi && id2exe_csr_waddr == `CSR_SATP_ADDR;
assign exe_misa_upd =  id2exe_sru_csr_wr &
                      ~exe_csr_hazard & ~stall_wfi && id2exe_csr_waddr == `CSR_MISA_ADDR;

tpu u_tpu (
    .inst_valid          ( id2exe_inst_valid & ~exe_hazard & ~stall_wfi),
    .inst                ( id2exe_inst                 ),
    .exe_pc              ( id2exe_pc                   ),
    .wb_pc               ( mr2wb_pc                    ),
    .ldst_badaddr        ( mr2wb_mem_addr              ),
    .inst_badaddr        ( id2exe_inst_badaddr         ),
    .prv_cur             ( exe_prv                     ),
    .prv_req             ( id2exe_prv_req              ),
    .satp_upd            ( exe_satp_upd                ),
    .tsr                 ( exe_mstatus_tsr             ),
    .tvm                 ( exe_mstatus_tvm             ),
    .sret                ( id2exe_sret                 ),
    .ecall               ( id2exe_ecall                ),
    .ebreak              ( id2exe_ebreak               ),
    .tlb_flush_req       ( id2exe_tlb_flush_req        ),
    .ill_inst            ( id2exe_ill_inst             ),
    .inst_misaligned_epc ( id2exe_inst_misaligned_epc  ),
    .inst_misaligned     ( id2exe_inst_misaligned      ),
    .inst_pg_fault       ( id2exe_inst_page_fault      ),
    .inst_xes_fault      ( id2exe_inst_xes_fault       ),
    .load_misaligned     ( mr2wb_load_misaligned       ),
    .load_pg_fault       ( mr2wb_load_page_fault       ),
    .load_xes_fault      ( mr2wb_load_xes_fault        ),
    .store_misaligned    ( mr2wb_store_misaligned      ),
    .store_pg_fault      ( mr2wb_store_page_fault      ),
    .store_xes_fault     ( mr2wb_store_xes_fault       ),
    .trap_en             ( exe_trap_en                 ),
    .trap_cause          ( exe_trap_cause              ),
    .trap_val            ( exe_trap_val                ),
    .trap_epc            ( exe_trap_epc                )
);

assign satp_ppn    = exe_satp_ppn;
assign satp_asid   = exe_satp_asid;
assign satp_mode   = exe_satp_mode;
assign prv         = exe_prv;

csr_alu u_csr_alu(
    .csr_op ( id2exe_csr_op   ),
    .src1   ( exe_csr_src1    ),
    .src2   ( exe_csr_src2    ),
    .out    ( exe_csr_alu_out )
);

assign exe_csr_wdata_pre = id2exe_ext_csr_wr ? id2exe_ext_csr_wdata : exe_csr_alu_out;
assign exe_csr_wdata     = exe_misa_mxl == 1'h1 ? {32'b0, exe_csr_wdata_pre[31:0]}:
                                                  exe_csr_wdata_pre;

// EXE/MA pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
    if (~rstn_sync) begin
        exe2ma_pc                  <= `IM_ADDR_LEN'b0;
        exe2ma_inst                <= `IM_DATA_LEN'b0;
        exe2ma_inst_valid          <= 1'b0;
        exe2ma_amo                 <= 1'b0;
        exe2ma_amo_op              <= `AMO_OP_LEN'b0;
        exe2ma_mem_req             <= 1'b0;
        exe2ma_mem_wr              <= 1'b0;
        exe2ma_mem_ex              <= 1'b0;
        exe2ma_mem_byte            <= {(`DM_DATA_LEN >> 3){1'b0}};
        exe2ma_mem_sign_ext        <= 1'b0;
        exe2ma_len_64              <= 1'b0;
        exe2ma_pc_alu_sel          <= 1'b0;
        exe2ma_csr_rdata           <= `XLEN'b0;
        exe2ma_csr_alu_sel         <= 1'b0;
        exe2ma_mem_cal_sel         <= 1'b0;
        exe2ma_rd_wr               <= 1'b0;
        exe2ma_rd_addr             <= 5'b0;
        exe2ma_rs1_addr            <= 5'b0;
        exe2ma_rs2_addr            <= 5'b0;
        exe2ma_rd_data             <= `XLEN'b0;
        exe2ma_pc2rd               <= `XLEN'b0;
        exe2ma_rs1_data            <= `XLEN'b0;
        exe2ma_rs2_data            <= `XLEN'b0;
        exe2ma_csr_wr              <= 1'b0;
        exe2ma_csr_waddr           <= 12'b0;
        exe2ma_csr_wdata           <= `XLEN'b0;
        exe2ma_wfi                 <= 1'b0;
        exe2ma_prv                 <= 2'b0;
        exe2ma_trap_en             <= 1'b0;
        exe2ma_cause               <= `XLEN'b0;
        exe2ma_tval                <= `XLEN'b0;
        exe2ma_epc                 <= `IM_DATA_LEN'b0;
        exe2ma_tlb_flush_req       <= 1'b0;
        exe2ma_tlb_flush_all_vaddr <= 1'b0;
        exe2ma_tlb_flush_all_asid  <= 1'b0;
        exe2ma_fence_i             <= 1'b0;
        exe2ma_fwd_table           <= 32'b0;
        exe2ma_hz_table            <= 32'b0;
        exe2ma_attach              <= 1'b0;
        exe2ma_pipe_restart        <= 1'b0;
    end
    else begin
        if (~ma_stall | exe_flush_force) begin
            exe2ma_pc                  <= id2exe_pc;
            exe2ma_inst                <= id2exe_inst;
            exe2ma_inst_valid          <= ~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~((exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event) & id2exe_inst_valid;
            exe2ma_amo                 <= id2exe_amo;
            exe2ma_amo_op              <= id2exe_amo_op;
            exe2ma_mem_req             <= ~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~((exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event) & id2exe_mem_req;
            exe2ma_mem_wr              <= ~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~((exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event) & id2exe_mem_wr;
            exe2ma_mem_ex              <= id2exe_mem_ex;
            exe2ma_mem_byte            <= id2exe_mem_byte;
            exe2ma_mem_sign_ext        <= id2exe_mem_sign_ext;
            exe2ma_len_64              <= id2exe_len_64;
            exe2ma_pc_alu_sel          <= id2exe_pc_alu_sel;
            exe2ma_csr_rdata           <= id2exe_csr_rdata;
            exe2ma_csr_alu_sel         <= id2exe_csr_alu_sel;
            exe2ma_mem_cal_sel         <= id2exe_mem_cal_sel;
            exe2ma_rd_wr               <= ~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~((exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event) & id2exe_rd_wr;
            exe2ma_rd_addr             <= id2exe_rd_addr;
            exe2ma_rs1_addr            <= id2exe_rs1_addr;
            exe2ma_rs2_addr            <= id2exe_rs2_addr;
            exe2ma_rd_data             <= exe_rd_data;
            exe2ma_pc2rd               <= exe_pc2rd;
            exe2ma_rs1_data            <= exe_rs1_data;
            exe2ma_rs2_data            <= exe_rs2_data;
            exe2ma_csr_wr              <= ~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~((exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event) &
                                           (exe_pmu_csr_wr|
                                            exe_fpu_csr_wr|
                                            exe_dbg_csr_wr|
                                            exe_mmu_csr_wr|
                                            exe_mpu_csr_wr|
                                            exe_sru_csr_wr);
            exe2ma_csr_waddr           <= id2exe_csr_waddr;
            exe2ma_csr_wdata           <= exe_csr_wdata;
            exe2ma_wfi                 <= ~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~exe2ma_wfi & ~wakeup_event & id2exe_wfi;
            exe2ma_prv                 <= exe_prv;
            exe2ma_trap_en             <= exe_irq_en | exe_trap_en;
            exe2ma_cause               <= exe_cause;
            exe2ma_tval                <= exe_tval;
            exe2ma_epc                 <= exe_trap_epc;
            exe2ma_tlb_flush_req       <= ~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~((exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event) & id2exe_tlb_flush_req;
            exe2ma_tlb_flush_all_vaddr <= id2exe_tlb_flush_all_vaddr;
            exe2ma_tlb_flush_all_asid  <= id2exe_tlb_flush_all_asid;
            exe2ma_fence_i             <= ~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~((exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event) & id2exe_fence_i;
            exe2ma_fwd_table           <= {32{~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~((exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event)}} & exe_fwd_table;
            exe2ma_hz_table            <= {32{~exe_flush & ~exe_jump_fault & ~exe_irq_en & ~((exe2ma_wfi | ma2mr_wfi | mr2wb_wfi) & ~wakeup_event)}} & exe_hz_table;
            exe2ma_attach              <= id2exe_attach;
            exe2ma_pipe_restart        <= exe_misa_upd;
        end
        else begin
            exe2ma_rs1_data            <= ma_rs1_data;
            exe2ma_rs2_data            <= ma_dpu_wdata;
        end
    end
end

// MEMORY ACCESS stage
// MEM_ADDR Forward
assign ma_fwd_table = exe2ma_fwd_table & ~exe_fwd_table & ~exe_hz_table;
assign ma_hz_table  = exe2ma_hz_table;

assign ma_dpu_req   = ~ma_flush_force & exe2ma_mem_req;
assign ma_dpu_wr    = exe2ma_mem_wr;
assign ma_dpu_ex    = exe2ma_mem_ex;
assign ma_dpu_byte  = exe2ma_mem_byte;
assign ma_dpu_addr  = exe2ma_rd_data;

assign ma_rs1_data  = ({`XLEN{ mr2wb_fwd_table [exe2ma_rs1_addr]}} & wb_rd_data     ) |
                      ({`XLEN{~mr2wb_fwd_table [exe2ma_rs1_addr]}} & exe2ma_rs1_data);
assign ma_dpu_wdata = ({`XLEN{ mr2wb_fwd_table [exe2ma_rs2_addr]}} & wb_rd_data     ) |
                      ({`XLEN{~mr2wb_fwd_table [exe2ma_rs2_addr]}} & exe2ma_rs2_data);

assign ma_pipe_restart = exe2ma_tlb_flush_req || exe2ma_fence_i || exe2ma_pipe_restart;

dpu u_dpu (
    .clk              ( clk_wfi              ),
    .rstn             ( rstn                 ),

    .len_64           ( exe2ma_len_64        ),

    .amo_i            ( exe2ma_amo           ),
    .amo_op_i         ( exe2ma_amo_op        ),
    .pc_i             ( exe2ma_pc            ),
    .sign_ext_i       ( exe2ma_mem_sign_ext  ),
    .req_i            ( ma_dpu_req           ),
    .wr_i             ( ma_dpu_wr            ),
    .ex_i             ( ma_dpu_ex            ),
    .byte_i           ( ma_dpu_byte          ),
    .addr_i           ( ma_dpu_addr          ),
    .wdata_i          ( ma_dpu_wdata         ),

    .amo_wr_o         ( mr_amo_wr            ),
    .rdata_o          ( mr_dpu_rdata         ),
    .hazard_o         ( mr_dpu_hazard        ),

    .fault            ( mr_dpu_fault         ),
    .load_misaligned  ( mr_load_misaligned   ),
    .load_pg_fault    ( mr_load_page_fault   ),
    .load_xes_fault   ( mr_load_xes_fault    ),
    .store_misaligned ( mr_store_misaligned  ),
    .store_pg_fault   ( mr_store_page_fault  ),
    .store_xes_fault  ( mr_store_xes_fault   ),
                              
    .dmem_req         ( dmem_en              ),
    .dmem_addr        ( dmem_addr            ),
    .dmem_wr          ( dmem_write           ),
    .dmem_ex          ( dmem_ex              ),
    .dmem_byte        ( dmem_strb            ),
    .dmem_wdata       ( dmem_wdata           ),
    .dmem_rdata       ( dmem_rdata           ),
    .dmem_bad         ( dmem_bad             ),
    .dmem_xstate      ( dmem_xstate          ),
    .dmem_busy        ( dmem_busy            )
);

assign ma_rd_data = exe2ma_pc_alu_sel  ? exe2ma_pc2rd :
                    exe2ma_csr_alu_sel ? exe2ma_csr_rdata :
                                         exe2ma_rd_data;

// MA/WR pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
    if (~rstn_sync) begin
        ma2mr_pc                  <= `IM_ADDR_LEN'b0;
        ma2mr_inst                <= `IM_DATA_LEN'b0;
        ma2mr_inst_valid          <= 1'b0;
        ma2mr_rd_wr               <= 1'b0;
        ma2mr_rd_addr             <= 5'b0;
        ma2mr_mem_byte            <= {(`DM_DATA_LEN >> 3){1'b0}};
        ma2mr_mem_sign_ext        <= 1'b0;
        ma2mr_mem_cal_sel         <= 1'b0;
        ma2mr_len_64              <= 1'b0;
        ma2mr_rd_data             <= `XLEN'b0;
        ma2mr_pc2rd               <= `XLEN'b0;
        ma2mr_mem_addr            <= `DM_ADDR_LEN'b0;
        ma2mr_mem_wdata           <= `DM_DATA_LEN'b0;
        ma2mr_mem_req             <= 1'b0;
        ma2mr_mem_wr              <= 1'b0;
        ma2mr_csr_wr              <= 1'b0;
        ma2mr_csr_waddr           <= 12'b0;
        ma2mr_csr_wdata           <= `XLEN'b0;
        ma2mr_wfi                 <= 1'b0;
        ma2mr_prv                 <= 2'b0;
        ma2mr_trap_en             <= 1'b0;
        ma2mr_cause               <= `XLEN'b0;
        ma2mr_tval                <= `XLEN'b0;
        ma2mr_epc                 <= `IM_ADDR_LEN'b0;
        ma2mr_attach              <= 1'b0;
        ma2mr_tlb_flush_req       <= 1'b0;
        ma2mr_tlb_flush_all_vaddr <= 1'b0;
        ma2mr_tlb_flush_all_asid  <= 1'b0;
        ma2mr_tlb_flush_vaddr     <= `XLEN'b0;
        ma2mr_tlb_flush_asid      <= `XLEN'b0;
        ma2mr_fence_i             <= 1'b0;
        ma2mr_pipe_restart        <= 1'b0;
        ma2mr_fwd_table           <= 32'b0;
        ma2mr_hz_table            <= 32'b0;
    end
    else begin
        if ((~mr_stall & ~mr_amo_wr) | ma_flush_force) begin
            ma2mr_pc                  <= exe2ma_pc;
            ma2mr_inst                <= exe2ma_inst;
            ma2mr_inst_valid          <= ~ma_flush & exe2ma_inst_valid;
            ma2mr_rd_wr               <= ~ma_flush & exe2ma_rd_wr;
            ma2mr_rd_addr             <= exe2ma_rd_addr;
            ma2mr_pc2rd               <= exe2ma_pc2rd;
            ma2mr_mem_byte            <= dmem_strb;
            ma2mr_mem_sign_ext        <= exe2ma_mem_sign_ext;
            ma2mr_mem_cal_sel         <= exe2ma_mem_cal_sel;
            ma2mr_len_64              <= exe2ma_len_64;
            ma2mr_rd_data             <= ma_rd_data;
            ma2mr_mem_addr            <= ma_dpu_addr;
            ma2mr_mem_wdata           <= dmem_wdata;
            ma2mr_mem_req             <= ~ma_flush & exe2ma_mem_req;
            ma2mr_mem_wr              <= ~ma_flush & exe2ma_mem_wr;
            ma2mr_csr_wr              <= exe2ma_csr_wr;
            ma2mr_csr_waddr           <= exe2ma_csr_waddr;
            ma2mr_csr_wdata           <= exe2ma_csr_wdata;
            ma2mr_wfi                 <= ~ma_flush & ~ma2mr_wfi & ~wakeup_event & exe2ma_wfi;
            ma2mr_prv                 <= exe2ma_prv;
            ma2mr_trap_en             <= exe2ma_trap_en;
            ma2mr_cause               <= exe2ma_cause;
            ma2mr_tval                <= exe2ma_tval;
            ma2mr_epc                 <= exe2ma_epc;
            ma2mr_attach              <= exe2ma_attach;
            ma2mr_tlb_flush_req       <= ~ma_flush & exe2ma_tlb_flush_req;
            ma2mr_tlb_flush_all_vaddr <= exe2ma_tlb_flush_all_vaddr;
            ma2mr_tlb_flush_all_asid  <= exe2ma_tlb_flush_all_asid;
            ma2mr_tlb_flush_vaddr     <= ma_rs1_data;
            ma2mr_tlb_flush_asid      <= ma_dpu_wdata;
            ma2mr_fence_i             <= ~ma_flush & exe2ma_fence_i;
            ma2mr_pipe_restart        <= ~ma_flush & ma_pipe_restart;
            ma2mr_fwd_table           <= {32{~ma_flush}} & ma_fwd_table;
            ma2mr_hz_table            <= {32{~ma_flush}} & ma_hz_table;
        end
    end
end

// MEMORY RECEIVE stage
assign mr_fwd_table  = (ma2mr_fwd_table | ma2mr_hz_table) & ~exe2ma_fwd_table & ~(exe_fwd_table & ~{32{exe_hazard}});
assign all_fwd_table = (mr_fwd_table & {32{~mr_stall}}) | (ma_fwd_table & {32{~ma_stall}}) | (exe_fwd_table & {32{~exe_stall}});
assign mr_rd_data    = ma2mr_mem_cal_sel ?  mr_dpu_rdata : ma2mr_rd_data;

assign tlb_flush_req       = ~mr_flush_force & (ma2mr_tlb_flush_req);
assign tlb_flush_all_vaddr = ma2mr_tlb_flush_all_vaddr;
assign tlb_flush_all_asid  = ma2mr_tlb_flush_all_asid;
assign tlb_flush_vaddr     = ma2mr_tlb_flush_vaddr;
assign tlb_flush_asid      = ma2mr_tlb_flush_asid;

assign ic_flush            = ~mr_flush_force & ma2mr_fence_i;
assign mr_pipe_restart     = ~mr_flush_force & ma2mr_pipe_restart;


// MR/WB pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
    if (~rstn_sync) begin
        mr2wb_pc               <= `IM_ADDR_LEN'b0;
        mr2wb_inst             <= `IM_DATA_LEN'b0;
        mr2wb_inst_valid       <= 1'b0;
        mr2wb_rd_wr            <= 1'b0;
        mr2wb_rd_addr          <= 5'b0;
        mr2wb_mem_byte         <= {(`DM_DATA_LEN >> 3){1'b0}};
        mr2wb_mem_sign_ext     <= 1'b0;
        mr2wb_len_64           <= 1'b0;
        mr2wb_rd_data          <= `XLEN'b0;
        mr2wb_mem_addr         <= `DM_ADDR_LEN'b0;
        mr2wb_mem_wdata        <= `DM_DATA_LEN'b0;
        mr2wb_mem_req          <= 1'b0;
        mr2wb_mem_wr           <= 1'b0;
        mr2wb_dpu_fault        <= 1'b0;
        mr2wb_load_misaligned  <= 1'b0;
        mr2wb_load_page_fault  <= 1'b0;
        mr2wb_load_xes_fault   <= 1'b0;
        mr2wb_store_misaligned <= 1'b0;
        mr2wb_store_page_fault <= 1'b0;
        mr2wb_store_xes_fault  <= 1'b0;
        mr2wb_csr_wr           <= 1'b0;
        mr2wb_csr_waddr        <= 12'b0;
        mr2wb_csr_wdata        <= `XLEN'b0;
        mr2wb_wfi              <= 1'b0;
        mr2wb_prv              <= 2'b0;
        mr2wb_trap_en          <= 1'b0;
        mr2wb_cause            <= `XLEN'b0;
        mr2wb_tval             <= `XLEN'b0;
        mr2wb_epc              <= `IM_ADDR_LEN'b0;
        mr2wb_fwd_table        <= 32'b0;
        mr2wb_attach           <= 1'b0;
    end
    else begin
        if (~wb_stall | mr_flush_force) begin
            mr2wb_pc               <= ma2mr_pc;
            mr2wb_inst             <= ma2mr_inst;
            mr2wb_inst_valid       <= ~mr_flush & ~mr_amo_wr & ma2mr_inst_valid;
            mr2wb_rd_wr            <= ~mr_flush & ~mr_amo_wr & ma2mr_rd_wr;
            mr2wb_rd_addr          <= ma2mr_rd_addr;
            mr2wb_mem_byte         <= ma2mr_mem_byte;
            mr2wb_mem_sign_ext     <= ma2mr_mem_sign_ext;
            mr2wb_len_64           <= ma2mr_len_64;
            mr2wb_rd_data          <= mr_rd_data;
            mr2wb_mem_addr         <= ma2mr_mem_addr;
            mr2wb_mem_wdata        <= ma2mr_mem_wdata;
            mr2wb_mem_req          <= ~mr_flush & ~mr_amo_wr & ma2mr_mem_req;
            mr2wb_mem_wr           <= ~mr_flush & ~mr_amo_wr & ma2mr_mem_wr;
            mr2wb_dpu_fault        <= ~mr_flush & ~mr_amo_wr & ma2mr_inst_valid & mr_dpu_fault;
            mr2wb_load_misaligned  <= ~mr_flush & ~mr_amo_wr & ma2mr_inst_valid & mr_load_misaligned;
            mr2wb_load_page_fault  <= ~mr_flush & ~mr_amo_wr & ma2mr_inst_valid & mr_load_page_fault;
            mr2wb_load_xes_fault   <= ~mr_flush & ~mr_amo_wr & ma2mr_inst_valid & mr_load_xes_fault;
            mr2wb_store_misaligned <= ~mr_flush & ~mr_amo_wr & ma2mr_inst_valid & mr_store_misaligned;
            mr2wb_store_page_fault <= ~mr_flush & ~mr_amo_wr & ma2mr_inst_valid & mr_store_page_fault;
            mr2wb_store_xes_fault  <= ~mr_flush & ~mr_amo_wr & ma2mr_inst_valid & mr_store_xes_fault;
            mr2wb_csr_wr           <= ma2mr_csr_wr;
            mr2wb_csr_waddr        <= ma2mr_csr_waddr;
            mr2wb_csr_wdata        <= ma2mr_csr_wdata;
            mr2wb_wfi              <= ~mr_flush & ~mr_amo_wr & ~mr2wb_wfi & ~wakeup_event & ma2mr_wfi;
            mr2wb_prv              <= ma2mr_prv;
            mr2wb_trap_en          <= ~mr_flush & ~mr_amo_wr & ma2mr_trap_en;
            mr2wb_cause            <= ma2mr_cause;
            mr2wb_tval             <= ma2mr_tval;
            mr2wb_epc              <= ma2mr_epc;
            mr2wb_fwd_table        <= {32{~mr_flush & ~mr_amo_wr}} & mr_fwd_table;
            mr2wb_attach           <= ma2mr_attach;
        end
    end
end

// WB stage
assign wb_rd_data    = mr2wb_rd_data;
assign wb_rd_wr      = ~wb_flush & mr2wb_rd_wr;
assign wb_inst_valid = ~wb_flush & mr2wb_inst_valid;
assign wb_wfi        = ~wb_flush & mr2wb_wfi;

assign dbg_pc_out    = mr2wb_pc;
assign halted        = mr2wb_attach;

// PMU
pmu u_pmu (
    .clk_free   ( clk               ),
    .rstn       ( rstn_sync         ),
    .cpu_id     ( cpu_id            ),
    .inst_valid ( wb_inst_valid     ),

    .csr_wr     ( exe_pmu_csr_wr    ),
    .csr_raddr  ( id_csr_addr       ),
    .csr_waddr  ( id2exe_csr_waddr  ),
    .csr_wdata  ( exe_csr_wdata     ),
    .csr_rdata  ( id_pmu_csr_rdata  )
);

`ifdef CPULOG
// Tracer
cpu_tracer u_cpu_tracer (
    .clk       ( clk_wfi         ),
    .valid     ( wb_inst_valid   ),
    .pc        ( mr2wb_pc        ),
    .epc       ( mr2wb_epc       ),
    .inst      ( mr2wb_inst      ),
    .prv       ( mr2wb_prv       ),
    .rd_wr     ( wb_rd_wr        ),
    .rd_addr   ( mr2wb_rd_addr   ),
    .rd_data   ( mr2wb_rd_data   ),
    .csr_wr    ( mr2wb_csr_wr    ),
    .csr_waddr ( mr2wb_csr_waddr ),
    .csr_wdata ( mr2wb_csr_wdata ),
    .mem_addr  ( mr2wb_mem_addr  ),
    .mem_req   ( mr2wb_mem_req   ),
    .mem_wr    ( mr2wb_mem_wr    ),
    .mem_byte  ( mr2wb_mem_byte  ),
    .mem_rdata ( mr2wb_rd_data   ),
    .mem_wdata ( mr2wb_mem_wdata ),
    .trap_en   ( mr2wb_trap_en   ),
    .mcause    ( mr2wb_cause     ),
    .mtval     ( mr2wb_tval      ),
    .halted    ( halted          )
);
`endif

endmodule
