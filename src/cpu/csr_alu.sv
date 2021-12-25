module csr_alu (
    input        [`CSR_OP_LEN-1:0] csr_op,
    input        [      `XLEN-1:0] src1,
    input        [      `XLEN-1:0] src2,
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

endmodule
