module sram32x64 (
    input                CK,
    input                CS,
    input                WE,
    input        [  4:0] A,
    input        [ 63:0] DI,
    output logic [ 63:0] DO
);

logic [63:0] data_out_pre;
logic [63:0] memory [32];

assign data_out_pre = CS ? memory[A] : 64'hx;

always_ff @(posedge CK) begin
    integer i;

    if (CS & WE) begin
        memory[A] <= DI;
    end
end

always_ff @(posedge CK) begin
    DO <= data_out_pre;
end

endmodule
