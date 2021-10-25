module hzu (
    input  [4:0] inst_valid,
    input        pc_jump_en,
    input        pc_alu_en,
    input        id_hazard,
    input        exe_hazard,
    input        dpu_hazard,
    output       if_stall,
    output       id_stall,
    output       exe_stall,
    output       mem_stall,
    output       wb_stall,
    output       if_flush,
    output       id_flush,
    output       exe_flush,
    output       mem_flush,
    output       wb_flush,
    output       if_flush_force,
    output       id_flush_force,
    output       exe_flush_force,
    output       mem_flush_force,
    output       wb_flush_force
);

logic [4:0] stall_all;
logic [4:0] flush_all;
logic [4:0] flush_force_all;

assign {wb_stall, mem_stall, exe_stall, id_stall, if_stall} = stall_all/* & inst_valid*/;
assign {wb_flush, mem_flush, exe_flush, id_flush, if_flush} = flush_all | flush_force_all;
assign {wb_flush_force, mem_flush_force, exe_flush_force, id_flush_force, if_flush_force} = flush_force_all;

assign stall_all = dpu_hazard ? 5'b11111:
                   exe_hazard ? 5'b00111:
                   id_hazard  ? 5'b00011:
                                5'b00000;

assign flush_all = dpu_hazard ? 5'b10000:
                   exe_hazard ? 5'b00100:
                   id_hazard  ? 5'b00010:
                                5'b00000;

assign flush_force_all = pc_alu_en  ? 5'b00011 : 5'b00000;

endmodule
