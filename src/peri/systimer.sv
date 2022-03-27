module systimer (
    input               clk_sys,
    input               clk_32k,
    input               rstn,
    output logic [63:0] systime
);

logic        rstn_32k;
logic        rstn_sys;
logic [63:0] timer_gray;
logic [63:0] timer_bin;
logic [63:0] nxt_timer_gray;
logic [63:0] nxt_timer_bin;
logic [63:0] gray_32k;
logic [63:0] timer_gray_d1;
logic [63:0] timer_gray_d2;
logic [63:0] gray_sys;
logic [63:0] systime_pre;

resetn_synchronizer u_rst_sync_32k(
    .clk        ( clk_32k  ),
    .rstn_async ( rstn     ),
    .rstn_sync  ( rstn_32k )
);

resetn_synchronizer u_rst_sync_sys(
    .clk        ( clk_sys  ),
    .rstn_async ( rstn     ),
    .rstn_sync  ( rstn_sys )
);

assign nxt_timer_bin = timer_bin + 64'b1;

bin2gray u_bin2gray_32k (
    .in  ( nxt_timer_bin  ),
    .out ( nxt_timer_gray )
);

always_ff @(posedge clk_32k or negedge rstn_32k) begin: reg_timer_32k
    if (~rstn_32k) timer_gray <= 64'b0;
    else           timer_gray <= nxt_timer_gray;
end

gray2bin u_gray2bin_32k (
    .in  ( timer_gray ),
    .out ( timer_bin  )
);

always_ff @(posedge clk_sys or negedge rstn_sys) begin: timer_sync
    if (~rstn_32k) begin
        timer_gray_d1 <= 64'b0;
        timer_gray_d2 <= 64'b0;
    end
    else begin
        timer_gray_d1 <= timer_gray;
        timer_gray_d2 <= timer_gray_d1;
    end
end

assign gray_sys = timer_gray_d2;

gray2bin u_gray2bin (
    .in  ( gray_sys    ),
    .out ( systime_pre )
);

always_ff @(posedge clk_sys or negedge rstn_sys) begin: reg_systime
    if (~rstn_sys) systime <= 64'b0;
    else           systime <= systime_pre;
end

endmodule

module gray2bin (
    input        [63:0] in,
    output logic [63:0] out
);

always_comb begin: comb_g2b
    integer i;
    out[63] = in[63];
    for (i = 62; i >= 0; i = i - 1) begin
        out[i] = out[i+1] ^ in[i];
    end
end

endmodule

module bin2gray (
    input        [63:0] in,
    output logic [63:0] out
);

always_comb begin: comb_b2g
    integer i;
    out[63] = in[63];
    for (i = 62; i >= 0; i = i - 1) begin
        out[i] = in[i+1] ^ in[i];
    end
end

endmodule
