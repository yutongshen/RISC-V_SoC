`define BURST_FIXED 2'b00
`define BURST_INCR  2'b01
`define BURST_WRAP  2'b10

`define RESP_OKAY   2'b00
`define RESP_EXOKAY 2'b01
`define RESP_SLVERR 2'b10
`define RESP_DECERR 2'b11

`define VERBOSE     0

module axi_vip_master #(
    parameter ID                = 0,
    parameter AXI_AXID_WIDTH    = 10,
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
    output logic [   AXI_AXID_WIDTH - 1: 0] m_awid,
    output logic [ AXI_AXADDR_WIDTH - 1: 0] m_awaddr,
    output logic [  AXI_AXLEN_WIDTH - 1: 0] m_awlen,
    output logic [ AXI_AXSIZE_WIDTH - 1: 0] m_awsize,
    output logic [AXI_AXBURST_WIDTH - 1: 0] m_awburst,
    output logic                            m_awvalid,
    input                                   m_awready,
    // Write Data Channel
    output logic [   AXI_AXID_WIDTH - 1: 0] m_wid,
    output logic [   AXI_DATA_WIDTH - 1: 0] m_wdata,
    output logic [ AXI_DATA_WIDTH/8 - 1: 0] m_wstrb,
    output logic                            m_wlast,
    output logic                            m_wvalid,
    input                                   m_wready,
    // Write Response Channel
    input        [   AXI_AXID_WIDTH - 1: 0] m_bid,
    input        [   AXI_RESP_WIDTH - 1: 0] m_bresp,
    input                                   m_bvalid,
    output logic                            m_bready,
    // Read Address Channel
    output logic [   AXI_AXID_WIDTH - 1: 0] m_arid,
    output logic [ AXI_AXADDR_WIDTH - 1: 0] m_araddr,
    output logic [  AXI_AXLEN_WIDTH - 1: 0] m_arlen,
    output logic [ AXI_AXSIZE_WIDTH - 1: 0] m_arsize,
    output logic [AXI_AXBURST_WIDTH - 1: 0] m_arburst,
    output logic                            m_arvalid,
    input                                   m_arready,
    //  Read Data Channel
    input        [   AXI_AXID_WIDTH - 1: 0] m_rid,
    input        [   AXI_DATA_WIDTH - 1: 0] m_rdata,
    input        [   AXI_RESP_WIDTH - 1: 0] m_rresp,
    input                                   m_rlast, 
    input                                   m_rvalid,
    output logic                            m_rready
);

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

task w_chn_send(
    input [   AXI_AXID_WIDTH - 1: 0] wid,
    input [   AXI_DATA_WIDTH - 1: 0] wdata,
    input [ AXI_DATA_WIDTH/8 - 1: 0] wstrb,
    input                            wlast
);

integer i;
for (i = 0; i < AXI_DATA_WIDTH/8; i = i + 1) begin
    wdata[i*8+:8] = {8{wstrb[i]}} & wdata[i*8+:8];
end

w_verbose(wid, wdata, wstrb, wlast);

fork begin
    repeat ($random() % 1) @(posedge aclk);
    m_wid = wid;
end join_none
fork begin
    repeat ($random() % 1) @(posedge aclk);
    m_wdata = wdata;
end join_none
fork begin
    repeat ($random() % 1) @(posedge aclk);
    m_wstrb = wstrb;
end join_none
fork begin
    repeat ($random() % 1) @(posedge aclk);
    m_wlast = wlast;
end join_none

wait fork;
m_wvalid = 1'b1;

do @(posedge (aclk)); while (m_wready !== 1'b1);
m_wvalid = 1'b0;

endtask

task aw_chn_send(
    input [   AXI_AXID_WIDTH - 1: 0] awid,
    input [ AXI_AXADDR_WIDTH - 1: 0] awaddr,
    input [  AXI_AXLEN_WIDTH - 1: 0] awlen,
    input [ AXI_AXSIZE_WIDTH - 1: 0] awsize,
    input [AXI_AXBURST_WIDTH - 1: 0] awburst
);
aw_verbose(awid, awaddr, awlen, awsize, awburst);

fork begin
    repeat ($random() % 1) @(posedge aclk);
    m_awid = awid;
end join_none
fork begin
    repeat ($random() % 1) @(posedge aclk);
    m_awaddr = awaddr;
end join_none
fork begin
    repeat ($random() % 1) @(posedge aclk);
    m_awlen = awlen;
end join_none
fork begin
    repeat ($random() % 1) @(posedge aclk);
    m_awsize = awsize;
end join_none
fork begin
    repeat ($random() % 1) @(posedge aclk);
    m_awburst = awburst;
end join_none

wait fork;
m_awvalid = 1'b1;

do @(posedge (aclk)); while (m_awready !== 1'b1);
m_awvalid = 1'b0;

endtask

task write (
    input [   AXI_AXID_WIDTH - 1: 0] awid,
    input [ AXI_AXADDR_WIDTH - 1: 0] awaddr,
    input [  AXI_AXLEN_WIDTH - 1: 0] awlen,
    input [ AXI_AXSIZE_WIDTH - 1: 0] awsize,
    input [AXI_AXBURST_WIDTH - 1: 0] awburst
);
integer i;
fork begin
aw_chn_send(awid, awaddr, awlen, awsize, awburst);
end join_none
fork begin
    logic [ AXI_DATA_WIDTH/8 - 1: 0] wstrb;
    logic [ AXI_AXADDR_WIDTH - 1: 0] waddr;
    wstrb = (1 << (1 << awsize)) - 1;
    wstrb = wstrb << (awaddr % (AXI_DATA_WIDTH/8)) |
            wstrb >> (AXI_DATA_WIDTH/8 - (awaddr % (AXI_DATA_WIDTH/8)));
    for (i = 0; i <= awlen; i = i + 1) begin
        w_chn_send(awid, $random(), wstrb, i == awlen);
        case (awburst)
            `BURST_FIXED: wstrb = wstrb;
            `BURST_INCR:  wstrb = wstrb << (1 << awsize) | wstrb >> (AXI_DATA_WIDTH/8 - (1 << awsize));
            `BURST_WRAP:  wstrb = wstrb << (1 << awsize) | wstrb >> (AXI_DATA_WIDTH/8 - (1 << awsize));
        endcase
    end
end join_none
wait fork;

endtask

task read (
    input [   AXI_AXID_WIDTH - 1: 0] arid,
    input [ AXI_AXADDR_WIDTH - 1: 0] araddr,
    input [  AXI_AXLEN_WIDTH - 1: 0] arlen,
    input [ AXI_AXSIZE_WIDTH - 1: 0] arsize,
    input [AXI_AXBURST_WIDTH - 1: 0] arburst
);

ar_verbose(arid, araddr, arlen, arsize, arburst);

fork
begin
    repeat ($random() % 1) @(posedge aclk);
    m_arid = arid;
end
join_none
fork
begin
    repeat ($random() % 1) @(posedge aclk);
    m_araddr = araddr;
end
join_none
fork
begin
    repeat ($random() % 1) @(posedge aclk);
    m_arlen = arlen;
end
join_none
fork
begin
    repeat ($random() % 1) @(posedge aclk);
    m_arsize = arsize;
end
join_none
fork
begin
    repeat ($random() % 1) @(posedge aclk);
    m_arburst = arburst;
end
join_none

wait fork;
m_arvalid = 1'b1;

do @(posedge (aclk)); while (m_arready !== 1'b1);
m_arvalid = 1'b0;

endtask

task random_read;

integer i;

logic [   AXI_AXID_WIDTH - 1: 0] arid;
logic [ AXI_AXADDR_WIDTH - 1: 0] araddr;
logic [  AXI_AXLEN_WIDTH - 1: 0] arlen;
logic [ AXI_AXSIZE_WIDTH - 1: 0] arsize;
logic [AXI_AXBURST_WIDTH - 1: 0] arburst;

for (i = 0; i < AXI_AXID_WIDTH; i = i + 1) begin
    arid[i] = $random() & 1'b1;
end
for (i = 0; i < AXI_AXADDR_WIDTH; i = i + 1) begin
    araddr[i] = $random() & 1'b1;
end
for (i = 0; i < AXI_AXLEN_WIDTH; i = i + 1) begin
    arlen[i] = $random() & 1'b1;
end
for (i = 0; i < AXI_AXSIZE_WIDTH; i = i + 1) begin
    arsize[i] = $random() & 1'b1;
end
for (i = 0; i < AXI_AXBURST_WIDTH; i = i + 1) begin
    arburst[i] = $random() & 1'b1;
end

arlen   = 8'd3;
arburst = 2'd1;

read(arid, araddr, arlen, arsize, arburst);

endtask

logic [   AXI_AXID_WIDTH - 1: 0] _id;
logic [ AXI_AXADDR_WIDTH - 1: 0] _addr;
logic [  AXI_AXLEN_WIDTH - 1: 0] _len;
logic [ AXI_AXSIZE_WIDTH - 1: 0] _size;
logic [AXI_AXBURST_WIDTH - 1: 0] _burst;

initial begin
    integer i;
    m_arvalid = 1'b0;
    m_awvalid = 1'b0;
    m_wvalid  = 1'b0;
    wait (aresetn);
    repeat (10) @(posedge aclk);
    
    _len   = 8'd3;
    _size  = 3'd1;
    _burst = 2'd2;

    _id    = 0;
    _addr  = 32'h0_0000;
    write(_id, _addr, _len, _size, _burst);
    _id    = 1;
    _addr  = 32'h2_0000;
    write(_id, _addr, _len, _size, _burst);
    _id    = 2;
    _addr  = 32'h0_0010;
    write(_id, _addr, _len, _size, _burst);
    _id    = 3;
    _addr  = 32'h1_0010;
    write(_id, _addr, _len, _size, _burst);
    _id    = 0;
    _addr  = 32'h0_0000;
    read (_id, _addr, _len, _size, _burst);
    _id    = 1;
    _addr  = 32'h2_0000;
    read (_id, _addr, _len, _size, _burst);
    _id    = 2;
    _addr  = 32'h0_0010;
    read (_id, _addr, _len, _size, _burst);
    _id    = 3;
    _addr  = 32'h1_0010;
    read (_id, _addr, _len, _size, _burst);
    // for (i = 0; i < 10000; i = i + 1) begin
    //     write($random(), $random(), $random(), $random(), $random());
    //     write($random(), $random(), $random(), $random(), $random());
    //     write($random(), $random(), $random(), $random(), $random());
    //     write($random(), $random(), $random(), $random(), $random());
    //     read($random(), $random(), $random(), $random(), $random());
    //     read($random(), $random(), $random(), $random(), $random());
    //     read($random(), $random(), $random(), $random(), $random());
    //     read($random(), $random(), $random(), $random(), $random());
    //     write($random(), $random(), $random(), $random(), $random());
    //     read($random(), $random(), $random(), $random(), $random());
    //     write($random(), $random(), $random(), $random(), $random());
    //     read($random(), $random(), $random(), $random(), $random());
    // end
    // repeat (10) @(posedge aclk);
    // $finish;
end

always @(posedge aclk) begin
    if (~aresetn) begin
        m_rready = 1'b1;
    end
    else begin
        if (m_rvalid & m_rready) begin
            r_verbose(m_rid, m_rdata, m_rresp, m_rlast);
        end
	    m_rready = ~m_rready;
    end
end

always @(posedge aclk) begin
    if (~aresetn) begin
        m_bready = 1'b1;
    end
    else begin
        if (m_bvalid & m_bready) begin
            b_verbose(m_bid, m_bresp);
        end
    end
end

endmodule
