/*-----------------------------------------------------*/
// axi_1to2_mon.sv is generated by ../script/gen_axi_mon.sh
//
//                                         2021-10-14
//                                           21:32:09
/*-----------------------------------------------------*/

module axi_1to2_mon (
    input                  aclk,
    input                  aresetn,
    input         [  1: 0] m0_awburst,
    input         [  9: 0] m0_awid,
    input         [ 31: 0] m0_awaddr,
    input         [  2: 0] m0_awsize,
    input         [  7: 0] m0_awlen,
    input                  m0_awvalid,
    input                  m0_awready,
    input         [  3: 0] m0_wstrb,
    input         [  9: 0] m0_wid,
    input         [ 31: 0] m0_wdata,
    input                  m0_wlast,
    input                  m0_wvalid,
    input                  m0_wready,
    input         [  9: 0] m0_bid,
    input         [  1: 0] m0_bresp,
    input                  m0_bvalid,
    input                  m0_bready,
    input         [ 31: 0] m0_araddr,
    input         [  1: 0] m0_arburst,
    input         [  2: 0] m0_arsize,
    input         [  9: 0] m0_arid,
    input         [  7: 0] m0_arlen,
    input                  m0_arvalid,
    input                  m0_arready,
    input         [ 31: 0] m0_rdata,
    input         [  1: 0] m0_rresp,
    input         [  9: 0] m0_rid,
    input                  m0_rlast,
    input                  m0_rvalid,
    input                  m0_rready,
    input         [  1: 0] s0_awburst,
    input         [  9: 0] s0_awid,
    input         [ 31: 0] s0_awaddr,
    input         [  2: 0] s0_awsize,
    input         [  7: 0] s0_awlen,
    input                  s0_awvalid,
    input                  s0_awready,
    input         [  3: 0] s0_wstrb,
    input         [  9: 0] s0_wid,
    input         [ 31: 0] s0_wdata,
    input                  s0_wlast,
    input                  s0_wvalid,
    input                  s0_wready,
    input         [  9: 0] s0_bid,
    input         [  1: 0] s0_bresp,
    input                  s0_bvalid,
    input                  s0_bready,
    input         [ 31: 0] s0_araddr,
    input         [  1: 0] s0_arburst,
    input         [  2: 0] s0_arsize,
    input         [  9: 0] s0_arid,
    input         [  7: 0] s0_arlen,
    input                  s0_arvalid,
    input                  s0_arready,
    input         [ 31: 0] s0_rdata,
    input         [  1: 0] s0_rresp,
    input         [  9: 0] s0_rid,
    input                  s0_rlast,
    input                  s0_rvalid,
    input                  s0_rready,
    input         [  1: 0] s1_awburst,
    input         [  9: 0] s1_awid,
    input         [ 31: 0] s1_awaddr,
    input         [  2: 0] s1_awsize,
    input         [  7: 0] s1_awlen,
    input                  s1_awvalid,
    input                  s1_awready,
    input         [  3: 0] s1_wstrb,
    input         [  9: 0] s1_wid,
    input         [ 31: 0] s1_wdata,
    input                  s1_wlast,
    input                  s1_wvalid,
    input                  s1_wready,
    input         [  9: 0] s1_bid,
    input         [  1: 0] s1_bresp,
    input                  s1_bvalid,
    input                  s1_bready,
    input         [ 31: 0] s1_araddr,
    input         [  1: 0] s1_arburst,
    input         [  2: 0] s1_arsize,
    input         [  9: 0] s1_arid,
    input         [  7: 0] s1_arlen,
    input                  s1_arvalid,
    input                  s1_arready,
    input         [ 31: 0] s1_rdata,
    input         [  1: 0] s1_rresp,
    input         [  9: 0] s1_rid,
    input                  s1_rlast,
    input                  s1_rvalid,
    input                  s1_rready
);

string errmsg;
bit    errflag;

parameter AW_PAYLD_WIDTH = 0 + 2 + 10 + 32 + 3 + 8;
parameter W_PAYLD_WIDTH  = 0 + 4 + 10 + 32 + 1;
parameter B_PAYLD_WIDTH  = 10 + 2;
parameter AR_PAYLD_WIDTH = 0 + 32 + 2 + 3 + 10 + 8;
parameter R_PAYLD_WIDTH  = 32 + 2 + 10 + 1;

logic [AW_PAYLD_WIDTH - 1: 0] aw_payld_in;
logic [W_PAYLD_WIDTH - 1: 0] w_payld_in;
logic [B_PAYLD_WIDTH - 1: 0] b_payld_in;
logic [AR_PAYLD_WIDTH - 1: 0] ar_payld_in;
logic [R_PAYLD_WIDTH - 1: 0] r_payld_in;
logic [AW_PAYLD_WIDTH - 1: 0] aw_payld_out;
logic [W_PAYLD_WIDTH - 1: 0] w_payld_out;
logic [B_PAYLD_WIDTH - 1: 0] b_payld_out;
logic [AR_PAYLD_WIDTH - 1: 0] ar_payld_out;
logic [R_PAYLD_WIDTH - 1: 0] r_payld_out;
logic [AW_PAYLD_WIDTH - 1: 0] aw_payld_cmp;
logic [W_PAYLD_WIDTH - 1: 0] w_payld_cmp;
logic [B_PAYLD_WIDTH - 1: 0] b_payld_cmp;
logic [AR_PAYLD_WIDTH - 1: 0] ar_payld_cmp;
logic [R_PAYLD_WIDTH - 1: 0] r_payld_cmp;
logic          aw_mon_fifo_wr;
logic          aw_mon_fifo_rd;
logic          aw_mon_fifo_empty;
logic          aw_mon_fifo_full;
logic          w_mon_fifo_wr;
logic          w_mon_fifo_rd;
logic          w_mon_fifo_empty;
logic          w_mon_fifo_full;
logic          b_mon_fifo_wr;
logic          b_mon_fifo_rd;
logic          b_mon_fifo_empty;
logic          b_mon_fifo_full;
logic          ar_mon_fifo_wr;
logic          ar_mon_fifo_rd;
logic          ar_mon_fifo_empty;
logic          ar_mon_fifo_full;
logic          r_mon_fifo_wr;
logic          r_mon_fifo_rd;
logic          r_mon_fifo_empty;
logic          r_mon_fifo_full;
logic          aw_payld_cmp_en;
logic          w_payld_cmp_en;
logic          b_payld_cmp_en;
logic          ar_payld_cmp_en;
logic          r_payld_cmp_en;
logic          aw_cmp_fail;
logic          w_cmp_fail;
logic          b_cmp_fail;
logic          ar_cmp_fail;
logic          r_cmp_fail;
logic          m_aw_sel;
logic          m_w_sel;
logic          m_b_sel;
logic          m_ar_sel;
logic          m_r_sel;
logic [  1: 0] s_aw_sel;
logic [  1: 0] s_w_sel;
logic [  1: 0] s_b_sel;
logic [  1: 0] s_ar_sel;
logic [  1: 0] s_r_sel;
logic [  1: 0] s_wlast;
//
logic          m_wlast;
logic [  1: 0] cmp_awburst;
logic [  9: 0] cmp_awid;
logic [ 31: 0] cmp_awaddr;
logic [  2: 0] cmp_awsize;
logic [  7: 0] cmp_awlen;
logic [  3: 0] cmp_wstrb;
logic [  9: 0] cmp_wid;
logic [ 31: 0] cmp_wdata;
logic          cmp_wlast;
logic [  9: 0] cmp_bid;
logic [  1: 0] cmp_bresp;
logic [ 31: 0] cmp_araddr;
logic [  1: 0] cmp_arburst;
logic [  2: 0] cmp_arsize;
logic [  9: 0] cmp_arid;
logic [  7: 0] cmp_arlen;
logic [ 31: 0] cmp_rdata;
logic [  1: 0] cmp_rresp;
logic [  9: 0] cmp_rid;
logic          cmp_rlast;
logic [  9: 0] dfslv_awid_in;
logic [  9: 0] dfslv_awid_out;
logic [  9: 0] dfslv_arid_in;
logic [  9: 0] dfslv_arid_out;
logic [  7: 0] dfslv_arlen_in;
logic [  7: 0] dfslv_arlen_out;
logic [  1: 0] aw_slvsel_in;
logic [  1: 0] aw_slvsel_out;
logic          aw_dfslvsel_out;
logic [  1: 0] w_slvsel_in;
logic [  1: 0] w_slvsel_out;
logic          w_dfslvsel_out;
logic          b_mstsel_in;
logic          b_mstsel_out;
logic [  1: 0] ar_slvsel_in;
logic [  1: 0] ar_slvsel_out;
logic          ar_dfslvsel_out;
logic          r_mstsel_in;
logic          r_mstsel_out;
logic          r_dfslvsel_out;
logic          dfslv_rlast;
logic [  7: 0] dfslv_arlen_cnt;
//

logic          m_aw_sel_sum;
logic          m_w_sel_sum;
logic          m_b_sel_sum;
logic          m_ar_sel_sum;
logic          m_r_sel_sum;
logic [  1: 0] s_aw_sel_sum;
logic [  1: 0] s_w_sel_sum;
logic [  1: 0] s_b_sel_sum;
logic [  1: 0] s_ar_sel_sum;
logic [  1: 0] s_r_sel_sum;

assign m_aw_sel   = m0_awvalid & m0_awready;
assign m_w_sel    = m0_wvalid  & m0_wready;
assign m_b_sel    = m0_bvalid  & m0_bready;
assign m_ar_sel   = m0_arvalid & m0_arready;
assign m_r_sel    = m0_rvalid  & m0_rready;
assign m_rlast    = m0_rlast;
assign s_aw_sel  [  0] = s0_awvalid & s0_awready;
assign s_w_sel   [  0] = s0_wvalid  & s0_wready;
assign s_b_sel   [  0] = s0_bvalid  & s0_bready;
assign s_ar_sel  [  0] = s0_arvalid & s0_arready;
assign s_r_sel   [  0] = s0_rvalid  & s0_rready;
assign s_wlast   [  0] = s0_wlast;
assign s_aw_sel  [  1] = s1_awvalid & s1_awready;
assign s_w_sel   [  1] = s1_wvalid  & s1_wready;
assign s_b_sel   [  1] = s1_bvalid  & s1_bready;
assign s_ar_sel  [  1] = s1_arvalid & s1_arready;
assign s_r_sel   [  1] = s1_rvalid  & s1_rready;
assign s_wlast   [  1] = s1_wlast;

always @(*) begin
    integer i;

    m_aw_sel_sum = m_aw_sel;
    m_w_sel_sum  = m_w_sel;
    m_b_sel_sum  = m_b_sel;
    m_ar_sel_sum = m_ar_sel;
    m_r_sel_sum  = m_r_sel;

    s_aw_sel_sum = 2'b0;
    s_w_sel_sum  = 2'b0;
    s_b_sel_sum  = 2'b0;
    s_ar_sel_sum = 2'b0;
    s_r_sel_sum  = 2'b0;
    for (i = 0; i < 2; i = i + 1) begin
        s_aw_sel_sum = s_aw_sel_sum + (s_aw_sel[i] ? 2'b1 : 2'b0);
        s_w_sel_sum  = s_w_sel_sum  + (s_w_sel [i] ? 2'b1 : 2'b0);
        s_b_sel_sum  = s_b_sel_sum  + (s_b_sel [i] ? 2'b1 : 2'b0);
        s_ar_sel_sum = s_ar_sel_sum + (s_ar_sel[i] ? 2'b1 : 2'b0);
        s_r_sel_sum  = s_r_sel_sum  + (s_r_sel [i] ? 2'b1 : 2'b0);
    end
end

always @(posedge aclk) begin
    if (~aresetn) begin
        errflag = 0;
    end
    else begin
        if (aw_mon_fifo_full)              begin errmsg = "aw payld fifo full";              errflag = 1; end
        if (w_mon_fifo_full)               begin errmsg = "w  payld fifo full";              errflag = 1; end
        if (b_mon_fifo_full)               begin errmsg = "b  payld fifo full";              errflag = 1; end
        if (ar_mon_fifo_full)              begin errmsg = "ar payld fifo full";              errflag = 1; end
        if (r_mon_fifo_full)               begin errmsg = "r  payld fifo full";              errflag = 1; end
        if (m_aw_sel_sum > 1)              begin errmsg = "master aw transfer at same time"; errflag = 1; end
        if (m_w_sel_sum  > 1)              begin errmsg = "master w  transfer at same time"; errflag = 1; end
        if (m_b_sel_sum  > 1)              begin errmsg = "master b  transfer at same time"; errflag = 1; end
        if (m_ar_sel_sum > 1)              begin errmsg = "master ar transfer at same time"; errflag = 1; end
        if (m_r_sel_sum  > 1)              begin errmsg = "master ar transfer at same time"; errflag = 1; end
        if (s_aw_sel_sum > 1)              begin errmsg = "slave aw transfer at same time";  errflag = 1; end
        if (s_w_sel_sum  > 1)              begin errmsg = "slave w  transfer at same time";  errflag = 1; end
        if (s_b_sel_sum  > 1)              begin errmsg = "slave b  transfer at same time";  errflag = 1; end
        if (s_ar_sel_sum > 1)              begin errmsg = "slave ar transfer at same time";  errflag = 1; end
        if (s_r_sel_sum  > 1)              begin errmsg = "slave ar transfer at same time";  errflag = 1; end
        if (|s_aw_sel & ~aw_payld_cmp_en)  begin errmsg = "aw got transaction unexpacted";   errflag = 1; end
        if (|s_w_sel  & ~w_payld_cmp_en )  begin errmsg = "w  got transaction unexpacted";   errflag = 1; end
        if (|m_b_sel  & ~b_payld_cmp_en )  begin errmsg = "b  got transaction unexpacted";   errflag = 1; end
        if (|s_ar_sel & ~ar_payld_cmp_en)  begin errmsg = "ar got transaction unexpacted";   errflag = 1; end
        if (|m_r_sel  & ~r_payld_cmp_en )  begin errmsg = "r  got transaction unexpacted";   errflag = 1; end
        if (aw_payld_cmp_en & aw_cmp_fail) begin errmsg = "aw got transaction mismatch";     errflag = 1; end
        if (w_payld_cmp_en  & w_cmp_fail ) begin errmsg = "w  got transaction mismatch";     errflag = 1; end
        if (b_payld_cmp_en  & b_cmp_fail ) begin errmsg = "b  got transaction mismatch";     errflag = 1; end
        if (ar_payld_cmp_en & ar_cmp_fail) begin errmsg = "ar got transaction mismatch";     errflag = 1; end
        if (r_payld_cmp_en  & r_cmp_fail ) begin errmsg = "r  got transaction mismatch";     errflag = 1; end
    end
end

always @(posedge errflag) begin
    $display("[ERROR] [%0d ns] %s", $time, errmsg);
    $finish;
end

always @(posedge aclk) begin
    if (aresetn) begin
        if (aw_payld_cmp_en & ~aw_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv aw transaction match. awid: 0x%0x, awaddr: 0x%0x, awburst: 0x%0x, awsize: 0x%0x, awlen: 0x%0x",
                     $time, cmp_awid, cmp_awaddr, cmp_awburst, cmp_awsize, cmp_awlen);
        end
        if (w_payld_cmp_en  & ~w_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv w  transaction match. wid: 0x%0x, wstrb: 0x%0x, wdata: 0x%0x, wlast: 0x%0x",
                     $time, cmp_wid, cmp_wstrb, cmp_wdata, cmp_wlast);
        end
        if (b_payld_cmp_en  & ~b_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv b  transaction match. bid: 0x%0x, bresp: 0x%0x",
                     $time, cmp_bid, cmp_bresp);
        end
        if (ar_payld_cmp_en & ~ar_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv ar transaction match. arid: 0x%0x, araddr: 0x%0x, arburst: 0x%0x, arsize: 0x%0x, arlen: 0x%0x",
                     $time, cmp_arid, cmp_araddr, cmp_arburst, cmp_arsize, cmp_arlen);
        end
        if (r_payld_cmp_en  & ~r_cmp_fail) begin
            $display("[INFO] [%0d ns] mst & slv r  transaction match. rid: 0x%0x, rdata: 0x%0x, rresp: 0x%0x, rlast: 0x%0x",
                     $time, cmp_rid, cmp_rdata, cmp_rresp, cmp_rlast);
        end
    end
end


// AW channel monitor
assign aw_payld_cmp_en = |(s_aw_sel & (~aw_mon_fifo_empty ? aw_slvsel_out : ({2{|m_aw_sel}} & aw_slvsel_in)));
assign aw_payld_cmp = s_aw_sel[  0] ? {s0_awburst, s0_awid, s0_awaddr, s0_awsize, s0_awlen}:
                      s_aw_sel[  1] ? {s1_awburst, s1_awid, s1_awaddr, s1_awsize, s1_awlen}:
                                      {AW_PAYLD_WIDTH{1'b0}};
assign {cmp_awburst, cmp_awid, cmp_awaddr, cmp_awsize, cmp_awlen} = aw_payld_cmp;
assign aw_payld_in = m_aw_sel ? {m0_awburst, m0_awid, m0_awaddr, m0_awsize, m0_awlen}:
                                {AW_PAYLD_WIDTH{1'b0}};
assign aw_slvsel_in[  0] = m_aw_sel ? (m0_awaddr >= 32'h0_0000 && m0_awaddr < 32'h0_0000 + 32'h1_0000):
                                      1'b0;
assign aw_slvsel_in[  1] = m_aw_sel ? (m0_awaddr >= 32'h1_0000 && m0_awaddr < 32'h1_0000 + 32'h1_0000):
                                      1'b0;
assign dfslv_awid_in = m_aw_sel ? m0_awid:
                                  10'b0;
assign aw_cmp_fail  = ~aw_mon_fifo_empty ? (aw_payld_cmp !== aw_payld_out):
                                           (aw_payld_cmp !== aw_payld_in);

assign aw_mon_fifo_wr = |m_aw_sel & ~(aw_mon_fifo_empty & (|s_aw_sel | ~|aw_slvsel_in));
assign aw_mon_fifo_rd = |s_aw_sel | aw_dfslvsel_out;

axi_mon_fifo #(
    .DATA_WIDTH(AW_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) u_aw_mon_payld_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( aw_mon_fifo_wr    ),
    .wdata ( aw_payld_in       ),
    .rd    ( aw_mon_fifo_rd    ),
    .rdata ( aw_payld_out      ),
    .empty ( aw_mon_fifo_empty ),
    .full  ( aw_mon_fifo_full  )
);

axi_mon_fifo #(
    .DATA_WIDTH(2 + 1),
    .FIFO_DEPTH(128)
) u_aw_mon_slvsel_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( aw_mon_fifo_wr    ),
    .wdata ( {~|aw_slvsel_in, aw_slvsel_in} ),
    .rd    ( aw_mon_fifo_rd    ),
    .rdata ( {aw_dfslvsel_out, aw_slvsel_out} )
);

axi_mon_fifo #(
    .DATA_WIDTH(10 + 0),
    .FIFO_DEPTH(128)
) u_aw_mon_dfslv_awid_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( |m_aw_sel & ~|aw_slvsel_in ),
    .wdata ( dfslv_awid_in     ),
    .rd    ( |m_b_sel & w_dfslvsel_out ),
    .rdata ( dfslv_awid_out    )
);

// W channel monitor
assign w_payld_cmp_en = |(s_w_sel & w_slvsel_out);
assign w_payld_cmp  = s_w_sel[  0] ? {s0_wstrb, s0_wid, s0_wdata, s0_wlast}:
                      s_w_sel[  1] ? {s1_wstrb, s1_wid, s1_wdata, s1_wlast}:
                                     {W_PAYLD_WIDTH{1'b0}};
assign {cmp_wstrb, cmp_wid, cmp_wdata, cmp_wlast} = w_payld_cmp;
assign w_payld_in  = m_w_sel ? {m0_wstrb, m0_wid, m0_wdata, m0_wlast}:
                               {W_PAYLD_WIDTH{1'b0}};
assign w_cmp_fail  = ~w_mon_fifo_empty ? (w_payld_cmp !== w_payld_out):
                                         (w_payld_cmp !== w_payld_in);

assign w_mon_fifo_wr = (|m_w_sel & ~(w_mon_fifo_empty & (|s_w_sel | w_dfslvsel_out)));
assign w_mon_fifo_rd = |s_w_sel;

axi_mon_fifo #(
    .DATA_WIDTH(W_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) u_w_mon_payld_fifo (
    .clk   ( aclk             ),
    .rstn  ( aresetn          ),
    .wr    ( w_mon_fifo_wr    ),
    .wdata ( w_payld_in       ),
    .rd    ( w_mon_fifo_rd    ),
    .rdata ( w_payld_out      ),
    .empty ( w_mon_fifo_empty ),
    .full  ( w_mon_fifo_full  )
);

axi_mon_fifo #(
    .DATA_WIDTH(2 + 1),
    .FIFO_DEPTH(128)
) u_w_mon_slvsel_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( |m_aw_sel         ),
    .wdata ( {~|aw_slvsel_in, aw_slvsel_in} ),
    .rd    ( |m_b_sel          ),
    .rdata ( {w_dfslvsel_out, w_slvsel_out} )
);

// B channel monitor
assign b_payld_cmp_en = |(m_b_sel & (~b_mon_fifo_empty ? b_mstsel_out:
                                     |s_b_sel          ? b_mstsel_in:
                                     w_dfslvsel_out    ? (1'b1):
                                                         1'b0));
assign b_payld_cmp  = m_b_sel ? {m0_bid, m0_bresp}:
                                {B_PAYLD_WIDTH{1'b0}};
assign {cmp_bid, cmp_bresp} = b_payld_cmp;
assign b_payld_in  = s_b_sel[  0] ? {s0_bid, s0_bresp}:
                     s_b_sel[  1] ? {s1_bid, s1_bresp}:
                                    {dfslv_awid_out, 2'b11};
assign b_mstsel_in = s_b_sel[  0] ? 1'b1:
                     s_b_sel[  1] ? 1'b1:
                                    1'b1;
assign b_cmp_fail  = ~b_mon_fifo_empty ? (b_payld_cmp !== b_payld_out):
                                         (b_payld_cmp !== b_payld_in);

assign b_mon_fifo_wr = (|s_b_sel & ~(b_mon_fifo_empty & |m_b_sel)) & ~w_dfslvsel_out;
assign b_mon_fifo_rd = |m_b_sel & ~w_dfslvsel_out;

axi_mon_fifo #(
    .DATA_WIDTH(B_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) u_b_mon_payld_fifo (
    .clk   ( aclk             ),
    .rstn  ( aresetn          ),
    .wr    ( b_mon_fifo_wr    ),
    .wdata ( b_payld_in       ),
    .rd    ( b_mon_fifo_rd    ),
    .rdata ( b_payld_out      ),
    .empty ( b_mon_fifo_empty ),
    .full  ( b_mon_fifo_full  )
);

axi_mon_fifo #(
    .DATA_WIDTH(1),
    .FIFO_DEPTH(128)
) u_b_mon_mstsel_fifo (
    .clk   ( aclk          ),
    .rstn  ( aresetn       ),
    .wr    ( b_mon_fifo_wr ),
    .wdata ( b_mstsel_in   ),
    .rd    ( b_mon_fifo_rd ),
    .rdata ( b_mstsel_out  )
);

// AR channel monitor
assign ar_payld_cmp_en = |(s_ar_sel & (~ar_mon_fifo_empty ? ar_slvsel_out : ({2{|m_ar_sel}} & ar_slvsel_in)));
assign ar_payld_cmp = s_ar_sel[  0] ? {s0_araddr, s0_arburst, s0_arsize, s0_arid, s0_arlen}:
                      s_ar_sel[  1] ? {s1_araddr, s1_arburst, s1_arsize, s1_arid, s1_arlen}:
                                      {AR_PAYLD_WIDTH{1'b0}};
assign {cmp_araddr, cmp_arburst, cmp_arsize, cmp_arid, cmp_arlen} = ar_payld_cmp;
assign ar_payld_in = m_ar_sel ? {m0_araddr, m0_arburst, m0_arsize, m0_arid, m0_arlen}:
                                {AR_PAYLD_WIDTH{1'b0}};
assign ar_slvsel_in[  0] = m_ar_sel ? (m0_araddr >= 32'h0_0000 && m0_araddr < 32'h0_0000 + 32'h1_0000):
                                      1'b0;
assign ar_slvsel_in[  1] = m_ar_sel ? (m0_araddr >= 32'h1_0000 && m0_araddr < 32'h1_0000 + 32'h1_0000):
                                      1'b0;
assign dfslv_arid_in = m_ar_sel ? m0_arid:
                                  10'b0;
assign dfslv_arlen_in = m_ar_sel ? m0_arlen:
                                   8'b0;
assign ar_cmp_fail  = ~ar_mon_fifo_empty ? (ar_payld_cmp !== ar_payld_out):
                                           (ar_payld_cmp !== ar_payld_in);

assign ar_mon_fifo_wr = |m_ar_sel & ~(ar_mon_fifo_empty & (|s_ar_sel | ~|ar_slvsel_in));
assign ar_mon_fifo_rd = |s_ar_sel | ar_dfslvsel_out;

axi_mon_fifo #(
    .DATA_WIDTH(AR_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) u_ar_mon_payld_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( ar_mon_fifo_wr    ),
    .wdata ( ar_payld_in       ),
    .rd    ( ar_mon_fifo_rd    ),
    .rdata ( ar_payld_out      ),
    .empty ( ar_mon_fifo_empty ),
    .full  ( ar_mon_fifo_full  )
);

axi_mon_fifo #(
    .DATA_WIDTH(2 + 1),
    .FIFO_DEPTH(128)
) u_ar_mon_slvsel_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( ar_mon_fifo_wr    ),
    .wdata ( {~|ar_slvsel_in, ar_slvsel_in} ),
    .rd    ( ar_mon_fifo_rd    ),
    .rdata ( {ar_dfslvsel_out, ar_slvsel_out} )
);

axi_mon_fifo #(
    .DATA_WIDTH(10 + 0),
    .FIFO_DEPTH(128)
) u_ar_mon_dfslv_arid_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( |m_ar_sel & ~|ar_slvsel_in ),
    .wdata ( dfslv_arid_in     ),
    .rd    ( |(m_r_sel & m_rlast) & r_dfslvsel_out ),
    .rdata ( dfslv_arid_out    )
);

axi_mon_fifo #(
    .DATA_WIDTH(8),
    .FIFO_DEPTH(128)
) u_ar_mon_dfslv_arlen_fifo (
    .clk   ( aclk              ),
    .rstn  ( aresetn           ),
    .wr    ( |m_ar_sel & ~|ar_slvsel_in ),
    .wdata ( dfslv_arlen_in     ),
    .rd    ( |(m_r_sel & m_rlast) & r_dfslvsel_out ),
    .rdata ( dfslv_arlen_out    )
);

// R channel monitor
assign r_payld_cmp_en = |(m_r_sel & (~r_mon_fifo_empty ? r_mstsel_out:
                                     |s_r_sel          ? r_mstsel_in:
                                     r_dfslvsel_out    ? (1'b1):
                                                         1'b0));
assign r_payld_cmp  = m_r_sel ? {m0_rdata, m0_rresp, m0_rid, m0_rlast}:
                                {R_PAYLD_WIDTH{1'b0}};
assign {cmp_rdata, cmp_rresp, cmp_rid, cmp_rlast} = r_payld_cmp;
assign r_payld_in  = s_r_sel[  0] ? {s0_rdata, s0_rresp, s0_rid, s0_rlast}:
                     s_r_sel[  1] ? {s1_rdata, s1_rresp, s1_rid, s1_rlast}:
                                    {32'b0, 2'b11, dfslv_arid_out, dfslv_rlast};
assign r_mstsel_in = s_r_sel[  0] ? 1'b1:
                     s_r_sel[  1] ? 1'b1:
                                    1'b1;
assign r_cmp_fail  = ~r_mon_fifo_empty ? (r_payld_cmp !== r_payld_out):
                                         (r_payld_cmp !== r_payld_in);

assign r_mon_fifo_wr = (|s_r_sel & ~(r_mon_fifo_empty & |m_r_sel)) & ~r_dfslvsel_out;
assign r_mon_fifo_rd = |m_r_sel & ~r_dfslvsel_out;

assign dfslv_rlast = dfslv_arlen_out == dfslv_arlen_cnt;

always @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
	    dfslv_arlen_cnt <= 8'b0;
	end
	else begin
	    if (r_dfslvsel_out) begin
	        if (m_r_sel) begin
	            dfslv_arlen_cnt <= m_rlast ? 8'b0 : (dfslv_arlen_cnt + 8'b1);
			end
		end
	end
end

axi_mon_fifo #(
    .DATA_WIDTH(R_PAYLD_WIDTH),
    .FIFO_DEPTH(128)
) u_r_mon_payld_fifo (
    .clk   ( aclk             ),
    .rstn  ( aresetn          ),
    .wr    ( r_mon_fifo_wr    ),
    .wdata ( r_payld_in       ),
    .rd    ( r_mon_fifo_rd    ),
    .rdata ( r_payld_out      ),
    .empty ( r_mon_fifo_empty ),
    .full  ( r_mon_fifo_full  )
);

axi_mon_fifo #(
    .DATA_WIDTH(1),
    .FIFO_DEPTH(128)
) u_r_mon_mstsel_fifo (
    .clk   ( aclk          ),
    .rstn  ( aresetn       ),
    .wr    ( r_mon_fifo_wr ),
    .wdata ( r_mstsel_in   ),
    .rd    ( r_mon_fifo_rd ),
    .rdata ( r_mstsel_out  )
);

axi_mon_fifo #(
    .DATA_WIDTH(1),
    .FIFO_DEPTH(128)
) u_r_mon_dfslvsel_fifo (
    .clk   ( aclk           ),
    .rstn  ( aresetn        ),
    .wr    ( |m_ar_sel      ),
    .wdata ( ~|ar_slvsel_in ),
    .rd    ( |(m_r_sel & m_rlast) ),
    .rdata ( r_dfslvsel_out )
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
logic [(FIFO_DEPTH):0] wptr;
logic [(FIFO_DEPTH):0] rptr;

assign empty = wptr == rptr;
assign full  = (wptr[(FIFO_DEPTH)] ^ rptr[(FIFO_DEPTH)]) &&
               (wptr[(FIFO_DEPTH)-1:0] == rptr[(FIFO_DEPTH)-1:0]);

assign rdata = fifo[rptr[0+:(FIFO_DEPTH)]];

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        wptr <= {((FIFO_DEPTH)+1){1'b0}};
        rptr <= {((FIFO_DEPTH)+1){1'b0}};
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
        if (wr & ~full) fifo[wptr[0+:(FIFO_DEPTH)]] <= wdata;
    end
end

endmodule
