/*-----------------------------------------------------*/
// axi_1to4_dec.sv is generated by ./../../script/gen_axi_dec.sh
//
//                                         2021-12-03
//                                           22:13:57
/*-----------------------------------------------------*/

module axi_1to4_dec (
    input                  aclk,
    input                  aresetn,
    input         [  1: 0] s_awburst,
    input         [ 12: 0] s_awid,
    input         [ 31: 0] s_awaddr,
    input         [  2: 0] s_awsize,
    input         [  7: 0] s_awlen,
    input                  s_awvalid,
    output logic           s_awready,
    input         [  3: 0] s_wstrb,
    input         [ 12: 0] s_wid,
    input         [ 31: 0] s_wdata,
    input                  s_wlast,
    input                  s_wvalid,
    output logic           s_wready,
    output logic  [ 12: 0] s_bid,
    output logic  [  1: 0] s_bresp,
    output logic           s_bvalid,
    input                  s_bready,
    input         [ 31: 0] s_araddr,
    input         [  1: 0] s_arburst,
    input         [  2: 0] s_arsize,
    input         [ 12: 0] s_arid,
    input         [  7: 0] s_arlen,
    input                  s_arvalid,
    output logic           s_arready,
    output logic  [ 31: 0] s_rdata,
    output logic  [  1: 0] s_rresp,
    output logic  [ 12: 0] s_rid,
    output logic           s_rlast,
    output logic           s_rvalid,
    input                  s_rready,
    output logic  [  1: 0] m0_awburst,
    output logic  [ 12: 0] m0_awid,
    output logic  [ 31: 0] m0_awaddr,
    output logic  [  2: 0] m0_awsize,
    output logic  [  7: 0] m0_awlen,
    output logic           m0_awvalid,
    input                  m0_awready,
    output logic  [  3: 0] m0_wstrb,
    output logic  [ 12: 0] m0_wid,
    output logic  [ 31: 0] m0_wdata,
    output logic           m0_wlast,
    output logic           m0_wvalid,
    input                  m0_wready,
    input         [ 12: 0] m0_bid,
    input         [  1: 0] m0_bresp,
    input                  m0_bvalid,
    output logic           m0_bready,
    output logic  [ 31: 0] m0_araddr,
    output logic  [  1: 0] m0_arburst,
    output logic  [  2: 0] m0_arsize,
    output logic  [ 12: 0] m0_arid,
    output logic  [  7: 0] m0_arlen,
    output logic           m0_arvalid,
    input                  m0_arready,
    input         [ 31: 0] m0_rdata,
    input         [  1: 0] m0_rresp,
    input         [ 12: 0] m0_rid,
    input                  m0_rlast,
    input                  m0_rvalid,
    output logic           m0_rready,
    output logic  [  1: 0] m1_awburst,
    output logic  [ 12: 0] m1_awid,
    output logic  [ 31: 0] m1_awaddr,
    output logic  [  2: 0] m1_awsize,
    output logic  [  7: 0] m1_awlen,
    output logic           m1_awvalid,
    input                  m1_awready,
    output logic  [  3: 0] m1_wstrb,
    output logic  [ 12: 0] m1_wid,
    output logic  [ 31: 0] m1_wdata,
    output logic           m1_wlast,
    output logic           m1_wvalid,
    input                  m1_wready,
    input         [ 12: 0] m1_bid,
    input         [  1: 0] m1_bresp,
    input                  m1_bvalid,
    output logic           m1_bready,
    output logic  [ 31: 0] m1_araddr,
    output logic  [  1: 0] m1_arburst,
    output logic  [  2: 0] m1_arsize,
    output logic  [ 12: 0] m1_arid,
    output logic  [  7: 0] m1_arlen,
    output logic           m1_arvalid,
    input                  m1_arready,
    input         [ 31: 0] m1_rdata,
    input         [  1: 0] m1_rresp,
    input         [ 12: 0] m1_rid,
    input                  m1_rlast,
    input                  m1_rvalid,
    output logic           m1_rready,
    output logic  [  1: 0] m2_awburst,
    output logic  [ 12: 0] m2_awid,
    output logic  [ 31: 0] m2_awaddr,
    output logic  [  2: 0] m2_awsize,
    output logic  [  7: 0] m2_awlen,
    output logic           m2_awvalid,
    input                  m2_awready,
    output logic  [  3: 0] m2_wstrb,
    output logic  [ 12: 0] m2_wid,
    output logic  [ 31: 0] m2_wdata,
    output logic           m2_wlast,
    output logic           m2_wvalid,
    input                  m2_wready,
    input         [ 12: 0] m2_bid,
    input         [  1: 0] m2_bresp,
    input                  m2_bvalid,
    output logic           m2_bready,
    output logic  [ 31: 0] m2_araddr,
    output logic  [  1: 0] m2_arburst,
    output logic  [  2: 0] m2_arsize,
    output logic  [ 12: 0] m2_arid,
    output logic  [  7: 0] m2_arlen,
    output logic           m2_arvalid,
    input                  m2_arready,
    input         [ 31: 0] m2_rdata,
    input         [  1: 0] m2_rresp,
    input         [ 12: 0] m2_rid,
    input                  m2_rlast,
    input                  m2_rvalid,
    output logic           m2_rready,
    output logic  [  1: 0] m3_awburst,
    output logic  [ 12: 0] m3_awid,
    output logic  [ 31: 0] m3_awaddr,
    output logic  [  2: 0] m3_awsize,
    output logic  [  7: 0] m3_awlen,
    output logic           m3_awvalid,
    input                  m3_awready,
    output logic  [  3: 0] m3_wstrb,
    output logic  [ 12: 0] m3_wid,
    output logic  [ 31: 0] m3_wdata,
    output logic           m3_wlast,
    output logic           m3_wvalid,
    input                  m3_wready,
    input         [ 12: 0] m3_bid,
    input         [  1: 0] m3_bresp,
    input                  m3_bvalid,
    output logic           m3_bready,
    output logic  [ 31: 0] m3_araddr,
    output logic  [  1: 0] m3_arburst,
    output logic  [  2: 0] m3_arsize,
    output logic  [ 12: 0] m3_arid,
    output logic  [  7: 0] m3_arlen,
    output logic           m3_arvalid,
    input                  m3_arready,
    input         [ 31: 0] m3_rdata,
    input         [  1: 0] m3_rresp,
    input         [ 12: 0] m3_rid,
    input                  m3_rlast,
    input                  m3_rvalid,
    output logic           m3_rready
);

logic [  1: 0] m_awburst  [0:   4];
logic [ 12: 0] m_awid     [0:   4];
logic [ 31: 0] m_awaddr   [0:   4];
logic [  2: 0] m_awsize   [0:   4];
logic [  7: 0] m_awlen    [0:   4];
logic [  3: 0] m_wstrb    [0:   4];
logic [ 12: 0] m_wid      [0:   4];
logic [ 31: 0] m_wdata    [0:   4];
logic [ 12: 0] m_bid      [0:   4];
logic [  1: 0] m_bresp    [0:   4];
logic [ 31: 0] m_araddr   [0:   4];
logic [  1: 0] m_arburst  [0:   4];
logic [  2: 0] m_arsize   [0:   4];
logic [ 12: 0] m_arid     [0:   4];
logic [  7: 0] m_arlen    [0:   4];
logic [ 31: 0] m_rdata    [0:   4];
logic [  1: 0] m_rresp    [0:   4];
logic [ 12: 0] m_rid      [0:   4];

logic [  4: 0] m_arvalid;
logic [  4: 0] m_arready;
logic [  4: 0] m_rlast;
logic [  4: 0] m_rvalid;
logic [  4: 0] m_rready;
logic [  4: 0] m_awvalid;
logic [  4: 0] m_awready;
logic [  4: 0] m_wlast;
logic [  4: 0] m_wvalid;
logic [  4: 0] m_wready;
logic [  4: 0] m_bvalid;
logic [  4: 0] m_bready;

assign m0_awburst = m_awburst [0];
assign m0_awid    = m_awid    [0];
assign m0_awaddr  = m_awaddr  [0];
assign m0_awsize  = m_awsize  [0];
assign m0_awlen   = m_awlen   [0];
assign m0_wstrb   = m_wstrb   [0];
assign m0_wid     = m_wid     [0];
assign m0_wdata   = m_wdata   [0];
assign m0_araddr  = m_araddr  [0];
assign m0_arburst = m_arburst [0];
assign m0_arsize  = m_arsize  [0];
assign m0_arid    = m_arid    [0];
assign m0_arlen   = m_arlen   [0];
assign m1_awburst = m_awburst [1];
assign m1_awid    = m_awid    [1];
assign m1_awaddr  = m_awaddr  [1];
assign m1_awsize  = m_awsize  [1];
assign m1_awlen   = m_awlen   [1];
assign m1_wstrb   = m_wstrb   [1];
assign m1_wid     = m_wid     [1];
assign m1_wdata   = m_wdata   [1];
assign m1_araddr  = m_araddr  [1];
assign m1_arburst = m_arburst [1];
assign m1_arsize  = m_arsize  [1];
assign m1_arid    = m_arid    [1];
assign m1_arlen   = m_arlen   [1];
assign m2_awburst = m_awburst [2];
assign m2_awid    = m_awid    [2];
assign m2_awaddr  = m_awaddr  [2];
assign m2_awsize  = m_awsize  [2];
assign m2_awlen   = m_awlen   [2];
assign m2_wstrb   = m_wstrb   [2];
assign m2_wid     = m_wid     [2];
assign m2_wdata   = m_wdata   [2];
assign m2_araddr  = m_araddr  [2];
assign m2_arburst = m_arburst [2];
assign m2_arsize  = m_arsize  [2];
assign m2_arid    = m_arid    [2];
assign m2_arlen   = m_arlen   [2];
assign m3_awburst = m_awburst [3];
assign m3_awid    = m_awid    [3];
assign m3_awaddr  = m_awaddr  [3];
assign m3_awsize  = m_awsize  [3];
assign m3_awlen   = m_awlen   [3];
assign m3_wstrb   = m_wstrb   [3];
assign m3_wid     = m_wid     [3];
assign m3_wdata   = m_wdata   [3];
assign m3_araddr  = m_araddr  [3];
assign m3_arburst = m_arburst [3];
assign m3_arsize  = m_arsize  [3];
assign m3_arid    = m_arid    [3];
assign m3_arlen   = m_arlen   [3];

assign m_bid     [0] = m0_bid;
assign m_bresp   [0] = m0_bresp;
assign m_rdata   [0] = m0_rdata;
assign m_rresp   [0] = m0_rresp;
assign m_rid     [0] = m0_rid;
assign m_bid     [1] = m1_bid;
assign m_bresp   [1] = m1_bresp;
assign m_rdata   [1] = m1_rdata;
assign m_rresp   [1] = m1_rresp;
assign m_rid     [1] = m1_rid;
assign m_bid     [2] = m2_bid;
assign m_bresp   [2] = m2_bresp;
assign m_rdata   [2] = m2_rdata;
assign m_rresp   [2] = m2_rresp;
assign m_rid     [2] = m2_rid;
assign m_bid     [3] = m3_bid;
assign m_bresp   [3] = m3_bresp;
assign m_rdata   [3] = m3_rdata;
assign m_rresp   [3] = m3_rresp;
assign m_rid     [3] = m3_rid;

assign m0_arvalid = m_arvalid [0];
assign m0_awvalid = m_awvalid [0];
assign m0_wvalid  = m_wvalid  [0];
assign m0_wlast   = m_wlast   [0];
assign m0_bready  = m_bready  [0];
assign m0_rready  = m_rready  [0];
assign m1_arvalid = m_arvalid [1];
assign m1_awvalid = m_awvalid [1];
assign m1_wvalid  = m_wvalid  [1];
assign m1_wlast   = m_wlast   [1];
assign m1_bready  = m_bready  [1];
assign m1_rready  = m_rready  [1];
assign m2_arvalid = m_arvalid [2];
assign m2_awvalid = m_awvalid [2];
assign m2_wvalid  = m_wvalid  [2];
assign m2_wlast   = m_wlast   [2];
assign m2_bready  = m_bready  [2];
assign m2_rready  = m_rready  [2];
assign m3_arvalid = m_arvalid [3];
assign m3_awvalid = m_awvalid [3];
assign m3_wvalid  = m_wvalid  [3];
assign m3_wlast   = m_wlast   [3];
assign m3_bready  = m_bready  [3];
assign m3_rready  = m_rready  [3];

assign m_arready [0] = m0_arready;
assign m_awready [0] = m0_awready;
assign m_wready  [0] = m0_wready;
assign m_bvalid  [0] = m0_bvalid;
assign m_rlast   [0] = m0_rlast;
assign m_rvalid  [0] = m0_rvalid;
assign m_arready [1] = m1_arready;
assign m_awready [1] = m1_awready;
assign m_wready  [1] = m1_wready;
assign m_bvalid  [1] = m1_bvalid;
assign m_rlast   [1] = m1_rlast;
assign m_rvalid  [1] = m1_rvalid;
assign m_arready [2] = m2_arready;
assign m_awready [2] = m2_awready;
assign m_wready  [2] = m2_wready;
assign m_bvalid  [2] = m2_bvalid;
assign m_rlast   [2] = m2_rlast;
assign m_rvalid  [2] = m2_rvalid;
assign m_arready [3] = m3_arready;
assign m_awready [3] = m3_awready;
assign m_wready  [3] = m3_wready;
assign m_bvalid  [3] = m3_bvalid;
assign m_rlast   [3] = m3_rlast;
assign m_rvalid  [3] = m3_rvalid;

logic [  4: 0] awsel;
logic [  4: 0] wsel;
logic [  4: 0] bsel;
logic [  4: 0] arsel;
logic [  4: 0] rsel;

logic          b_fifo_wr;
logic          b_fifo_rd;
logic          b_fifo_empty;
logic          b_fifo_full;
logic          r_fifo_wr;
logic          r_fifo_rd;
logic          r_fifo_empty;
logic          r_fifo_full;

assign awsel[  0] = s_awaddr >= 32'h0000_0000 && s_awaddr < 32'h0000_0000 + 32'h0001_0000;
assign awsel[  1] = s_awaddr >= 32'h0001_0000 && s_awaddr < 32'h0001_0000 + 32'h0001_0000;
assign awsel[  2] = s_awaddr >= 32'h0400_0000 && s_awaddr < 32'h0400_0000 + 32'h0c00_0000;
assign awsel[  3] = s_awaddr >= 32'h1000_0000 && s_awaddr < 32'h1000_0000 + 32'h0000_1000;
assign awsel[  4] = ~|awsel[3:0]; // default slv

assign arsel[  0] = s_araddr >= 32'h0000_0000 && s_araddr < 32'h0000_0000 + 32'h0001_0000;
assign arsel[  1] = s_araddr >= 32'h0001_0000 && s_araddr < 32'h0001_0000 + 32'h0001_0000;
assign arsel[  2] = s_araddr >= 32'h0400_0000 && s_araddr < 32'h0400_0000 + 32'h0c00_0000;
assign arsel[  3] = s_araddr >= 32'h1000_0000 && s_araddr < 32'h1000_0000 + 32'h0000_1000;
assign arsel[  4] = ~|arsel[3:0]; // default slv

assign b_fifo_wr = s_awvalid & s_awready;
assign b_fifo_rd = s_bvalid  & s_bready;

assign r_fifo_wr = s_arvalid & s_arready;
assign r_fifo_rd = s_rlast  & s_rvalid & s_rready;

axi_dec_fifo u_b_fifo (
    .clk           ( aclk       ),
    .rstn          ( aresetn    ),
    .wr            ( b_fifo_wr  ),
    .wdata         ( awsel      ),
    .rd            ( b_fifo_rd  ),
    .rdata         ( bsel       ),
    .empty         ( b_fifo_empty ),
    .full          ( b_fifo_full )
);

axi_dec_fifo u_r_fifo (
    .clk           ( aclk       ),
    .rstn          ( aresetn    ),
    .wr            ( r_fifo_wr  ),
    .wdata         ( arsel      ),
    .rd            ( r_fifo_rd  ),
    .rdata         ( rsel       ),
    .empty         ( r_fifo_empty ),
    .full          ( r_fifo_full )
);

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        wsel <= 5'b0;
    end
    else begin
        if (s_awvalid & s_awready & ~|wsel) begin
            wsel <= awsel;
        end
        else if (s_wlast & s_wvalid & s_wready) begin
            wsel <= 5'b0;
        end
    end
end

always_comb begin
    integer i;

    for (i = 0; i <= 4; i = i + 1) begin
        m_awburst [i] = {    2{awsel[i]}} & s_awburst;
        m_awid    [i] = {   13{awsel[i]}} & s_awid;
        m_awaddr  [i] = {   32{awsel[i]}} & s_awaddr;
        m_awsize  [i] = {    3{awsel[i]}} & s_awsize;
        m_awlen   [i] = {    8{awsel[i]}} & s_awlen;

        m_wstrb   [i] = {    4{ wsel[i]}} & s_wstrb;
        m_wid     [i] = {   13{ wsel[i]}} & s_wid;
        m_wdata   [i] = {   32{ wsel[i]}} & s_wdata;

        m_araddr  [i] = {   32{arsel[i]}} & s_araddr;
        m_arburst [i] = {    2{arsel[i]}} & s_arburst;
        m_arsize  [i] = {    3{arsel[i]}} & s_arsize;
        m_arid    [i] = {   13{arsel[i]}} & s_arid;
        m_arlen   [i] = {    8{arsel[i]}} & s_arlen;
    end
end

always_comb begin
    integer i;

    s_bid      =  13'b0;
    s_bresp    =   2'b0;

    s_rdata    =  32'b0;
    s_rresp    =   2'b0;
    s_rid      =  13'b0;
    for (i = 0; i <= 4; i = i + 1) begin
        s_bid      = s_bid      | ({   13{bsel[i]}} & m_bid     [i]);
        s_bresp    = s_bresp    | ({    2{bsel[i]}} & m_bresp   [i]);

        s_rdata    = s_rdata    | ({   32{rsel[i]}} & m_rdata   [i]);
        s_rresp    = s_rresp    | ({    2{rsel[i]}} & m_rresp   [i]);
        s_rid      = s_rid      | ({   13{rsel[i]}} & m_rid     [i]);
    end
end

assign m_awvalid = awsel & {5{s_awvalid & ~b_fifo_full}};
assign s_awready = |(awsel & m_awready) & ~b_fifo_full;

assign m_wlast   = wsel & {5{s_wlast }};
assign m_wvalid  = wsel & {5{s_wvalid}};
assign s_wready  = |(wsel  & m_wready );

assign s_bvalid  = |(bsel  & m_bvalid) & ~b_fifo_empty;
assign m_bready  = bsel & {5{s_bready}};

assign m_arvalid = arsel & {5{s_arvalid & ~r_fifo_full}};
assign s_arready = |(arsel & m_arready) & ~r_fifo_full;

assign s_rlast   = |(rsel  & m_rlast ) & ~r_fifo_empty;
assign s_rvalid  = |(rsel  & m_rvalid) & ~r_fifo_empty;
assign m_rready  = rsel & {5{s_rready}};

axi_dfslv u_axi_dfslv (
    .aclk          ( aclk       ),
    .aresetn       ( aresetn    ),
    .s_awburst     ( m_awburst[4] ),
    .s_awid        ( m_awid[4]  ),
    .s_awaddr      ( m_awaddr[4] ),
    .s_awsize      ( m_awsize[4] ),
    .s_awlen       ( m_awlen[4] ),
    .s_awvalid     ( m_awvalid[4] ),
    .s_awready     ( m_awready[4] ),
    .s_wstrb       ( m_wstrb[4] ),
    .s_wid         ( m_wid[4]   ),
    .s_wdata       ( m_wdata[4] ),
    .s_wlast       ( m_wlast[4] ),
    .s_wvalid      ( m_wvalid[4] ),
    .s_wready      ( m_wready[4] ),
    .s_bid         ( m_bid[4]   ),
    .s_bresp       ( m_bresp[4] ),
    .s_bvalid      ( m_bvalid[4] ),
    .s_bready      ( m_bready[4] ),
    .s_araddr      ( m_araddr[4] ),
    .s_arburst     ( m_arburst[4] ),
    .s_arsize      ( m_arsize[4] ),
    .s_arid        ( m_arid[4]  ),
    .s_arlen       ( m_arlen[4] ),
    .s_arvalid     ( m_arvalid[4] ),
    .s_arready     ( m_arready[4] ),
    .s_rdata       ( m_rdata[4] ),
    .s_rresp       ( m_rresp[4] ),
    .s_rid         ( m_rid[4]   ),
    .s_rlast       ( m_rlast[4] ),
    .s_rvalid      ( m_rvalid[4] ),
    .s_rready      ( m_rready[4] )
);

endmodule

module axi_dec_fifo (
    input                  clk,
    input                  rstn,
    input                  wr,
    input         [  4: 0] wdata,
    input                  rd,
    output logic  [  4: 0] rdata,
    output logic           empty,
    output logic           full
);

parameter FIFO_DEPTH = 4;

logic [  4: 0] fifo       [0: FIFO_DEPTH - 1];

logic [  2: 0] wptr;
logic [  2: 0] rptr;

assign empty = wptr == rptr;
assign full  = (wptr[2] ^ rptr[2]) && (wptr[0+:2] == rptr[0+:2]);

assign rdata = fifo[rptr[0+:2]];

always_ff @(posedge clk or negedge rstn) begin
    integer i;

    if (~rstn) begin
        wptr <= 3'b0;
        rptr <= 3'b0;
    end
    else begin
        if (wr & ~full)  wptr <= wptr + 3'b1;
        if (rd & ~empty) rptr <= rptr + 3'b1;
    end

    if (~rstn) begin
        for (i = 0; i < FIFO_DEPTH; i = i + 1)
            fifo[i] <= 5'b0;
    end
    else begin
        if (wr & ~full) fifo[wptr[0+:2]] <= wdata;
    end
end
endmodule

module axi_dfslv (
    input                  aclk,
    input                  aresetn,
    input         [  1: 0] s_awburst,
    input         [ 12: 0] s_awid,
    input         [ 31: 0] s_awaddr,
    input         [  2: 0] s_awsize,
    input         [  7: 0] s_awlen,
    input                  s_awvalid,
    output logic           s_awready,
    input         [  3: 0] s_wstrb,
    input         [ 12: 0] s_wid,
    input         [ 31: 0] s_wdata,
    input                  s_wlast,
    input                  s_wvalid,
    output logic           s_wready,
    output logic  [ 12: 0] s_bid,
    output logic  [  1: 0] s_bresp,
    output logic           s_bvalid,
    input                  s_bready,
    input         [ 31: 0] s_araddr,
    input         [  1: 0] s_arburst,
    input         [  2: 0] s_arsize,
    input         [ 12: 0] s_arid,
    input         [  7: 0] s_arlen,
    input                  s_arvalid,
    output logic           s_arready,
    output logic  [ 31: 0] s_rdata,
    output logic  [  1: 0] s_rresp,
    output logic  [ 12: 0] s_rid,
    output logic           s_rlast,
    output logic           s_rvalid,
    input                  s_rready
);

`define AXI_RESP_OKAY   2'b00
`define AXI_RESP_EXOKAY 2'b01
`define AXI_RESP_SLVERR 2'b10
`define AXI_RESP_DECERR 2'b11

// READ
logic [  7: 0] rlen;

assign s_rdata    =  32'b0;
assign s_rresp    = `AXI_RESP_DECERR;
assign s_rlast    = ~|rlen;
assign s_arready  = ~s_rvalid | (s_rlast & s_rvalid & s_rready);

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_rid <=  13'b0;
    end
    else begin
        if (s_arvalid & s_arready) begin
            s_rid <= s_arid;
        end
    end

    if (~aresetn) begin
        rlen <= 8'b0;
    end
    else begin
        if (s_arvalid & s_arready) begin
            rlen <= s_arlen;
        end
        else if (~s_rlast & s_rvalid & s_rready) begin
            rlen <= rlen - 8'b1;
        end
    end

    if (~aresetn) begin
        s_rvalid <= 1'b0;
    end
    else begin
        if (s_arvalid & s_arready) begin
            s_rvalid <= 1'b1;
        end
        else if (s_rlast & s_rvalid & s_rready) begin
            s_rvalid <= 1'b0;
        end
    end
end

// WRITE
assign s_bresp    = `AXI_RESP_DECERR;
assign s_awready  = (~s_wready & ~s_bvalid) | (s_bvalid & s_bready);

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_wready <= 1'b0;
    end
    else begin
        if (s_awvalid & s_awready) begin
            s_wready <= 1'b1;
        end
        else if (s_wvalid & s_wlast) begin
            s_wready <= 1'b0;
        end
    end

    if (~aresetn) begin
        s_bid <= 13'b0;
    end
    else begin
        if (s_awvalid & s_awready) begin
            s_bid <= s_awid;
        end
    end

    if (~aresetn) begin
        s_bvalid <= 1'b0;
    end
    else begin
        if (s_wvalid & s_wlast & s_wready) begin
            s_bvalid <= 1'b1;
        end
        else if (s_bready) begin
            s_bvalid <= 1'b0;
        end
    end
end

endmodule
