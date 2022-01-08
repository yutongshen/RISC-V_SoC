module iommu_ext (
    axi_intf.slave  s_axi_intf,
    axi_intf.master m_axi_intf
);

assign s_axi_intf.awready = m_axi_intf.awready;
assign s_axi_intf.wready  = m_axi_intf.wready ;
assign s_axi_intf.bid     = m_axi_intf.bid    ;
assign s_axi_intf.bresp   = m_axi_intf.bresp  ;
assign s_axi_intf.bvalid  = m_axi_intf.bvalid ;
assign s_axi_intf.arready = m_axi_intf.arready;
assign s_axi_intf.rdata   = m_axi_intf.rdata  ;
assign s_axi_intf.rresp   = m_axi_intf.rresp  ;
assign s_axi_intf.rid     = m_axi_intf.rid    ;
assign s_axi_intf.rlast   = m_axi_intf.rlast  ;
assign s_axi_intf.rvalid  = m_axi_intf.rvalid ;

assign m_axi_intf.awburst = s_axi_intf.awburst;
assign m_axi_intf.awid    = s_axi_intf.awid   ;
assign m_axi_intf.awaddr  = {2'b0, s_axi_intf.awaddr[29:0]};
assign m_axi_intf.awsize  = s_axi_intf.awsize ;
assign m_axi_intf.awlen   = s_axi_intf.awlen  ;
assign m_axi_intf.awlock  = s_axi_intf.awlock ;
assign m_axi_intf.awcache = s_axi_intf.awcache;
assign m_axi_intf.awprot  = s_axi_intf.awprot ;
assign m_axi_intf.awvalid = s_axi_intf.awvalid;
assign m_axi_intf.wstrb   = s_axi_intf.wstrb  ;
assign m_axi_intf.wid     = s_axi_intf.wid    ;
assign m_axi_intf.wdata   = s_axi_intf.wdata  ;
assign m_axi_intf.wlast   = s_axi_intf.wlast  ;
assign m_axi_intf.wvalid  = s_axi_intf.wvalid ;
assign m_axi_intf.bready  = s_axi_intf.bready ;
assign m_axi_intf.araddr  = {2'b0, s_axi_intf.araddr[29:0]};
assign m_axi_intf.arburst = s_axi_intf.arburst;
assign m_axi_intf.arsize  = s_axi_intf.arsize ;
assign m_axi_intf.arid    = s_axi_intf.arid   ;
assign m_axi_intf.arlen   = s_axi_intf.arlen  ;
assign m_axi_intf.arlock  = s_axi_intf.arlock ;
assign m_axi_intf.arcache = s_axi_intf.arcache;
assign m_axi_intf.arprot  = s_axi_intf.arprot ;
assign m_axi_intf.arvalid = s_axi_intf.arvalid;
assign m_axi_intf.rready  = s_axi_intf.rready ;

endmodule

module iommu_ddr (
    axi_intf.slave  s_axi_intf,
    axi_intf.master m_axi_intf,
    input [31:0]    offset
);

assign s_axi_intf.awready = m_axi_intf.awready;
assign s_axi_intf.wready  = m_axi_intf.wready ;
assign s_axi_intf.bid     = {6'b0, m_axi_intf.bid};
assign s_axi_intf.bresp   = m_axi_intf.bresp  ;
assign s_axi_intf.bvalid  = m_axi_intf.bvalid ;
assign s_axi_intf.arready = m_axi_intf.arready;
assign s_axi_intf.rdata   = m_axi_intf.rdata  ;
assign s_axi_intf.rresp   = m_axi_intf.rresp  ;
assign s_axi_intf.rid     = {6'b0, m_axi_intf.rid};
assign s_axi_intf.rlast   = m_axi_intf.rlast  ;
assign s_axi_intf.rvalid  = m_axi_intf.rvalid ;

assign m_axi_intf.awburst = s_axi_intf.awburst;
assign m_axi_intf.awid    = s_axi_intf.awid[5:0];
assign m_axi_intf.awaddr  = s_axi_intf.awaddr + offset + 32'h8000_0000;
assign m_axi_intf.awsize  = s_axi_intf.awsize ;
assign m_axi_intf.awlen   = s_axi_intf.awlen  ;
assign m_axi_intf.awlock  = s_axi_intf.awlock ;
assign m_axi_intf.awcache = s_axi_intf.awcache;
assign m_axi_intf.awprot  = s_axi_intf.awprot ;
assign m_axi_intf.awvalid = s_axi_intf.awvalid;
assign m_axi_intf.wstrb   = s_axi_intf.wstrb  ;
assign m_axi_intf.wid     = s_axi_intf.wid[5:0];
assign m_axi_intf.wdata   = s_axi_intf.wdata  ;
assign m_axi_intf.wlast   = s_axi_intf.wlast  ;
assign m_axi_intf.wvalid  = s_axi_intf.wvalid ;
assign m_axi_intf.bready  = s_axi_intf.bready ;
assign m_axi_intf.araddr  = s_axi_intf.araddr + offset + 32'h8000_0000;
assign m_axi_intf.arburst = s_axi_intf.arburst;
assign m_axi_intf.arsize  = s_axi_intf.arsize ;
assign m_axi_intf.arid    = s_axi_intf.arid[5:0];
assign m_axi_intf.arlen   = s_axi_intf.arlen  ;
assign m_axi_intf.arlock  = s_axi_intf.arlock ;
assign m_axi_intf.arcache = s_axi_intf.arcache;
assign m_axi_intf.arprot  = s_axi_intf.arprot ;
assign m_axi_intf.arvalid = s_axi_intf.arvalid;
assign m_axi_intf.rready  = s_axi_intf.rready ;

endmodule
