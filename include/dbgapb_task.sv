task dbgapb_status_rd;

dbgapb_wr(`DBGAPB_INST, {20'b0, `INST_STATUS_RD});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA);
$display("[DBGAPB] READ STATUS_REG: %8x", dbg_rdata);
endtask

task dbgapb_pc_rd;

dbgapb_wr(`DBGAPB_INST, {20'b0, `INST_PC_RD});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA);
$display("[DBGAPB] READ PC: %8x", dbg_rdata);
endtask

task dbgapb_gpr_rd;
input [4:0] addr;

dbgapb_wr(`DBGAPB_INST, {11'b0, addr, 4'b0, `INST_GPR_RD});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA);
$display("[DBGAPB] READ GPR[0x%0x]: %8x", addr, dbg_rdata);
endtask

task dbgapb_gpr_wr;
input [ 4:0] addr;
input [31:0] wdata;

dbgapb_wr(`DBGAPB_WDATA, wdata);
dbgapb_wr(`DBGAPB_WDATA_WR, 32'b1);
dbgapb_wr(`DBGAPB_INST, {11'b0, addr, 4'b0, `INST_GPR_WR});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA);
$display("[DBGAPB] WRITE GPR[0x%0x]: %8x", addr, wdata);
endtask

task dbgapb_csr_rd;
input [11:0] addr;

dbgapb_wr(`DBGAPB_INST, {4'b0, addr, 4'b0, `INST_CSR_RD});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA);
$display("[DBGAPB] READ CSR[0x%0x]: %8x", addr, dbg_rdata);
endtask

task dbgapb_csr_wr;
input [11:0] addr;
input [31:0] wdata;

dbgapb_wr(`DBGAPB_WDATA, wdata);
dbgapb_wr(`DBGAPB_WDATA_WR, 32'b1);
dbgapb_wr(`DBGAPB_INST, {4'b0, addr, 4'b0, `INST_CSR_WR});
dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
dbgapb_rd(`DBGAPB_RDATA);
$display("[DBGAPB] WRITE CSR[0x%0x]: %8x", addr, wdata);
endtask

task dbgapb_exec;
input [31:0] inst;

dbgapb_wr(`DBGAPB_WDATA, inst);
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

dbg_psel    = 1'b1;
dbg_penable = 1'b0;
dbg_paddr   = addr;
dbg_pwrite  = 1'b0;
@(posedge clk);
@(negedge clk);
dbg_penable = 1'b1;
do @(posedge (clk)); while (dbg_pready !== 1'b1);
@(negedge clk);
dbg_rdata   = dbg_prdata;
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
