`define APB_LOW  1'b0
`define APB_HIGH 1'b1

task dbgapb_status_rd;

dbgapb_wr(`DBGAPB_INST, {20'b0, `INST_STATUS_RD});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA_L, `APB_LOW);
`ifdef RV32
$display("[DBGAPB] READ STATUS_REG: %8x", dbg_rdata);
`else
dbgapb_rd(`DBGAPB_RDATA_H, `APB_HIGH);
$display("[DBGAPB] READ STATUS_REG: %16x", dbg_rdata);
`endif
endtask

task dbgapb_pc_rd;

dbgapb_wr(`DBGAPB_INST, {20'b0, `INST_PC_RD});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA_L, `APB_LOW);
`ifdef RV32
$display("[DBGAPB] READ PC: %8x", dbg_rdata);
`else
dbgapb_rd(`DBGAPB_RDATA_H, `APB_HIGH);
$display("[DBGAPB] READ PC: %16x", dbg_rdata);
`endif
endtask

task dbgapb_gpr_rd;
input [4:0] addr;

dbgapb_wr(`DBGAPB_INST, {11'b0, addr, 4'b0, `INST_GPR_RD});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA_L, `APB_LOW);
`ifdef RV32
$display("[DBGAPB] READ GPR[0x%0x]: %8x", addr, dbg_rdata);
`else
dbgapb_rd(`DBGAPB_RDATA_H, `APB_HIGH);
$display("[DBGAPB] READ GPR[0x%0x]: %16x", addr, dbg_rdata);
`endif
endtask

task dbgapb_gpr_wr;
input [      4:0] addr;
input [`XLEN-1:0] wdata;

`ifdef RV32
dbgapb_wr(`DBGAPB_WDATA_L, wdata);
`else
dbgapb_wr(`DBGAPB_WDATA_L, wdata[ 0+:32]);
dbgapb_wr(`DBGAPB_WDATA_H, wdata[32+:32]);
`endif
dbgapb_wr(`DBGAPB_WDATA_WR, 32'b1);
dbgapb_wr(`DBGAPB_INST, {11'b0, addr, 4'b0, `INST_GPR_WR});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
//dbgapb_rd(`DBGAPB_RDATA_L);
`ifdef RV32
$display("[DBGAPB] WRITE GPR[0x%0x]: %8x", addr, wdata);
`else
$display("[DBGAPB] WRITE GPR[0x%0x]: %16x", addr, wdata);
`endif
endtask

task dbgapb_csr_rd;
input [11:0] addr;

dbgapb_wr(`DBGAPB_INST, {4'b0, addr, 4'b0, `INST_CSR_RD});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA_L, `APB_LOW);
`ifdef RV32
$display("[DBGAPB] READ CSR[0x%0x]: %8x", addr, dbg_rdata);
`else
dbgapb_rd(`DBGAPB_RDATA_H, `APB_HIGH);
$display("[DBGAPB] READ CSR[0x%0x]: %16x", addr, dbg_rdata);
`endif
endtask

task dbgapb_csr_wr;
input [     11:0] addr;
input [`XLEN-1:0] wdata;

`ifdef RV32
dbgapb_wr(`DBGAPB_WDATA_L, wdata);
`else
dbgapb_wr(`DBGAPB_WDATA_L, wdata[ 0+:32]);
dbgapb_wr(`DBGAPB_WDATA_H, wdata[32+:32]);
`endif
dbgapb_wr(`DBGAPB_WDATA_WR, 32'b1);
dbgapb_wr(`DBGAPB_INST, {4'b0, addr, 4'b0, `INST_CSR_WR});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
//dbgapb_rd(`DBGAPB_RDATA_L);
`ifdef RV32
$display("[DBGAPB] WRITE CSR[0x%0x]: %8x", addr, wdata);
`else
$display("[DBGAPB] WRITE CSR[0x%0x]: %16x", addr, wdata);
`endif
endtask

task dbgapb_exec;
input [31:0] inst;

dbgapb_wr(`DBGAPB_WDATA_L, inst);
dbgapb_wr(`DBGAPB_WDATA_WR, 32'b1);
dbgapb_wr(`DBGAPB_INST, {20'b0, `INST_INSTREG_WR});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_wr(`DBGAPB_INST, {20'b0, `INST_EXECUTE});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
endtask

task dbgapb_wr;
input [31:0] addr;
input [31:0] wdata;

dbg_psel    = 1'b1;
dbg_penable = 1'b0;
dbg_paddr   = addr;
dbg_pwrite  = 1'b1;
dbg_pstrb   = 4'hf;
dbg_pwdata  = wdata;
@(posedge clk);
@(negedge clk);
dbg_penable = 1'b1;
do @(posedge (clk)); while (dbg_pready !== 1'b1);
@(negedge clk);
dbg_psel    = 1'b0;
dbg_penable = 1'b0;
dbg_pwrite  = 1'b0;
endtask

task dbgapb_rd;
input [31:0] addr;
input        high;

dbg_psel    = 1'b1;
dbg_penable = 1'b0;
dbg_paddr   = addr;
dbg_pwrite  = 1'b0;
@(posedge clk);
@(negedge clk);
dbg_penable = 1'b1;
do @(posedge (clk)); while (dbg_pready !== 1'b1);
@(negedge clk);
`ifdef RV32
dbg_rdata   = dbg_prdata;
`else
if (~high) dbg_rdata[ 0+:32] = dbg_prdata;
else       dbg_rdata[32+:32] = dbg_prdata;
`endif
dbg_psel    = 1'b0;
dbg_penable = 1'b0;
endtask

task dbgapb_init;
dbg_psel    = 1'b0;
dbg_penable = 1'b0;
dbg_paddr   = 32'b0;
dbg_pwrite  = 1'b0;
dbg_pstrb   = 4'b0;
dbg_pprot   = 3'b0;
dbg_pwdata  = 32'b0;
endtask
