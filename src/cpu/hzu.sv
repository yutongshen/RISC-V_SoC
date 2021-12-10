module hzu (
    input  [4:0] inst_valid,
    input        pc_jump_en,
    input        pc_alu_en,
    input        irq_en,
    input        trap_en,
    input        eret_en,
    input        pipe_restart_en,
    input        id_hazard,
    input        exe_hazard,
    input        dpu_hazard,
    input        dpu_fault,
    output       if_stall,
    output       id_stall,
    output       exe_stall,
    output       ma_stall,
    output       mr_stall,
    output       wb_stall,
    output       if_flush,
    output       id_flush,
    output       exe_flush,
    output       ma_flush,
    output       mr_flush,
    output       wb_flush,
    output       if_flush_force,
    output       id_flush_force,
    output       exe_flush_force,
    output       ma_flush_force,
    output       mr_flush_force,
    output       wb_flush_force
);

logic [5:0] stall_all;
logic [5:0] flush_all;
logic [5:0] flush_force_all;
logic [5:0] flush_trap_all;

assign {wb_stall, mr_stall, ma_stall, exe_stall, id_stall, if_stall} = stall_all/* & inst_valid*/;
assign {wb_flush, mr_flush, ma_flush, exe_flush, id_flush, if_flush} = flush_all | flush_trap_all | flush_force_all;
assign {wb_flush_force, mr_flush_force, ma_flush_force, exe_flush_force, id_flush_force, if_flush_force} = flush_force_all;

assign stall_all = dpu_hazard ? 6'b011111:
                   exe_hazard ? 6'b000111:
                   id_hazard  ? 6'b000011:
                                6'b000000;

assign flush_all = dpu_hazard ? 6'b010000:
                   exe_hazard ? 6'b000100:
                   id_hazard  ? 6'b000010:
                                6'b000000;

assign flush_force_all = dpu_fault                                   ? 6'b111111:
                         pipe_restart_en                             ? 6'b001111:
                         (pc_alu_en || eret_en || irq_en || trap_en) ? 6'b000011:
                                                                       6'b000000;

assign flush_trap_all = (irq_en || trap_en) ? 6'b000100 : 6'b000000;

endmodule
