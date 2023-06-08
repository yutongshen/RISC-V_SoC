`include "cpu_define.h"

module tpu (
    input                           insn_valid,
    input        [`IM_DATA_LEN-1:0] insn,
    input                           exe_hazard,
    input        [`IM_ADDR_LEN-1:0] exe_pc,
    input        [`IM_ADDR_LEN-1:0] wb_pc,
    input        [`DM_ADDR_LEN-1:0] ldst_badaddr,
    input        [`IM_ADDR_LEN-1:0] insn_badaddr,
    input        [             1:0] prv_cur,
    input        [             1:0] prv_req,
    input                           touch_satp,
    input                           tvm,
    input                           tsr,
    input                           sret,
    input                           ecall,
    input                           ebreak,
    input                           tlb_flush_req,
    input                           ill_insn,
    input                           csr_ill,
    input        [`IM_ADDR_LEN-1:0] insn_misaligned_epc,
    input                           insn_misaligned,
    input                           insn_pg_fault,
    input                           insn_xes_fault,
    input                           load_misaligned,
    input                           load_pg_fault,
    input                           load_xes_fault,
    input                           store_misaligned,
    input                           store_pg_fault,
    input                           store_xes_fault,
    output logic                    trap_en,
    output logic [       `XLEN-1:0] trap_cause,
    output logic [`IM_ADDR_LEN-1:0] trap_epc,
    output logic [       `XLEN-1:0] trap_val
);

logic trap_insn_misaligned;
logic trap_insn_access_fault;
logic trap_ill_insn;
logic trap_insn_addr_break_point;
logic trap_ldst_addr_break_point;
logic trap_env_break_point;
logic trap_load_misaligned;
logic trap_load_access_fault;
logic trap_store_misaligned;
logic trap_store_access_fault;
logic trap_u_ecall;
logic trap_s_ecall;
logic trap_h_ecall;
logic trap_m_ecall;
logic trap_insn_pg_fault;
logic trap_load_pg_fault;
logic trap_store_pg_fault;

logic if_trap_en;
logic exe_trap_en;
logic wb_trap_en;

assign trap_insn_misaligned       = insn_misaligned;
assign trap_insn_access_fault     = insn_xes_fault;
assign trap_ill_insn              = ill_insn || csr_ill || prv_cur < prv_req ||
                                    ((touch_satp || tlb_flush_req) && tvm && prv_cur < `PRV_M) ||
                                    (sret && tsr && prv_cur < `PRV_M);
assign trap_insn_addr_break_point = 1'b0;
assign trap_ldst_addr_break_point = 1'b0;
assign trap_env_break_point       = ebreak;
assign trap_load_misaligned       = load_misaligned;
assign trap_load_access_fault     = load_xes_fault;
assign trap_store_misaligned      = store_misaligned;
assign trap_store_access_fault    = store_xes_fault;
assign trap_u_ecall               = ecall && prv_cur == `PRV_U;
assign trap_s_ecall               = ecall && prv_cur == `PRV_S;
assign trap_h_ecall               = ecall && prv_cur == `PRV_H;
assign trap_m_ecall               = ecall && prv_cur == `PRV_M;
assign trap_insn_pg_fault         = insn_pg_fault;
assign trap_load_pg_fault         = load_pg_fault;
assign trap_store_pg_fault        = store_pg_fault;

assign trap_en = (insn_valid && ~exe_hazard && (if_trap_en | exe_trap_en)) || wb_trap_en;

assign if_trap_en  = trap_insn_misaligned | trap_insn_access_fault |
                     trap_insn_pg_fault | trap_insn_addr_break_point;

assign exe_trap_en = trap_ill_insn |
                     trap_env_break_point |
                     trap_u_ecall | trap_s_ecall |
                     trap_h_ecall | trap_m_ecall;

assign wb_trap_en = trap_load_misaligned   | trap_store_misaligned |
                    trap_load_access_fault | trap_store_access_fault |
                    trap_load_pg_fault     | trap_store_pg_fault |
                    trap_ldst_addr_break_point;

assign trap_cause = wb_trap_en ?
                    (({`XLEN{trap_store_misaligned      }} & `XLEN'd6) |
                     ({`XLEN{trap_load_misaligned       }} & `XLEN'd4) |
                     ({`XLEN{trap_store_pg_fault        }} & `XLEN'd15) |
                     ({`XLEN{trap_load_pg_fault         }} & `XLEN'd13) |
                     ({`XLEN{trap_store_access_fault    }} & `XLEN'd7) |
                     ({`XLEN{trap_load_access_fault     }} & `XLEN'd5) |
                     ({`XLEN{trap_ldst_addr_break_point }} & `XLEN'd3)):
                    if_trap_en ?
                    (({`XLEN{trap_insn_addr_break_point }} & `XLEN'd3) |
                     ({`XLEN{trap_insn_pg_fault         }} & `XLEN'd12) |
                     ({`XLEN{trap_insn_access_fault     }} & `XLEN'd1) |
                     ({`XLEN{trap_insn_misaligned       }} & `XLEN'd0)):
                    exe_trap_en ?
                    (({`XLEN{trap_ill_insn              }} & `XLEN'd2) |
                     ({`XLEN{trap_u_ecall               }} & `XLEN'd8) |
                     ({`XLEN{trap_s_ecall               }} & `XLEN'd9) |
                     ({`XLEN{trap_m_ecall               }} & `XLEN'd11) |
                     ({`XLEN{trap_env_break_point       }} & `XLEN'd3)):
                                                             `XLEN'd0;

assign trap_val   = wb_trap_en           ? ldst_badaddr:
                    trap_insn_misaligned ? exe_pc:
                    if_trap_en           ? insn_badaddr:
                    trap_ill_insn        ? insn:
                                           `XLEN'd0;

assign trap_epc   = wb_trap_en           ? wb_pc :
                    trap_insn_misaligned ? insn_misaligned_epc:
                                           exe_pc;

endmodule
