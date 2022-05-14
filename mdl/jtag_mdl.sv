`include "dbgapb_define.h"
`include "dbgapb_mmap.h"

`define TCK_PERIOD    100
`define RESP_WAIT     3'h1
`define RESP_OK_FAULT 3'h2
`define JALR(RS1) {12'b0, RS1, 3'b000, 5'b00000, 7'b1100111}
`define ADDI(RD, RS1, IMM) {IMM, RS1, 3'b000, RD, 7'b0010011}


module jtag_mdl (
    output logic tck,
    output logic tms,
    output logic tdi,
    input        tdo
);

logic [34:0] rdata;
logic [31:0] apb_rdata;
logic [63:0] apb64_rdata;
logic [ 3:0] ir_latch;
logic [ 7:0] apsel_latch;
logic [ 3:0] apaddr_h_latch;
logic [31:0] apbap_tar_latch;
logic [31:0] axi_ap_test_addr;
logic [31:0] axi_ap_test_data;

initial begin
    // // Test reset fault toggle
    // force test.u_cpu_wrap.u_dap.u_apb_ap.u_mem_ap.tx_tog     = 1'b1;
    // force test.u_cpu_wrap.u_dap.u_apb_ap.u_mem_ap.tx_tog_pre = 1'b1;
    // force test.u_cpu_wrap.u_dap.u_apb_ap.u_mem_ap.ap_busy    = $random();
    // force test.u_cpu_wrap.u_dap.u_jtag_dp.dpacc_apsel        = $random();
    // force test.u_cpu_wrap.u_dap.u_jtag_dp.sfter              = $random();
    // #1;
    // release test.u_cpu_wrap.u_dap.u_apb_ap.u_mem_ap.tx_tog;
    // release test.u_cpu_wrap.u_dap.u_apb_ap.u_mem_ap.tx_tog_pre;
    // release test.u_cpu_wrap.u_dap.u_apb_ap.u_mem_ap.ap_busy;
    // release test.u_cpu_wrap.u_dap.u_jtag_dp.dpacc_apsel;
    // release test.u_cpu_wrap.u_dap.u_jtag_dp.sfter;
end

initial begin
    integer i;

    tck = 1'b0;
    tms = 1'b0;
    tdi = 1'b0;
    force test.u_cpu_wrap.u_dap.u_jtag_dp.cur_state = $random() & 4'hf;
    #1;
    release test.u_cpu_wrap.u_dap.u_jtag_dp.cur_state;
    repeat(10) #(`TCK_PERIOD);
    jtag_reset;
    jtag_tms(1'b0); // goto run-test or idle
    jtag_dpacc_wr(4'h4, 32'h54000000); // CTRL/STAT

`ifdef DBGAPB_TEST
    jtag_apb_wr(`DBGAPB_DBG_EN, 32'h1);
    jtag_apb_wr(`DBGAPB_INST, {20'b0, `INST_ATTACH});
    jtag_apb_wr(`DBGAPB_INST_WR, 32'b1);
    while (apb64_rdata != `XLEN'h3) begin
        jtag_dbgapb_status_rd;
    end
    jtag_dbgapb_pc_rd;
    jtag_dbgapb_exec(`ADDI(`GPR_T0_ADDR, `GPR_ZERO_ADDR, 12'hcc));
    jtag_dbgapb_exec(`JALR(`GPR_T0_ADDR));
    jtag_dbgapb_pc_rd;
    repeat(10) jtag_tms_tdi(1'b0, 1'b0);
    jtag_apb_wr(`DBGAPB_INST, {20'b0, `INST_RESUME});
    jtag_apb_wr(`DBGAPB_INST_WR, 32'b1);
`else
/*
    $display("[JTAG_MDL] jtag test start");
    // APB_AP test
    jtag_apb_wr(`DBGAPB_DBG_EN, 32'h1);
    jtag_apb_wr(`DBGAPB_INST, 32'hbeefbeef);
    jtag_w_ir(4'ha);
    do begin // CTRL/STAT CMP mode
        jtag_rw_dr(35, {32'hf08, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'hbeefbeef, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h1, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    if (rdata[7]) $display("[JTAG_MDL] STICKYCMP PASS (CTRL/STAT: %08x)", rdata[34:3]);
    else          $display("[JTAG_MDL] STICKYCMP FAIL (CTRL/STAT: %08x)", rdata[34:3]);
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'hbeef0000, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h1, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    if (~rdata[7]) $display("[JTAG_MDL] STICKYCMP PASS (CTRL/STAT: %08x)", rdata[34:3]);
    else           $display("[JTAG_MDL] STICKYCMP FAIL (CTRL/STAT: %08x)", rdata[34:3]);
    jtag_w_ir(4'ha);
    do begin // CTRL/STAT VERF mode
        jtag_rw_dr(35, {32'hf04, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'hbeefbeef, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h1, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    if (~rdata[7]) $display("[JTAG_MDL] STICKYCMP PASS (CTRL/STAT: %08x)", rdata[34:3]);
    else           $display("[JTAG_MDL] STICKYCMP FAIL (CTRL/STAT: %08x)", rdata[34:3]);
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'hbeef0000, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h1, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    if (rdata[7]) $display("[JTAG_MDL] STICKYCMP PASS (CTRL/STAT: %08x)", rdata[34:3]);
    else          $display("[JTAG_MDL] STICKYCMP FAIL (CTRL/STAT: %08x)", rdata[34:3]);
    // auto addr incr
    jtag_w_ir(4'ha);
    do begin // CTRL/STAT NORM mode
        jtag_rw_dr(35, {32'hf00, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'hb);
    do begin // CSW ADDRINC
        jtag_rw_dr(35, {32'h10, 2'h0, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h11111111, 2'h3, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h22222222, 2'h3, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h33333333, 2'h3, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h44444444, 2'h3, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin // TAR
        jtag_rw_dr(35, {32'h4, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h11111111, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h22222222, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h33333333, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    do begin
        jtag_rw_dr(35, {32'h44444444, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    
    // AXI_AP test
    // APSEL AXI_AP sel
    axi_ap_test_addr = 32'h0200_0000;
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {{8'h2, 16'b0, 4'h0, 4'b0}, 2'h2, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    // AXI_AP CSW 32-bit and Auto-incr addr
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'h12, 2'h0, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    // AXI_AP TAR
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {axi_ap_test_addr, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'hb);
    for (i = 0; i < 'h20; i = i + 1) begin
        axi_ap_test_data = i << 24 | i << 16 | i << 8 | i;
        do begin
            jtag_rw_dr(35, {axi_ap_test_data, 2'h3, 1'b0});
        end while (rdata[2:0] == `RESP_WAIT);
        $display("[JTAG_MDL] AXI write [%08x] = %08x", axi_ap_test_addr + 4 * i, axi_ap_test_data);
    end
    // AXI_AP TAR
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {axi_ap_test_addr, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'hb);
    for (i = 0; i < 'h20; i = i + 1) begin
        jtag_w_ir(4'hb);
        do begin
            jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
        end while (rdata[2:0] == `RESP_WAIT);
        jtag_w_ir(4'ha);
        do begin
            jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
        end while (rdata[2:0] == `RESP_WAIT);
        $display("[JTAG_MDL] AXI read [%08x] = %08x", axi_ap_test_addr + 4 * i, rdata[34:3]);
    end

    // AXI_AP test
    // APSEL AXI_AP sel
    axi_ap_test_addr = 32'h0002_0003;
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {{8'h2, 16'b0, 4'h0, 4'b0}, 2'h2, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    // AXI_AP CSW 32-bit and Auto-incr addr
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'h12, 2'h0, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    // AXI_AP TAR
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {axi_ap_test_addr, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'hb);
    for (i = 0; i < 'h20; i = i + 1) begin
        axi_ap_test_data = i << 24 | i << 16 | i << 8 | i;
        do begin
            jtag_rw_dr(35, {axi_ap_test_data, 2'h3, 1'b0});
        end while (rdata[2:0] == `RESP_WAIT);
        $display("[JTAG_MDL] AXI write [%08x] = %08x", axi_ap_test_addr + 4 * i, axi_ap_test_data);
    end
    // AXI_AP TAR
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {axi_ap_test_addr, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'hb);
    for (i = 0; i < 'h20; i = i + 1) begin
        jtag_w_ir(4'hb);
        do begin
            jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
        end while (rdata[2:0] == `RESP_WAIT);
        jtag_w_ir(4'ha);
        do begin
            jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
        end while (rdata[2:0] == `RESP_WAIT);
        $display("[JTAG_MDL] AXI read [%08x] = %08x", axi_ap_test_addr + 4 * i, rdata[34:3]);
    end

    // AXI_AP test
    // APSEL AXI_AP sel
    axi_ap_test_addr = 32'h0000_0000;
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {{8'h2, 16'b0, 4'h0, 4'b0}, 2'h2, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    // AXI_AP CSW 32-bit and Auto-incr addr and sector
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'h1a, 2'h0, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    // AXI_AP TAR
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {axi_ap_test_addr, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    $display("[JTAG_MDL] AXI read sector [%08x]", axi_ap_test_addr);
    jtag_w_ir(4'hc);
    jtag_rd_dbuf;

    // AXI_AP test
    // APSEL AXI_AP sel
    axi_ap_test_addr = 32'h0400_1000;
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {{8'h2, 16'b0, 4'h0, 4'b0}, 2'h2, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    // AXI_AP CSW 32-bit and Auto-incr addr and sector
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'h1a, 2'h0, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    // AXI_AP TAR
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {axi_ap_test_addr, 2'h1, 1'b0});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'hb);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {32'h0, 2'h3, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    $display("[JTAG_MDL] AXI read sector [%08x]", axi_ap_test_addr);
    jtag_w_ir(4'hc);
    jtag_rd_dbuf;
    jtag_w_ir(4'hd);
    jtag_rd_rbuf;
*/
`endif
end

task jtag_tms_tdi;
input tms_i;
input tdi_i;

tck = 1'b0;
tms = tms_i;
tdi = tdi_i;
#(`TCK_PERIOD/4);
tck = 1'b1;
#(`TCK_PERIOD/2);
tck = 1'b0;
#(`TCK_PERIOD/4);
endtask

task jtag_tms;
input tms_i;
jtag_tms_tdi(tms_i, 1'b0);
endtask

task jtag_tdi;
input tdi_i;
jtag_tms_tdi(1'b0, tdi_i);
endtask

task jtag_reset;
integer i;
for (i = 0; i < 5; i = i + 1) begin
    jtag_tms(1'b1);
end
endtask

task jtag_w_ir;
input [3:0] ir;
integer i;
if (ir !== ir_latch) begin
    jtag_tms(1'b1); // Select-DR scan
    jtag_tms(1'b1); // Select-IR scan
    jtag_tms(1'b0); // Capture-IR
    jtag_tms(1'b0); // Shift-IR
    for (i = 0; i < 3; i = i + 1)
        jtag_tdi(ir[i]);
    jtag_tms_tdi(1'b1, ir[i]); // Exit1-IR
    jtag_tms(1'b1); // Update-IR
    jtag_tms(1'b0); // Run-Test or Idle
    ir_latch = ir;
end
endtask

task jtag_rd_dbuf;
integer i;
jtag_tms(1'b1); // Select-DR scan
jtag_tms(1'b0); // Capture-DR
jtag_tms(1'b0); // Shift-DR
for (i = 0; i < 32*64 - 1; i = i + 1) begin
    rdata[31:0] = {tdo, rdata[31:1]};
    if (i % 32 == 31)
        $display("dbuf[0x%2x] = 0x%8x", i / 32, rdata[31:0]);
    jtag_tdi(1'b0);
end
rdata[31:0] = {tdo, rdata[31:1]};
$display("dbuf[0x%2x] = 0x%8x", i / 32, rdata[31:0]);
jtag_tms_tdi(1'b1, 1'b0); // Exit1-DR
jtag_tms(1'b1); // Update-DR
jtag_tms(1'b0); // Run-Test or Idle
endtask

task jtag_rd_rbuf;
integer i;
jtag_tms(1'b1); // Select-DR scan
jtag_tms(1'b0); // Capture-DR
jtag_tms(1'b0); // Shift-DR
for (i = 0; i < 2*64 - 1; i = i + 1) begin
    rdata[31:0] = {tdo, rdata[31:1]};
    if (i % 2 == 1)
        $display("rbuf[0x%2x] = 0x%1x", i / 2, rdata[31:30]);
    jtag_tdi(1'b0);
end
rdata[31:0] = {tdo, rdata[31:1]};
$display("rbuf[0x%2x] = 0x%1x", i / 2, rdata[31:30]);
jtag_tms_tdi(1'b1, 1'b0); // Exit1-DR
jtag_tms(1'b1); // Update-DR
jtag_tms(1'b0); // Run-Test or Idle
endtask

task jtag_rw_dr;
input [ 5:0] length;
input [34:0] dr;
integer i;
jtag_tms(1'b1); // Select-DR scan
jtag_tms(1'b0); // Capture-DR
jtag_tms(1'b0); // Shift-DR
for (i = 0; i < length-1; i = i + 1) begin
    rdata = {tdo, rdata[34:1]};
    jtag_tdi(dr[i]);
end
rdata = {tdo, rdata[34:1]};
jtag_tms_tdi(1'b1, dr[i]); // Exit1-DR
for (; i < 34; i = i + 1)
    rdata = {1'b0, rdata[34:1]};
jtag_tms(1'b1); // Update-DR
jtag_tms(1'b0); // Run-Test or Idle
endtask

task jtag_dpacc_wr;
input [ 3:0] addr;
input [31:0] wdata;

if (~|addr[1:0]) begin
    if (addr[3:2] !== 2'h2 || apsel_latch !== wdata[31:24] || apaddr_h_latch !== wdata[7:4]) begin
        jtag_w_ir(4'ha);
        do begin
            jtag_rw_dr(35, {wdata, addr[3:2], 1'b0});
        end while (rdata[2:0] == `RESP_WAIT);
        if (addr[3:2] === 2'h2) begin
            apsel_latch    = wdata[31:24];
            apaddr_h_latch = wdata[ 7: 4];
        end
    end
end
endtask

task jtag_dapacc_rdbuff;

jtag_w_ir(4'ha);
do begin
    jtag_rw_dr(35, {32'b0, 2'h3, 1'b1});
end while (rdata[2:0] == `RESP_WAIT);

endtask

task jtag_apbapacc_wr;
input [ 7:0] addr;
input [31:0] wdata;

if (~|addr[1:0]) begin
    jtag_w_ir(4'hb);
    if (addr !== 8'h4 || apbap_tar_latch !== wdata) begin
        jtag_dpacc_wr(4'h8, {8'b0, 16'b0, addr[7:4], 4'b0}); // SELECT
        do begin
            jtag_rw_dr(35, {wdata, addr[3:2], 1'b0});
        end while (rdata[2:0] == `RESP_WAIT);
        if (addr === 8'h4) begin
            apbap_tar_latch = wdata;
        end
    end
end
endtask

task jtag_apbapacc_rd;
input [ 7:0] addr;

if (~|addr[1:0]) begin
    jtag_w_ir(4'hb);
    jtag_dpacc_wr(4'h8, {8'b0, 16'b0, addr[7:4], 4'b0}); // SELECT
    do begin
        jtag_rw_dr(35, {32'b0, addr[3:2], 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_dapacc_rdbuff;
end
endtask

task jtag_apbapacc_rd_cmp;
input [ 7:0] addr;
input [31:0] cmp_data;

if (~|addr[1:0]) begin
    jtag_w_ir(4'hb);
    jtag_dpacc_wr(4'h8, {8'b0, 16'b0, addr[7:4], 4'b0}); // SELECT
    do begin
        jtag_rw_dr(35, {cmp_data, addr[3:2], 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_w_ir(4'ha);
    do begin
        jtag_rw_dr(35, {32'b0, 2'h1, 1'b1});
    end while (rdata[2:0] == `RESP_WAIT);
    jtag_dapacc_rdbuff;
end
endtask

task jtag_apb_wr;
input [31:0] addr;
input [31:0] wdata;

jtag_apbapacc_wr(8'h4, addr); // APBAP_TAR
jtag_apbapacc_wr(8'hc, wdata); // APBAP_TAR

endtask

task jtag_apb_rd;
input [31:0] addr;

jtag_dpacc_wr(4'h4, 32'hf00); // CTRL/STAT
jtag_apbapacc_wr(8'h4, addr); // APBAP_TAR
jtag_apbapacc_rd(8'hc);
apb_rdata = rdata[34:3];
endtask

task jtag_apb_rd_cmp;
input [31:0] addr;
input [31:0] cmp_data;

jtag_dpacc_wr(4'h4, 32'hf08); // CTRL/STAT
jtag_apbapacc_wr(8'h4, addr); // APBAP_TAR
jtag_apbapacc_rd_cmp(8'hc, cmp_data);
endtask

task jtag_apb_rd_verf;
input [31:0] addr;
input [31:0] cmp_data;

jtag_dpacc_wr(4'h4, 32'hf04); // CTRL/STAT
jtag_apbapacc_wr(8'h4, addr); // APBAP_TAR
jtag_apbapacc_rd_cmp(8'hc, cmp_data);
endtask

task jtag_dbgapb_status_rd;

jtag_apb_wr(`DBGAPB_INST, {20'b0, `INST_STATUS_RD});
jtag_apb_wr(`DBGAPB_INST_WR, 32'b1);
jtag_apb_rd(`DBGAPB_RDATA_L);
apb64_rdata[31: 0] = apb_rdata;
jtag_apb_rd(`DBGAPB_RDATA_H);
apb64_rdata[63:32] = apb_rdata;
$display("[JTAG_MDL][DBGAPB] READ STATUS_REG: %16x", apb64_rdata);
endtask

task jtag_dbgapb_pc_rd;

jtag_apb_wr(`DBGAPB_INST, {20'b0, `INST_PC_RD});
jtag_apb_wr(`DBGAPB_INST_WR, 32'b1);
jtag_apb_rd(`DBGAPB_RDATA_L);
apb64_rdata[31: 0] = apb_rdata;
jtag_apb_rd(`DBGAPB_RDATA_H);
apb64_rdata[63:32] = apb_rdata;
$display("[JTAG_MDL][DBGAPB] READ PC: %16x", apb64_rdata);
endtask

task jtag_dbgapb_exec;
input [31:0] inst;

jtag_apb_wr(`DBGAPB_WDATA_L, inst);
jtag_apb_wr(`DBGAPB_WDATA_WR, 32'b1);
jtag_apb_wr(`DBGAPB_INST, {20'b0, `INST_INSTREG_WR});
jtag_apb_wr(`DBGAPB_INST_WR, 32'b1);
jtag_apb_wr(`DBGAPB_INST, {20'b0, `INST_EXECUTE});
jtag_apb_wr(`DBGAPB_INST_WR, 32'b1);
endtask

endmodule
