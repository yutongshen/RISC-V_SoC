module scu (
    input                                    clk,
    input                                    rstn,

    axi_intf.slave                           s_axi_intf,
    axi_intf.master                          m_axi_intf,

    output logic [  `CACHE_ADDR_WIDTH - 1:0] m0_snp_addr,
    output logic                             m0_snp_valid,
    input                                    m0_snp_ready,

    output logic [  `CACHE_ADDR_WIDTH - 1:0] m1_snp_addr,
    output logic                             m1_snp_valid,
    input                                    m1_snp_ready
);

logic        m0_fifo_push;
logic [31:0] m0_fifo_wdata;
logic        m0_fifo_full;
logic        m0_fifo_pop;
logic [31:0] m0_fifo_rdata;
logic        m0_fifo_empty;
logic        m1_fifo_push;
logic [31:0] m1_fifo_wdata;
logic        m1_fifo_full;
logic        m1_fifo_pop;
logic [31:0] m1_fifo_rdata;
logic        m1_fifo_empty;
logic        stall;

assign m_axi_intf.awid    = s_axi_intf.awid;
assign m_axi_intf.awaddr  = s_axi_intf.awaddr;
assign m_axi_intf.awburst = s_axi_intf.awburst;
assign m_axi_intf.awsize  = s_axi_intf.awsize;
assign m_axi_intf.awlen   = s_axi_intf.awlen;
assign m_axi_intf.awlock  = s_axi_intf.awlock;
assign m_axi_intf.awcache = s_axi_intf.awcache;
assign m_axi_intf.awprot  = s_axi_intf.awprot;
assign m_axi_intf.awvalid = s_axi_intf.awvalid && ~stall;
assign s_axi_intf.awready = m_axi_intf.awready && ~stall;
assign m_axi_intf.wid     = s_axi_intf.wid;
assign m_axi_intf.wstrb   = s_axi_intf.wstrb;
assign m_axi_intf.wdata   = s_axi_intf.wdata;
assign m_axi_intf.wlast   = s_axi_intf.wlast;
assign m_axi_intf.wvalid  = s_axi_intf.wvalid;
assign s_axi_intf.wready  = m_axi_intf.wready;
assign s_axi_intf.bid     = m_axi_intf.bid;
assign s_axi_intf.bresp   = m_axi_intf.bresp;
assign s_axi_intf.bvalid  = m_axi_intf.bvalid;
assign m_axi_intf.bready  = s_axi_intf.bready;
assign m_axi_intf.arid    = s_axi_intf.arid;
assign m_axi_intf.araddr  = s_axi_intf.araddr;
assign m_axi_intf.arburst = s_axi_intf.arburst;
assign m_axi_intf.arsize  = s_axi_intf.arsize;
assign m_axi_intf.arlen   = s_axi_intf.arlen;
assign m_axi_intf.arlock  = s_axi_intf.arlock;
assign m_axi_intf.arcache = s_axi_intf.arcache;
assign m_axi_intf.arprot  = s_axi_intf.arprot;
assign m_axi_intf.arvalid = s_axi_intf.arvalid;
assign s_axi_intf.arready = m_axi_intf.arready;
assign s_axi_intf.rid     = m_axi_intf.rid;
assign s_axi_intf.rdata   = m_axi_intf.rdata;
assign s_axi_intf.rresp   = m_axi_intf.rresp;
assign s_axi_intf.rlast   = m_axi_intf.rlast;
assign s_axi_intf.rvalid  = m_axi_intf.rvalid;
assign m_axi_intf.rready  = s_axi_intf.rready;

assign stall = m0_fifo_full || m1_fifo_full;

assign m0_fifo_push  = s_axi_intf.awvalid && s_axi_intf.awready;
assign m0_fifo_wdata = s_axi_intf.awaddr;
assign m0_fifo_pop   = m0_snp_valid && m0_snp_ready;
assign m1_fifo_push  = s_axi_intf.awvalid && s_axi_intf.awready;
assign m1_fifo_wdata = s_axi_intf.awaddr;
assign m1_fifo_pop   = m1_snp_valid && m1_snp_ready;

assign m0_snp_addr  =  m0_fifo_rdata;
assign m0_snp_valid = ~m0_fifo_empty;
assign m1_snp_addr  =  m1_fifo_rdata;
assign m1_snp_valid = ~m1_fifo_empty;

scu_fifo u_m0_fifo (
    .clk   ( clk           ),
    .rstn  ( rstn          ),

    .push  ( m0_fifo_push  ),
    .wdata ( m0_fifo_wdata ),
    .full  ( m0_fifo_full  ),

    .pop   ( m0_fifo_pop   ),
    .rdata ( m0_fifo_rdata ),
    .empty ( m0_fifo_empty )
);

scu_fifo u_m1_fifo (
    .clk   ( clk           ),
    .rstn  ( rstn          ),

    .push  ( m1_fifo_push  ),
    .wdata ( m1_fifo_wdata ),
    .full  ( m1_fifo_full  ),

    .pop   ( m1_fifo_pop   ),
    .rdata ( m1_fifo_rdata ),
    .empty ( m1_fifo_empty )
);

endmodule

module scu_fifo (
    input               clk,
    input               rstn,

    input               push,
    input        [31:0] wdata,
    output logic        full,

    input               pop,
    output logic [31:0] rdata,
    output logic        empty
);

parameter DEPTH = 2;
parameter SIZE  = 2 ** DEPTH;

logic [   31:0] fifo [SIZE];
logic [DEPTH:0] rptr;
logic [DEPTH:0] wptr;

assign empty = rptr == wptr;
assign full  = rptr[0+:DEPTH] == wptr[0+:DEPTH] &&
               (rptr[DEPTH] ^ wptr[DEPTH]);

assign rdata = fifo[rptr[0+:DEPTH]];

always_ff @(posedge clk or negedge rstn) begin: reg_rptr
    if (~rstn) rptr <= {DEPTH+1{1'b0}};
    else       rptr <= rptr + {{DEPTH{1'b0}}, pop & ~empty};
end

always_ff @(posedge clk or negedge rstn) begin: reg_wptr
    if (~rstn) wptr <= {DEPTH+1{1'b0}};
    else       wptr <= wptr + {{DEPTH{1'b0}}, push & ~full};
end

always_ff @(posedge clk or negedge rstn) begin: reg_fifo
    integer i;
    if (~rstn) begin
        for (i = 0; i < SIZE; i = i + 1)
            fifo[i] <= 32'b0;
    end
    else if (push && ~full) begin
        fifo[wptr[0+:DEPTH]] <= wdata;
    end
end

endmodule
