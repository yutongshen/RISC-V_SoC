`include "csr_define.h"

module mmu_csr (
    input                               clk,
    input                               rstn,

    input        [                 1:0] misa_mxl,

    output logic [ `SATP_PPN_WIDTH-1:0] satp_ppn,
    output logic [`SATP_ASID_WIDTH-1:0] satp_asid,
    output logic [`SATP_MODE_WIDTH-1:0] satp_mode,
    // CSR interface
    input                               csr_wr,
    input        [                11:0] csr_waddr,
    input        [                11:0] csr_raddr,
    // input        [           `XLEN-1:0] csr_wdata,
    input        [           `XLEN-1:0] csr_sdata,
    input        [           `XLEN-1:0] csr_cdata,
    output logic [           `XLEN-1:0] csr_rdata
);

logic [           `XLEN-1:0] satp;

`ifdef RV32
assign satp = {satp_mode, satp_asid, satp_ppn};
`else
assign satp = misa_mxl == 2'h1 ? {32'b0, satp_mode[0+:`SATP32_MODE_WIDTH],
                                         satp_asid[0+:`SATP32_ASID_WIDTH],
                                         satp_ppn [0+:`SATP32_PPN_WIDTH]}:
                                 {satp_mode, satp_asid, satp_ppn};
`endif

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        satp_ppn  <= `SATP_PPN_WIDTH'b0;
        satp_asid <= `SATP_ASID_WIDTH'b0;
        satp_mode <= `SATP_MODE_WIDTH'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_SATP_ADDR) begin
`ifdef RV32
        satp_ppn  <= `CSR_WDATA(satp_ppn ,  `SATP32_PPN_BIT);
        satp_asid <= `CSR_WDATA(satp_asid, `SATP32_ASID_BIT);
        satp_mode <= `CSR_WDATA(satp_mode, `SATP32_MODE_BIT);
`else
        satp_ppn  <= misa_mxl == 2'h1 ? `CSR_WDATA(satp_ppn , `SATP32_PPN_BIT):
                                        `CSR_WDATA(satp_ppn , `SATP64_PPN_BIT);
        satp_asid <= misa_mxl == 2'h1 ? `CSR_WDATA(satp_asid, `SATP32_ASID_BIT):
                                        `CSR_WDATA(satp_asid, `SATP64_ASID_BIT);
        satp_mode <= misa_mxl == 2'h1 ? `CSR_WDATA(satp_mode, `SATP32_MODE_BIT):
                                        `CSR_WDATA(satp_mode, `SATP64_MODE_BIT);
`endif
    end
end

always_comb begin
    csr_rdata = `XLEN'b0;
    case (csr_raddr) 
        `CSR_SATP_ADDR   : csr_rdata = satp;
    endcase
end

endmodule
