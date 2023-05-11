// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Thu May 11 08:52:08 2023
// Host        : yutong-virtual-machine running 64-bit Ubuntu 22.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/yutong/RISC-V_SoC/vivado/soc/soc.srcs/sources_1/bd/soc/ip/soc_cpu_wrap_0_0/soc_cpu_wrap_0_0_stub.v
// Design      : soc_cpu_wrap_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "cpu_wrap,Vivado 2018.3" *)
module soc_cpu_wrap_0_0(clk, clk_32k, rstn, ddr_m_awburst, ddr_m_awid, 
  ddr_m_awaddr, ddr_m_awsize, ddr_m_awlen, ddr_m_awlock, ddr_m_awcache, ddr_m_awprot, 
  ddr_m_awvalid, ddr_m_awready, ddr_m_wstrb, ddr_m_wid, ddr_m_wdata, ddr_m_wlast, ddr_m_wvalid, 
  ddr_m_wready, ddr_m_bid, ddr_m_bresp, ddr_m_bvalid, ddr_m_bready, ddr_m_araddr, 
  ddr_m_arburst, ddr_m_arsize, ddr_m_arid, ddr_m_arlen, ddr_m_arlock, ddr_m_arcache, 
  ddr_m_arprot, ddr_m_arvalid, ddr_m_arready, ddr_m_rdata, ddr_m_rresp, ddr_m_rid, ddr_m_rlast, 
  ddr_m_rvalid, ddr_m_rready, ext_s_awburst, ext_s_awid, ext_s_awaddr, ext_s_awsize, 
  ext_s_awlen, ext_s_awlock, ext_s_awcache, ext_s_awprot, ext_s_awvalid, ext_s_awready, 
  ext_s_wstrb, ext_s_wid, ext_s_wdata, ext_s_wlast, ext_s_wvalid, ext_s_wready, ext_s_bid, 
  ext_s_bresp, ext_s_bvalid, ext_s_bready, ext_s_araddr, ext_s_arburst, ext_s_arsize, 
  ext_s_arid, ext_s_arlen, ext_s_arlock, ext_s_arcache, ext_s_arprot, ext_s_arvalid, 
  ext_s_arready, ext_s_rdata, ext_s_rresp, ext_s_rid, ext_s_rlast, ext_s_rvalid, ext_s_rready, 
  dbg_psel, dbg_penable, dbg_paddr, dbg_pwrite, dbg_pstrb, dbg_pprot, dbg_pwdata, dbg_prdata, 
  dbg_pslverr, dbg_pready, uart_tx, uart_rx, sclk, nss, mosi, miso, rmii_refclk, rmii_crsdv, rmii_rxd, 
  rmii_txen, rmii_txd, tck, tms, tdi, tdo)
/* synthesis syn_black_box black_box_pad_pin="clk,clk_32k,rstn,ddr_m_awburst[1:0],ddr_m_awid[5:0],ddr_m_awaddr[31:0],ddr_m_awsize[2:0],ddr_m_awlen[7:0],ddr_m_awlock[1:0],ddr_m_awcache[3:0],ddr_m_awprot[2:0],ddr_m_awvalid,ddr_m_awready,ddr_m_wstrb[3:0],ddr_m_wid[5:0],ddr_m_wdata[31:0],ddr_m_wlast,ddr_m_wvalid,ddr_m_wready,ddr_m_bid[5:0],ddr_m_bresp[1:0],ddr_m_bvalid,ddr_m_bready,ddr_m_araddr[31:0],ddr_m_arburst[1:0],ddr_m_arsize[2:0],ddr_m_arid[5:0],ddr_m_arlen[7:0],ddr_m_arlock[1:0],ddr_m_arcache[3:0],ddr_m_arprot[2:0],ddr_m_arvalid,ddr_m_arready,ddr_m_rdata[31:0],ddr_m_rresp[1:0],ddr_m_rid[5:0],ddr_m_rlast,ddr_m_rvalid,ddr_m_rready,ext_s_awburst[1:0],ext_s_awid[7:0],ext_s_awaddr[31:0],ext_s_awsize[2:0],ext_s_awlen[7:0],ext_s_awlock[1:0],ext_s_awcache[3:0],ext_s_awprot[2:0],ext_s_awvalid,ext_s_awready,ext_s_wstrb[3:0],ext_s_wid[7:0],ext_s_wdata[31:0],ext_s_wlast,ext_s_wvalid,ext_s_wready,ext_s_bid[7:0],ext_s_bresp[1:0],ext_s_bvalid,ext_s_bready,ext_s_araddr[31:0],ext_s_arburst[1:0],ext_s_arsize[2:0],ext_s_arid[7:0],ext_s_arlen[7:0],ext_s_arlock[1:0],ext_s_arcache[3:0],ext_s_arprot[2:0],ext_s_arvalid,ext_s_arready,ext_s_rdata[31:0],ext_s_rresp[1:0],ext_s_rid[7:0],ext_s_rlast,ext_s_rvalid,ext_s_rready,dbg_psel,dbg_penable,dbg_paddr[31:0],dbg_pwrite,dbg_pstrb[3:0],dbg_pprot[2:0],dbg_pwdata[31:0],dbg_prdata[31:0],dbg_pslverr,dbg_pready,uart_tx,uart_rx,sclk,nss,mosi,miso,rmii_refclk,rmii_crsdv,rmii_rxd[1:0],rmii_txen,rmii_txd[1:0],tck,tms,tdi,tdo" */;
  input clk;
  input clk_32k;
  input rstn;
  output [1:0]ddr_m_awburst;
  output [5:0]ddr_m_awid;
  output [31:0]ddr_m_awaddr;
  output [2:0]ddr_m_awsize;
  output [7:0]ddr_m_awlen;
  output [1:0]ddr_m_awlock;
  output [3:0]ddr_m_awcache;
  output [2:0]ddr_m_awprot;
  output ddr_m_awvalid;
  input ddr_m_awready;
  output [3:0]ddr_m_wstrb;
  output [5:0]ddr_m_wid;
  output [31:0]ddr_m_wdata;
  output ddr_m_wlast;
  output ddr_m_wvalid;
  input ddr_m_wready;
  input [5:0]ddr_m_bid;
  input [1:0]ddr_m_bresp;
  input ddr_m_bvalid;
  output ddr_m_bready;
  output [31:0]ddr_m_araddr;
  output [1:0]ddr_m_arburst;
  output [2:0]ddr_m_arsize;
  output [5:0]ddr_m_arid;
  output [7:0]ddr_m_arlen;
  output [1:0]ddr_m_arlock;
  output [3:0]ddr_m_arcache;
  output [2:0]ddr_m_arprot;
  output ddr_m_arvalid;
  input ddr_m_arready;
  input [31:0]ddr_m_rdata;
  input [1:0]ddr_m_rresp;
  input [5:0]ddr_m_rid;
  input ddr_m_rlast;
  input ddr_m_rvalid;
  output ddr_m_rready;
  input [1:0]ext_s_awburst;
  input [7:0]ext_s_awid;
  input [31:0]ext_s_awaddr;
  input [2:0]ext_s_awsize;
  input [7:0]ext_s_awlen;
  input [1:0]ext_s_awlock;
  input [3:0]ext_s_awcache;
  input [2:0]ext_s_awprot;
  input ext_s_awvalid;
  output ext_s_awready;
  input [3:0]ext_s_wstrb;
  input [7:0]ext_s_wid;
  input [31:0]ext_s_wdata;
  input ext_s_wlast;
  input ext_s_wvalid;
  output ext_s_wready;
  output [7:0]ext_s_bid;
  output [1:0]ext_s_bresp;
  output ext_s_bvalid;
  input ext_s_bready;
  input [31:0]ext_s_araddr;
  input [1:0]ext_s_arburst;
  input [2:0]ext_s_arsize;
  input [7:0]ext_s_arid;
  input [7:0]ext_s_arlen;
  input [1:0]ext_s_arlock;
  input [3:0]ext_s_arcache;
  input [2:0]ext_s_arprot;
  input ext_s_arvalid;
  output ext_s_arready;
  output [31:0]ext_s_rdata;
  output [1:0]ext_s_rresp;
  output [7:0]ext_s_rid;
  output ext_s_rlast;
  output ext_s_rvalid;
  input ext_s_rready;
  input dbg_psel;
  input dbg_penable;
  input [31:0]dbg_paddr;
  input dbg_pwrite;
  input [3:0]dbg_pstrb;
  input [2:0]dbg_pprot;
  input [31:0]dbg_pwdata;
  output [31:0]dbg_prdata;
  output dbg_pslverr;
  output dbg_pready;
  output uart_tx;
  input uart_rx;
  output sclk;
  output nss;
  output mosi;
  input miso;
  input rmii_refclk;
  input rmii_crsdv;
  input [1:0]rmii_rxd;
  output rmii_txen;
  output [1:0]rmii_txd;
  input tck;
  input tms;
  input tdi;
  output tdo;
endmodule
