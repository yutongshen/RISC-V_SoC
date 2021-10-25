`include "cpu_define.h"

module cpu_top (
    input                                    clk,
    input                                    rstn,
    input        [              `XLEN - 1:0] cpu_id,
    // interrupt interface
    input                                    msip,
    input                                    mtip,
    input                                    meip,
    // inst interface
    output logic                             imem_en,
    output logic [       `IM_ADDR_LEN - 1:0] imem_addr,
    input        [       `IM_DATA_LEN - 1:0] imem_rdata,
    input                                    imem_busy,
    // data interface                             
    output logic                             dmem_en,
    output logic [       `IM_ADDR_LEN - 1:0] dmem_addr,
    output logic                             dmem_write,
    output logic [(`IM_DATA_LEN >> 3) - 1:0] dmem_strb,
    output logic [       `IM_DATA_LEN - 1:0] dmem_wdata,
    input        [       `IM_DATA_LEN - 1:0] dmem_rdata,
    input                                    dmem_busy
);

parameter [31:0] INST_NOP = {12'b0, 5'b0, 3'b0, 5'b0, 7'b00_100_11};

logic                             rstn_sync;
logic                             wakeup_event;
logic                             sleep;
logic                             stall_wfi;
logic [                      4:0] inst_valid;
logic                             irq_en;
logic [       `IM_ADDR_LEN - 1:0] irq_vec;

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

// IF/ID pipeline
logic [       `IM_DATA_LEN - 1:0] if2id_inst;
logic                             if2id_inst_valid;
logic [       `IM_ADDR_LEN - 1:0] if2id_pc;

// ID stage
logic [                      4:0] id_rd_addr;
logic [                      4:0] id_rs1_addr;
logic [                      4:0] id_rs2_addr;
logic [              `XLEN - 1:0] id_rs1_data;
logic [              `XLEN - 1:0] id_rs2_data;
logic [                     11:0] id_csr_addr;
logic [              `XLEN - 1:0] id_imm;

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

logic                             id_mem_cal_sel;
logic                             id_rd_wr;

logic                             id_hazard;
logic                             id_csr_rd;
logic                             id_csr_wr;
logic                             id_pmu_csr_wr;
logic                             id_fpu_csr_wr;
logic                             id_dbg_csr_wr;
logic                             id_mpu_csr_wr;
logic                             id_sru_csr_wr;
logic [              `XLEN - 1:0] id_csr_rdata;
logic [              `XLEN - 1:0] id_pmu_csr_rdata;
logic [              `XLEN - 1:0] id_fpu_csr_rdata;
logic [              `XLEN - 1:0] id_dbg_csr_rdata;
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
logic                             id2exe_pmu_csr_wr;
logic                             id2exe_fpu_csr_wr;
logic                             id2exe_dbg_csr_wr;
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
logic                             exe_mpu_csr_wr;
logic                             exe_sru_csr_wr;

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
logic [                      4:0] exe2mem_rs2_addr;
logic [              `XLEN - 1:0] exe2mem_alu_out;
logic [              `XLEN - 1:0] exe2mem_pc2rd;
logic [              `XLEN - 1:0] exe2mem_rs2_data;
logic                             exe2mem_csr_wr;
logic [                     11:0] exe2mem_csr_waddr;
logic [              `XLEN - 1:0] exe2mem_csr_wdata;
logic                             exe2mem_wfi;

// MEM stage
logic [              `XLEN - 1:0] mem_rd_data;

logic                             mem_dpu_req;
logic                             mem_dpu_wr;
logic [(`IM_DATA_LEN >> 3) - 1:0] mem_dpu_byte;
logic [       `IM_ADDR_LEN - 1:0] mem_dpu_addr;
logic [       `IM_DATA_LEN - 1:0] mem_dpu_wdata;

logic [       `IM_DATA_LEN - 1:0] mem_dpu_rdata;
logic                             mem_dpu_hazard;

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
    .id_hazard       ( id_hazard       ),
    .exe_hazard      ( exe_hazard      ),
    .dpu_hazard      ( mem_dpu_hazard  ),
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
    .clk        ( clk                          ),
    .rstn       ( rstn_sync                    ),
    .irq_en     ( irq_en                       ),
    .irq_vec    ( irq_vec                      ),
    .pc_jump_en ( if_pc_jump_en                ),
    .pc_jump    ( if_pc_jump                   ),
    .pc_alu_en  ( if_pc_alu_en                 ),
    .pc_alu     ( if_pc_alu                    ),
    .imem_req   ( imem_en                      ),
    .imem_addr  ( imem_addr                    ),
    .imem_rdata ( imem_rdata                   ),
    .imem_busy  ( imem_busy                    ),
    .pc         ( if_pc                        ),
    .inst       ( if_inst                      ),
    .inst_valid ( if_inst_valid                ),
    .flush      ( if_flush                     ),
    .stall      ( if_stall | stall_wfi | sleep )
);

assign exe_branch_match = id2exe_branch & (id2exe_branch_zcmp == exe_alu_zero);

assign if_pc_jump_en = id_jump & if2id_inst_valid & ~id_stall & ~stall_wfi;
assign if_pc_jump    = id_imm + if2id_pc;
assign if_pc_alu_en  = (id2exe_jump_alu | exe_branch_match) & id2exe_inst_valid & ~exe_stall;
assign if_pc_alu     = ({`IM_ADDR_LEN{id2exe_jump_alu}}  & exe_alu_out) |
                   ({`IM_ADDR_LEN{exe_branch_match}} & exe_pc_imm[`IM_ADDR_LEN - 1:0] );

// IF/ID pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
if (~rstn_sync) begin
    if2id_pc         <= `IM_ADDR_LEN'b0;
    if2id_inst       <= `IM_DATA_LEN'b0;
    if2id_inst_valid <= 1'b0;
end
else begin
    if ((~id_stall & ~stall_wfi) | if_flush_force) begin
        if2id_pc         <= if_pc;
        if2id_inst       <= if_inst;
        if2id_inst_valid <= ~if_flush & if_inst_valid;
    end
end
end

// ID stage
idu u_idu (
    .clk          ( clk_wfi          ),
    .rstn         ( rstn_sync        ),
    .inst         ( if2id_inst       ),
    .inst_valid   ( if2id_inst_valid ),
    .pc           ( if2id_pc         ),
    .rd_wr_i      ( wb_rd_wr         ),
    .rd_addr_i    ( mem2wb_rd_addr   ),
    .rd_data      ( wb_rd_data       ),
    .rd_addr_o    ( id_rd_addr       ),
    .rs1_addr     ( id_rs1_addr      ),
    .rs2_addr     ( id_rs2_addr      ),
    .rs1_data     ( id_rs1_data      ),
    .rs2_data     ( id_rs2_data      ),
    .csr_addr     ( id_csr_addr      ),
    .imm          ( id_imm           ),
    // Control
    .ill_inst     ( id_ill_inst      ),
    .fense        ( id_fense         ),
    .fense_i      ( id_fense_i       ),
    .ecall        ( id_ecall         ),
    .ebreak       ( id_ebreak        ),
    .wfi          ( id_wfi           ),
    .sret         ( id_sret          ),
    .mret         ( id_mret          ),
    .jump         ( id_jump          ),
    .jump_alu     ( id_jump_alu      ),
    // For EXE stage
    .alu_op       ( id_alu_op        ),
    .rs1_zero_sel ( id_rs1_zero_sel  ),
    .rs2_imm_sel  ( id_rs2_imm_sel   ),
    .pc_imm_sel   ( id_pc_imm_sel    ),
    .branch       ( id_branch        ),
    .branch_zcmp  ( id_branch_zcmp   ),
    .csr_op       ( id_csr_op        ),
    .uimm_rs1_sel ( id_uimm_rs1_sel  ),
    .csr_rd       ( id_csr_rd        ),
    .csr_wr       ( id_csr_wr        ),
    // For MEM stage
    .pc_alu_sel   ( id_pc_alu_sel    ),
    .csr_alu_sel  ( id_csr_alu_sel   ),
    .mem_req      ( id_mem_req       ),
    .mem_wr       ( id_mem_wr        ),
    .mem_byte     ( id_mem_byte      ),
    .mem_sign_ext ( id_mem_sign_ext  ),
    // For WB stage
    .mem_cal_sel  ( id_mem_cal_sel   ),
    .rd_wr_o      ( id_rd_wr         )
);

assign id_fpu_csr_rdata = `XLEN'b0;
assign id_dbg_csr_rdata = `XLEN'b0;
assign id_mpu_csr_rdata = `XLEN'b0;

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
    .mpu_csr_wr    ( id_mpu_csr_wr    ),
    .sru_csr_wr    ( id_sru_csr_wr    ),
    .pmu_csr_rdata ( id_pmu_csr_rdata ),
    .fpu_csr_rdata ( id_fpu_csr_rdata ),
    .dbg_csr_rdata ( id_dbg_csr_rdata ),
    .mpu_csr_rdata ( id_mpu_csr_rdata ),
    .sru_csr_rdata ( id_sru_csr_rdata )
);

sru u_sru (
    .clk         ( clk_wfi           ),
    .clk_free    ( clk               ),
    .rstn        ( rstn_sync         ),
    .sleep       ( sleep             ),

    // IRQ signal
    .msip        ( msip              ),
    .mtip        ( mtip              ),
    .meip        ( meip              ),
    .wakeup      ( wakeup_event      ),
    .irq_trigger ( irq_en            ),

    // PC control
    .trap_vec    ( irq_vec           ),
    .ret_epc     (                   ),

    // Trap signal
    .epc         ( id2exe_pc         ),
    .trap_en     ( 1'b0              ),
    .trap_cause  ( 32'b0             ),
    .trap_val    ( 32'b0             ),
    .sret        ( 1'b0              ),
    .mret        ( 1'b0              ),
    
    // CSR interface
    .csr_wr      ( id2exe_sru_csr_wr & ~exe_stall & ~stall_wfi & ~exe_flush ),
    .csr_waddr   ( id2exe_csr_waddr  ),
    .csr_raddr   ( id_csr_addr       ),
    .csr_wdata   ( exe_csr_wdata     ),
    .csr_rdata   ( id_sru_csr_rdata  )
);

// ID Hazard
assign id_hazard = id_csr_rd &&
                   (exe_pmu_csr_wr | exe_fpu_csr_wr | exe_dbg_csr_wr | exe_mpu_csr_wr | exe_sru_csr_wr) &&
                   (id_csr_addr == id2exe_csr_waddr);


// ID/EXE pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
if (~rstn_sync) begin
    id2exe_pc           <= `IM_ADDR_LEN'b0;
    id2exe_inst         <= `IM_DATA_LEN'b0;
    id2exe_inst_valid   <= 1'b0;
    id2exe_rd_addr      <= 5'b0;
    id2exe_rs1_addr     <= 5'b0;
    id2exe_rs2_addr     <= 5'b0;
    id2exe_rs1_data     <= `XLEN'b0;
    id2exe_rs2_data     <= `XLEN'b0;
    id2exe_csr_waddr    <= 12'b0;
    id2exe_csr_rdata    <= `XLEN'b0;
    id2exe_imm          <= `XLEN'b0;
    id2exe_alu_op       <= `ALU_OP_LEN'b0;
    id2exe_rs1_zero_sel <= 1'b0;
    id2exe_rs2_imm_sel  <= 1'b0;
    id2exe_pc_imm_sel   <= 1'b0;
    id2exe_jump_alu     <= 1'b0;
    id2exe_branch       <= 1'b0;
    id2exe_branch_zcmp  <= 1'b0;
    id2exe_csr_op       <= `CSR_OP_LEN'b0;
    id2exe_uimm_rs1_sel <= 1'b0;
    id2exe_pmu_csr_wr   <= 1'b0;
    id2exe_fpu_csr_wr   <= 1'b0;
    id2exe_dbg_csr_wr   <= 1'b0;
    id2exe_mpu_csr_wr   <= 1'b0;
    id2exe_sru_csr_wr   <= 1'b0;
    id2exe_pc_alu_sel   <= 1'b0;
    id2exe_csr_alu_sel  <= 1'b0;
    id2exe_mem_req      <= 1'b0;
    id2exe_mem_wr       <= 1'b0;
    id2exe_mem_byte     <= {(`DM_DATA_LEN >> 3){1'b0}};
    id2exe_mem_sign_ext <= 1'b0;
    id2exe_mem_cal_sel  <= 1'b0;
    id2exe_rd_wr        <= 1'b0;
    id2exe_wfi          <= 1'b0;
end
else begin
    if ((~exe_stall & ~stall_wfi) | id_flush_force) begin
        id2exe_pc           <= if2id_pc;
        id2exe_inst         <= if2id_inst;
        id2exe_inst_valid   <= ~id_flush & if2id_inst_valid;
        id2exe_rd_addr      <= id_rd_addr;
        id2exe_rs1_addr     <= id_rs1_addr;
        id2exe_rs2_addr     <= id_rs2_addr;
        id2exe_rs1_data     <= id_rs1_data;
        id2exe_rs2_data     <= id_rs2_data;
        id2exe_csr_waddr    <= id_csr_addr;
        id2exe_csr_rdata    <= id_csr_rdata;
        id2exe_imm          <= id_imm;
        id2exe_alu_op       <= id_alu_op;
        id2exe_rs1_zero_sel <= id_rs1_zero_sel;
        id2exe_rs2_imm_sel  <= id_rs2_imm_sel;
        id2exe_pc_imm_sel   <= id_pc_imm_sel;
        id2exe_jump_alu     <= id_jump_alu;
        id2exe_branch       <= id_branch;
        id2exe_branch_zcmp  <= id_branch_zcmp;
        id2exe_csr_op       <= id_csr_op;
        id2exe_uimm_rs1_sel <= id_uimm_rs1_sel;
        id2exe_pmu_csr_wr   <= ~id_flush & id_pmu_csr_wr;
        id2exe_fpu_csr_wr   <= ~id_flush & id_fpu_csr_wr;
        id2exe_dbg_csr_wr   <= ~id_flush & id_dbg_csr_wr;
        id2exe_mpu_csr_wr   <= ~id_flush & id_mpu_csr_wr;
        id2exe_sru_csr_wr   <= ~id_flush & id_sru_csr_wr;
        id2exe_pc_alu_sel   <= id_pc_alu_sel;
        id2exe_csr_alu_sel  <= id_csr_alu_sel;
        id2exe_mem_req      <= ~id_flush & id_mem_req;
        id2exe_mem_wr       <= ~id_flush & id_mem_wr;
        id2exe_mem_byte     <= id_mem_byte;
        id2exe_mem_sign_ext <= id_mem_sign_ext;
        id2exe_mem_cal_sel  <= id_mem_cal_sel;
        id2exe_rd_wr        <= ~id_flush & id_rd_wr;
        id2exe_wfi          <= ~id_flush & id_wfi;
    end
    else begin
        id2exe_rs1_data     <= exe_rs1_data;
        id2exe_rs2_data     <= exe_rs2_data;
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

assign exe_hazard   = (exe2mem_mem_req & ~exe2mem_mem_wr & exe2mem_mem_cal_sel) &
                  (exe2mem_rd_wr & (id2exe_rs1_addr == exe2mem_rd_addr) & |id2exe_rs1_addr |
                   exe2mem_rd_wr & (id2exe_rs2_addr == exe2mem_rd_addr) & |id2exe_rs2_addr);

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

assign exe_pmu_csr_wr = id2exe_pmu_csr_wr & ~exe_stall;
assign exe_fpu_csr_wr = id2exe_fpu_csr_wr & ~exe_stall;
assign exe_dbg_csr_wr = id2exe_dbg_csr_wr & ~exe_stall;
assign exe_mpu_csr_wr = id2exe_mpu_csr_wr & ~exe_stall;
assign exe_sru_csr_wr = id2exe_sru_csr_wr & ~exe_stall;

assign exe_csr_src1 = id2exe_uimm_rs1_sel ? {{(`XLEN-5){1'b0}}, id2exe_rs1_addr} : exe_rs1_data;
assign exe_csr_src2 = id2exe_csr_rdata;

always_comb begin
exe_csr_wdata = `XLEN'b0;
case (id2exe_csr_op)
    CSR_OP_NONE: exe_csr_wdata = exe_csr_src1;
    CSR_OP_SET : exe_csr_wdata = exe_csr_src2 |  exe_csr_src1;
    CSR_OP_CLR : exe_csr_wdata = exe_csr_src2 & ~exe_csr_src1;
endcase
end

// EXE/MEM pipeline
always_ff @(posedge clk_wfi or negedge rstn_sync) begin
if (~rstn_sync) begin
    exe2mem_pc           <= `IM_ADDR_LEN'b0;
    exe2mem_inst         <= `IM_DATA_LEN'b0;
    exe2mem_inst_valid   <= 1'b0;
    exe2mem_mem_req      <= 1'b0;
    exe2mem_mem_wr       <= 1'b0;
    exe2mem_mem_byte     <= {(`DM_DATA_LEN >> 3){1'b0}};
    exe2mem_mem_sign_ext <= 1'b0;
    exe2mem_pc_alu_sel   <= 1'b0;
    exe2mem_csr_rdata    <= `XLEN'b0;
    exe2mem_csr_alu_sel  <= 1'b0;
    exe2mem_mem_cal_sel  <= 1'b0;
    exe2mem_rd_wr        <= 1'b0;
    exe2mem_rd_addr      <= 5'b0;
    exe2mem_rs2_addr     <= 5'b0;
    exe2mem_alu_out      <= `XLEN'b0;
    exe2mem_pc2rd        <= `XLEN'b0;
    exe2mem_rs2_data     <= `XLEN'b0;
    exe2mem_csr_wr       <= 1'b0;
    exe2mem_csr_waddr    <= 12'b0;
    exe2mem_csr_wdata    <= `XLEN'b0;
    exe2mem_wfi          <= 1'b0;
end
else begin
    if (~mem_stall | exe_flush_force) begin
        exe2mem_pc           <= id2exe_pc;
        exe2mem_inst         <= id2exe_inst;
        exe2mem_inst_valid   <= ~exe_flush & ~irq_en & ~((exe2mem_wfi | mem2wb_wfi) & ~wakeup_event) & id2exe_inst_valid;
        exe2mem_mem_req      <= ~exe_flush & ~irq_en & ~((exe2mem_wfi | mem2wb_wfi) & ~wakeup_event) & id2exe_mem_req;
        exe2mem_mem_wr       <= ~exe_flush & ~irq_en & ~((exe2mem_wfi | mem2wb_wfi) & ~wakeup_event) & id2exe_mem_wr;
        exe2mem_mem_byte     <= id2exe_mem_byte;
        exe2mem_mem_sign_ext <= id2exe_mem_sign_ext;
        exe2mem_pc_alu_sel   <= id2exe_pc_alu_sel;
        exe2mem_csr_rdata    <= id2exe_csr_rdata;
        exe2mem_csr_alu_sel  <= id2exe_csr_alu_sel;
        exe2mem_mem_cal_sel  <= id2exe_mem_cal_sel;
        exe2mem_rd_wr        <= ~exe_flush & ~irq_en & ~((exe2mem_wfi | mem2wb_wfi) & ~wakeup_event) & id2exe_rd_wr;
        exe2mem_rd_addr      <= id2exe_rd_addr;
        exe2mem_rs2_addr     <= id2exe_rs2_addr;
        exe2mem_alu_out      <= exe_alu_out;
        exe2mem_pc2rd        <= exe_pc2rd;
        exe2mem_rs2_data     <= exe_rs2_data;
        exe2mem_csr_wr       <= exe_pmu_csr_wr|
                                exe_fpu_csr_wr|
                                exe_dbg_csr_wr|
                                exe_mpu_csr_wr|
                                exe_sru_csr_wr;
        exe2mem_csr_waddr    <= id2exe_csr_waddr;
        exe2mem_csr_wdata    <= exe_csr_wdata;
        exe2mem_wfi          <= ~exe_flush & ~irq_en & ~exe2mem_wfi & ~wakeup_event & id2exe_wfi;
    end
    else begin
        exe2mem_rs2_data     <= dmem_wdata;
    end
end
end

// MEM stage
// MEM_ADDR Forward
assign fwd_wb2mem_rd_rs2  = mem2wb_rd_wr & (exe2mem_rs2_addr == mem2wb_rd_addr) & |exe2mem_rs2_addr;

assign mem_dpu_req   = exe2mem_mem_req;
assign mem_dpu_wr    = exe2mem_mem_wr;
assign mem_dpu_byte  = exe2mem_mem_byte;
assign mem_dpu_addr  = exe2mem_alu_out;
assign mem_dpu_wdata = fwd_wb2mem_rd_rs2 ? wb_rd_data : exe2mem_rs2_data;

dpu u_dpu (
    .clk        ( clk_wfi        ),
    .rstn       ( rstn           ),
                            
    .sign_ext_i ( exe2mem_mem_sign_ext ),
    .req_i      ( mem_dpu_req    ),
    .wr_i       ( mem_dpu_wr     ),
    .byte_i     ( mem_dpu_byte   ),
    .addr_i     ( mem_dpu_addr   ),
    .wdata_i    ( mem_dpu_wdata  ),
    .rdata_o    ( mem_dpu_rdata  ),
    .hazard_o   ( mem_dpu_hazard ),
                            
    .dmem_req   ( dmem_en        ),
    .dmem_addr  ( dmem_addr      ),
    .dmem_wr    ( dmem_write     ),
    .dmem_byte  ( dmem_strb      ),
    .dmem_wdata ( dmem_wdata     ),
    .dmem_rdata ( dmem_rdata     ),
    .dmem_busy  ( dmem_busy      )
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
        mem2wb_mem_req      <= exe2mem_mem_req;
        mem2wb_mem_wr       <= exe2mem_mem_wr;
        mem2wb_csr_wr       <= exe2mem_csr_wr;
        mem2wb_csr_waddr    <= exe2mem_csr_waddr;
        mem2wb_csr_wdata    <= exe2mem_csr_wdata;
        mem2wb_wfi          <= ~mem_flush & ~mem2wb_wfi & ~wakeup_event & exe2mem_wfi;
    end
end
end

// WB stage
assign wb_rd_data    = mem2wb_mem_cal_sel ?  mem_dpu_rdata : mem2wb_rd_data;
assign wb_rd_wr      = ~wb_flush & mem2wb_rd_wr;
assign wb_inst_valid = ~wb_flush & mem2wb_inst_valid;
assign wb_wfi        = ~wb_flush /*& ~wakeup_event*/ & mem2wb_wfi;

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

// Tracer
cpu_tracer u_cpu_tracer (
    .clk       ( clk_wfi          ),
    .valid     ( wb_inst_valid    ),
    .pc        ( mem2wb_pc        ),
    .inst      ( mem2wb_inst      ),
    .rd_wr     ( mem2wb_rd_wr     ),
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
    .mem_wdata ( mem2wb_mem_wdata )
);

endmodule
