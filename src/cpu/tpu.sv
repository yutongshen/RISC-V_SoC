`include "cpu_define.h"

module tpu (
    input                           inst_valid,
    input        [`IM_DATA_LEN-1:0] inst,
    input        [`IM_ADDR_LEN-1:0] exe_pc,
    input        [`IM_ADDR_LEN-1:0] mem_pc,
    input        [`DM_ADDR_LEN-1:0] bad_dxes_val,
    input        [             1:0] prv_cur,
    input        [             1:0] prv_req,
    input                           satp_upd,
    input                           tvm,
    input                           ecall,
    input                           ebreak,
    input                           ill_inst,
    input                           inst_pg_fault,
    input                           inst_xes_fault,
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

logic trap_inst_misaligned;
logic trap_inst_access_fault;
logic trap_ill_inst;
logic trap_inst_addr_break_point;
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
logic trap_inst_pg_fault;
logic trap_load_pg_fault;
logic trap_store_pg_fault;

logic exe_trap_en;
logic mem_trap_en;

assign trap_inst_misaligned       = 1'b0;
assign trap_inst_access_fault     = inst_xes_fault;
assign trap_ill_inst              = ill_inst || prv_cur < prv_req || (satp_upd && tvm && prv_cur < `PRV_M);
assign trap_inst_addr_break_point = 1'b0;
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
assign trap_inst_pg_fault         = inst_pg_fault;
assign trap_load_pg_fault         = load_pg_fault;
assign trap_store_pg_fault        = store_pg_fault;

assign trap_en = (inst_valid && exe_trap_en) || mem_trap_en;

assign exe_trap_en = trap_inst_misaligned |
                     trap_inst_access_fault |
                     trap_ill_inst |
                     trap_inst_addr_break_point |
                     trap_ldst_addr_break_point |
                     trap_env_break_point |
                     trap_u_ecall | trap_s_ecall |
                     trap_h_ecall | trap_m_ecall |
                     trap_inst_pg_fault;

assign mem_trap_en = trap_load_misaligned   | trap_store_misaligned |
                     trap_load_access_fault | trap_store_access_fault |
                     trap_load_pg_fault     | trap_store_pg_fault;

assign trap_cause = mem_trap_en ?
                    (({`XLEN{trap_store_misaligned  }} & `XLEN'd6) |
                     ({`XLEN{trap_load_misaligned   }} & `XLEN'd4) |
                     ({`XLEN{trap_store_pg_fault    }} & `XLEN'd15) |
                     ({`XLEN{trap_load_pg_fault     }} & `XLEN'd13) |
                     ({`XLEN{trap_store_access_fault}} & `XLEN'd7) |
                     ({`XLEN{trap_load_access_fault }} & `XLEN'd5)):
                    trap_inst_addr_break_point ? `XLEN'd3:
                    trap_inst_pg_fault         ? `XLEN'd12:
                    trap_inst_access_fault     ? `XLEN'd1:
                    trap_ill_inst              ? `XLEN'd2:
                    trap_inst_misaligned       ? `XLEN'd0:
                    trap_u_ecall               ? `XLEN'd8:
                    trap_s_ecall               ? `XLEN'd9:
                    trap_m_ecall               ? `XLEN'd11:
                    trap_env_break_point       ? `XLEN'd3:
                    trap_ldst_addr_break_point ? `XLEN'd3:
                                                 `XLEN'd0;

assign trap_val   = mem_trap_en ?
                    (({`XLEN{trap_store_misaligned  }} & bad_dxes_val) |
                     ({`XLEN{trap_load_misaligned   }} & bad_dxes_val) |
                     ({`XLEN{trap_store_pg_fault    }} & bad_dxes_val) |
                     ({`XLEN{trap_load_pg_fault     }} & bad_dxes_val) |
                     ({`XLEN{trap_store_access_fault}} & bad_dxes_val) |
                     ({`XLEN{trap_load_access_fault }} & bad_dxes_val)):
                    trap_inst_addr_break_point ? `XLEN'd0:
                    trap_inst_pg_fault         ? exe_pc:
                    trap_inst_access_fault     ? exe_pc:
                    trap_ill_inst              ? inst:
                    trap_inst_misaligned       ? `XLEN'd0:
                    trap_u_ecall               ? `XLEN'd0:
                    trap_s_ecall               ? `XLEN'd0:
                    trap_m_ecall               ? `XLEN'd0:
                    trap_env_break_point       ? `XLEN'd0:
                    trap_ldst_addr_break_point ? `XLEN'd0:
                                                 `XLEN'd0;

assign trap_epc   = mem_trap_en ? mem_pc : exe_pc;

endmodule
