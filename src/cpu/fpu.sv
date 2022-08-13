module fpu (
    input                          clk,
    input                          rstn,
    input                          trig,
    input                          len_64,
    input        [`MDU_OP_LEN-1:0] fpu_op,
    input                          flush,
    input        [           63:0] src1,
    input        [           63:0] src2,
    output logic [           63:0] out,
    output logic                   okay
);

endmodule
