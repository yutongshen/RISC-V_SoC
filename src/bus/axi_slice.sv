`define AW_PAYLOAD_WIDTH 57
`define W_PAYLOAD_WIDTH  49
`define B_PAYLOAD_WIDTH  14
`define AR_PAYLOAD_WIDTH 57
`define R_PAYLOAD_WIDTH  47

module axi_slice (
    input                                  aclk,
    input                                  aresetn,

    // AXI slave port
    input         [`AW_PAYLOAD_WIDTH-1: 0] s_awpayload,
    input                                  s_awvalid,
    output logic                           s_awready,
    input         [ `W_PAYLOAD_WIDTH-1: 0] s_wpayload,
    input                                  s_wvalid,
    output logic                           s_wready,
    output logic  [ `B_PAYLOAD_WIDTH-1: 0] s_bpayload,
    output logic                           s_bvalid,
    input                                  s_bready,
    input         [`AR_PAYLOAD_WIDTH-1: 0] s_arpayload,
    input                                  s_arvalid,
    output logic                           s_arready,
    output logic  [ `R_PAYLOAD_WIDTH-1: 0] s_rpayload,
    output logic                           s_rvalid,
    input                                  s_rready,

    // AXI master port
    output logic  [`AW_PAYLOAD_WIDTH-1: 0] m_awpayload,
    output logic                           m_awvalid,
    input                                  m_awready,
    output logic  [ `W_PAYLOAD_WIDTH-1: 0] m_wpayload,
    output logic                           m_wvalid,
    input                                  m_wready,
    input         [ `B_PAYLOAD_WIDTH-1: 0] m_bpayload,
    input                                  m_bvalid,
    output logic                           m_bready,
    output logic  [`AR_PAYLOAD_WIDTH-1: 0] m_arpayload,
    output logic                           m_arvalid,
    input                                  m_arready,
    input         [ `R_PAYLOAD_WIDTH-1: 0] m_rpayload,
    input                                  m_rvalid,
    output logic                           m_rready
);

logic  [`AW_PAYLOAD_WIDTH-1: 0] awpayload_latch [2];
logic  [ `W_PAYLOAD_WIDTH-1: 0] wpayload_latch  [2];
logic  [ `B_PAYLOAD_WIDTH-1: 0] bpayload_latch  [2];
logic  [`AR_PAYLOAD_WIDTH-1: 0] arpayload_latch [2];
logic  [ `R_PAYLOAD_WIDTH-1: 0] rpayload_latch  [2];

logic [1:0] aw_wptr;
logic [1:0] w_wptr;
logic [1:0] b_wptr;
logic [1:0] ar_wptr;
logic [1:0] r_wptr;

logic [1:0] aw_rptr;
logic [1:0] w_rptr;
logic [1:0] b_rptr;
logic [1:0] ar_rptr;
logic [1:0] r_rptr;

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        awpayload_latch <= {`AW_PAYLOAD_WIDTH'b0, `AW_PAYLOAD_WIDTH'b0};
        wpayload_latch  <= { `W_PAYLOAD_WIDTH'b0,  `W_PAYLOAD_WIDTH'b0};
        bpayload_latch  <= { `B_PAYLOAD_WIDTH'b0,  `B_PAYLOAD_WIDTH'b0};
        arpayload_latch <= {`AR_PAYLOAD_WIDTH'b0, `AR_PAYLOAD_WIDTH'b0};
        rpayload_latch  <= { `R_PAYLOAD_WIDTH'b0,  `R_PAYLOAD_WIDTH'b0};
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
