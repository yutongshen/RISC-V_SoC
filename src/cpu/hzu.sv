module hzu (
    input  [5:0] insn_valid,
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
    input        id_jump_fault,
    input        exe_jump_fault,
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
logic [5:0] flush_jump_all;

assign {if_stall, id_stall, exe_stall, ma_stall, mr_stall, wb_stall} = stall_all;
assign {if_flush, id_flush, exe_flush, ma_flush, mr_flush, wb_flush} = flush_all | flush_jump_all | flush_force_all;
assign {if_flush_force, id_flush_force, exe_flush_force, ma_flush_force, mr_flush_force, wb_flush_force} = flush_force_all;

// assign {wb_stall, mr_stall, ma_stall, exe_stall, id_stall, if_stall} = stall_all;
// assign {wb_flush, mr_flush, ma_flush, exe_flush, id_flush, if_flush} = flush_all | flush_jump_all | flush_force_all;
// assign {wb_flush_force, mr_flush_force, ma_flush_force, exe_flush_force, id_flush_force, if_flush_force} = flush_force_all;

assign stall_all = (~({4'b0, dpu_hazard, 1'b0} + (insn_valid | 6'h2)) & (insn_valid | 6'h2))|
                   (~({2'b0, exe_hazard, 3'b0} + insn_valid) & insn_valid)|
                   (~({1'b0,  id_hazard, 4'b0} + insn_valid) & insn_valid);

// assign stall_all = dpu_hazard ? 6'b111110:
//                    exe_hazard ? 6'b111000:
//                    id_hazard  ? 6'b110000:
//                                 6'b000000;

assign flush_all = ({6{dpu_hazard}} & 6'b000010)|
                   ({6{exe_hazard}} & 6'b001000)|
                   ({6{pc_alu_en }} & 6'b110000)|
                   ({6{id_hazard }} & 6'b010000)|
                   ({6{pc_jump_en}} & 6'b100000);
// assign flush_all = dpu_hazard ? 6'b000010:
//                    exe_hazard ? 6'b001000:
//                    pc_alu_en  ? 6'b110000:
//                    id_hazard  ? 6'b010000:
//                    pc_jump_en ? 6'b100000:
//                                 6'b000000;

assign flush_jump_all = ({6{irq_en    }} & 6'b111000) |
                        ({6{trap_en   }} & 6'b111000) |
                        ({6{pc_alu_en }} & 6'b110000) |
                        ({6{pc_jump_en}} & 6'b100000);

assign flush_force_all = ({6{dpu_fault      }} & 6'b111111) |
                         ({6{pipe_restart_en}} & 6'b111100) |
                         ({6{eret_en        }} & 6'b110000) |
                         ({6{irq_en         }} & 6'b110000) |
                         ({6{trap_en        }} & 6'b110000) |
                         ({6{pc_alu_en      }} & 6'b100000);

endmodule
