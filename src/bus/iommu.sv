module iommu (
    input                  aclk,
    input                  aresetn,
    input         [  1: 0] s_awburst,
    input         [  9: 0] s_awid,
    input         [ 31: 0] s_awaddr,
    input         [  2: 0] s_awsize,
    input         [  7: 0] s_awlen,
    input                  s_awvalid,
    output logic           s_awready,
    input         [  3: 0] s_wstrb,
    input         [  9: 0] s_wid,
    input         [ 31: 0] s_wdata,
    input                  s_wlast,
    input                  s_wvalid,
    output logic           s_wready,
    output logic  [  9: 0] s_bid,
    output logic  [  1: 0] s_bresp,
    output logic           s_bvalid,
    input                  s_bready,
    input         [ 31: 0] s_araddr,
    input         [  1: 0] s_arburst,
    input         [  2: 0] s_arsize,
    input         [  9: 0] s_arid,
    input         [  7: 0] s_arlen,
    input                  s_arvalid,
    output logic           s_arready,
    output logic  [ 31: 0] s_rdata,
    output logic  [  1: 0] s_rresp,
    output logic  [  9: 0] s_rid,
    output logic           s_rlast,
    output logic           s_rvalid,
    input                  s_rready,
    output logic  [  1: 0] m_awburst,
    output logic  [  9: 0] m_awid,
    output logic  [ 31: 0] m_awaddr,
    output logic  [  2: 0] m_awsize,
    output logic  [  7: 0] m_awlen,
    output logic           m_awvalid,
    input                  m_awready,
    output logic  [  3: 0] m_wstrb,
    output logic  [  9: 0] m_wid,
    output logic  [ 31: 0] m_wdata,
    output logic           m_wlast,
    output logic           m_wvalid,
    input                  m_wready,
    input         [  9: 0] m_bid,
    input         [  1: 0] m_bresp,
    input                  m_bvalid,
    output logic           m_bready,
    output logic  [ 31: 0] m_araddr,
    output logic  [  1: 0] m_arburst,
    output logic  [  2: 0] m_arsize,
    output logic  [  9: 0] m_arid,
    output logic  [  7: 0] m_arlen,
    output logic           m_arvalid,
    input                  m_arready,
    input         [ 31: 0] m_rdata,
    input         [  1: 0] m_rresp,
    input         [  9: 0] m_rid,
    input                  m_rlast,
    input                  m_rvalid,
    output logic           m_rready
);

assign s_awready = m_awready;
assign s_wready  = m_wready ;
assign s_bid     = m_bid    ;
assign s_bresp   = m_bresp  ;
assign s_bvalid  = m_bvalid ;
assign s_arready = m_arready;
assign s_rdata   = m_rdata  ;
assign s_rresp   = m_rresp  ;
assign s_rid     = m_rid    ;
assign s_rlast   = m_rlast  ;
assign s_rvalid  = m_rvalid ;

assign m_awburst = s_awburst;
assign m_awid    = s_awid   ;
assign m_awaddr  = {2'b0, s_awaddr[29:0]};
assign m_awsize  = s_awsize ;
assign m_awlen   = s_awlen  ;
assign m_awvalid = s_awvalid;
assign m_wstrb   = s_wstrb  ;
assign m_wid     = s_wid    ;
assign m_wdata   = s_wdata  ;
assign m_wlast   = s_wlast  ;
assign m_wvalid  = s_wvalid ;
assign m_bready  = s_bready ;
assign m_araddr  = {2'b0, s_araddr[29:0]};
assign m_arburst = s_arburst;
assign m_arsize  = s_arsize ;
assign m_arid    = s_arid   ;
assign m_arlen   = s_arlen  ;
assign m_arvalid = s_arvalid;
assign m_rready  = s_rready ;

endmodule
