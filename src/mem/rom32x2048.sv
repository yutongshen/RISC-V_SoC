module rom32x2048 (
    input               CK,
    input               CS,
    input        [10:0] A,
    input               WE,
    input        [ 3:0] BYTE,
    input        [31:0] DI,
    output logic [31:0] DO
);
    
`ifdef BROM
(* rom_style = "block" *) logic [7:0] byte_0 [2048];
(* rom_style = "block" *) logic [7:0] byte_1 [2048];
(* rom_style = "block" *) logic [7:0] byte_2 [2048];
(* rom_style = "block" *) logic [7:0] byte_3 [2048];

initial begin
    $readmemh("rom_0.hex", byte_0);
    $readmemh("rom_1.hex", byte_1);
    $readmemh("rom_2.hex", byte_2);
    $readmemh("rom_3.hex", byte_3);
end
  
always_ff @(posedge CK) begin
    if (CS) DO <= {byte_3[A], byte_2[A], byte_1[A], byte_0[A]};
end
`else
logic [31:0] data_out_pre;
logic [7:0] byte_0 [2048];
logic [7:0] byte_1 [2048];
logic [7:0] byte_2 [2048];
logic [7:0] byte_3 [2048];

assign data_out_pre = CS ? {byte_3[A], byte_2[A], byte_1[A], byte_0[A]} : 32'hx;

always_ff @(posedge CK) begin
    if (CS & WE) begin
        if (BYTE[0]) byte_0[A] <= DI[ 7: 0];
        if (BYTE[1]) byte_1[A] <= DI[15: 8];
        if (BYTE[2]) byte_2[A] <= DI[23:16];
        if (BYTE[3]) byte_3[A] <= DI[31:24];
    end
end

always_ff @(posedge CK) begin
    DO <= data_out_pre;
end
`endif
        
endmodule
