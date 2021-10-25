module axi_vip_moniter (
    input          aclk,
    input          aresetn,
    input [  1: 0] m0_awburst,
    input [  9: 0] m0_awid,
    input [ 31: 0] m0_awaddr,
    input [  2: 0] m0_awsize,
    input [  7: 0] m0_awlen,
    input          m0_awvalid,
    input          m0_awready,
    input [  3: 0] m0_wstrb,
    input [  9: 0] m0_wid,
    input [ 31: 0] m0_wdata,
    input          m0_wlast,
    input          m0_wvalid,
    input          m0_wready,
    input [  9: 0] m0_bid,
    input [  1: 0] m0_bresp,
    input          m0_bvalid,
    input          m0_bready,
    input [ 31: 0] m0_araddr,
    input [  1: 0] m0_arburst,
    input [  2: 0] m0_arsize,
    input [  9: 0] m0_arid,
    input [  7: 0] m0_arlen,
    input          m0_arvalid,
    input          m0_arready,
    input [ 31: 0] m0_rdata,
    input [  1: 0] m0_rresp,
    input [  9: 0] m0_rid,
    input          m0_rlast,
    input          m0_rvalid,
    input          m0_rready,
    input [  1: 0] m1_awburst,
    input [  9: 0] m1_awid,
    input [ 31: 0] m1_awaddr,
    input [  2: 0] m1_awsize,
    input [  7: 0] m1_awlen,
    input          m1_awvalid,
    input          m1_awready,
    input [  3: 0] m1_wstrb,
    input [  9: 0] m1_wid,
    input [ 31: 0] m1_wdata,
    input          m1_wlast,
    input          m1_wvalid,
    input          m1_wready,
    input [  9: 0] m1_bid,
    input [  1: 0] m1_bresp,
    input          m1_bvalid,
    input          m1_bready,
    input [ 31: 0] m1_araddr,
    input [  1: 0] m1_arburst,
    input [  2: 0] m1_arsize,
    input [  9: 0] m1_arid,
    input [  7: 0] m1_arlen,
    input          m1_arvalid,
    input          m1_arready,
    input [ 31: 0] m1_rdata,
    input [  1: 0] m1_rresp,
    input [  9: 0] m1_rid,
    input          m1_rlast,
    input          m1_rvalid,
    input          m1_rready,
    input [  1: 0] s0_awburst,
    input [ 10: 0] s0_awid,
    input [ 31: 0] s0_awaddr,
    input [  2: 0] s0_awsize,
    input [  7: 0] s0_awlen,
    input          s0_awvalid,
    input          s0_awready,
    input [  3: 0] s0_wstrb,
    input [ 10: 0] s0_wid,
    input [ 31: 0] s0_wdata,
    input          s0_wlast,
    input          s0_wvalid,
    input          s0_wready,
    input [ 10: 0] s0_bid,
    input [  1: 0] s0_bresp,
    input          s0_bvalid,
    input          s0_bready,
    input [ 31: 0] s0_araddr,
    input [  1: 0] s0_arburst,
    input [  2: 0] s0_arsize,
    input [ 10: 0] s0_arid,
    input [  7: 0] s0_arlen,
    input          s0_arvalid,
    input          s0_arready,
    input [ 31: 0] s0_rdata,
    input [  1: 0] s0_rresp,
    input [ 10: 0] s0_rid,
    input          s0_rlast,
    input          s0_rvalid,
    input          s0_rready
);

string errmsg;
bit    errflag;

parameter AR_PAYLD_WIDTH = 32 + 2 + 3 + 11 + 8;
parameter AW_PAYLD_WIDTH = 32 + 2 + 3 + 11 + 8;
parameter W_PAYLD_WIDTH  = 4 + 10 + 32 + 1;
parameter B_PAYLD_WIDTH  = 2 + 10;
parameter R_PAYLD_WIDTH  = 32 + 2 + 10 + 1;

logic                      aw_mon_fifo_wr;
logic                      aw_mon_fifo_rd;
logic                      aw_mon_fifo_empty;
logic                      aw_mon_fifo_full;
logic                      w_mon_fifo_wr;
logic                      w_mon_fifo_rd;
logic                      w_mon_fifo_empty;
logic                      w_mon_fifo_full;
logic                      b_mon_fifo_wr;
logic                      b_mon_fifo_rd;
logic                      b_mon_fifo_empty;
logic                      b_mon_fifo_full;
logic                      ar_mon_fifo_wr;
logic                      ar_mon_fifo_rd;
logic                      ar_mon_fifo_empty;
logic                      ar_mon_fifo_full;
logic                      r_mon_fifo_wr;
logic                      r_mon_fifo_rd;
logic                      r_mon_fifo_empty;
logic                      r_mon_fifo_full;
logic                      m0_aw_sel;
logic                      m1_aw_sel;
logic                      m0_w_sel;
logic                      m1_w_sel;
logic                      m0_b_sel;
logic                      m1_b_sel;
logic                      m0_ar_sel;
logic                      m1_ar_sel;
logic                      m0_r_sel;
logic                      m1_r_sel;
logic                      s0_aw_sel;
logic                      s0_w_sel;
logic                      s0_b_sel;
logic                      s0_ar_sel;
logic                      s0_r_sel;
logic [AW_PAYLD_WIDTH-1:0] aw_payld_in;
logic [ W_PAYLD_WIDTH-1:0] w_payld_in;
logic [ B_PAYLD_WIDTH-1:0] b_payld_in;
logic [AR_PAYLD_WIDTH-1:0] ar_payld_in;
logic [ R_PAYLD_WIDTH-1:0] r_payld_in;
logic [AW_PAYLD_WIDTH-1:0] aw_payld_out;
logic [ W_PAYLD_WIDTH-1:0] w_payld_out;
logic [ B_PAYLD_WIDTH-1:0] b_payld_out;
logic [AR_PAYLD_WIDTH-1:0] ar_payld_out;
logic [ R_PAYLD_WIDTH-1:0] r_payld_out;
logic [AW_PAYLD_WIDTH-1:0] aw_payld_cmp;
logic [ W_PAYLD_WIDTH-1:0] w_payld_cmp;
logic [ B_PAYLD_WIDTH-1:0] b_payld_cmp;
logic [AR_PAYLD_WIDTH-1:0] ar_payld_cmp;
logic [ R_PAYLD_WIDTH-1:0] r_payld_cmp;
logic                      aw_payld_cmp_en;
logic                      w_payld_cmp_en;
logic                      b_payld_cmp_en;
logic                      ar_payld_cmp_en;
logic                      r_payld_cmp_en;
logic                      aw_cmp_fail;
logic                      w_cmp_fail;
logic                      b_cmp_fail;
logic                      ar_cmp_fail;
logic                      r_cmp_fail;

assign m0_aw_sel   = m0_awvalid & m0_awready;
assign m1_aw_sel   = m1_awvalid & m1_awready;
assign m0_w_sel    = m0_wvalid  & m0_wready;
assign m1_w_sel    = m1_wvalid  & m1_wready;
assign m0_b_sel    = m0_bvalid  & m0_bready;
assign m1_b_sel    = m1_bvalid  & m1_bready;
assign m0_ar_sel   = m0_arvalid & m0_arready;
assign m1_ar_sel   = m1_arvalid & m1_arready;
assign m0_r_sel    = m0_rvalid  & m0_rready;
assign m1_r_sel    = m1_rvalid  & m1_rready;

assign s0_aw_sel   = s0_awvalid & s0_awready;
assign s0_w_sel    = s0_wvalid  & s0_wready;
assign s0_b_sel    = s0_bvalid  & s0_bready;
assign s0_ar_sel   = s0_arvalid & s0_arready;
assign s0_r_sel    = s0_rvalid  & s0_rready;

always @(posedge aclk) begin
    if (~aresetn) begin
        errflag = 0;
    end
    else begin
        if (m0_aw_sel & m1_aw_sel)         begin errmsg = "both master aw transfer at same time"; errflag = 1; end
        if (m0_w_sel  & m1_w_sel )         begin errmsg = "both master w  transfer at same time"; errflag = 1; end
        if (m0_ar_sel & m1_ar_sel)         begin errmsg = "both master ar transfer at same time"; errflag = 1; end
        if (aw_mon_fifo_full)              begin errmsg = "aw payld fifo full";                   errflag = 1; end
        if (w_mon_fifo_full)               begin errmsg = "w  payld fifo full";                   errflag = 1; end
        if (b_mon_fifo_full)               begin errmsg = "b  payld fifo full";                   errflag = 1; end
        if (ar_mon_fifo_full)              begin errmsg = "ar payld fifo full";                   errflag = 1; end
        if (r_mon_fifo_full)               begin errmsg = "r  payld fifo full";                   errflag = 1; end
        if (s0_aw_sel & ~aw_payld_cmp_en)  begin errmsg = "aw got transaction unexpacted";        errflag = 1; end
        if (s0_w_sel  & ~w_payld_cmp_en )  begin errmsg = "w  got transaction unexpacted";        errflag = 1; end
        if (s0_b_sel  & ~b_payld_cmp_en )  begin errmsg = "b  got transaction unexpacted";        errflag = 1; end
        if (s0_ar_sel & ~ar_payld_cmp_en)  begin errmsg = "ar got transaction unexpacted";        errflag = 1; end
        if (s0_r_sel  & ~r_payld_cmp_en )  begin errmsg = "r  got transaction unexpacted";        errflag = 1; end
        if (aw_payld_cmp_en & aw_cmp_fail) begin errmsg = "aw got transaction mismatch";          errflag = 1; end
        if (w_payld_cmp_en  & w_cmp_fail ) begin errmsg = "w  got transaction mismatch";          errflag = 1; end
        if (b_payld_cmp_en  & b_cmp_fail ) begin errmsg = "b  got transaction mismatch";          errflag = 1; end
        if (ar_payld_cmp_en & ar_cmp_fail) begin errmsg = "ar got transaction mismatch";          errflag = 1; end
        if (r_payld_cmp_en  & r_cmp_fail ) begin errmsg = "r  got transaction mismatch";          errflag = 1; end
    end
end

always @(posedge aclk) begin
    if (aresetn) begin
        if (aw_payld_cmp_en & ~aw_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv aw transaction match. awid: 0x%0x, awaddr: 0x%0x, awburst: 0x%0x, awsize: 0x%0x, awlen: 0x%0x",
                     $time, s0_awid, s0_awaddr, s0_awburst, s0_awsize, s0_awlen);
        end
        if (w_payld_cmp_en  & ~w_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv w  transaction match. wid: 0x%0x, wstrb: 0x%0x, wdata: 0x%0x, wlast: 0x%0x",
                     $time, s0_wid, s0_wstrb, s0_wdata, s0_wlast);
        end
        if (b_payld_cmp_en  & ~b_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv b  transaction match. bid: 0x%0x, bresp: 0x%0x",
                     $time, b_payld_cmp[2+:10], b_payld_cmp[0+:2]);
        end
        if (ar_payld_cmp_en & ~ar_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv ar transaction match. arid: 0x%0x, araddr: 0x%0x, arburst: 0x%0x, arsize: 0x%0x, arlen: 0x%0x",
                     $time, s0_arid, s0_araddr, s0_arburst, s0_arsize, s0_arlen);
        end
        if (r_payld_cmp_en  & ~r_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv r  transaction match. rid: 0x%0x, rdata: 0x%0x, rresp: 0x%0x, rlast: 0x%0x",
                     $time, r_payld_cmp[35+:10], r_payld_cmp[3+:32], r_payld_cmp[1+:2], r_payld_cmp[0+:1]);
        end
    end
end

always @(posedge errflag) begin
    $display("[ERROR] [%0d ns] %s", $time, errmsg);
    $finish;
end

assign aw_payld_cmp_en = s0_aw_sel & (~aw_mon_fifo_empty | m0_aw_sel | m1_aw_sel);
assign aw_payld_in = m1_aw_sel ? {m1_awid, 1'b1, m1_awaddr, m1_awburst, m1_awsize, m1_awlen}:
                                 {m0_awid, 1'b0, m0_awaddr, m0_awburst, m0_awsize, m0_awlen};
assign aw_payld_cmp = {s0_awid, s0_awaddr, s0_awburst, s0_awsize, s0_awlen};
assign aw_cmp_fail  = ~aw_mon_fifo_empty ? (aw_payld_cmp !== aw_payld_out):
                                           (aw_payld_cmp !== aw_payld_in);

assign aw_mon_fifo_wr = (m0_aw_sel | m1_aw_sel) & ~(aw_mon_fifo_empty & s0_aw_sel);
assign aw_mon_fifo_rd = s0_aw_sel;

axi_mon_fifo #(
    .DATA_WIDTH(AW_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) aw_mon_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( aw_mon_fifo_wr    ),
    .wdata ( aw_payld_in       ),
    .rd    ( aw_mon_fifo_rd    ),
    .rdata ( aw_payld_out      ),
    .empty ( aw_mon_fifo_empty ),
    .full  ( aw_mon_fifo_full  )
);

assign w_payld_cmp_en = s0_w_sel & (~w_mon_fifo_empty | m0_w_sel | m1_w_sel);
assign w_payld_in = m1_w_sel ? {m1_wid, 1'b1, m1_wstrb, m1_wdata, m1_wlast}:
                               {m0_wid, 1'b0, m0_wstrb, m0_wdata, m0_wlast};
assign w_payld_cmp = {s0_wid, s0_wstrb, s0_wdata, s0_wlast};
assign w_cmp_fail  = ~w_mon_fifo_empty ? (w_payld_cmp !== w_payld_out):
                                         (w_payld_cmp !== w_payld_in);

assign w_mon_fifo_wr = (m0_w_sel | m1_w_sel) & ~(w_mon_fifo_empty & s0_w_sel);
assign w_mon_fifo_rd = s0_w_sel;

axi_mon_fifo #(
    .DATA_WIDTH(W_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) w_mon_fifo (
    .clk   ( aclk             ),
    .rstn  ( aresetn          ),
    .wr    ( w_mon_fifo_wr    ),
    .wdata ( w_payld_in       ),
    .rd    ( w_mon_fifo_rd    ),
    .rdata ( w_payld_out      ),
    .empty ( w_mon_fifo_empty ),
    .full  ( w_mon_fifo_full  )
);

assign b_payld_cmp_en = (m0_b_sel | m1_b_sel) & (~b_mon_fifo_empty | s0_b_sel);
assign b_payld_in = {s0_bid[1+:10], s0_bresp};
assign b_payld_cmp = m1_b_sel ? {m1_bid, m1_bresp}:
                                {m0_bid, m0_bresp};
assign b_cmp_fail  = ~b_mon_fifo_empty ? (b_payld_cmp !== b_payld_out):
                                         (b_payld_cmp !== b_payld_in);

assign b_mon_fifo_wr = (s0_b_sel) & ~(b_mon_fifo_empty & (m0_b_sel | m1_b_sel));
assign b_mon_fifo_rd = m0_b_sel | m1_b_sel;

axi_mon_fifo #(
    .DATA_WIDTH(B_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) b_mon_fifo (
    .clk   ( aclk             ),
    .rstn  ( aresetn          ),
    .wr    ( b_mon_fifo_wr    ),
    .wdata ( b_payld_in       ),
    .rd    ( b_mon_fifo_rd    ),
    .rdata ( b_payld_out      ),
    .empty ( b_mon_fifo_empty ),
    .full  ( b_mon_fifo_full  )
);

assign ar_payld_cmp_en = s0_ar_sel & (~ar_mon_fifo_empty | m0_ar_sel | m1_ar_sel);
assign ar_payld_in = m1_ar_sel ? {m1_arid, 1'b1, m1_araddr, m1_arburst, m1_arsize, m1_arlen}:
                                 {m0_arid, 1'b0, m0_araddr, m0_arburst, m0_arsize, m0_arlen};
assign ar_payld_cmp = {s0_arid, s0_araddr, s0_arburst, s0_arsize, s0_arlen};
assign ar_cmp_fail  = ~ar_mon_fifo_empty ? (ar_payld_cmp !== ar_payld_out):
                                           (ar_payld_cmp !== ar_payld_in);

assign ar_mon_fifo_wr = (m0_ar_sel | m1_ar_sel) & ~(ar_mon_fifo_empty & s0_ar_sel);
assign ar_mon_fifo_rd = s0_ar_sel;

axi_mon_fifo #(
    .DATA_WIDTH(AR_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) ar_mon_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( ar_mon_fifo_wr    ),
    .wdata ( ar_payld_in       ),
    .rd    ( ar_mon_fifo_rd    ),
    .rdata ( ar_payld_out      ),
    .empty ( ar_mon_fifo_empty ),
    .full  ( ar_mon_fifo_full  )
);

assign r_payld_cmp_en = (m0_r_sel | m1_r_sel) & (~r_mon_fifo_empty | s0_r_sel);
assign r_payld_in = {s0_rid[1+:10], s0_rdata, s0_rresp, s0_rlast};
assign r_payld_cmp = m1_r_sel ? {m1_rid, m1_rdata, m1_rresp, m1_rlast}:
                                {m0_rid, m0_rdata, m0_rresp, m0_rlast};
assign r_cmp_fail  = ~r_mon_fifo_empty ? (r_payld_cmp !== r_payld_out):
                                         (r_payld_cmp !== r_payld_in);

assign r_mon_fifo_wr = (s0_r_sel) & ~(r_mon_fifo_empty & (m0_r_sel | m1_r_sel));
assign r_mon_fifo_rd = m0_r_sel | m1_r_sel;

axi_mon_fifo #(
    .DATA_WIDTH(R_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) r_mon_fifo (
    .clk   ( aclk             ),
    .rstn  ( aresetn          ),
    .wr    ( r_mon_fifo_wr    ),
    .wdata ( r_payld_in       ),
    .rd    ( r_mon_fifo_rd    ),
    .rdata ( r_payld_out      ),
    .empty ( r_mon_fifo_empty ),
    .full  ( r_mon_fifo_full  )
);


endmodule

module axi_mon_fifo #(
    parameter DATA_WIDTH = 3,
    parameter FIFO_DEPTH = 128
)(
    input                         clk,
    input                         rstn,
    input                         wr,
    input        [DATA_WIDTH-1:0] wdata,
    input                         rd,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  empty,
    output logic                  full
);

logic [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];
logic [$clog2(FIFO_DEPTH):0] wptr;
logic [$clog2(FIFO_DEPTH):0] rptr;

assign empty = wptr == rptr;
assign full  = (wptr[$clog2(FIFO_DEPTH)] ^ rptr[$clog2(FIFO_DEPTH)]) &&
               (wptr[$clog2(FIFO_DEPTH)-1:0] == rptr[$clog2(FIFO_DEPTH)-1:0]);

assign rdata = fifo[rptr[0+:$clog2(FIFO_DEPTH)]];

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        wptr <= {($clog2(FIFO_DEPTH)+1){1'b0}};
        rptr <= {($clog2(FIFO_DEPTH)+1){1'b0}};
    end
    else begin
        if (wr & ~full)  wptr <= wptr + 1;
        if (rd & ~empty) rptr <= rptr + 1;
    end
end

always @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < FIFO_DEPTH; i = i + 1)
            fifo[i] <= {DATA_WIDTH{1'b0}};
    end
    else begin
        if (wr & ~full) fifo[wptr[0+:$clog2(FIFO_DEPTH)]] <= wdata;
    end
end

endmodule
