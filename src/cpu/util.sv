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
