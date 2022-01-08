/*-----------------------------------------------------*/
// axi_slice.sv is generated by gen_axi_mux.sh
//
//                                         2022-01-06
//                                           23:33:14
/*-----------------------------------------------------*/

module axi_slice (
    input                  aclk,
    input                  aresetn,
    input         [ 66: 0] s_awpayload,
    input                  s_awvalid,
    output logic           s_awready,
    input         [ 49: 0] s_wpayload,
    input                  s_wvalid,
    output logic           s_wready,
    output logic  [ 14: 0] s_bpayload,
    output logic           s_bvalid,
    input                  s_bready,
    input         [ 66: 0] s_arpayload,
    input                  s_arvalid,
    output logic           s_arready,
    output logic  [ 47: 0] s_rpayload,
    output logic           s_rvalid,
    input                  s_rready,
    output logic  [ 66: 0] m_awpayload,
    output logic           m_awvalid,
    input                  m_awready,
    output logic  [ 49: 0] m_wpayload,
    output logic           m_wvalid,
    input                  m_wready,
    input         [ 14: 0] m_bpayload,
    input                  m_bvalid,
    output logic           m_bready,
    output logic  [ 66: 0] m_arpayload,
    output logic           m_arvalid,
    input                  m_arready,
    input         [ 47: 0] m_rpayload,
    input                  m_rvalid,
    output logic           m_rready
);

logic [ 66: 0] awpayload_latch [0:   1];
logic [ 49: 0] wpayload_latch [0:   1];
logic [ 14: 0] bpayload_latch [0:   1];
logic [ 66: 0] arpayload_latch [0:   1];
logic [ 47: 0] rpayload_latch [0:   1];

logic [  1: 0] aw_wptr;
logic [  1: 0] w_wptr;
logic [  1: 0] b_wptr;
logic [  1: 0] ar_wptr;
logic [  1: 0] r_wptr;

logic [  1: 0] aw_rptr;
logic [  1: 0] w_rptr;
logic [  1: 0] b_rptr;
logic [  1: 0] ar_rptr;
logic [  1: 0] r_rptr;

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        awpayload_latch <= { 67'b0,  67'b0};
        wpayload_latch  <= { 50'b0,  50'b0};
        bpayload_latch  <= { 15'b0,  15'b0};
        arpayload_latch <= { 67'b0,  67'b0};
        rpayload_latch  <= { 48'b0,  48'b0};
    end
    else begin
        if (s_awvalid && s_awready) awpayload_latch[aw_wptr[0]] <= s_awpayload;
        if (s_wvalid  && s_wready)  wpayload_latch[w_wptr[0]]   <= s_wpayload;
        if (m_bvalid  && m_bready)  bpayload_latch[b_wptr[0]]   <= m_bpayload;
        if (s_arvalid && s_arready) arpayload_latch[ar_wptr[0]] <= s_arpayload;
        if (m_rvalid  && m_rready)  rpayload_latch[r_wptr[0]]   <= m_rpayload;
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        aw_wptr <= 2'b0;
        w_wptr  <= 2'b0;
        b_wptr  <= 2'b0;
        ar_wptr <= 2'b0;
        r_wptr  <= 2'b0;
    end
    else begin
        if (s_awvalid && s_awready) aw_wptr <= aw_wptr + 2'b1;
        if (s_wvalid  && s_wready)  w_wptr  <= w_wptr  + 2'b1;
        if (m_bvalid  && m_bready)  b_wptr  <= b_wptr  + 2'b1;
        if (s_arvalid && s_arready) ar_wptr <= ar_wptr + 2'b1;
        if (m_rvalid  && m_rready)  r_wptr  <= r_wptr  + 2'b1;
    end
end

assign s_awready = !((aw_wptr[1] != aw_rptr[1]) && (aw_wptr[0] == aw_rptr[0]));
assign s_wready  = !((w_wptr[1]  != w_rptr[1] ) && (w_wptr[0]  == w_rptr[0] ));
assign m_bready  = !((b_wptr[1]  != b_rptr[1] ) && (b_wptr[0]  == b_rptr[0] ));
assign s_arready = !((ar_wptr[1] != ar_rptr[1]) && (ar_wptr[0] == ar_rptr[0]));
assign m_rready  = !((r_wptr[1]  != r_rptr[1] ) && (r_wptr[0]  == r_rptr[0] ));

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        aw_rptr <= 2'b0;
        w_rptr  <= 2'b0;
        b_rptr  <= 2'b0;
        ar_rptr <= 2'b0;
        r_rptr  <= 2'b0;
    end
    else begin
        if (m_awvalid && m_awready) aw_rptr <= aw_rptr + 2'b1;
        if (m_wvalid  && m_wready)  w_rptr  <= w_rptr  + 2'b1;
        if (s_bvalid  && s_bready)  b_rptr  <= b_rptr  + 2'b1;
        if (m_arvalid && m_arready) ar_rptr <= ar_rptr + 2'b1;
        if (s_rvalid  && s_rready)  r_rptr  <= r_rptr  + 2'b1;
    end
end

assign m_awvalid = aw_wptr != aw_rptr;
assign m_wvalid  = w_wptr  != w_rptr ;
assign s_bvalid  = b_wptr  != b_rptr ;
assign m_arvalid = ar_wptr != ar_rptr;
assign s_rvalid  = r_wptr  != r_rptr ;

assign m_awpayload = awpayload_latch[aw_rptr[0]];
assign m_wpayload  = wpayload_latch [ w_rptr[0]];
assign s_bpayload  = bpayload_latch [ b_rptr[0]];
assign m_arpayload = arpayload_latch[ar_rptr[0]];
assign s_rpayload  = rpayload_latch [ r_rptr[0]];

endmodule
