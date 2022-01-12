module csr_alu (
    input        [`CSR_OP_LEN-1:0] csr_op,
    input        [      `XLEN-1:0] src1,
    input        [      `XLEN-1:0] src2,
    output logic [      `XLEN-1:0] stb,
    output logic [      `XLEN-1:0] clr,
    output logic [      `XLEN-1:0] out
);

`include "csr_op.sv"

always_comb begin
    out = `XLEN'b0;
    case (csr_op)
        CSR_OP_NONE: out = src2;
        CSR_OP_SET : out = src1 |  src2;
        CSR_OP_CLR : out = src1 & ~src2;
    endcase
end

always_comb begin
    stb = `XLEN'b0;
    case (csr_op)
        CSR_OP_NONE: stb = src2;
        CSR_OP_SET : stb = src2;
    endcase
end

always_comb begin
    clr = `XLEN'b0;
    case (csr_op)
        CSR_OP_NONE: clr = ~src2;
        CSR_OP_CLR : clr =  src2;
    endcase
end

endmodule
