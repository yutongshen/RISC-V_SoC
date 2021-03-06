`include "cpu_define.h"

module csr (
    input                       clk,
    input                       rstn,
    input        [        1: 0] misa_mxl,
    input                       rd,
    input                       wr,
    input        [       11: 0] raddr,
    output logic [`XLEN - 1: 0] rdata,
    output logic                pmu_csr_wr,
    output logic                fpu_csr_wr,
    output logic                dbg_csr_wr,
    output logic                mmu_csr_wr,
    output logic                mpu_csr_wr,
    output logic                sru_csr_wr,
    input        [`XLEN - 1: 0] pmu_csr_rdata,
    input        [`XLEN - 1: 0] fpu_csr_rdata,
    input        [`XLEN - 1: 0] dbg_csr_rdata,
    input        [`XLEN - 1: 0] mmu_csr_rdata,
    input        [`XLEN - 1: 0] mpu_csr_rdata,
    input        [`XLEN - 1: 0] sru_csr_rdata

);

logic [`XLEN - 1: 0] rdata_pre;

logic                pmu_csr_sel;
logic                dbg_csr_sel;
logic                mmu_csr_sel;
logic                mpu_csr_sel;
logic                sru_csr_sel;
logic                fpu_csr_sel;

assign pmu_csr_sel = raddr[11] || {raddr[11:10], raddr[7:5]} == 5'b00_001 || raddr == 12'h106 || raddr == 12'h306;
assign dbg_csr_sel = raddr[11:10] == 2'b01;
assign mmu_csr_sel = raddr == 12'h180;
assign mpu_csr_sel = {raddr[11:10], raddr[7]} == 3'b00_1 && ~mmu_csr_sel;
assign sru_csr_sel = (({raddr[11:10], raddr[7:6]} == 4'b00_00 && ~fpu_csr_sel) ||
                       {raddr[11:10], raddr[7:6]} == 4'b00_01) && (raddr != 12'h106 || raddr != 12'h306);
assign fpu_csr_sel = raddr[11:2] == 10'b0000_0000_00 && raddr[1:0] != 2'b00;

assign pmu_csr_wr = pmu_csr_sel & wr;
assign fpu_csr_wr = fpu_csr_sel & wr;
assign dbg_csr_wr = dbg_csr_sel & wr;
assign mmu_csr_wr = mmu_csr_sel & wr;
assign mpu_csr_wr = mpu_csr_sel & wr;
assign sru_csr_wr = sru_csr_sel & wr;

assign rdata_pre = ({`XLEN{pmu_csr_sel}} & pmu_csr_rdata) |
                   ({`XLEN{dbg_csr_sel}} & dbg_csr_rdata) |
                   ({`XLEN{mmu_csr_sel}} & mmu_csr_rdata) |
                   ({`XLEN{mpu_csr_sel}} & mpu_csr_rdata) |
                   ({`XLEN{sru_csr_sel}} & sru_csr_rdata) |
                   ({`XLEN{fpu_csr_sel}} & fpu_csr_rdata);

`ifdef RV32
assign rdata = rdata_pre;
`else
assign rdata = misa_mxl == 2'h1 ? {{32{rdata_pre[31]}}, rdata_pre[31:0]}:
                                  rdata_pre;
`endif

endmodule
