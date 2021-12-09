`timescale 1ns / 10ps

`define CLK_PRIOD 100
`define TEST_END_ADDR 32'hffc

`include "dbgapb_mmap.h"
`include "dbgapb_define.h"
`include "intf_define.h"

// `define DBG_TEST

module test;

integer       i;

logic         clk;
logic         rstn;

`AXI_INTF_DEF(axi_ext, 10)

logic         dbg_psel;
logic         dbg_penable;
logic [31: 0] dbg_paddr;
logic         dbg_pwrite;
logic [ 3: 0] dbg_pstrb;
logic [ 2: 0] dbg_pprot;
logic [31: 0] dbg_pwdata;
logic [31: 0] dbg_prdata;
logic         dbg_pslverr;
logic         dbg_pready;



logic       simend;

logic [7:0] prog_byte0 [32768];
logic [7:0] prog_byte1 [32768];
logic [7:0] prog_byte2 [32768];
logic [7:0] prog_byte3 [32768];

string      prog_path;

// clock and reset
initial begin
    simend <= 1'b0;
    clk    <= 1'b0;
    rstn   <= 1'b0;
	dbgapb_init;
	axi_init;
    repeat (10) @(posedge clk);
    rstn   <= 1'b1;
    repeat (10) @(posedge clk);
	axi_wr(32'h0400_0000, 32'h1);
    repeat (200000) @(posedge clk);
    simend <= 1'b1;
end

// Simulation end check
always @(posedge clk) begin
    if (u_cpu_wrap.u_sram_1.memory[`TEST_END_ADDR >> 2] === 32'b1) begin
        $display("TEST_END flag detected");
        $display("Simulation end!");
        $display("END CODE: %x", u_cpu_wrap.u_sram_1.memory[(`TEST_END_ADDR >> 2) - 1]);
        simend <= 1'b1;
    end
end

always @(posedge simend) begin
    $display("mcycle:   %0d", u_cpu_wrap.u_cpu_top.u_pmu.mcycle);
    $display("minstret: %0d", u_cpu_wrap.u_cpu_top.u_pmu.minstret);
    $finish;
end

initial begin
    // wait (u_cpu_wrap.u_intc.u_plic.int_en[0] != 32'b0);
    #(`CLK_PRIOD * 5);
    force u_cpu_wrap.u_intc.ints  = -32'b1;
    // force u_cpu_wrap.u_plic.int_en[0] = 32'h55555555;
    // force u_cpu_wrap.u_plic.int_prior[0]  = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[1]  = 32'h1;
    // force u_cpu_wrap.u_plic.int_prior[2]  = 32'h2;
    // force u_cpu_wrap.u_plic.int_prior[3]  = 32'h3;
    // force u_cpu_wrap.u_plic.int_prior[4]  = 32'h4;
    // force u_cpu_wrap.u_plic.int_prior[5]  = 32'h5;
    // force u_cpu_wrap.u_plic.int_prior[6]  = 32'h6;
    // force u_cpu_wrap.u_plic.int_prior[7]  = 32'h7;
    // force u_cpu_wrap.u_plic.int_prior[8]  = 32'h8;
    // force u_cpu_wrap.u_plic.int_prior[9]  = 32'h9;
    // force u_cpu_wrap.u_plic.int_prior[10] = 32'h9;
    // force u_cpu_wrap.u_plic.int_prior[11] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[12] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[13] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[14] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[15] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[16] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[17] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[18] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[19] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[20] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[21] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[22] = 32'hA;
    // force u_cpu_wrap.u_plic.int_prior[23] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[24] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[25] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[26] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[27] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[28] = 32'hA;
    // force u_cpu_wrap.u_plic.int_prior[29] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[30] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[31] = 32'h0;
    // wait (u_cpu_wrap.u_cpu_top.id2exe_wfi === 1'b1);
    // #1;
    // #(`CLK_PRIOD * 20)
    // force u_cpu_wrap.u_cpu_top.msip = 1'b1;
    // #(`CLK_PRIOD * 10)
    // release u_cpu_wrap.u_cpu_top.msip;
end

// sram initial
initial begin
    #(`CLK_PRIOD * 5)
    // Random initial
    $value$plusargs("prog=%s", prog_path);
    for (i = 0; i < 16384; i = i + 1) begin
        prog_byte0[i] = 8'h0; // $random();
        prog_byte1[i] = 8'h0; // $random();
        prog_byte2[i] = 8'h0; // $random();
        prog_byte3[i] = 8'h0; // $random();
    end
    $readmemh({prog_path, "/sram_0_0.hex"}, prog_byte0);
    $readmemh({prog_path, "/sram_0_1.hex"}, prog_byte1);
    $readmemh({prog_path, "/sram_0_2.hex"}, prog_byte2);
    $readmemh({prog_path, "/sram_0_3.hex"}, prog_byte3);
    $readmemh({prog_path, "/sram_1_0.hex"}, prog_byte0);
    $readmemh({prog_path, "/sram_1_1.hex"}, prog_byte1);
    $readmemh({prog_path, "/sram_1_2.hex"}, prog_byte2);
    $readmemh({prog_path, "/sram_1_3.hex"}, prog_byte3);
    #(`CLK_PRIOD)
    for (i = 0; i < 16384; i = i + 1) begin
        u_cpu_wrap.u_sram_0.memory[i] <= {prog_byte3[i], prog_byte2[i], prog_byte1[i], prog_byte0[i]};
        u_cpu_wrap.u_sram_1.memory[i] <= {prog_byte3[i+16384], prog_byte2[i+16384], prog_byte1[i+16384], prog_byte0[i+16384]};
    end
end

always #(`CLK_PRIOD / 2) clk <= ~clk;

`ifdef FSDB
initial begin
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, test, "+struct", "+mda");
end
`endif

cpu_wrap u_cpu_wrap (
    .clk         ( clk           ),
    .rstn        ( rstn          ),

    // external AXI interface
    `AXI_INTF_CONNECT(axi_ext, axi_ext),

    // debug APB interface
    .dbg_psel    ( dbg_psel      ),
    .dbg_penable ( dbg_penable   ),
    .dbg_paddr   ( dbg_paddr     ),
    .dbg_pwrite  ( dbg_pwrite    ),
    .dbg_pstrb   ( dbg_pstrb     ),
    .dbg_pprot   ( dbg_pprot     ),
    .dbg_pwdata  ( dbg_pwdata    ),
    .dbg_prdata  ( dbg_prdata    ),
    .dbg_pslverr ( dbg_pslverr   ),
    .dbg_pready  ( dbg_pready    )
);

// For riscv-tests used
logic [31:0] arg;
logic [31:0] cmd;
logic [ 1:0] _flag;

always @(posedge clk) begin
    if (~rstn) begin
        arg <= 32'b0;
        cmd <= 32'b0;
    end
    else if (u_cpu_wrap.u_sram_0.CS && u_cpu_wrap.u_sram_0.WE) begin
        if (u_cpu_wrap.u_sram_0.A == 14'h400) begin
            arg <= u_cpu_wrap.u_sram_0.DI;
        end
        else if (u_cpu_wrap.u_sram_0.A == 14'h401) begin
            cmd <= u_cpu_wrap.u_sram_0.DI;
        end
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        _flag <= 2'b0;
    end
    else if (u_cpu_wrap.u_sram_0.CS && u_cpu_wrap.u_sram_0.WE) begin
        if (_flag) begin
            _flag <= {_flag[0], 1'b0};
        end
        else if (u_cpu_wrap.u_sram_0.A == 14'h400) begin
            _flag <= 2'b1;
        end
    end
    else if (_flag[1]) begin
        case (cmd)
            32'h00000000: begin
                $display("ENDCODE = %x", arg);
                $finish;
            end
            32'h01010000: $write("%c", arg);
        endcase
        _flag <= 2'b0;
        u_cpu_wrap.u_sram_0.memory[14'h400] = 32'b0;
        u_cpu_wrap.u_sram_0.memory[14'h401] = 32'b0;
    end
end

logic [31:0] dbg_rdata;

`ifdef DBG_TEST
`include "dbgapb_test.sv"
`endif

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

task axi_wr;
input [31:0] addr;
input [31:0] wdata;

logic [ 1: 0] awburst;
logic [12: 0] awid;
logic [31: 0] awaddr;
logic [ 2: 0] awsize;
logic [ 7: 0] awlen;
logic         awvalid;
logic [ 3: 0] wstrb;
logic [12: 0] wid;
logic [31: 0] wdata;
logic         wlast;
logic         wvalid;

awburst = 2'h1;
awid    = 10'b0;
awaddr  = addr;
awsize  = 3'h2;
awlen   = 8'h0;

wstrb   = 4'hf;
wid     = 10'b0;
wdata   = wdata;
wlast   = 1'b1;

fork begin
axi_aw_chn_send(awid, awaddr, awlen, awsize, awburst);
end join_none
fork begin
axi_w_chn_send(wid, wdata, wstrb, wlast);
end join_none
wait fork;

axi_ext_bready  = 1'b1;
do @(posedge (clk)); while (axi_ext_bvalid !== 1'b1);
axi_ext_bready  = 1'b0;

endtask

task axi_aw_chn_send;
input [12: 0] awid;
input [31: 0] awaddr;
input [ 7: 0] awlen;
input [ 2: 0] awsize;
input [ 1: 0] awburst;

axi_ext_awburst = awburst;
axi_ext_awid    = awid;
axi_ext_awaddr  = awaddr;
axi_ext_awsize  = awsize;
axi_ext_awlen   = awlen;
axi_ext_awvalid = 1'b1;
do @(posedge (clk)); while (axi_ext_awready !== 1'b1);
axi_ext_awvalid = 1'b0;
endtask

task axi_w_chn_send;
input [12: 0] wid;
input [31: 0] wdata;
input [ 3: 0] wstrb;
input         wlast;

axi_ext_wstrb  = wstrb;
axi_ext_wid    = wid;
axi_ext_wdata  = wdata;
axi_ext_wlast  = wlast;
axi_ext_wvalid = 1'b1;
do @(posedge (clk)); while (axi_ext_wready !== 1'b1);
axi_ext_wvalid = 1'b0;
endtask

task axi_init;
axi_ext_awburst = 2'b0;
axi_ext_awid    = 10'b0;
axi_ext_awaddr  = 32'b0;
axi_ext_awsize  = 3'b0;
axi_ext_awlen   = 8'b0;
axi_ext_awvalid = 1'b0;
axi_ext_wstrb   = 4'b0;
axi_ext_wid     = 10'b0;
axi_ext_wdata   = 32'b0;
axi_ext_wlast   = 1'b0;
axi_ext_wvalid  = 1'b0;
axi_ext_bready  = 1'b0;
axi_ext_araddr  = 10'b0;
axi_ext_arburst = 2'b0;
axi_ext_arsize  = 3'b0;
axi_ext_arid    = 10'b0;
axi_ext_arlen   = 8'b0;
axi_ext_arvalid = 1'b0;
axi_ext_rready  = 1'b0;
endtask

endmodule
