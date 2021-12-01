module sram (
    input               CK,
    input               CS,
    input               WE,
    input        [13:0] A,
    input        [ 3:0] BYTE,
    input        [31:0] DI,
    output logic [31:0] DO
);

logic [31:0] data_out_pre;
logic [31:0] memory [16384];

assign data_out_pre = CS ? memory[A] : 32'hx;

always_ff @(posedge CK) begin
    if (CS & WE) begin
        if (BYTE[0]) memory[A][ 7: 0] <= DI[ 7: 0];
        if (BYTE[1]) memory[A][15: 8] <= DI[15: 8];
        if (BYTE[2]) memory[A][23:16] <= DI[23:16];
        if (BYTE[3]) memory[A][31:24] <= DI[31:24];
    end
end

always_ff @(posedge CK) begin
    DO <= data_out_pre;
end

endmodule
