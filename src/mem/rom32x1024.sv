module rom32x1024 (
    input               CK,
    input               CS,
    input        [ 9:0] A,
    output logic [31:0] DO
);
    
(* rom_style = "block" *) logic [7:0] byte_0 [1024];
(* rom_style = "block" *) logic [7:0] byte_1 [1024];
(* rom_style = "block" *) logic [7:0] byte_2 [1024];
(* rom_style = "block" *) logic [7:0] byte_3 [1024];

initial begin
    $readmemh("rom_0.hex", byte_0);
    $readmemh("rom_1.hex", byte_1);
    $readmemh("rom_2.hex", byte_2);
    $readmemh("rom_3.hex", byte_3);
end
  
always_ff @(posedge CK) begin
    if (CS) DO <= {byte_3[A], byte_2[A], byte_1[A], byte_0[A]};
end
        
endmodule
