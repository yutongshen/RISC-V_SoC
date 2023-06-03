-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
-- Date        : Thu Jun  1 02:20:12 2023
-- Host        : yutong-virtual-machine running 64-bit Ubuntu 22.04.2 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/yutong/RISC-V_SoC/vivado/soc/soc.srcs/sources_1/bd/soc/ip/soc_cpu_wrap_0_0/soc_cpu_wrap_0_0_stub.vhdl
-- Design      : soc_cpu_wrap_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity soc_cpu_wrap_0_0 is
  Port ( 
    clk : in STD_LOGIC;
    clk_32k : in STD_LOGIC;
    rstn : in STD_LOGIC;
    ddr_m_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_m_awid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    ddr_m_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ddr_m_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr_m_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ddr_m_awlock : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_m_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ddr_m_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr_m_awvalid : out STD_LOGIC;
    ddr_m_awready : in STD_LOGIC;
    ddr_m_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ddr_m_wid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    ddr_m_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ddr_m_wlast : out STD_LOGIC;
    ddr_m_wvalid : out STD_LOGIC;
    ddr_m_wready : in STD_LOGIC;
    ddr_m_bid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    ddr_m_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_m_bvalid : in STD_LOGIC;
    ddr_m_bready : out STD_LOGIC;
    ddr_m_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ddr_m_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_m_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr_m_arid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    ddr_m_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ddr_m_arlock : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_m_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ddr_m_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr_m_arvalid : out STD_LOGIC;
    ddr_m_arready : in STD_LOGIC;
    ddr_m_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ddr_m_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_m_rid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    ddr_m_rlast : in STD_LOGIC;
    ddr_m_rvalid : in STD_LOGIC;
    ddr_m_rready : out STD_LOGIC;
    ext_s_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ext_s_awid : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ext_s_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ext_s_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    ext_s_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ext_s_awlock : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ext_s_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    ext_s_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    ext_s_awvalid : in STD_LOGIC;
    ext_s_awready : out STD_LOGIC;
    ext_s_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    ext_s_wid : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ext_s_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ext_s_wlast : in STD_LOGIC;
    ext_s_wvalid : in STD_LOGIC;
    ext_s_wready : out STD_LOGIC;
    ext_s_bid : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ext_s_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ext_s_bvalid : out STD_LOGIC;
    ext_s_bready : in STD_LOGIC;
    ext_s_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ext_s_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ext_s_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    ext_s_arid : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ext_s_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ext_s_arlock : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ext_s_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    ext_s_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    ext_s_arvalid : in STD_LOGIC;
    ext_s_arready : out STD_LOGIC;
    ext_s_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ext_s_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ext_s_rid : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ext_s_rlast : out STD_LOGIC;
    ext_s_rvalid : out STD_LOGIC;
    ext_s_rready : in STD_LOGIC;
    dbg_psel : in STD_LOGIC;
    dbg_penable : in STD_LOGIC;
    dbg_paddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dbg_pwrite : in STD_LOGIC;
    dbg_pstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    dbg_pprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    dbg_pwdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dbg_prdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    dbg_pslverr : out STD_LOGIC;
    dbg_pready : out STD_LOGIC;
    uart_tx : out STD_LOGIC;
    uart_rx : in STD_LOGIC;
    sclk : out STD_LOGIC;
    nss : out STD_LOGIC;
    mosi : out STD_LOGIC;
    miso : in STD_LOGIC;
    rmii_refclk : in STD_LOGIC;
    rmii_crsdv : in STD_LOGIC;
    rmii_rxd : in STD_LOGIC_VECTOR ( 1 downto 0 );
    rmii_txen : out STD_LOGIC;
    rmii_txd : out STD_LOGIC_VECTOR ( 1 downto 0 );
    tck : in STD_LOGIC;
    tms : in STD_LOGIC;
    tdi : in STD_LOGIC;
    tdo : out STD_LOGIC
  );

end soc_cpu_wrap_0_0;

architecture stub of soc_cpu_wrap_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,clk_32k,rstn,ddr_m_awburst[1:0],ddr_m_awid[5:0],ddr_m_awaddr[31:0],ddr_m_awsize[2:0],ddr_m_awlen[7:0],ddr_m_awlock[1:0],ddr_m_awcache[3:0],ddr_m_awprot[2:0],ddr_m_awvalid,ddr_m_awready,ddr_m_wstrb[3:0],ddr_m_wid[5:0],ddr_m_wdata[31:0],ddr_m_wlast,ddr_m_wvalid,ddr_m_wready,ddr_m_bid[5:0],ddr_m_bresp[1:0],ddr_m_bvalid,ddr_m_bready,ddr_m_araddr[31:0],ddr_m_arburst[1:0],ddr_m_arsize[2:0],ddr_m_arid[5:0],ddr_m_arlen[7:0],ddr_m_arlock[1:0],ddr_m_arcache[3:0],ddr_m_arprot[2:0],ddr_m_arvalid,ddr_m_arready,ddr_m_rdata[31:0],ddr_m_rresp[1:0],ddr_m_rid[5:0],ddr_m_rlast,ddr_m_rvalid,ddr_m_rready,ext_s_awburst[1:0],ext_s_awid[7:0],ext_s_awaddr[31:0],ext_s_awsize[2:0],ext_s_awlen[7:0],ext_s_awlock[1:0],ext_s_awcache[3:0],ext_s_awprot[2:0],ext_s_awvalid,ext_s_awready,ext_s_wstrb[3:0],ext_s_wid[7:0],ext_s_wdata[31:0],ext_s_wlast,ext_s_wvalid,ext_s_wready,ext_s_bid[7:0],ext_s_bresp[1:0],ext_s_bvalid,ext_s_bready,ext_s_araddr[31:0],ext_s_arburst[1:0],ext_s_arsize[2:0],ext_s_arid[7:0],ext_s_arlen[7:0],ext_s_arlock[1:0],ext_s_arcache[3:0],ext_s_arprot[2:0],ext_s_arvalid,ext_s_arready,ext_s_rdata[31:0],ext_s_rresp[1:0],ext_s_rid[7:0],ext_s_rlast,ext_s_rvalid,ext_s_rready,dbg_psel,dbg_penable,dbg_paddr[31:0],dbg_pwrite,dbg_pstrb[3:0],dbg_pprot[2:0],dbg_pwdata[31:0],dbg_prdata[31:0],dbg_pslverr,dbg_pready,uart_tx,uart_rx,sclk,nss,mosi,miso,rmii_refclk,rmii_crsdv,rmii_rxd[1:0],rmii_txen,rmii_txd[1:0],tck,tms,tdi,tdo";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "cpu_wrap,Vivado 2018.3";
begin
end;
