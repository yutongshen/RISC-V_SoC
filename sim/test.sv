`timescale 1ns / 10ps

`include "clkdef.h"
`define MAX_CYCLE 20000000
//`define DDR_SIZE 2**17
`define DDR_SIZE 2**27
`define TEST_END_ADDR 32'h1fffc
`define DDR_DATA(addr) \
{u_ddr.mem_byte3[addr], u_ddr.mem_byte2[addr], u_ddr.mem_byte1[addr], u_ddr.mem_byte0[addr]}
`define SRAM_DATA(addr) u_cpu_wrap.u_sram.memory[addr]

`include "cpu_define.h"
`include "dbgapb_mmap.h"
`include "dbgapb_define.h"
`include "intf_define.h"

//`define DBG_TEST

module test;

integer       i;

logic         clk;
logic         clk_32k;
logic         rstn;

`AXI_INTF_DEF(axi_ext, 8)
`AXI_INTF_DEF(axi_ddr, 6)

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

logic              uart_tx;
logic              uart_rx;

wire               spi_sclk;
wire               spi_nss;
wire               spi_mosi;
wire               spi_miso;

logic              jtag_tck;
logic              jtag_tms;
logic              jtag_tdi;
logic              jtag_tdo;

logic              simend;

string             prog_path;

logic [     31: 0] dbg_sig;

assign dbg_sig = `DDR_DATA(32'h8affe8 >> 2);

// clock and reset
initial begin
    simend   <= 1'b0;
    rstn     <= 1'b0;
    repeat (10) @(posedge clk);
    rstn   <= 1'b1;
    repeat (`MAX_CYCLE) @(posedge clk);
    simend <= 1'b1;
end

initial begin
    dbgapb_init;
    repeat (10000) dbgapb_rd(32'h4, 1'b0);
end
initial begin
    axi_init;
    repeat (20) @(posedge clk);
    // extaxi_wr(32'h0400_0004, 32'h48);
    extaxi_wr(32'h0400_0000, 32'h1);
    // repeat (10000) extaxi_rd(32'h0400_0000);
end

initial begin
    clk_32k = 1'b0;
    // forever clk_32k = #(31250 / 2) ~clk_32k;
    forever clk_32k = #(1000 / 2) ~clk_32k;
end

initial begin
    clk = 1'b0;
    forever clk = #(`CLK_PRIOD / 2) ~clk;
end

// Simulation end check
always @(posedge clk) begin
    if (u_cpu_wrap.u_sram.memory[`TEST_END_ADDR >> 2] === 32'b1) begin
        $display("TEST_END flag detected");
        $display("Simulation end!");
        $display("END CODE: %x", u_cpu_wrap.u_sram.memory[(`TEST_END_ADDR >> 2) - 1]);
        simend <= 1'b1;
    end
end

always @(posedge simend) begin
    integer f, i;
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
    // dump sysram
    f = $fopen("./sysram.bin", "wb");
    for (i = 0; i < 1024/4; i = i + 1) begin
        $fwrite(f, "%u", `SRAM_DATA(i));
    end
    $fclose(f);
    $finish;
end

// initial begin
//     #(`CLK_PRIOD * 57995);
//     force u_cpu_wrap.u_cpu_top.u_sru.mie_meie = 1'b1;
//     force u_cpu_wrap.u_cpu_top.u_sru.mip_meip = 1'b1;
//     #(`CLK_PRIOD * 10);
//     release u_cpu_wrap.u_cpu_top.u_sru.mie_meie;
//     release u_cpu_wrap.u_cpu_top.u_sru.mip_meip;
// end

// brom initial
`ifndef BROM
`define ROM_SIZE 2048
`define ROM_BYTE0 u_cpu_wrap.u_brom.byte_0
`define ROM_BYTE1 u_cpu_wrap.u_brom.byte_1
`define ROM_BYTE2 u_cpu_wrap.u_brom.byte_2
`define ROM_BYTE3 u_cpu_wrap.u_brom.byte_3

initial begin
    integer i;
    // Fill ROM
    for (i = 0; i < `ROM_SIZE; i = i + 1) begin
        {`ROM_BYTE3[i], `ROM_BYTE2[i], `ROM_BYTE1[i], `ROM_BYTE0[i]} = 32'hdeaddead;
    end
    $readmemh({"rom_0.hex"}, `ROM_BYTE0);
    $readmemh({"rom_1.hex"}, `ROM_BYTE1);
    $readmemh({"rom_2.hex"}, `ROM_BYTE2);
    $readmemh({"rom_3.hex"}, `ROM_BYTE3);
end
`endif

// sram initial
`define SRAM_SIZE 2**15
logic [7:0] sram_byte0 [`SRAM_SIZE];
logic [7:0] sram_byte1 [`SRAM_SIZE];
logic [7:0] sram_byte2 [`SRAM_SIZE];
logic [7:0] sram_byte3 [`SRAM_SIZE];

initial begin
    integer i, flash_bin;
    logic [31:0] tmp;
    $value$plusargs("prog_path=%s", prog_path);
    // Fill SRAM
    for (i = 0; i < `SRAM_SIZE; i = i + 1) begin
        {sram_byte3[i], sram_byte2[i], sram_byte1[i], sram_byte0[i]} = 32'hdeaddead;
    end
    {sram_byte3[0], sram_byte2[0], sram_byte1[0], sram_byte0[0]} = 32'h00100293; // li t0, 1
    {sram_byte3[1], sram_byte2[1], sram_byte1[1], sram_byte0[1]} = 32'h928202fe; // slli  t0,t0,0x1f; jalr t0
    // {sram_byte3[0], sram_byte2[0], sram_byte1[0], sram_byte0[0]} = 32'h800002b7; // lui t0, 0x80000
    // {sram_byte3[1], sram_byte2[1], sram_byte1[1], sram_byte0[1]} = 32'h00009282; // jalr t0
    $readmemh({prog_path, "/sram_0.hex"}, sram_byte0);
    $readmemh({prog_path, "/sram_1.hex"}, sram_byte1);
    $readmemh({prog_path, "/sram_2.hex"}, sram_byte2);
    $readmemh({prog_path, "/sram_3.hex"}, sram_byte3);
    for (i = 0; i < `SRAM_SIZE; i = i + 1) begin
        `SRAM_DATA(i) = {sram_byte3[i], sram_byte2[i], sram_byte1[i], sram_byte0[i]};
    end

    // Fill DRAM
    for (i = 0; i < 2**25; i = i + 1) begin
        `DDR_DATA(i) = 32'h00000000;
    end
    $readmemh({prog_path, "/ddr_0.hex"}, u_ddr.mem_byte0);
    $readmemh({prog_path, "/ddr_1.hex"}, u_ddr.mem_byte1);
    $readmemh({prog_path, "/ddr_2.hex"}, u_ddr.mem_byte2);
    $readmemh({prog_path, "/ddr_3.hex"}, u_ddr.mem_byte3);
    $display("DDR[%08x] = %08x", 0, `DDR_DATA(0));
    $display("DDR[%08x] = %08x", 1, `DDR_DATA(1));
    $display("DDR[%08x] = %08x", 2, `DDR_DATA(2));
    $display("DDR[%08x] = %08x", 3, `DDR_DATA(3));

    // Fill DRAM
    flash_bin = $fopen({prog_path, "/riscv_disk"}, "rb");
    if (flash_bin) begin
        i = 2**26;
        while (!$feof(flash_bin)) begin
            $fread(tmp, flash_bin);
            `DDR_DATA(i) = {tmp[7:0], tmp[15:8], tmp[23:16], tmp[31:24]};
            i = i + 1;
        end
        $fclose(flash_bin);
    end
    i = 2**26 + 'h100;
    $display("DDR[%08x] = %08x", i+0, `DDR_DATA(i+0));
    $display("DDR[%08x] = %08x", i+1, `DDR_DATA(i+1));
    $display("DDR[%08x] = %08x", i+2, `DDR_DATA(i+2));
    $display("DDR[%08x] = %08x", i+3, `DDR_DATA(i+3));
end

`ifdef FSDB
`ifndef NOFSDB
initial begin
    integer i;
    // 0x7fff_ffff = 2147483647
    // for (i = 0; i < 8; i = i + 1)
    //     #2000000000;
    // #1000000000;
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, test, "+struct", "+mda");
end
`endif
`endif

cpu_wrap u_cpu_wrap (
    .clk         ( clk           ),
    .clk_32k     ( clk_32k       ),
    .rstn        ( rstn          ),

    // external AXI interface
    `AXI_INTF_CONNECT(ext_s, axi_ext),
    `AXI_INTF_CONNECT(ddr_m, axi_ddr),

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
    .uart_rx     ( uart_rx       ),

    // SPI interface
    .sclk        ( spi_sclk      ),
    .nss         ( spi_nss       ),
    .mosi        ( spi_mosi      ),
    .miso        ( spi_miso      ),

    // JTAG interface
    .tck         ( jtag_tck      ),
    .tms         ( jtag_tms      ),
    .tdi         ( jtag_tdi      ),
    .tdo         ( jtag_tdo      )
);

axi_vip_slave #(
    .ID                ( 0         ),
    .MEM_SIZE          ( `DDR_SIZE ),
    .AXI_AXID_WIDTH    ( 6         ),
    .AXI_AXADDR_WIDTH  ( 32        ),
    .AXI_AXLEN_WIDTH   ( 8         ),
    .AXI_AXSIZE_WIDTH  ( 3         ),
    .AXI_AXBURST_WIDTH ( 2         ),
    .AXI_DATA_WIDTH    ( 32        ),
    .AXI_RESP_WIDTH    ( 2         )
) u_ddr (
    .aclk    ( clk  ),
    .aresetn ( rstn ),
    `AXI_INTF_CONNECT(s, axi_ddr)
);

uart_mdl u_uart_mdl(
    .uart_tx ( uart_rx ),
    .uart_rx ( uart_tx )
);

spi_mdl u_spi_mdl (
    .rstn     ( rstn     ),

    .SCLK     ( spi_sclk ),
    .NSS      ( spi_nss  ),
    .MOSI     ( spi_mosi ),
    .MISO     ( spi_miso ),

    // Control signal
    .CPHA     ( u_cpu_wrap.u_peri.u_spi_core.u_spi.spi_cr1_cpha     ),
    .CPOL     ( u_cpu_wrap.u_peri.u_spi_core.u_spi.spi_cr1_cpol     ),
    .LSBFIRST ( u_cpu_wrap.u_peri.u_spi_core.u_spi.spi_cr1_lsbfirst ),
    .DFF      ( u_cpu_wrap.u_peri.u_spi_core.u_spi.spi_cr1_dff      )
);

jtag_mdl u_jtag_mdl (
    .tck ( jtag_tck ),
    .tms ( jtag_tms ),
    .tdi ( jtag_tdi ),
    .tdo ( jtag_tdo )
);

// For riscv-tests used
logic [31:0] arg;
logic [31:0] cmd;
logic [ 1:0] _flag;

int          tohost;
string       isa;
string       prog;

initial begin
    isa = "";
    $value$plusargs("isa=%s", isa);
    if (isa != "") $display("isa: %s", isa);
    if (isa == "rv32uc-p-rvc" || isa == "rv64uc-p-rvc") begin
        tohost = 'hc00;
    end
    else begin
        tohost = 'h400;
    end
end

always @(posedge clk) begin
    $value$plusargs("prog=%s", prog);
    if (prog == "prog3") begin
        if (~rstn) begin
            `DDR_DATA(tohost)   = 32'b0;
            `DDR_DATA(tohost+1) = 32'b0;
        end
        else if ({`DDR_DATA(tohost+1), `DDR_DATA(tohost)} !== 64'b0) begin
            repeat (20) @(posedge clk); 
            case (`DDR_DATA(tohost+1))
                32'h00000000: begin
                    $display("ENDCODE = %x", `DDR_DATA(tohost));
                    simend = 1'b1;
                end
                32'h01010000: $write("%c", `DDR_DATA(tohost));
            endcase
            `DDR_DATA(tohost)   = 32'b0;
            `DDR_DATA(tohost+1) = 32'b0;
        end
    end
end

`include "tmdl.sv"

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
return `DDR_DATA(addr[26:2]);
endfunction

endmodule
