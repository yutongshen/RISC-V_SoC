module sram64x128 (
    input                CK,
    input                CS,
    input                WE,
    input        [  5:0] A,
    input        [ 15:0] BYTE,
    input        [127:0] DI,
    output logic [127:0] DO
);

logic [127:0] data_out_pre;
logic [127:0] memory [64];

assign data_out_pre = CS ? memory[A] : 128'hx;

always_ff @(posedge CK) begin
    integer i;

    if (CS & WE) begin
        for (i = 0; i < 16; i = i + 1) begin
            if (BYTE[i]) memory[A][i*8+:8] <= DI[i*8+:8];
        end
    end
end

always_ff @(posedge CK) begin
    DO <= data_out_pre;
end

endmodule
