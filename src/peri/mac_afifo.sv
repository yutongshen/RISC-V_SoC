module mac_afifo (
    input               rclk,
    input               rrstn,
    input               wclk,
    input               wrstn,

    output logic        full,
    output logic        nxt_full,
    input               write,
    input        [34:0] wdata,

    output logic        empty,
    output logic        nxt_empty,
    input               read,
    output logic [34:0] rdata
);

logic [34:0] mem [1:0];
logic        rptr;
logic        wptr;
logic [ 1:0] rflag;
logic [ 1:0] rflag_d1;
logic [ 1:0] rflag_d2;
logic [ 1:0] wflag;
logic [ 1:0] wflag_d1;
logic [ 1:0] wflag_d2;

always_ff @(posedge rclk or negedge rrstn) begin
    if (~rrstn) rptr <= 1'b0;
    else        rptr <= rptr + (~empty && read);
end

always_ff @(posedge wclk or negedge wrstn) begin
    if (~wrstn) wptr <= 1'b0;
    else        wptr <= wptr + (~full && write);
end

always_ff @(posedge wclk or negedge wrstn) begin
    if (~wrstn) begin
        rflag_d1 <= 2'b0;
        rflag_d2 <= 2'b0;
    end
    else begin
        rflag_d1 <= rflag;
        rflag_d2 <= rflag_d1;
    end
end

always_ff @(posedge rclk or negedge rrstn) begin
    if (~rrstn) begin
        wflag_d1 <= 2'b0;
        wflag_d2 <= 2'b0;
    end
    else begin
        wflag_d1 <= wflag;
        wflag_d2 <= wflag_d1;
    end
end

always_ff @(posedge rclk or negedge rrstn) begin
    if (~rrstn) begin
        rflag <= 2'b0;
    end
    else begin
        if (~empty && read)
            rflag[rptr] <= ~rflag[rptr];
    end
end

always_ff @(posedge wclk or negedge wrstn) begin
    if (~wrstn) begin
        wflag <= 2'b0;
    end
    else begin
        if (~full && write)
            wflag[wptr] <= ~wflag[wptr];
    end
end

always_ff @(posedge wclk or negedge wrstn) begin
    integer i;
    if (~wrstn) begin
        for (i = 0; i < 2; i = i + 1)
            mem[i] <= 35'b0;
    end
    else begin
        if (~full && write)
            mem[wptr] <= wdata;
    end
end

assign rdata     = mem[rptr];
assign empty     = !(rflag[rptr] ^ wflag_d2[rptr]);
assign full      =  (wflag[wptr] ^ rflag_d2[wptr]);
assign nxt_empty = !(rflag[rptr + 1'b1] ^ wflag_d2[rptr + 1'b1]);
assign nxt_full  =  (wflag[wptr + 1'b1] ^ rflag_d2[wptr + 1'b1]);

endmodule

module mac_fifo (
    input               clk,
    input               rstn,

    // Write side
    output logic        full,
    input               write,
    input        [10:0] wdata,

    // Read side
    output logic        empty,
    input               read,
    output logic [10:0] rdata
);

logic [10:0] mem [16];
logic [ 4:0] rptr;
logic [ 4:0] wptr;

assign empty = rptr == wptr;
assign full  = rptr[3:0] == wptr[3:0] && (rptr[4] ^ wptr[4]);

assign rdata = mem[rptr[3:0]];

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) rptr <= 5'b0;
    else       rptr <= rptr + {4'b0, ~empty & read};
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) wptr <= 5'b0;
    else       wptr <= wptr + {4'b0, ~full & write};
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < 16; i = i + 1)
            mem[i] <= 11'b0;
    end
    else begin
        if (~full & write)
            mem[wptr[3:0]] <= wdata;
    end
end

endmodule
