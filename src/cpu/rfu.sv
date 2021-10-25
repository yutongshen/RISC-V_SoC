module rfu (
    input                clk,
    input                rstn,
    input  [        4:0] rs1_addr,
    input  [        4:0] rs2_addr,
    output [`XLEN - 1:0] rs1_data,
    output [`XLEN - 1:0] rs2_data,
    input                wen,
    input  [        4:0] rd_addr,
    input  [`XLEN - 1:0] rd_data
);

logic               rstn_sync;
logic [`XLEN - 1:0] gpr [0:31];
integer             i;

// assign gpr[0] = {`XLEN{1'b0}};

resetn_synchronizer u_sync (
    .clk        ( clk       ),
    .rstn_async ( rstn      ),
    .rstn_sync  ( rstn_sync )
);

always_ff @(posedge clk or negedge rstn_sync) begin
    if (~rstn_sync) begin
        for (i = 0; i < 32; i = i + 1) begin
            gpr[i] <= {`XLEN{1'b0}};
        end
    end
    else begin
        if (wen & |rd_addr) begin
            gpr[rd_addr] <= rd_data;
        end
    end
end

assign rs1_data = gpr[rs1_addr];
assign rs2_data = gpr[rs2_addr];

endmodule
