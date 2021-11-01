module sram64x22 (
    input               CK,
    input               CS,
    input               WE,
    input        [ 5:0] A,
    input        [21:0] DI,
    output logic [21:0] DO
);

logic [21:0] data_out_pre;
logic [21:0] memory [64];

assign data_out_pre = CS ? memory[A] : 22'hx;

always_ff @(posedge CK) begin
    if (CS & WE) begin
        memory[A] <= DI;
    end
end

always_ff @(posedge CK) begin
    DO <= data_out_pre;
end

endmodule
