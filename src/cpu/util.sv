module CG (
    input  CK,
    input  EN,
    output CKEN
);

logic en_latch;

always_latch begin
    if (~CK) en_latch <= EN;
end

assign CKEN = CK & en_latch;

endmodule

module resetn_synchronizer (
    input  clk,
    input  rstn_async,
    output rstn_sync
);

logic rstn_async_d1;
logic rstn_async_d2;

always @(posedge clk or negedge rstn_async) begin
    if (~rstn_async) rstn_async_d1 <= 1'b0;
    else             rstn_async_d1 <= 1'b1;
end

always @(posedge clk or negedge rstn_async) begin
    if (~rstn_async) rstn_async_d2 <= 1'b0;
    else             rstn_async_d2 <= rstn_async_d1;
end

assign rstn_sync = rstn_async_d2;

endmodule

module clz_64 (
    input        [63:0] in,
    output logic [ 6:0] out
);

// logic [63:0] tmp5;
// logic [31:0] tmp4;
// logic [15:0] tmp3;
// logic [ 7:0] tmp2;
// logic [ 3:0] tmp1;
// logic [ 1:0] tmp0;
// 
// assign out[6] = ~|in;
// assign out[5] = ~|tmp5[63:32];
// assign out[4] = ~|tmp4[31:16];
// assign out[3] = ~|tmp3[15: 8];
// assign out[2] = ~|tmp2[ 7: 4];
// assign out[1] = ~|tmp1[ 3: 2];
// assign out[0] = ~ tmp0[ 1];
// 
// assign tmp5   = out[6] ? -64'b1     : in;
// assign tmp4   = out[5] ? tmp5[31:0] : tmp5[63:32];
// assign tmp3   = out[4] ? tmp4[15:0] : tmp4[31:16];
// assign tmp2   = out[3] ? tmp3[ 7:0] : tmp3[15: 8];
// assign tmp1   = out[2] ? tmp2[ 3:0] : tmp2[ 7: 4];
// assign tmp0   = out[1] ? tmp1[ 1:0] : tmp1[ 3: 2];

// assign out[6] = ~|in;
// assign out[5] = ~|in[63:32];
// assign out[4] = ~|in[31:16];
// assign out[3] = ~|tmp3[15: 8];
// assign out[2] = ~|tmp2[ 7: 4];
// assign out[1] = ~|tmp1[ 3: 2];
// assign out[0] = ~ tmp0[ 1];

logic [63:0] encode;
logic [47:0] tmp1;
logic [31:0] tmp2;
logic [19:0] tmp3;
logic [11:0] tmp4;
logic [ 6:0] tmp5;

always_comb begin
    integer i;
    for (i = 0; i < 64; i = i + 2) begin
        encode[i+:2] = {~|in[i+:2], ~in[i+1] & in[i]};
    end
    for (i = 0; i < 16; i = i + 1) begin
        tmp1[(i*3)+:3] = {encode[(i*4)+3] & encode[(i*4)+1], ~{2{encode[(i*4)+3] & encode[(i*4)+1]}} & (encode[(i*4)+3] ? {1'b1, encode[(i*4)]} : encode[((i*4)+2)+:2])};
    end
    for (i = 0; i < 8; i = i + 1) begin
        tmp2[(i*4)+:4] = {tmp1[(i*6)+5] & tmp1[(i*6)+2], ~{3{tmp1[(i*6)+5] & tmp1[(i*6)+2]}} & (tmp1[(i*6)+5] ? {1'b1, tmp1[(i*6)+:2]} : tmp1[((i*6)+3)+:3])};
    end
    for (i = 0; i < 4; i = i + 1) begin
        tmp3[(i*5)+:5] = {tmp2[(i*8)+7] & tmp2[(i*8)+3], ~{4{tmp2[(i*8)+7] & tmp2[(i*8)+3]}} & (tmp2[(i*8)+7] ? {1'b1, tmp2[(i*8)+:3]} : tmp2[((i*8)+4)+:4])};
    end
    for (i = 0; i < 2; i = i + 1) begin
        tmp4[(i*6)+:6] = {tmp3[(i*10)+9] & tmp3[(i*10)+4], ~{5{tmp3[(i*10)+9] & tmp3[(i*10)+4]}} & (tmp3[(i*10)+9] ? {1'b1, tmp3[(i*10)+:4]} : tmp3[((i*10)+5)+:5])};
    end
    for (i = 0; i < 1; i = i + 1) begin
        tmp5[(i*7)+:7] = {tmp4[(i*12)+11] & tmp4[(i*12)+5], ~{6{tmp4[(i*12)+11] & tmp4[(i*12)+5]}} & (tmp4[(i*12)+11] ? {1'b1, tmp4[(i*12)+:5]} : tmp4[((i*12)+6)+:6])};
    end
end

assign out = tmp5;

endmodule

module clz_32 (
    input        [31:0] in,
    output logic [ 5:0] out
);

logic [31:0] encode;
logic [23:0] tmp1;
logic [15:0] tmp2;
logic [ 9:0] tmp3;
logic [ 5:0] tmp4;

always_comb begin
    integer i;
    for (i = 0; i < 32; i = i + 2) begin
        encode[i+:2] = {~|in[i+:2], ~in[i+1] & in[i]};
    end
    for (i = 0; i < 8; i = i + 1) begin
        tmp1[(i*3)+:3] = {encode[(i*4)+3] & encode[(i*4)+1], ~{2{encode[(i*4)+3] & encode[(i*4)+1]}} & (encode[(i*4)+3] ? {1'b1, encode[(i*4)]} : encode[((i*4)+2)+:2])};
    end
    for (i = 0; i < 4; i = i + 1) begin
        tmp2[(i*4)+:4] = {tmp1[(i*6)+5] & tmp1[(i*6)+2], ~{3{tmp1[(i*6)+5] & tmp1[(i*6)+2]}} & (tmp1[(i*6)+5] ? {1'b1, tmp1[(i*6)+:2]} : tmp1[((i*6)+3)+:3])};
    end
    for (i = 0; i < 2; i = i + 1) begin
        tmp3[(i*5)+:5] = {tmp2[(i*8)+7] & tmp2[(i*8)+3], ~{4{tmp2[(i*8)+7] & tmp2[(i*8)+3]}} & (tmp2[(i*8)+7] ? {1'b1, tmp2[(i*8)+:3]} : tmp2[((i*8)+4)+:4])};
    end
    for (i = 0; i < 1; i = i + 1) begin
        tmp4[(i*6)+:6] = {tmp3[(i*10)+9] & tmp3[(i*10)+4], ~{5{tmp3[(i*10)+9] & tmp3[(i*10)+4]}} & (tmp3[(i*10)+9] ? {1'b1, tmp3[(i*10)+:4]} : tmp3[((i*10)+5)+:5])};
    end
end

assign out = tmp4;

endmodule
