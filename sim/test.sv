`timescale 1ns / 10ps

`define CLK_PRIOD 20
`define TEST_END_ADDR 32'hffc

`include "cpu_define.h"
`include "dbgapb_mmap.h"
`include "dbgapb_define.h"
`include "intf_define.h"

//`define DBG_TEST

module test;

integer       i;

logic         clk;
logic         rstn;

`AXI_INTF_DEF(axi_ext, 10)

logic              dbg_psel;
logic              dbg_penable;
logic [     31: 0] dbg_paddr;
logic              dbg_pwrite;
logic [      3: 0] dbg_pstrb;
logic [      2: 0] dbg_pprot;
logic [     31: 0] dbg_pwdata;
logic [     31: 0] dbg_prdata;
logic              dbg_pslverr;
logic              dbg_pready;
logic [`XLEN-1: 0] dbg_rdata;

logic         uart_tx;
logic         uart_rx;



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
    // extaxi_wr(32'h0400_0004, 32'h48);
    extaxi_wr(32'h0400_0000, 32'h1);
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
    $display("CPI:      %f",  u_cpu_wrap.u_cpu_top.u_pmu.mcycle * 1.0 / u_cpu_wrap.u_cpu_top.u_pmu.minstret);
`ifdef RV32
    $display("\nSATP_MODE: %0s", u_cpu_wrap.u_cpu_top.u_mmu_csr.satp_mode == 1'b1 ? "SV32" : "NONE");
`else
    $display("\nSATP_MODE: %0s", u_cpu_wrap.u_cpu_top.u_mmu_csr.satp_mode == 4'h0 ? "NONE" :
                                 u_cpu_wrap.u_cpu_top.u_mmu_csr.satp_mode == 4'h1 ? "SV32" :
                                 u_cpu_wrap.u_cpu_top.u_mmu_csr.satp_mode == 4'h8 ? "SV39" :
                                 u_cpu_wrap.u_cpu_top.u_mmu_csr.satp_mode == 4'h8 ? "SV48" :
                                 u_cpu_wrap.u_cpu_top.u_mmu_csr.satp_mode == 4'h8 ? "SV57" :
                                 u_cpu_wrap.u_cpu_top.u_mmu_csr.satp_mode == 4'h8 ? "SV64" :
                                                                                    "Reserved");
`endif
    show_pt({u_cpu_wrap.u_cpu_top.u_mmu_csr.satp_ppn, 12'b0}, {u_cpu_wrap.u_cpu_top.u_mmu_csr.satp_mode});
    $finish;
end

initial begin
    // wait (u_cpu_wrap.u_intc.u_plic.int_en[0] != 32'b0);
    // #(`CLK_PRIOD * 5);
    // force u_cpu_wrap.u_intc.ints  = -32'b1;
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
    // #(`CLK_PRIOD * 5)
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
    // $readmemh({prog_path, "/sram_1_0.hex"}, prog_byte0);
    // $readmemh({prog_path, "/sram_1_1.hex"}, prog_byte1);
    // $readmemh({prog_path, "/sram_1_2.hex"}, prog_byte2);
    // $readmemh({prog_path, "/sram_1_3.hex"}, prog_byte3);
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
    .dbg_pready  ( dbg_pready    ),

    // UART interface
    .uart_tx     ( uart_tx       ),
    .uart_rx     ( uart_rx       )
);

uart_mdl u_uart_mdl(
    .uart_tx ( uart_rx ),
    .uart_rx ( uart_tx )
);

// For riscv-tests used
logic [31:0] arg;
logic [31:0] cmd;
logic [ 1:0] _flag;

logic [13:0] tohost;
string       isa;

initial begin
    isa = "";
    $value$plusargs("isa=%s", isa);
    if (isa != "") $display("isa: %s", isa);
    if (isa == "rv32uc-p-rvc" || isa == "rv64uc-p-rvc") begin
        tohost = 14'hc00;
    end
    else begin
        tohost = 14'h400;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        arg <= 32'b0;
        cmd <= 32'b0;
    end
    else if (u_cpu_wrap.u_sram_0.CS && u_cpu_wrap.u_sram_0.WE) begin
        if (u_cpu_wrap.u_sram_0.A == tohost) begin
            arg <= u_cpu_wrap.u_sram_0.DI;
        end
        else if (u_cpu_wrap.u_sram_0.A == tohost + 14'h1) begin
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
        else if (u_cpu_wrap.u_sram_0.A == tohost) begin
            _flag <= 2'b1;
        end
    end
    else if (_flag[1]) begin
        case (cmd)
            32'h00000000: begin
                $display("ENDCODE = %x", arg);
                simend = 1'b1;
            end
            32'h01010000: $write("%c", arg);
        endcase
        _flag <= 2'b0;
        u_cpu_wrap.u_sram_0.memory[tohost] = 32'b0;
        u_cpu_wrap.u_sram_0.memory[tohost+14'h1] = 32'b0;
    end
end

`ifdef DBG_TEST
`include "dbgapb_test.sv"
`endif

`include "dbgapb_task.sv"
`include "extaxi_task.sv"

task show_pt;
input [`XLEN-1:0] base;
input [      3:0] mode;

integer i;
logic [`XLEN-1:0] pte;
logic [`XLEN-1:0] fifo [1024];
integer           ptr;

if (mode) begin
    ptr = 0;
    $write("\nPAGE TABLE %08x\n", base);
    $write("%3s %8s %s %s %s %s %s %s %s\n", "ID", "ADDR", "V", "R", "W", "X", "U", "A", "D");
    for (i = 0; i < (mode != 1 ? 512 : 1024); i = i + 1) begin
        pte = {mode != 1 ? read(base + i * 8 + 4) : 32'b0, read(base + i * (mode != 1 ? 8 : 4))};
        if (pte[`PTE_V_BIT]) begin
            $write("%03x %08x %d %d %d %d %d %d %d\n", i,
                   {pte[`XLEN-1:`PTE_PPN_SHIFT], 12'b0},  pte[`PTE_V_BIT],
                   pte[`PTE_R_BIT], pte[`PTE_W_BIT], pte[`PTE_X_BIT],
                   pte[`PTE_U_BIT], pte[`PTE_A_BIT], pte[`PTE_D_BIT]);
            if (~pte[`PTE_X_BIT] & ~pte[`PTE_W_BIT] & ~pte[`PTE_R_BIT]) begin
                fifo[ptr] = {pte[31:`PTE_PPN_SHIFT], 12'b0};
                ptr = ptr + 1;
            end
        end
    end
    for (i = 0; i < ptr; i = i + 1) begin
        show_pt(fifo[i], mode);
    end
end

endtask

function logic [31:0] read;
input [31:0] addr;

if (~addr[16]) return u_cpu_wrap.u_sram_0.memory[addr[15:2]];
else           return u_cpu_wrap.u_sram_1.memory[addr[15:2]];
endfunction

endmodule
