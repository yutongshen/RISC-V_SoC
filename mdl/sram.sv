module sram (
    input               CK,
    input               CS,
    input               WE,
    input        [13:0] A,
    input        [ 3:0] BYTE,
    input        [31:0] DI,
    output logic [31:0] DO
);

`ifdef DC
SRAM i_SRAM (
    .A0   ( A[0]         ),
    .A1   ( A[1]         ),
    .A2   ( A[2]         ),
    .A3   ( A[3]         ),
    .A4   ( A[4]         ),
    .A5   ( A[5]         ),
    .A6   ( A[6]         ),
    .A7   ( A[7]         ),
    .A8   ( A[8]         ),
    .A9   ( A[9]         ),
    .A10  ( A[10]        ),
    .A11  ( A[11]        ),
    .A12  ( A[12]        ),
    .A13  ( A[13]        ),
    .DO0  ( DO[0]        ),
    .DO1  ( DO[1]        ),
    .DO2  ( DO[2]        ),
    .DO3  ( DO[3]        ),
    .DO4  ( DO[4]        ),
    .DO5  ( DO[5]        ),
    .DO6  ( DO[6]        ),
    .DO7  ( DO[7]        ),
    .DO8  ( DO[8]        ),
    .DO9  ( DO[9]        ),
    .DO10 ( DO[10]       ),
    .DO11 ( DO[11]       ),
    .DO12 ( DO[12]       ),
    .DO13 ( DO[13]       ),
    .DO14 ( DO[14]       ),
    .DO15 ( DO[15]       ),
    .DO16 ( DO[16]       ),
    .DO17 ( DO[17]       ),
    .DO18 ( DO[18]       ),
    .DO19 ( DO[19]       ),
    .DO20 ( DO[20]       ),
    .DO21 ( DO[21]       ),
    .DO22 ( DO[22]       ),
    .DO23 ( DO[23]       ),
    .DO24 ( DO[24]       ),
    .DO25 ( DO[25]       ),
    .DO26 ( DO[26]       ),
    .DO27 ( DO[27]       ),
    .DO28 ( DO[28]       ),
    .DO29 ( DO[29]       ),
    .DO30 ( DO[30]       ),
    .DO31 ( DO[31]       ),
    .DI0  ( DI[0]        ),
    .DI1  ( DI[1]        ),
    .DI2  ( DI[2]        ),
    .DI3  ( DI[3]        ),
    .DI4  ( DI[4]        ),
    .DI5  ( DI[5]        ),
    .DI6  ( DI[6]        ),
    .DI7  ( DI[7]        ),
    .DI8  ( DI[8]        ),
    .DI9  ( DI[9]        ),
    .DI10 ( DI[10]       ),
    .DI11 ( DI[11]       ),
    .DI12 ( DI[12]       ),
    .DI13 ( DI[13]       ),
    .DI14 ( DI[14]       ),
    .DI15 ( DI[15]       ),
    .DI16 ( DI[16]       ),
    .DI17 ( DI[17]       ),
    .DI18 ( DI[18]       ),
    .DI19 ( DI[19]       ),
    .DI20 ( DI[20]       ),
    .DI21 ( DI[21]       ),
    .DI22 ( DI[22]       ),
    .DI23 ( DI[23]       ),
    .DI24 ( DI[24]       ),
    .DI25 ( DI[25]       ),
    .DI26 ( DI[26]       ),
    .DI27 ( DI[27]       ),
    .DI28 ( DI[28]       ),
    .DI29 ( DI[29]       ),
    .DI30 ( DI[30]       ),
    .DI31 ( DI[31]       ),
    .CK   ( CK           ),
    .WEB0 ( ~BYTE[0]     ),
    .WEB1 ( ~BYTE[1]     ),
    .WEB2 ( ~BYTE[2]     ),
    .WEB3 ( ~BYTE[3]     ),
    .OE   ( 1'b1         ),
    .CS   ( CS           )
);
`else
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
`endif

endmodule
