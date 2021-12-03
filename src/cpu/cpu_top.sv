`include "cpu_define.h"

module cpu_top (
    input                                    clk,
    input                                    rstn,
    input        [              `XLEN - 1:0] cpu_id,

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
    output logic [(`IM_DATA_LEN >> 3) - 1:0] dmem_strb,
    output logic [       `IM_DATA_LEN - 1:0] dmem_wdata,
    input        [       `IM_DATA_LEN - 1:0] dmem_rdata,
    input        [                      1:0] dmem_bad,
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
logic [                      4:0] inst_valid;
logic [       `IM_ADDR_LEN - 1:0] irq_vec;
logic [       `IM_ADDR_LEN - 1:0] ret_epc;

// Hazard Control Unit
logic                             if_stall;
logic                             id_stall;
logic                             exe_stall;
logic                             mem_stall;
logic                             wb_stall;
logic                             if_flush;
logic                             id_flush;
logic                             exe_flush;
logic                             mem_flush;
logic                             wb_flush;
logic                             if_flush_force;
logic                             id_flush_force;
logic                             exe_flush_force;
logic                             mem_flush_force;
logic                             wb_flush_force;

// IF stage
logic                             if_pc_jump_en;
logic [       `IM_ADDR_LEN - 1:0] if_pc_jump;
logic                             if_pc_alu_en;
logic [       `IM_ADDR_LEN - 1:0] if_pc_alu;
logic [       `IM_ADDR_LEN - 1:0] if_pc;
logic [       `IM_DATA_LEN - 1:0] if_inst;
logic                             if_inst_valid;
logic                             if_inst_misaligned;
logic                             if_inst_page_fault;
logic                             if_inst_xes_fault;

// IF/ID pipeline
logic [       `IM_DATA_LEN - 1:0] if2id_inst;
logic                             if2id_inst_valid;
logic                             if2id_inst_misaligned;
logic                             if2id_inst_page_fault;
logic                             if2id_inst_xes_fault;
logic [       `IM_ADDR_LEN - 1:0] if2id_pc;
logic                             if2id_attach;

// ID stage
logic [                      4:0] id_rd_addr;
logic [                      4:0] id_rs1_addr;
logic [                      4:0] id_rs2_addr;
logic [              `XLEN - 1:0] id_rs1_data;
logic [              `XLEN - 1:0] id_rs2_data;
logic [                     11:0] id_csr_addr;
logic [              `XLEN - 1:0] id_imm;

logic [                      1:0] id_prv_req;
logic                             id_ill_inst;
logic                             id_fense;
logic                             id_fense_i;
logic                             id_ecall;
logic                             id_ebreak;
logic                             id_wfi;
logic                             id_sret;
logic                             id_mret;
logic                             id_jump;
logic                             id_jump_alu;

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
logic                             id_mem_req;
logic                             id_mem_wr;
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
logic [              `XLEN - 1:0] id2exe_imm;

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
logic                             id2exe_mem_req;
logic                             id2exe_mem_wr;
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
logic                             id2exe_inst_misaligned;
logic                             id2exe_inst_page_fault;
logic                             id2exe_inst_xes_fault;
logic                             id2exe_tlb_flush_req;
logic                             id2exe_tlb_flush_all_vaddr;
logic                             id2exe_tlb_flush_all_asid;
logic                             id2exe_fense_i;
logic                             id2exe_attach;
logic                             id2exe_ext_csr_wr;
logic [              `XLEN - 1:0] id2exe_ext_csr_wdata;

// EXE stage
logic                             exe_alu_zero;
logic                             exe_branch_match;
logic [              `XLEN - 1:0] exe_pc_imm;
logic [              `XLEN - 1:0] exe_pc_add_4;
logic [              `XLEN - 1:0] exe_rs1_data;
logic [              `XLEN - 1:0] exe_rs2_data;
logic [              `XLEN - 1:0] exe_alu_src1;
logic [              `XLEN - 1:0] exe_alu_src2;
logic [              `XLEN - 1:0] exe_alu_out;
logic [              `XLEN - 1:0] exe_pc2rd;
logic                             exe_hazard;
logic [              `XLEN - 1:0] exe_csr_src1;
logic [              `XLEN - 1:0] exe_csr_src2;
logic [              `XLEN - 1:0] exe_csr_wdata;
logic                             exe_pmu_csr_wr;
logic                             exe_fpu_csr_wr;
logic                             exe_dbg_csr_wr;
logic                             exe_mmu_csr_wr;
logic                             exe_mpu_csr_wr;
logic                             exe_sru_csr_wr;
logic                             exe_sret;
logic                             exe_mret;
logic                             exe_satp_upd;
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

// EXE/MEM pipeline
logic [       `IM_ADDR_LEN - 1:0] exe2mem_pc;
logic [       `IM_DATA_LEN - 1:0] exe2mem_inst;
logic                             exe2mem_inst_valid;
logic                             exe2mem_mem_req;
logic                             exe2mem_mem_wr;
logic [(`DM_DATA_LEN >> 3) - 1:0] exe2mem_mem_byte;
logic                             exe2mem_mem_sign_ext;
logic [              `XLEN - 1:0] exe2mem_csr_rdata;
logic                             exe2mem_pc_alu_sel;
logic                             exe2mem_csr_alu_sel;
logic                             exe2mem_mem_cal_sel;
logic                             exe2mem_rd_wr;
logic [                      4:0] exe2mem_rd_addr;
logic [                      4:0] exe2mem_rs1_addr;
logic [                      4:0] exe2mem_rs2_addr;
logic [              `XLEN - 1:0] exe2mem_alu_out;
logic [              `XLEN - 1:0] exe2mem_pc2rd;
logic [              `XLEN - 1:0] exe2mem_rs1_data;
logic [              `XLEN - 1:0] exe2mem_rs2_data;
logic                             exe2mem_csr_wr;
logic [                     11:0] exe2mem_csr_waddr;
logic [              `XLEN - 1:0] exe2mem_csr_wdata;
logic                             exe2mem_wfi;
logic [                      1:0] exe2mem_prv;
logic                             exe2mem_trap_en;
logic [              `XLEN - 1:0] exe2mem_cause;
logic [              `XLEN - 1:0] exe2mem_tval;
logic [       `IM_ADDR_LEN - 1:0] exe2mem_epc;
logic                             exe2mem_tlb_flush_req;
logic                             exe2mem_tlb_flush_all_vaddr;
logic                             exe2mem_tlb_flush_all_asid;
logic                             exe2mem_fense_i;
logic                             exe2mem_attach;

// MEM stage
logic [              `XLEN - 1:0] mem_rd_data;

logic [              `XLEN - 1:0] mem_rs1_data;
logic                             mem_dpu_req;
logic                             mem_dpu_wr;
logic [(`DM_DATA_LEN >> 3) - 1:0] mem_dpu_byte;
logic [       `DM_ADDR_LEN - 1:0] mem_dpu_addr;
logic [       `DM_DATA_LEN - 1:0] mem_dpu_wdata;

logic [       `DM_DATA_LEN - 1:0] mem_dpu_rdata;
logic                             mem_dpu_hazard;
logic                             mem_dpu_fault;

logic [       `DM_ADDR_LEN - 1:0] mem_bad_dxes_val;
logic                             mem_load_misaligned;
logic                             mem_load_page_fault;
logic                             mem_load_xes_fault;
logic                             mem_store_misaligned;
logic                             mem_store_page_fault;
logic                             mem_store_xes_fault;
logic [       `IM_ADDR_LEN - 1:0] mem_dpu_pc;
logic                             mem_pl_restart;

// MEM/WB pipeline
logic [       `IM_ADDR_LEN - 1:0] mem2wb_pc;
logic [       `IM_DATA_LEN - 1:0] mem2wb_inst;
logic                             mem2wb_inst_valid;
logic [                      4:0] mem2wb_rd_addr;
logic                             mem2wb_rd_wr;
logic [(`DM_DATA_LEN >> 3) - 1:0] mem2wb_mem_byte;
logic                             mem2wb_mem_sign_ext;
logic                             mem2wb_mem_cal_sel;
logic [              `XLEN - 1:0] mem2wb_rd_data;
logic [       `DM_ADDR_LEN - 1:0] mem2wb_mem_addr;
logic [       `DM_DATA_LEN - 1:0] mem2wb_mem_wdata;
logic                             mem2wb_mem_req;
logic                             mem2wb_mem_wr;
logic                             mem2wb_csr_wr;
logic [                     11:0] mem2wb_csr_waddr;
logic [              `XLEN - 1:0] mem2wb_csr_wdata;
logic                             mem2wb_wfi;
logic [                      1:0] mem2wb_prv;
logic                             mem2wb_trap_en;
logic [              `XLEN - 1:0] mem2wb_cause;
logic [              `XLEN - 1:0] mem2wb_tval;
logic [       `IM_ADDR_LEN - 1:0] mem2wb_epc;
logic                             mem2wb_attach;

// WB stage
logic [              `XLEN - 1:0] wb_rd_data;
logic                             wb_rd_wr;
logic                             wb_inst_valid;
logic                             wb_wfi;

// Forward
logic                             fwd_wb2exe_rd_rs1;
logic                             fwd_wb2exe_rd_rs2;
logic                             fwd_mem2exe_rd_rs1;
logic                             fwd_mem2exe_rd_rs2;
logic                             fwd_wb2mem_rd_rs1;
logic                             fwd_wb2mem_rd_rs2;

`include "csr_op.sv"

resetn_synchronizer u_sync (
    .clk        ( clk       ),
    .rstn_async ( rstn      ),
    .rstn_sync  ( rstn_sync )
);

assign stall_wfi  = (exe2mem_wfi | mem2wb_wfi) & ~wakeup_event;
assign inst_valid = {mem2wb_inst_valid, exe2mem_inst_valid, id2exe_inst_valid, if2id_inst_valid, 1'b1};

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
    .pl_restart_en   ( mem_pl_restart  ),
    .id_hazard       ( id_hazard       ),
    .exe_hazard      ( exe_hazard      ),
    .dpu_hazard      ( mem_dpu_hazard  ),
    .dpu_fault       ( mem_dpu_fault   ),
    .if_stall        ( if_stall        ),
    .id_stall        ( id_stall        ),
    .exe_stall       ( exe_stall       ),
    .mem_stall       ( mem_stall       ),
    .wb_stall        ( wb_stall        ),
    .if_flush        ( if_flush        ),
    .id_flush        ( id_flush        ),
    .exe_flush       ( exe_flush       ),
    .mem_flush       ( mem_flush       ),
    .wb_flush        ( wb_flush        ),
    .if_flush_force  ( if_flush_force  ),
    .id_flush_force  ( id_flush_force  ),
    .exe_flush_force ( exe_flush_force ),
    .mem_flush_force ( mem_flush_force ),
    .wb_flush_force  ( wb_flush_force  )
);

// IF stage
ifu u_ifu (
    .clk           ( clk                          ),
    .rstn          ( rstn_sync                    ),
    .irq_en        ( exe_irq_en | exe_trap_en     ),
    .irq_vec       ( irq_vec                      ),
    .eret_en       ( exe_eret_en                  ),
    .ret_epc       ( ret_epc                      ),
    .pc_jump_en    ( if_pc_jump_en                ),
    .pc_jump       ( if_pc_jump                   ),
    .pc_alu_en     ( if_pc_alu_en                 ),
    .pc_alu        ( if_pc_alu                    ),
    .pl_restart_en ( mem_pl_restart               ),
    .pl_restart    ( exe2mem_pc2rd                ),
    .imem_req      ( imem_en                      ),
    .imem_addr     ( imem_addr                    ),
    .imem_rdata    ( imem_rdata                   ),
    .imem_bad      ( imem_bad                     ),
    .imem_busy     ( imem_busy                    ),
    .pc            ( if_pc                        ),
    .inst          ( if_inst                      ),
    .inst_valid    ( if_inst_valid                ),
    .misaligned    ( if_inst_misaligned           ),
    .page_fault    ( if_inst_page_fault           ),
    .xes_fault     ( if_inst_xes_fault            ),
    .flush         ( if_flush                     ),
    .stall         ( if_stall | stall_wfi | sleep ),
    .attach        ( attach                       ),
    .dbg_exec      ( dbg_exec                     ),
    .dbg_inst      ( dbg_inst                     )
);

assign exe_branch_match = id2exe_branch & (id2exe_branch_zcmp == exe_alu_zero);

assign if_pc_jump_en = id_jump & if2id_inst_valid & ~id_stall & ~id_flush & ~stall_wfi;
assign if_pc_jump    = id_imm + if2id_pc;
assign if_pc_alu_en  = (id2exe_jump_alu | exe_branch_match) & id2exe_inst_valid & ~exe_stall;
assign if_pc_alu     = ({`IM_ADDR_LEN{id2exe_jump_alu}}  & exe_alu_out) |
                       ({`IM_ADDR_LEN{exe_branch_match}} & exe_pc_imm[`IM_ADDR_LEN - 1:0] );

// IF/ID pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
    if (~rstn_sync) begin
        if2id_pc              <= `IM_ADDR_LEN'b0;
        if2id_inst            <= `IM_DATA_LEN'b0;
        if2id_inst_valid      <= 1'b0;
        if2id_inst_misaligned <= 1'b0;
        if2id_inst_page_fault <= 1'b0;
        if2id_inst_xes_fault  <= 1'b0;
        if2id_attach          <= 1'b0;
    end
    else begin
        if ((~id_stall & ~stall_wfi) | if_flush_force) begin
            if2id_pc              <= if_pc;
            if2id_inst            <= if_inst;
            if2id_inst_valid      <= ~if_flush & if_inst_valid;
            if2id_inst_misaligned <= if_inst_misaligned;
            if2id_inst_page_fault <= if_inst_page_fault;
            if2id_inst_xes_fault  <= if_inst_xes_fault;
            if2id_attach          <= attach;
        end
    end
end

// ID stage
idu u_idu (
    .clk                 ( clk_wfi                ),
    .rstn                ( rstn_sync              ),
    .inst                ( if2id_inst             ),
    .inst_valid          ( if2id_inst_valid       ),
    .pc                  ( if2id_pc               ),
    .rd_wr_i             ( wb_rd_wr               ),
    .rd_addr_i           ( mem2wb_rd_addr         ),
    .rd_data             ( wb_rd_data             ),
    .rd_addr_o           ( id_rd_addr             ),
    .rs1_addr            ( id_rs1_addr            ),
    .rs2_addr            ( id_rs2_addr            ),
    .rs1_data            ( id_rs1_data            ),
    .rs2_data            ( id_rs2_data            ),
    .csr_addr            ( id_csr_addr            ),
    .imm                 ( id_imm                 ),
    // Control
    .prv_req             ( id_prv_req             ),
    .ill_inst            ( id_ill_inst            ),
    .fense               ( id_fense               ),
    .fense_i             ( id_fense_i             ),
    .ecall               ( id_ecall               ),
    .ebreak              ( id_ebreak              ),
    .wfi                 ( id_wfi                 ),
    .sret                ( id_sret                ),
    .mret                ( id_mret                ),
    .jump                ( id_jump                ),
    .jump_alu            ( id_jump_alu            ),
    // For EXE stage
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
    .mem_req             ( id_mem_req             ),
    .mem_wr              ( id_mem_wr              ),
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

// ID Hazard
assign id_hazard = (id_csr_rd &&
                    (exe_pmu_csr_wr | exe_fpu_csr_wr | exe_dbg_csr_wr |
                     exe_mmu_csr_wr | exe_mpu_csr_wr | exe_sru_csr_wr) &&
                    (id_csr_addr == id2exe_csr_waddr)) ||
                   (id_jump && (exe2mem_mem_req || id2exe_mem_req));


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
        id2exe_imm                 <= `XLEN'b0;
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
        id2exe_mem_req             <= 1'b0;
        id2exe_mem_wr              <= 1'b0;
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
        id2exe_inst_misaligned     <= 1'b0;
        id2exe_inst_page_fault     <= 1'b0;
        id2exe_inst_xes_fault      <= 1'b0;
        id2exe_tlb_flush_req       <= 1'b0;
        id2exe_tlb_flush_all_vaddr <= 1'b0;
        id2exe_tlb_flush_all_asid  <= 1'b0;
        id2exe_fense_i             <= 1'b0;
        id2exe_attach              <= 1'b0;
        id2exe_ext_csr_wr          <= 1'b0;
        id2exe_ext_csr_wdata       <= 32'b0;
    end
    else begin
        if ((~exe_stall & ~stall_wfi) | id_flush_force) begin
            id2exe_pc                  <= if2id_pc;
            id2exe_inst                <= if2id_inst;
            id2exe_inst_valid          <= ~id_flush & if2id_inst_valid;
            id2exe_rd_addr             <= id_rd_addr;
            id2exe_rs1_addr            <= id_rs1_addr;
            id2exe_rs2_addr            <= id_rs2_addr;
            id2exe_rs1_data            <= id_rs1_data;
            id2exe_rs2_data            <= id_rs2_data;
            id2exe_csr_waddr           <= id_csr_addr;
            id2exe_csr_rdata           <= id_csr_rdata;
            id2exe_imm                 <= id_imm;
            id2exe_alu_op              <= id_alu_op;
            id2exe_rs1_zero_sel        <= id_rs1_zero_sel;
            id2exe_rs2_imm_sel         <= id_rs2_imm_sel;
            id2exe_pc_imm_sel          <= id_pc_imm_sel;
            id2exe_jump_alu            <= id_jump_alu;
            id2exe_branch              <= id_branch;
            id2exe_branch_zcmp         <= id_branch_zcmp;
            id2exe_csr_op              <= id_csr_op;
            id2exe_uimm_rs1_sel        <= id_uimm_rs1_sel;
            id2exe_csr_rd              <= ~id_flush & id_csr_rd;
            id2exe_pmu_csr_wr          <= ~id_flush & id_pmu_csr_wr;
            id2exe_fpu_csr_wr          <= ~id_flush & id_fpu_csr_wr;
            id2exe_dbg_csr_wr          <= ~id_flush & id_dbg_csr_wr;
            id2exe_mmu_csr_wr          <= ~id_flush & id_mmu_csr_wr;
            id2exe_mpu_csr_wr          <= ~id_flush & id_mpu_csr_wr;
            id2exe_sru_csr_wr          <= ~id_flush & id_sru_csr_wr;
            id2exe_pc_alu_sel          <= id_pc_alu_sel;
            id2exe_csr_alu_sel         <= id_csr_alu_sel;
            id2exe_mem_req             <= ~id_flush & id_mem_req;
            id2exe_mem_wr              <= ~id_flush & id_mem_wr;
            id2exe_mem_byte            <= id_mem_byte;
            id2exe_mem_sign_ext        <= id_mem_sign_ext;
            id2exe_mem_cal_sel         <= id_mem_cal_sel;
            id2exe_rd_wr               <= ~id_flush & id_rd_wr;
            id2exe_wfi                 <= ~id_flush & id_wfi;
            id2exe_ecall               <= ~id_flush & id_ecall;
            id2exe_ebreak              <= ~id_flush & id_ebreak;
            id2exe_sret                <= ~id_flush & id_sret;
            id2exe_mret                <= ~id_flush & id_mret;
            id2exe_ill_inst            <= ~id_flush & id_ill_inst;
            id2exe_prv_req             <= id_prv_req;
            id2exe_inst_misaligned     <= if_pc_jump_en & |if_pc_jump[1];
            id2exe_inst_page_fault     <= if2id_inst_page_fault;
            id2exe_inst_xes_fault      <= if2id_inst_xes_fault;
            id2exe_tlb_flush_req       <= ~id_flush & id_tlb_flush_req;
            id2exe_tlb_flush_all_vaddr <= id_tlb_flush_all_vaddr;
            id2exe_tlb_flush_all_asid  <= id_tlb_flush_all_asid;
            id2exe_fense_i             <= ~id_flush & id_fense_i;
            id2exe_attach              <= if2id_attach;
            id2exe_ext_csr_wr          <= dbg_csr_wr;
            id2exe_ext_csr_wdata       <= dbg_wdata;
        end
        else begin
            id2exe_rs1_data            <= exe_rs1_data;
            id2exe_rs2_data            <= exe_rs2_data;
        end
    end
end

// EXE stage
// RS1 Forward
assign fwd_wb2exe_rd_rs1  = mem2wb_rd_wr  & (id2exe_rs1_addr == mem2wb_rd_addr ) & |id2exe_rs1_addr;
assign fwd_mem2exe_rd_rs1 = exe2mem_rd_wr & (id2exe_rs1_addr == exe2mem_rd_addr) & |id2exe_rs1_addr &
                          ~(exe2mem_mem_req & ~exe2mem_mem_wr & exe2mem_mem_cal_sel);
assign exe_rs1_data       = fwd_mem2exe_rd_rs1 ? mem_rd_data :
                            fwd_wb2exe_rd_rs1  ? wb_rd_data  :
                                                 id2exe_rs1_data;

// RS2 Forward
assign fwd_wb2exe_rd_rs2  = mem2wb_rd_wr  & (id2exe_rs2_addr == mem2wb_rd_addr ) & |id2exe_rs2_addr;
assign fwd_mem2exe_rd_rs2 = exe2mem_rd_wr & (id2exe_rs2_addr == exe2mem_rd_addr) & |id2exe_rs2_addr &
                        ~(exe2mem_mem_req & ~exe2mem_mem_wr & exe2mem_mem_cal_sel);
assign exe_rs2_data       = fwd_mem2exe_rd_rs2 ? mem_rd_data :
                            fwd_wb2exe_rd_rs2  ? wb_rd_data  :
                                                 id2exe_rs2_data;

assign exe_hazard   = ((exe2mem_mem_req & ~exe2mem_mem_wr & exe2mem_mem_cal_sel) &
                       (exe2mem_rd_wr & (id2exe_rs1_addr == exe2mem_rd_addr) & |id2exe_rs1_addr |
                        exe2mem_rd_wr & (id2exe_rs2_addr == exe2mem_rd_addr) & |id2exe_rs2_addr)) ||
                      (exe2mem_mem_req & (id2exe_pmu_csr_wr | id2exe_fpu_csr_wr | id2exe_dbg_csr_wr | 
                       id2exe_mmu_csr_wr | id2exe_mpu_csr_wr | id2exe_sru_csr_wr | id2exe_branch |
                       id2exe_sret | id2exe_mret));

assign exe_pc_imm   = {{(`XLEN - `IM_ADDR_LEN){id2exe_pc[`IM_ADDR_LEN - 1]}}, id2exe_pc} + id2exe_imm;
assign exe_pc_add_4 = {{(`XLEN - `IM_ADDR_LEN){id2exe_pc[`IM_ADDR_LEN - 1]}}, id2exe_pc} + `XLEN'h4;
assign exe_pc2rd    = id2exe_pc_imm_sel   ? exe_pc_imm : exe_pc_add_4;

assign exe_alu_src1 = id2exe_rs1_zero_sel ? exe_rs1_data : `XLEN'b0;
assign exe_alu_src2 = id2exe_rs2_imm_sel  ? exe_rs2_data : id2exe_imm;

alu u_alu (
   .alu_op    ( id2exe_alu_op ),
   .src1      ( exe_alu_src1  ),
   .src2      ( exe_alu_src2  ),
   .out       ( exe_alu_out   ),
   .zero_flag ( exe_alu_zero  )
);

assign exe_pmu_csr_wr = id2exe_pmu_csr_wr & ~exe_flush_force & ~exe_stall & ~exe_trap_en & ~stall_wfi;
assign exe_fpu_csr_wr = id2exe_fpu_csr_wr & ~exe_flush_force & ~exe_stall & ~exe_trap_en & ~stall_wfi;
assign exe_dbg_csr_wr = id2exe_dbg_csr_wr & ~exe_flush_force & ~exe_stall & ~exe_trap_en & ~stall_wfi;
assign exe_mmu_csr_wr = id2exe_mmu_csr_wr & ~exe_flush_force & ~exe_stall & ~exe_trap_en & ~stall_wfi;
assign exe_mpu_csr_wr = id2exe_mpu_csr_wr & ~exe_flush_force & ~exe_stall & ~exe_trap_en & ~stall_wfi;
assign exe_sru_csr_wr = id2exe_sru_csr_wr & ~exe_flush_force & ~exe_stall & ~exe_trap_en & ~stall_wfi;
assign exe_sret       = id2exe_sret       & ~exe_flush_force & ~exe_stall & ~exe_trap_en & ~stall_wfi;
assign exe_mret       = id2exe_mret       & ~exe_flush_force & ~exe_stall & ~exe_trap_en & ~stall_wfi;

assign exe_csr_src1 = id2exe_uimm_rs1_sel ? {{(`XLEN-5){1'b0}}, id2exe_rs1_addr} : exe_rs1_data;
assign exe_csr_src2 = id2exe_csr_rdata;

sru u_sru (
    .clk         ( clk_wfi           ),
    .clk_free    ( clk               ),
    .rstn        ( rstn_sync         ),
    .sleep       ( sleep             ),
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
                      ~exe_stall & ~stall_wfi && id2exe_csr_waddr == `CSR_SATP_ADDR;
assign exe_inst_misaligned         = id2exe_inst_misaligned | (if_pc_alu_en & |if_pc_alu[1]);
assign exe_inst_misaligned_badaddr[`XLEN-1:1] = id2exe_inst_misaligned ? (id2exe_imm[`XLEN-1:1] + id2exe_pc[`XLEN-1:1]):
                                                                          if_pc_alu[`XLEN-1:1];
assign exe_inst_misaligned_badaddr[0]         = 1'b0;

tpu u_tpu (
    .inst_valid       ( id2exe_inst_valid & ~exe_stall & ~stall_wfi),
    .inst             ( id2exe_inst                 ),
    .exe_pc           ( id2exe_pc                   ),
    .mem_pc           ( mem_dpu_pc                  ),
    .ldst_badaddr     ( mem_bad_dxes_val            ),
    .inst_badaddr     ( exe_inst_misaligned_badaddr ),
    .prv_cur          ( exe_prv                     ),
    .prv_req          ( id2exe_prv_req              ),
    .satp_upd         ( exe_satp_upd                ),
    .tsr              ( exe_mstatus_tsr             ),
    .tvm              ( exe_mstatus_tvm             ),
    .sret             ( id2exe_sret                 ),
    .ecall            ( id2exe_ecall                ),
    .ebreak           ( id2exe_ebreak               ),
    .tlb_flush_req    ( id2exe_tlb_flush_req        ),
    .ill_inst         ( id2exe_ill_inst             ),
    .inst_misaligned  ( exe_inst_misaligned         ),
    .inst_pg_fault    ( id2exe_inst_page_fault      ),
    .inst_xes_fault   ( id2exe_inst_xes_fault       ),
    .load_misaligned  ( mem_load_misaligned         ),
    .load_pg_fault    ( mem_load_page_fault         ),
    .load_xes_fault   ( mem_load_xes_fault          ),
    .store_misaligned ( mem_store_misaligned        ),
    .store_pg_fault   ( mem_store_page_fault        ),
    .store_xes_fault  ( mem_store_xes_fault         ),
    .trap_en          ( exe_trap_en                 ),
    .trap_cause       ( exe_trap_cause              ),
    .trap_val         ( exe_trap_val                ),
    .trap_epc         ( exe_trap_epc                )
);

assign satp_ppn    = exe_satp_ppn;
assign satp_asid   = exe_satp_asid;
assign satp_mode   = exe_satp_mode;
assign prv         = exe_prv;

always_comb begin
    if (id2exe_ext_csr_wr) begin
        exe_csr_wdata = id2exe_ext_csr_wdata;
    end
    else begin
        exe_csr_wdata = `XLEN'b0;
        case (id2exe_csr_op)
            CSR_OP_NONE: exe_csr_wdata = exe_csr_src1;
            CSR_OP_SET : exe_csr_wdata = exe_csr_src2 |  exe_csr_src1;
            CSR_OP_CLR : exe_csr_wdata = exe_csr_src2 & ~exe_csr_src1;
        endcase
    end
end

// EXE/MEM pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
    if (~rstn_sync) begin
        exe2mem_pc                  <= `IM_ADDR_LEN'b0;
        exe2mem_inst                <= `IM_DATA_LEN'b0;
        exe2mem_inst_valid          <= 1'b0;
        exe2mem_mem_req             <= 1'b0;
        exe2mem_mem_wr              <= 1'b0;
        exe2mem_mem_byte            <= {(`DM_DATA_LEN >> 3){1'b0}};
        exe2mem_mem_sign_ext        <= 1'b0;
        exe2mem_pc_alu_sel          <= 1'b0;
        exe2mem_csr_rdata           <= `XLEN'b0;
        exe2mem_csr_alu_sel         <= 1'b0;
        exe2mem_mem_cal_sel         <= 1'b0;
        exe2mem_rd_wr               <= 1'b0;
        exe2mem_rd_addr             <= 5'b0;
        exe2mem_rs1_addr            <= 5'b0;
        exe2mem_rs2_addr            <= 5'b0;
        exe2mem_alu_out             <= `XLEN'b0;
        exe2mem_pc2rd               <= `XLEN'b0;
        exe2mem_rs1_data            <= `XLEN'b0;
        exe2mem_rs2_data            <= `XLEN'b0;
        exe2mem_csr_wr              <= 1'b0;
        exe2mem_csr_waddr           <= 12'b0;
        exe2mem_csr_wdata           <= `XLEN'b0;
        exe2mem_wfi                 <= 1'b0;
        exe2mem_prv                 <= 2'b0;
        exe2mem_trap_en             <= 1'b0;
        exe2mem_cause               <= `XLEN'b0;
        exe2mem_tval                <= `XLEN'b0;
        exe2mem_epc                 <= `IM_DATA_LEN'b0;
        exe2mem_tlb_flush_req       <= 1'b0;
        exe2mem_tlb_flush_all_vaddr <= 1'b0;
        exe2mem_tlb_flush_all_asid  <= 1'b0;
        exe2mem_fense_i             <= 1'b0;
        exe2mem_attach              <= 1'b0;
    end
    else begin
        if (~mem_stall | exe_flush_force) begin
            exe2mem_pc                  <= id2exe_pc;
            exe2mem_inst                <= id2exe_inst;
            exe2mem_inst_valid          <= ~exe_flush & ~exe_irq_en & ~((exe2mem_wfi | mem2wb_wfi) & ~wakeup_event) & id2exe_inst_valid;
            exe2mem_mem_req             <= ~exe_flush & ~exe_irq_en & ~((exe2mem_wfi | mem2wb_wfi) & ~wakeup_event) & id2exe_mem_req;
            exe2mem_mem_wr              <= ~exe_flush & ~exe_irq_en & ~((exe2mem_wfi | mem2wb_wfi) & ~wakeup_event) & id2exe_mem_wr;
            exe2mem_mem_byte            <= id2exe_mem_byte;
            exe2mem_mem_sign_ext        <= id2exe_mem_sign_ext;
            exe2mem_pc_alu_sel          <= id2exe_pc_alu_sel;
            exe2mem_csr_rdata           <= id2exe_csr_rdata;
            exe2mem_csr_alu_sel         <= id2exe_csr_alu_sel;
            exe2mem_mem_cal_sel         <= id2exe_mem_cal_sel;
            exe2mem_rd_wr               <= ~exe_flush & ~exe_irq_en & ~((exe2mem_wfi | mem2wb_wfi) & ~wakeup_event) & id2exe_rd_wr;
            exe2mem_rd_addr             <= id2exe_rd_addr;
            exe2mem_rs1_addr            <= id2exe_rs1_addr;
            exe2mem_rs2_addr            <= id2exe_rs2_addr;
            exe2mem_alu_out             <= exe_alu_out;
            exe2mem_pc2rd               <= exe_pc2rd;
            exe2mem_rs1_data            <= exe_rs1_data;
            exe2mem_rs2_data            <= exe_rs2_data;
            exe2mem_csr_wr              <= ~exe_flush & ~exe_irq_en & ~((exe2mem_wfi | mem2wb_wfi) & ~wakeup_event) &
                                           (exe_pmu_csr_wr|
                                            exe_fpu_csr_wr|
                                            exe_dbg_csr_wr|
                                            exe_mmu_csr_wr|
                                            exe_mpu_csr_wr|
                                            exe_sru_csr_wr);
            exe2mem_csr_waddr           <= id2exe_csr_waddr;
            exe2mem_csr_wdata           <= exe_csr_wdata;
            exe2mem_wfi                 <= ~exe_flush & ~exe_irq_en & ~exe2mem_wfi & ~wakeup_event & id2exe_wfi;
            exe2mem_prv                 <= exe_prv;
            exe2mem_trap_en             <= exe_irq_en | exe_trap_en;
            exe2mem_cause               <= exe_cause;
            exe2mem_tval                <= exe_tval;
            exe2mem_epc                 <= exe_trap_epc;
            exe2mem_tlb_flush_req       <= ~exe_flush & id2exe_tlb_flush_req;
            exe2mem_tlb_flush_all_vaddr <= id2exe_tlb_flush_all_vaddr;
            exe2mem_tlb_flush_all_asid  <= id2exe_tlb_flush_all_asid;
            exe2mem_fense_i             <= ~exe_flush & id2exe_fense_i;
            exe2mem_attach              <= id2exe_attach;
        end
        else begin
            exe2mem_rs1_data     <= mem_rs1_data;
            exe2mem_rs2_data     <= mem_dpu_wdata;
        end
    end
end

// MEM stage
// MEM_ADDR Forward
assign fwd_wb2mem_rd_rs1  = mem2wb_rd_wr & (exe2mem_rs1_addr == mem2wb_rd_addr) & |mem2wb_rd_addr;
assign fwd_wb2mem_rd_rs2  = mem2wb_rd_wr & (exe2mem_rs2_addr == mem2wb_rd_addr) & |mem2wb_rd_addr;

assign mem_dpu_req   = ~mem_flush & ~(mem2wb_wfi & ~wakeup_event) & exe2mem_mem_req;
assign mem_dpu_wr    = exe2mem_mem_wr;
assign mem_dpu_byte  = exe2mem_mem_byte;
assign mem_dpu_addr  = exe2mem_alu_out;
assign mem_rs1_data  = fwd_wb2mem_rd_rs1 ? wb_rd_data : exe2mem_rs1_data;
assign mem_dpu_wdata = fwd_wb2mem_rd_rs2 ? wb_rd_data : exe2mem_rs2_data;

assign tlb_flush_req       = exe2mem_tlb_flush_req;
assign tlb_flush_all_vaddr = exe2mem_tlb_flush_all_vaddr;
assign tlb_flush_all_asid  = exe2mem_tlb_flush_all_asid;
assign tlb_flush_vaddr     = mem_rs1_data;
assign tlb_flush_asid      = mem_dpu_wdata;

assign ic_flush            = exe2mem_fense_i;
assign mem_pl_restart      = ~mem_stall && (exe2mem_tlb_flush_req | exe2mem_fense_i);

dpu u_dpu (
    .clk              ( clk_wfi              ),
    .rstn             ( rstn                 ),

    .pc_i             ( exe2mem_pc           ),
    .sign_ext_i       ( exe2mem_mem_sign_ext ),
    .req_i            ( mem_dpu_req          ),
    .wr_i             ( mem_dpu_wr           ),
    .byte_i           ( mem_dpu_byte         ),
    .addr_i           ( mem_dpu_addr         ),
    .wdata_i          ( mem_dpu_wdata        ),
    .rdata_o          ( mem_dpu_rdata        ),
    .hazard_o         ( mem_dpu_hazard       ),

    .bad_dxes_val     ( mem_bad_dxes_val     ),
    .fault            ( mem_dpu_fault        ),
    .load_misaligned  ( mem_load_misaligned  ),
    .load_pg_fault    ( mem_load_page_fault  ),
    .load_xes_fault   ( mem_load_xes_fault   ),
    .store_misaligned ( mem_store_misaligned ),
    .store_pg_fault   ( mem_store_page_fault ),
    .store_xes_fault  ( mem_store_xes_fault  ),
    .fault_pc         ( mem_dpu_pc           ),
                              
    .dmem_req         ( dmem_en              ),
    .dmem_addr        ( dmem_addr            ),
    .dmem_wr          ( dmem_write           ),
    .dmem_byte        ( dmem_strb            ),
    .dmem_wdata       ( dmem_wdata           ),
    .dmem_rdata       ( dmem_rdata           ),
    .dmem_bad         ( dmem_bad             ),
    .dmem_busy        ( dmem_busy            )
);

assign mem_rd_data = exe2mem_pc_alu_sel  ? exe2mem_pc2rd :
                     exe2mem_csr_alu_sel ? exe2mem_csr_rdata :
                                           exe2mem_alu_out;

// MEM/WB pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
    if (~rstn_sync) begin
        mem2wb_pc           <= `IM_ADDR_LEN'b0;
        mem2wb_inst         <= `IM_DATA_LEN'b0;
        mem2wb_inst_valid   <= 1'b0;
        mem2wb_rd_wr        <= 1'b0;
        mem2wb_rd_addr      <= 5'b0;
        mem2wb_mem_byte     <= {(`DM_DATA_LEN >> 3){1'b0}};
        mem2wb_mem_sign_ext <= 1'b0;
        mem2wb_mem_cal_sel  <= 1'b0;
        mem2wb_rd_data      <= `XLEN'b0;
        mem2wb_mem_addr     <= `DM_ADDR_LEN'b0;
        mem2wb_mem_wdata    <= `DM_DATA_LEN'b0;
        mem2wb_mem_req      <= 1'b0;
        mem2wb_mem_wr       <= 1'b0;
        mem2wb_csr_wr       <= 1'b0;
        mem2wb_csr_waddr    <= 12'b0;
        mem2wb_csr_wdata    <= `XLEN'b0;
        mem2wb_wfi          <= 1'b0;
        mem2wb_prv          <= 2'b0;
        mem2wb_trap_en      <= 1'b0;
        mem2wb_cause        <= `XLEN'b0;
        mem2wb_tval         <= `XLEN'b0;
        mem2wb_epc          <= `IM_ADDR_LEN'b0;
        mem2wb_attach       <= 1'b0;
    end
    else begin
        if (~wb_stall | mem_flush_force) begin
            mem2wb_pc           <= exe2mem_pc;
            mem2wb_inst         <= exe2mem_inst;
            mem2wb_inst_valid   <= ~mem_flush & ~(mem2wb_wfi & ~wakeup_event) & exe2mem_inst_valid;
            mem2wb_rd_wr        <= ~mem_flush & ~(mem2wb_wfi & ~wakeup_event) & exe2mem_rd_wr;
            mem2wb_rd_addr      <= exe2mem_rd_addr;
            mem2wb_mem_byte     <= dmem_strb;
            mem2wb_mem_sign_ext <= exe2mem_mem_sign_ext;
            mem2wb_mem_cal_sel  <= exe2mem_mem_cal_sel;
            mem2wb_rd_data      <= mem_rd_data;
            mem2wb_mem_addr     <= mem_dpu_addr;
            mem2wb_mem_wdata    <= dmem_wdata;
            mem2wb_mem_req      <= ~mem_flush & ~(mem2wb_wfi & ~wakeup_event) & exe2mem_mem_req;
            mem2wb_mem_wr       <= ~mem_flush & ~(mem2wb_wfi & ~wakeup_event) & exe2mem_mem_wr;
            mem2wb_csr_wr       <= exe2mem_csr_wr;
            mem2wb_csr_waddr    <= exe2mem_csr_waddr;
            mem2wb_csr_wdata    <= exe2mem_csr_wdata;
            mem2wb_wfi          <= ~mem_flush & ~mem2wb_wfi & ~wakeup_event & exe2mem_wfi;
            mem2wb_prv          <= exe2mem_prv;
            mem2wb_trap_en      <= exe2mem_trap_en;
            mem2wb_cause        <= exe2mem_cause;
            mem2wb_tval         <= exe2mem_tval;
            mem2wb_epc          <= exe2mem_epc;
            mem2wb_attach       <= exe2mem_attach;
        end
    end
end

// WB stage
assign wb_rd_data    = mem2wb_mem_cal_sel ?  mem_dpu_rdata : mem2wb_rd_data;
assign wb_rd_wr      = ~wb_flush & mem2wb_rd_wr;
assign wb_inst_valid = ~wb_flush & mem2wb_inst_valid;
assign wb_wfi        = ~wb_flush /*& ~wakeup_event*/ & mem2wb_wfi;

assign dbg_pc_out    = mem2wb_pc;
assign halted        = mem2wb_attach;

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
    .clk       ( clk_wfi          ),
    .valid     ( wb_inst_valid    ),
    .pc        ( mem2wb_pc        ),
    .epc       ( mem2wb_epc       ),
    .inst      ( mem2wb_inst      ),
    .prv       ( mem2wb_prv       ),
    .rd_wr     ( wb_rd_wr         ),
    .rd_addr   ( mem2wb_rd_addr   ),
    .rd_data   ( wb_rd_data       ),
    .csr_wr    ( mem2wb_csr_wr    ),
    .csr_waddr ( mem2wb_csr_waddr ),
    .csr_wdata ( mem2wb_csr_wdata ),
    .mem_addr  ( mem2wb_mem_addr  ),
    .mem_req   ( mem2wb_mem_req   ),
    .mem_wr    ( mem2wb_mem_wr    ),
    .mem_byte  ( mem2wb_mem_byte  ),
    .mem_rdata ( dmem_rdata       ),
    .mem_wdata ( mem2wb_mem_wdata ),
    .trap_en   ( mem2wb_trap_en   ),
    .mcause    ( mem2wb_cause     ),
    .mtval     ( mem2wb_tval      ),
    .halted    ( halted           )
);
`endif

endmodule
