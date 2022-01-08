task extaxi_wr;
input [31:0] addr;
input [31:0] wdata;

logic [ 1: 0] awburst;
logic [12: 0] awid;
logic [31: 0] awaddr;
logic [ 2: 0] awsize;
logic [ 7: 0] awlen;
logic         awvalid;
logic [ 3: 0] wstrb;
logic [12: 0] wid;
logic [31: 0] wdata;
logic         wlast;
logic         wvalid;

awburst = 2'h1;
awid    = 10'b0;
awaddr  = addr;
awsize  = 3'h2;
awlen   = 8'h0;

wstrb   = 4'hf;
wid     = 10'b0;
wdata   = wdata;
wlast   = 1'b1;

fork begin
extaxi_aw_chn_send(awid, awaddr, awlen, awsize, awburst);
end join_none
fork begin
extaxi_w_chn_send(wid, wdata, wstrb, wlast);
end join_none
wait fork;

axi_ext_bready  = 1'b1;
do @(posedge (clk)); while (axi_ext_bvalid !== 1'b1);
axi_ext_bready  = 1'b0;

endtask

task extaxi_aw_chn_send;
input [12: 0] awid;
input [31: 0] awaddr;
input [ 7: 0] awlen;
input [ 2: 0] awsize;
input [ 1: 0] awburst;

axi_ext_awburst = awburst;
axi_ext_awid    = awid;
axi_ext_awaddr  = awaddr;
axi_ext_awsize  = awsize;
axi_ext_awlen   = awlen;
axi_ext_awvalid = 1'b1;
do @(posedge (clk)); while (axi_ext_awready !== 1'b1);
axi_ext_awvalid = 1'b0;
endtask

task extaxi_w_chn_send;
input [12: 0] wid;
input [31: 0] wdata;
input [ 3: 0] wstrb;
input         wlast;

axi_ext_wstrb  = wstrb;
axi_ext_wid    = wid;
axi_ext_wdata  = wdata;
axi_ext_wlast  = wlast;
axi_ext_wvalid = 1'b1;
do @(posedge (clk)); while (axi_ext_wready !== 1'b1);
axi_ext_wvalid = 1'b0;
endtask

task axi_init;
axi_ext_awburst = 2'b0;
axi_ext_awid    = 10'b0;
axi_ext_awaddr  = 32'b0;
axi_ext_awsize  = 3'b0;
axi_ext_awlen   = 8'b0;
axi_ext_awlock  = 2'b0;
axi_ext_awcache = 4'b0;
axi_ext_awprot  = 3'b0;
axi_ext_awvalid = 1'b0;
axi_ext_wstrb   = 4'b0;
axi_ext_wid     = 10'b0;
axi_ext_wdata   = 32'b0;
axi_ext_wlast   = 1'b0;
axi_ext_wvalid  = 1'b0;
axi_ext_bready  = 1'b0;
axi_ext_araddr  = 10'b0;
axi_ext_arburst = 2'b0;
axi_ext_arsize  = 3'b0;
axi_ext_arid    = 10'b0;
axi_ext_arlen   = 8'b0;
axi_ext_arlock  = 2'b0;
axi_ext_arcache = 4'b0;
axi_ext_arprot  = 3'b0;
axi_ext_arvalid = 1'b0;
axi_ext_rready  = 1'b0;
endtask
