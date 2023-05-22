//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
//Date        : Sun May 21 21:54:39 2023
//Host        : yutong-virtual-machine running 64-bit Ubuntu 22.04.2 LTS
//Command     : generate_target soc_wrapper.bd
//Design      : soc_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module soc_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    miso_0,
    mosi_0,
    nss_0,
    riscv_jtag_tck,
    riscv_jtag_tdi,
    riscv_jtag_tdo,
    riscv_jtag_tms,
    riscv_rmii_crs_dv,
    riscv_rmii_refclk,
    riscv_rmii_rxd,
    riscv_rmii_tx_en,
    riscv_rmii_txd,
    riscv_uart_rxd,
    riscv_uart_txd,
    sclk_0);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input miso_0;
  output mosi_0;
  output nss_0;
  input riscv_jtag_tck;
  input riscv_jtag_tdi;
  output riscv_jtag_tdo;
  input riscv_jtag_tms;
  input riscv_rmii_crs_dv;
  input riscv_rmii_refclk;
  input [1:0]riscv_rmii_rxd;
  output riscv_rmii_tx_en;
  output [1:0]riscv_rmii_txd;
  input riscv_uart_rxd;
  output riscv_uart_txd;
  output sclk_0;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire miso_0;
  wire mosi_0;
  wire nss_0;
  wire riscv_jtag_tck;
  wire riscv_jtag_tdi;
  wire riscv_jtag_tdo;
  wire riscv_jtag_tms;
  wire riscv_rmii_crs_dv;
  wire riscv_rmii_refclk;
  wire [1:0]riscv_rmii_rxd;
  wire riscv_rmii_tx_en;
  wire [1:0]riscv_rmii_txd;
  wire riscv_uart_rxd;
  wire riscv_uart_txd;
  wire sclk_0;

  soc soc_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .miso_0(miso_0),
        .mosi_0(mosi_0),
        .nss_0(nss_0),
        .riscv_jtag_tck(riscv_jtag_tck),
        .riscv_jtag_tdi(riscv_jtag_tdi),
        .riscv_jtag_tdo(riscv_jtag_tdo),
        .riscv_jtag_tms(riscv_jtag_tms),
        .riscv_rmii_crs_dv(riscv_rmii_crs_dv),
        .riscv_rmii_refclk(riscv_rmii_refclk),
        .riscv_rmii_rxd(riscv_rmii_rxd),
        .riscv_rmii_tx_en(riscv_rmii_tx_en),
        .riscv_rmii_txd(riscv_rmii_txd),
        .riscv_uart_rxd(riscv_uart_rxd),
        .riscv_uart_txd(riscv_uart_txd),
        .sclk_0(sclk_0));
endmodule
