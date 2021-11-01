`include "cpu_define.h"

module tpu (
    input                           inst_valid,
    input        [`IM_DATA_LEN-1:0] inst,
    input        [             1:0] prv_cur,
    input        [             1:0] prv_req,
    input                           satp_upd,
    input                           tvm,
    input                           ecall,
    input                           ebreak,
    input                           ill_inst,
    output logic                    trap_en,
    output logic [       `XLEN-1:0] trap_cause,
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

assign trap_inst_misaligned       = 1'b0;
assign trap_inst_access_fault     = 1'b0;
assign trap_ill_inst              = ill_inst || prv_cur < prv_req || (satp_upd && tvm && prv_cur < `PRV_M);
assign trap_inst_addr_break_point = 1'b0;
assign trap_ldst_addr_break_point = 1'b0;
assign trap_env_break_point       = ebreak;
assign trap_load_misaligned       = 1'b0;
assign trap_load_access_fault     = 1'b0;
assign trap_store_misaligned      = 1'b0;
assign trap_store_access_fault    = 1'b0;
assign trap_u_ecall               = ecall && prv_cur == `PRV_U;
assign trap_s_ecall               = ecall && prv_cur == `PRV_S;
assign trap_h_ecall               = ecall && prv_cur == `PRV_H;
assign trap_m_ecall               = ecall && prv_cur == `PRV_M;
assign trap_inst_pg_fault         = 1'b0;
assign trap_load_pg_fault         = 1'b0;
assign trap_store_pg_fault        = 1'b0;

assign trap_en = inst_valid & (trap_inst_misaligned |
                               trap_inst_access_fault |
                               trap_ill_inst |
                               trap_inst_addr_break_point |
                               trap_ldst_addr_break_point |
                               trap_env_break_point |
                               trap_load_misaligned |
                               trap_load_access_fault |
                               trap_store_misaligned |
                               trap_store_access_fault |
                               trap_u_ecall |
                               trap_s_ecall |
                               trap_h_ecall |
                               trap_m_ecall |
                               trap_inst_pg_fault |
                               trap_load_pg_fault |
                               trap_store_pg_fault);

assign trap_cause = trap_inst_addr_break_point ? `XLEN'd3:
                    trap_inst_pg_fault         ? `XLEN'd12:
                    trap_inst_access_fault     ? `XLEN'd1:
                    trap_ill_inst              ? `XLEN'd2:
                    trap_inst_misaligned       ? `XLEN'd0:
                    trap_u_ecall               ? `XLEN'd8:
                    trap_s_ecall               ? `XLEN'd9:
                    trap_m_ecall               ? `XLEN'd11:
                    trap_env_break_point       ? `XLEN'd3:
                    trap_ldst_addr_break_point ? `XLEN'd3:
                    trap_store_misaligned      ? `XLEN'd6:
                    trap_load_misaligned       ? `XLEN'd4:
                    trap_store_pg_fault        ? `XLEN'd15:
                    trap_load_pg_fault         ? `XLEN'd13:
                    trap_store_access_fault    ? `XLEN'd7:
                    trap_load_access_fault     ? `XLEN'd5:
                                                 `XLEN'd0;

assign trap_val = trap_ill_inst ? inst : `XLEN'b0;

endmodule
