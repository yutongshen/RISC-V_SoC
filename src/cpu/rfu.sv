module rfu (
    input                      clk,
    input                      rstn,
    input        [        4:0] rs1_addr,
    input        [        4:0] rs2_addr,
    output logic [`XLEN - 1:0] rs1_data,
    output logic [`XLEN - 1:0] rs2_data,
    input                      wen,
    input        [        4:0] rd_addr,
    input        [`XLEN - 1:0] rd_data,

    input                      halted,
    input        [        4:0] dbg_gpr_addr,
    input        [       31:0] dbg_gpr_in,
    input                      dbg_gpr_rd,
    input                      dbg_gpr_wr,
    output logic [       31:0] dbg_gpr_out
);

logic               rstn_sync;
logic [`XLEN - 1:0] gpr [0:31];
integer             i;

logic [        4:0] rd_addr_dbg;
logic               wen_dbg;
logic [       31:0] rd_data_dbg;

assign rd_addr_dbg = (halted && dbg_gpr_wr) ? dbg_gpr_addr : rd_addr;
assign wen_dbg     = wen || (halted && dbg_gpr_wr);
assign rd_data_dbg = (halted && dbg_gpr_wr) ? dbg_gpr_in : rd_data;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        for (i = 0; i < 32; i = i + 1) begin
            gpr[i] <= {`XLEN{1'b0}};
        end
    end
    else begin
        if (wen_dbg & |rd_addr_dbg) begin
            gpr[rd_addr_dbg] <= rd_data_dbg;
        end
    end
end

assign rs1_data = gpr[rs1_addr];
assign rs2_data = gpr[rs2_addr];

assign dbg_gpr_out = gpr[dbg_gpr_addr];

endmodule
