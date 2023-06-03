// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: user.org:user:cpu_wrap:1.0
// IP Revision: 29

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module soc_cpu_wrap_0_0 (
  clk,
  clk_32k,
  rstn,
  ddr_m_awburst,
  ddr_m_awid,
  ddr_m_awaddr,
  ddr_m_awsize,
  ddr_m_awlen,
  ddr_m_awlock,
  ddr_m_awcache,
  ddr_m_awprot,
  ddr_m_awvalid,
  ddr_m_awready,
  ddr_m_wstrb,
  ddr_m_wid,
  ddr_m_wdata,
  ddr_m_wlast,
  ddr_m_wvalid,
  ddr_m_wready,
  ddr_m_bid,
  ddr_m_bresp,
  ddr_m_bvalid,
  ddr_m_bready,
  ddr_m_araddr,
  ddr_m_arburst,
  ddr_m_arsize,
  ddr_m_arid,
  ddr_m_arlen,
  ddr_m_arlock,
  ddr_m_arcache,
  ddr_m_arprot,
  ddr_m_arvalid,
  ddr_m_arready,
  ddr_m_rdata,
  ddr_m_rresp,
  ddr_m_rid,
  ddr_m_rlast,
  ddr_m_rvalid,
  ddr_m_rready,
  ext_s_awburst,
  ext_s_awid,
  ext_s_awaddr,
  ext_s_awsize,
  ext_s_awlen,
  ext_s_awlock,
  ext_s_awcache,
  ext_s_awprot,
  ext_s_awvalid,
  ext_s_awready,
  ext_s_wstrb,
  ext_s_wid,
  ext_s_wdata,
  ext_s_wlast,
  ext_s_wvalid,
  ext_s_wready,
  ext_s_bid,
  ext_s_bresp,
  ext_s_bvalid,
  ext_s_bready,
  ext_s_araddr,
  ext_s_arburst,
  ext_s_arsize,
  ext_s_arid,
  ext_s_arlen,
  ext_s_arlock,
  ext_s_arcache,
  ext_s_arprot,
  ext_s_arvalid,
  ext_s_arready,
  ext_s_rdata,
  ext_s_rresp,
  ext_s_rid,
  ext_s_rlast,
  ext_s_rvalid,
  ext_s_rready,
  dbg_psel,
  dbg_penable,
  dbg_paddr,
  dbg_pwrite,
  dbg_pstrb,
  dbg_pprot,
  dbg_pwdata,
  dbg_prdata,
  dbg_pslverr,
  dbg_pready,
  uart_tx,
  uart_rx,
  sclk,
  nss,
  mosi,
  miso,
  rmii_refclk,
  rmii_crsdv,
  rmii_rxd,
  rmii_txen,
  rmii_txd,
  tck,
  tms,
  tdi,
  tdo
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF ddr_m:ext_s, ASSOCIATED_RESET rstn, FREQ_HZ 45454544, PHASE 0.000, CLK_DOMAIN soc_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
input wire clk_32k;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rstn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rstn RST" *)
input wire rstn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWBURST" *)
output wire [1 : 0] ddr_m_awburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWID" *)
output wire [5 : 0] ddr_m_awid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWADDR" *)
output wire [31 : 0] ddr_m_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWSIZE" *)
output wire [2 : 0] ddr_m_awsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWLEN" *)
output wire [7 : 0] ddr_m_awlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWLOCK" *)
output wire [1 : 0] ddr_m_awlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWCACHE" *)
output wire [3 : 0] ddr_m_awcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWPROT" *)
output wire [2 : 0] ddr_m_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWVALID" *)
output wire ddr_m_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m AWREADY" *)
input wire ddr_m_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m WSTRB" *)
output wire [3 : 0] ddr_m_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m WID" *)
output wire [5 : 0] ddr_m_wid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m WDATA" *)
output wire [31 : 0] ddr_m_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m WLAST" *)
output wire ddr_m_wlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m WVALID" *)
output wire ddr_m_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m WREADY" *)
input wire ddr_m_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m BID" *)
input wire [5 : 0] ddr_m_bid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m BRESP" *)
input wire [1 : 0] ddr_m_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m BVALID" *)
input wire ddr_m_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m BREADY" *)
output wire ddr_m_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARADDR" *)
output wire [31 : 0] ddr_m_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARBURST" *)
output wire [1 : 0] ddr_m_arburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARSIZE" *)
output wire [2 : 0] ddr_m_arsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARID" *)
output wire [5 : 0] ddr_m_arid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARLEN" *)
output wire [7 : 0] ddr_m_arlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARLOCK" *)
output wire [1 : 0] ddr_m_arlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARCACHE" *)
output wire [3 : 0] ddr_m_arcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARPROT" *)
output wire [2 : 0] ddr_m_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARVALID" *)
output wire ddr_m_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m ARREADY" *)
input wire ddr_m_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m RDATA" *)
input wire [31 : 0] ddr_m_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m RRESP" *)
input wire [1 : 0] ddr_m_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m RID" *)
input wire [5 : 0] ddr_m_rid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m RLAST" *)
input wire ddr_m_rlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m RVALID" *)
input wire ddr_m_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ddr_m, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 45454544, ID_WIDTH 6, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN soc_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM\
_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ddr_m RREADY" *)
output wire ddr_m_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWBURST" *)
input wire [1 : 0] ext_s_awburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWID" *)
input wire [7 : 0] ext_s_awid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWADDR" *)
input wire [31 : 0] ext_s_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWSIZE" *)
input wire [2 : 0] ext_s_awsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWLEN" *)
input wire [7 : 0] ext_s_awlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWLOCK" *)
input wire [1 : 0] ext_s_awlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWCACHE" *)
input wire [3 : 0] ext_s_awcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWPROT" *)
input wire [2 : 0] ext_s_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWVALID" *)
input wire ext_s_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s AWREADY" *)
output wire ext_s_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s WSTRB" *)
input wire [3 : 0] ext_s_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s WID" *)
input wire [7 : 0] ext_s_wid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s WDATA" *)
input wire [31 : 0] ext_s_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s WLAST" *)
input wire ext_s_wlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s WVALID" *)
input wire ext_s_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s WREADY" *)
output wire ext_s_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s BID" *)
output wire [7 : 0] ext_s_bid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s BRESP" *)
output wire [1 : 0] ext_s_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s BVALID" *)
output wire ext_s_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s BREADY" *)
input wire ext_s_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARADDR" *)
input wire [31 : 0] ext_s_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARBURST" *)
input wire [1 : 0] ext_s_arburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARSIZE" *)
input wire [2 : 0] ext_s_arsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARID" *)
input wire [7 : 0] ext_s_arid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARLEN" *)
input wire [7 : 0] ext_s_arlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARLOCK" *)
input wire [1 : 0] ext_s_arlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARCACHE" *)
input wire [3 : 0] ext_s_arcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARPROT" *)
input wire [2 : 0] ext_s_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARVALID" *)
input wire ext_s_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s ARREADY" *)
output wire ext_s_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s RDATA" *)
output wire [31 : 0] ext_s_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s RRESP" *)
output wire [1 : 0] ext_s_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s RID" *)
output wire [7 : 0] ext_s_rid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s RLAST" *)
output wire ext_s_rlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s RVALID" *)
output wire ext_s_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ext_s, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 45454544, ID_WIDTH 8, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN soc_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM\
_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 ext_s RREADY" *)
input wire ext_s_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PSEL" *)
input wire dbg_psel;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PENABLE" *)
input wire dbg_penable;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PADDR" *)
input wire [31 : 0] dbg_paddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PWRITE" *)
input wire dbg_pwrite;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PSTRB" *)
input wire [3 : 0] dbg_pstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PPROT" *)
input wire [2 : 0] dbg_pprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PWDATA" *)
input wire [31 : 0] dbg_pwdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PRDATA" *)
output wire [31 : 0] dbg_prdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PSLVERR" *)
output wire dbg_pslverr;
(* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 dbg_apb_s PREADY" *)
output wire dbg_pready;
(* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 uart TxD" *)
output wire uart_tx;
(* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 uart RxD" *)
input wire uart_rx;
output wire sclk;
output wire nss;
output wire mosi;
input wire miso;
input wire rmii_refclk;
(* X_INTERFACE_INFO = "xilinx.com:interface:rmii:1.0 rmii CRS_DV" *)
input wire rmii_crsdv;
(* X_INTERFACE_INFO = "xilinx.com:interface:rmii:1.0 rmii RXD" *)
input wire [1 : 0] rmii_rxd;
(* X_INTERFACE_INFO = "xilinx.com:interface:rmii:1.0 rmii TX_EN" *)
output wire rmii_txen;
(* X_INTERFACE_INFO = "xilinx.com:interface:rmii:1.0 rmii TXD" *)
output wire [1 : 0] rmii_txd;
(* X_INTERFACE_INFO = "xilinx.com:interface:jtag:2.0 jtag TCK" *)
input wire tck;
(* X_INTERFACE_INFO = "xilinx.com:interface:jtag:2.0 jtag TMS" *)
input wire tms;
(* X_INTERFACE_INFO = "xilinx.com:interface:jtag:2.0 jtag TDI" *)
input wire tdi;
(* X_INTERFACE_INFO = "xilinx.com:interface:jtag:2.0 jtag TDO" *)
output wire tdo;

  cpu_wrap inst (
    .clk(clk),
    .clk_32k(clk_32k),
    .rstn(rstn),
    .ddr_m_awburst(ddr_m_awburst),
    .ddr_m_awid(ddr_m_awid),
    .ddr_m_awaddr(ddr_m_awaddr),
    .ddr_m_awsize(ddr_m_awsize),
    .ddr_m_awlen(ddr_m_awlen),
    .ddr_m_awlock(ddr_m_awlock),
    .ddr_m_awcache(ddr_m_awcache),
    .ddr_m_awprot(ddr_m_awprot),
    .ddr_m_awvalid(ddr_m_awvalid),
    .ddr_m_awready(ddr_m_awready),
    .ddr_m_wstrb(ddr_m_wstrb),
    .ddr_m_wid(ddr_m_wid),
    .ddr_m_wdata(ddr_m_wdata),
    .ddr_m_wlast(ddr_m_wlast),
    .ddr_m_wvalid(ddr_m_wvalid),
    .ddr_m_wready(ddr_m_wready),
    .ddr_m_bid(ddr_m_bid),
    .ddr_m_bresp(ddr_m_bresp),
    .ddr_m_bvalid(ddr_m_bvalid),
    .ddr_m_bready(ddr_m_bready),
    .ddr_m_araddr(ddr_m_araddr),
    .ddr_m_arburst(ddr_m_arburst),
    .ddr_m_arsize(ddr_m_arsize),
    .ddr_m_arid(ddr_m_arid),
    .ddr_m_arlen(ddr_m_arlen),
    .ddr_m_arlock(ddr_m_arlock),
    .ddr_m_arcache(ddr_m_arcache),
    .ddr_m_arprot(ddr_m_arprot),
    .ddr_m_arvalid(ddr_m_arvalid),
    .ddr_m_arready(ddr_m_arready),
    .ddr_m_rdata(ddr_m_rdata),
    .ddr_m_rresp(ddr_m_rresp),
    .ddr_m_rid(ddr_m_rid),
    .ddr_m_rlast(ddr_m_rlast),
    .ddr_m_rvalid(ddr_m_rvalid),
    .ddr_m_rready(ddr_m_rready),
    .ext_s_awburst(ext_s_awburst),
    .ext_s_awid(ext_s_awid),
    .ext_s_awaddr(ext_s_awaddr),
    .ext_s_awsize(ext_s_awsize),
    .ext_s_awlen(ext_s_awlen),
    .ext_s_awlock(ext_s_awlock),
    .ext_s_awcache(ext_s_awcache),
    .ext_s_awprot(ext_s_awprot),
    .ext_s_awvalid(ext_s_awvalid),
    .ext_s_awready(ext_s_awready),
    .ext_s_wstrb(ext_s_wstrb),
    .ext_s_wid(ext_s_wid),
    .ext_s_wdata(ext_s_wdata),
    .ext_s_wlast(ext_s_wlast),
    .ext_s_wvalid(ext_s_wvalid),
    .ext_s_wready(ext_s_wready),
    .ext_s_bid(ext_s_bid),
    .ext_s_bresp(ext_s_bresp),
    .ext_s_bvalid(ext_s_bvalid),
    .ext_s_bready(ext_s_bready),
    .ext_s_araddr(ext_s_araddr),
    .ext_s_arburst(ext_s_arburst),
    .ext_s_arsize(ext_s_arsize),
    .ext_s_arid(ext_s_arid),
    .ext_s_arlen(ext_s_arlen),
    .ext_s_arlock(ext_s_arlock),
    .ext_s_arcache(ext_s_arcache),
    .ext_s_arprot(ext_s_arprot),
    .ext_s_arvalid(ext_s_arvalid),
    .ext_s_arready(ext_s_arready),
    .ext_s_rdata(ext_s_rdata),
    .ext_s_rresp(ext_s_rresp),
    .ext_s_rid(ext_s_rid),
    .ext_s_rlast(ext_s_rlast),
    .ext_s_rvalid(ext_s_rvalid),
    .ext_s_rready(ext_s_rready),
    .dbg_psel(dbg_psel),
    .dbg_penable(dbg_penable),
    .dbg_paddr(dbg_paddr),
    .dbg_pwrite(dbg_pwrite),
    .dbg_pstrb(dbg_pstrb),
    .dbg_pprot(dbg_pprot),
    .dbg_pwdata(dbg_pwdata),
    .dbg_prdata(dbg_prdata),
    .dbg_pslverr(dbg_pslverr),
    .dbg_pready(dbg_pready),
    .uart_tx(uart_tx),
    .uart_rx(uart_rx),
    .sclk(sclk),
    .nss(nss),
    .mosi(mosi),
    .miso(miso),
    .rmii_refclk(rmii_refclk),
    .rmii_crsdv(rmii_crsdv),
    .rmii_rxd(rmii_rxd),
    .rmii_txen(rmii_txen),
    .rmii_txd(rmii_txd),
    .tck(tck),
    .tms(tms),
    .tdi(tdi),
    .tdo(tdo)
  );
endmodule
