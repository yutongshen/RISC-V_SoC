module sram64x22 (
    input               CK,
    input               CS,
    input               WE,
    input        [ 5:0] A,
    input        [21:0] DI,
    output logic [21:0] DO
);

`ifdef DC
SRAM i_SRAM (
    .A0   ( A[0]         ),
    .A1   ( A[1]         ),
    .A2   ( A[2]         ),
    .A3   ( A[3]         ),
    .A4   ( A[4]         ),
    .A5   ( A[5]         ),
    .A6   ( 1'b0         ),
    .A7   ( 1'b0         ),
    .A8   ( 1'b0         ),
    .A9   ( 1'b0         ),
    .A10  ( 1'b0         ),
    .A11  ( 1'b0         ),
    .A12  ( 1'b0         ),
    .A13  ( 1'b0         ),
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
    .DO22 (              ),
    .DO23 (              ),
    .DO24 (              ),
    .DO25 (              ),
    .DO26 (              ),
    .DO27 (              ),
    .DO28 (              ),
    .DO29 (              ),
    .DO30 (              ),
    .DO31 (              ),
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
    .DI22 ( 1'b0         ),
    .DI23 ( 1'b0         ),
    .DI24 ( 1'b0         ),
    .DI25 ( 1'b0         ),
    .DI26 ( 1'b0         ),
    .DI27 ( 1'b0         ),
    .DI28 ( 1'b0         ),
    .DI29 ( 1'b0         ),
    .DI30 ( 1'b0         ),
    .DI31 ( 1'b0         ),
    .CK   ( CK           ),
    .WEB0 ( 1'b0         ),
    .WEB1 ( 1'b0         ),
    .WEB2 ( 1'b0         ),
    .WEB3 ( 1'b0         ),
    .OE   ( 1'b1         ),
    .CS   ( CS           )
);
`else
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
`endif

endmodule
