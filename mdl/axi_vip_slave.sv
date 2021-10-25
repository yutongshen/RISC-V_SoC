`define BURST_FIXED 2'b00
`define BURST_INCR  2'b01
`define BURST_WRAP  2'b10

`define RESP_OKAY   2'b00
`define RESP_EXOKAY 2'b01
`define RESP_SLVERR 2'b10
`define RESP_DECERR 2'b11

`define VERBOSE     0

module axi_vip_slave #(
    parameter ID                = 0,
    parameter MEM_SIZE          = 8192,
    parameter AXI_AXID_WIDTH    = 11,
    parameter AXI_AXADDR_WIDTH  = 32,
    parameter AXI_AXLEN_WIDTH   = 8,
    parameter AXI_AXSIZE_WIDTH  = 3,
    parameter AXI_AXBURST_WIDTH = 2,
    parameter AXI_DATA_WIDTH    = 32,
    parameter AXI_RESP_WIDTH    = 2
)(
    input                                   aclk,
    input                                   aresetn,
    // Write Address Channel
    input        [   AXI_AXID_WIDTH - 1: 0] s_awid,
    input        [ AXI_AXADDR_WIDTH - 1: 0] s_awaddr,
    input        [  AXI_AXLEN_WIDTH - 1: 0] s_awlen,
    input        [ AXI_AXSIZE_WIDTH - 1: 0] s_awsize,
    input        [AXI_AXBURST_WIDTH - 1: 0] s_awburst,
    input                                   s_awvalid,
    output logic                            s_awready,
    // Write Data Channel
    input        [   AXI_AXID_WIDTH - 1: 0] s_wid,
    input        [   AXI_DATA_WIDTH - 1: 0] s_wdata,
    input        [ AXI_DATA_WIDTH/8 - 1: 0] s_wstrb,
    input                                   s_wlast,
    input                                   s_wvalid,
    output logic                            s_wready,
    // Write Response Channel
    output logic [   AXI_AXID_WIDTH - 1: 0] s_bid,
    output logic [   AXI_RESP_WIDTH - 1: 0] s_bresp,
    output logic                            s_bvalid,
    input                                   s_bready,
    // Read Address Channel
    input        [   AXI_AXID_WIDTH - 1: 0] s_arid,
    input        [ AXI_AXADDR_WIDTH - 1: 0] s_araddr,
    input        [  AXI_AXLEN_WIDTH - 1: 0] s_arlen,
    input        [ AXI_AXSIZE_WIDTH - 1: 0] s_arsize,
    input        [AXI_AXBURST_WIDTH - 1: 0] s_arburst,
    input                                   s_arvalid,
    output logic                            s_arready,
    //  Read Data Channel
    output logic [   AXI_AXID_WIDTH - 1: 0] s_rid,
    output logic [   AXI_DATA_WIDTH - 1: 0] s_rdata,
    output logic [   AXI_RESP_WIDTH - 1: 0] s_rresp,
    output logic                            s_rlast, 
    output logic                            s_rvalid,
    input                                   s_rready
);

task err_msg (
    input string msg
);

    $display("[%0d ns] [VIP_SLV%0d] %s", ID, $time, msg);

endtask

task aw_verbose (
    input [   AXI_AXID_WIDTH - 1: 0] awid,
    input [ AXI_AXADDR_WIDTH - 1: 0] awaddr,
    input [  AXI_AXLEN_WIDTH - 1: 0] awlen,
    input [ AXI_AXSIZE_WIDTH - 1: 0] awsize,
    input [AXI_AXBURST_WIDTH - 1: 0] awburst
);

if (`VERBOSE)
    $display("[%0d ns] [VIP_MST%0d] [AW] AWID=0x%x, AWADDR=0x%x, AWLEN=0x%x, AWSIZE=0x%x, AWBURST=0x%x",
             $time,             ID,           awid,      awaddr,      awlen,      awsize,      awburst);

endtask

task w_verbose (
    input [   AXI_AXID_WIDTH - 1: 0] wid,
    input [   AXI_DATA_WIDTH - 1: 0] wdata,
    input [ AXI_DATA_WIDTH/8 - 1: 0] wstrb,
    input                            wlast
);

if (`VERBOSE)
    $display("[%0d ns] [VIP_MST%0d] [W]  WID=0x%x, WDATA=0x%x, WSTRB=0x%x, RLAST=0x%x",
             $time,             ID,           wid,      wdata,      wstrb,      wlast);

endtask

task b_verbose (
    input [   AXI_AXID_WIDTH - 1: 0] bid,
    input [   AXI_RESP_WIDTH - 1: 0] bresp
);

if (`VERBOSE)
    $display("[%0d ns] [VIP_MST%0d] [B]  BID=0x%x, BRESP=0x%x",
             $time,             ID,           bid,      bresp);

endtask

task ar_verbose (
    input [   AXI_AXID_WIDTH - 1: 0] arid,
    input [ AXI_AXADDR_WIDTH - 1: 0] araddr,
    input [  AXI_AXLEN_WIDTH - 1: 0] arlen,
    input [ AXI_AXSIZE_WIDTH - 1: 0] arsize,
    input [AXI_AXBURST_WIDTH - 1: 0] arburst
);

if (`VERBOSE)
    $display("[%0d ns] [VIP_MST%0d] [AR] ARID=0x%x, ARADDR=0x%x, ARLEN=0x%x, ARSIZE=0x%x, ARBURST=0x%x",
             $time,             ID,           arid,      araddr,      arlen,      arsize,      arburst);

endtask

task r_verbose (
    input [   AXI_AXID_WIDTH - 1: 0] rid,
    input [   AXI_DATA_WIDTH - 1: 0] rdata,
    input [   AXI_RESP_WIDTH - 1: 0] rresp,
    input                            rlast
);

if (`VERBOSE)
    $display("[%0d ns] [VIP_MST%0d] [R]  RID=0x%x, RDATA=0x%x, ARRESP=0x%x, RLAST=0x%x",
             $time,             ID,           rid,      rdata,      rresp,       rlast);

endtask

logic [   AXI_DATA_WIDTH - 1: 0] memory [MEM_SIZE];

initial begin
    integer i, j;
    for (i = 0; i < MEM_SIZE; i = i + 1)
        for (j = 0; j < AXI_DATA_WIDTH; j = j + 1)
            memory[i][j] <= /*$random() % 2*/0;
end

// WRITE

logic                            awfifo_full;
logic                            awfifo_empty;
logic                            awburst_err;
logic [ AXI_AXADDR_WIDTH - 1: 0] waddr;
logic [   AXI_DATA_WIDTH - 1: 0] wmask;

logic [   AXI_AXID_WIDTH - 1: 0] awid;
logic [ AXI_AXADDR_WIDTH - 1: 0] awaddr;
logic [  AXI_AXLEN_WIDTH - 1: 0] awlen;
logic [ AXI_AXSIZE_WIDTH - 1: 0] awsize;
logic [AXI_AXBURST_WIDTH - 1: 0] awburst;

assign s_awready = ~awfifo_full;

fifo #(
    .DATA_WIDTH ( AXI_AXID_WIDTH+AXI_AXADDR_WIDTH+AXI_AXLEN_WIDTH+AXI_AXSIZE_WIDTH+AXI_AXBURST_WIDTH ),
    .FIFO_DEPTH ( 4 )
) u_aw_fifo (
    .clk   ( aclk    ),
    .rstn  ( aresetn ),
    .wr    ( s_awvalid & s_awready ),
    .wdata ( {s_awid, s_awaddr, s_awlen, s_awsize, s_awburst} ),
    .rd    ( s_wvalid & s_wready & s_wlast ),
    .rdata ( {awid, awaddr, awlen, awsize, awburst} ),
    .empty ( awfifo_empty ),
    .full  ( awfifo_full  )
);

always @(posedge aclk) begin
    if (~aresetn) begin
    end
    else begin
        if (s_awvalid & s_awready) begin
            aw_verbose(s_awid, s_awaddr, s_awlen, s_awsize, s_awburst);
        end
    end
end

always @(posedge aclk) begin
    integer i;
    if (~aresetn) begin
        s_wready = 1'b0;
        s_bvalid = 1'b0;
    end
    else begin
        if (~awfifo_empty) begin
            waddr = awaddr;
            wmask = (1 << awsize)*8 - 1;
            wmask = wmask << (awaddr % (1 << awsize))*8 |
                    wmask >> (AXI_AXADDR_WIDTH - (awaddr % (1 << awsize))*8);
            awburst_err = (awburst == `BURST_WRAP) && ((awlen != 8'b1)   && (awlen != 8'b11) &&
                                                       (awlen != 8'b111) && (awlen != 8'b1111));
            if (awburst_err) err_msg("Detect illigal burst");
            s_wready = 1'b1;
            
            do begin
                do @(posedge aclk); while (s_wvalid !== 1'b1);
                s_bid = s_wid;
                w_verbose(s_wid, s_wdata, s_wstrb, s_wlast);
                if (~awburst_err) begin
                    for (i = 0; i < AXI_DATA_WIDTH/8; i = i + 1) begin
                        if (s_wstrb[i])
                            memory[(waddr / (AXI_DATA_WIDTH/8)) % MEM_SIZE][i*8+:8] = s_wdata[i*8+:8];
                    end
                end
                case (awburst)
                    `BURST_FIXED: waddr = waddr;
                    `BURST_INCR:  waddr = (waddr + (1 << awsize));
                    `BURST_WRAP:  waddr = (waddr & ~(((awlen + 1) << awsize) - 1)) |
                                          ((waddr + (1 << awsize)) & (((awlen + 1) << awsize) - 1));
                    default:      waddr = 0;
                endcase
            end while (s_wlast !== 1'b1);
            s_wready = 1'b0;
            s_bresp  = awburst_err ? `RESP_SLVERR :
                                     `RESP_OKAY;
            s_bvalid = 1'b1;
            b_verbose(s_bid, s_bresp);
            do @(posedge aclk); while (s_bready !== 1'b1);
            s_bvalid = 1'b0;
        end
    end
end

// READ

logic                            arfifo_full;
logic                            arfifo_empty;
logic                            arburst_err;
logic [ AXI_AXADDR_WIDTH - 1: 0] raddr;

logic [   AXI_AXID_WIDTH - 1: 0] arid;
logic [ AXI_AXADDR_WIDTH - 1: 0] araddr;
logic [  AXI_AXLEN_WIDTH - 1: 0] arlen;
logic [ AXI_AXSIZE_WIDTH - 1: 0] arsize;
logic [AXI_AXBURST_WIDTH - 1: 0] arburst;

assign s_arready = ~arfifo_full;

fifo #(
    .DATA_WIDTH ( AXI_AXID_WIDTH+AXI_AXADDR_WIDTH+AXI_AXLEN_WIDTH+AXI_AXSIZE_WIDTH+AXI_AXBURST_WIDTH ),
    .FIFO_DEPTH ( 4 )
) u_ar_fifo (
    .clk   ( aclk    ),
    .rstn  ( aresetn ),
    .wr    ( s_arvalid & s_arready ),
    .wdata ( {s_arid, s_araddr, s_arlen, s_arsize, s_arburst} ),
    .rd    ( s_rvalid & s_rready & s_rlast ),
    .rdata ( {arid, araddr, arlen, arsize, arburst} ),
    .empty ( arfifo_empty ),
    .full  ( arfifo_full  )
);

always @(posedge aclk) begin
    if (~aresetn) begin
    end
    else begin
        if (s_arvalid & s_arready) begin
            ar_verbose(s_arid, s_araddr, s_arlen, s_arsize, s_arburst);
        end
    end
end

always @(posedge aclk) begin
    integer i;
    if (~aresetn) begin
        s_rvalid = 1'b0;
    end
    else begin
        if (~arfifo_empty) begin
            s_rid       = arid;
            arburst_err = (arburst == `BURST_WRAP) && ((arlen != 8'b1)   && (arlen != 8'b11) &&
                                                       (arlen != 8'b111) && (arlen != 8'b1111));
            if (arburst_err) err_msg("Detect illigal burst");
            for (i = 0; i <= arlen; i = i + 1) begin
                repeat($random() % 10) @(posedge aclk);
                case (arburst)
                    `BURST_FIXED: raddr = araddr;
                    `BURST_INCR:  raddr = (araddr + (i << arsize));
                    `BURST_WRAP:  raddr = (araddr & ~(((arlen + 1) << arsize) - 1)) |
                                          ((araddr + (i << arsize)) & (((arlen + 1) << arsize) - 1));
                    default:      raddr = 0;
                endcase
                s_rdata = memory[(raddr / (AXI_DATA_WIDTH/8)) % MEM_SIZE];
                s_rresp = arburst_err ? `RESP_SLVERR :
                                        `RESP_OKAY;
                s_rlast  = i == arlen;
                s_rvalid = 1'b1;
                r_verbose(s_rid, s_rdata, s_rresp, s_rlast);
                do @(posedge aclk); while (s_rready !== 1'b1);
                s_rvalid = 1'b0;
            end
        end
    end
end


endmodule

module fifo #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 4
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
