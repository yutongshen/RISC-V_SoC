module amo (
    input                          clk,
    input                          rstn,
    input        [`AMO_OP_LEN-1:0] amo_op,
    input        [      `XLEN-1:0] amo_src,
    
    // memory intf
    input        [      `XLEN-1:0] amo_mem_rdata,
    output logic [      `XLEN-1:0] amo_mem_wdata
);

`include "amo_op.sv"

always_comb begin
    amo_mem_wdata = `XLEN'b0;
    case (amo_op)
        AMO_SWAP: amo_mem_wdata = amo_src;
        AMO_ADD : amo_mem_wdata = amo_mem_rdata + amo_src;
        AMO_XOR : amo_mem_wdata = amo_mem_rdata ^ amo_src;
        AMO_AND : amo_mem_wdata = amo_mem_rdata & amo_src;
        AMO_OR  : amo_mem_wdata = amo_mem_rdata | amo_src;
        AMO_MIN : amo_mem_wdata = $signed(amo_mem_rdata) < $signed(amo_src) ? amo_mem_rdata : amo_src;
        AMO_MAX : amo_mem_wdata = $signed(amo_mem_rdata) > $signed(amo_src) ? amo_mem_rdata : amo_src;
        AMO_MINU: amo_mem_wdata = amo_mem_rdata < amo_src ? amo_mem_rdata : amo_src;
        AMO_MAXU: amo_mem_wdata = amo_mem_rdata > amo_src ? amo_mem_rdata : amo_src;
    endcase
end

endmodule
