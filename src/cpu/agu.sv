module agu (
    input        [`XLEN-1:0] base,
    input        [`XLEN-1:0] offset,
    output logic [`XLEN-1:0] out
);

assign out = base + offset;

endmodule
