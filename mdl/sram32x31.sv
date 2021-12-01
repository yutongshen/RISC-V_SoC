module sram32x31 (
    input                CK,
    input                CS,
    input                WE,
    input        [  4:0] A,
    input        [ 30:0] DI,
    output logic [ 30:0] DO
);

logic [30:0] data_out_pre;
logic [30:0] memory [32];

assign data_out_pre = CS ? memory[A] : 31'hx;

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
