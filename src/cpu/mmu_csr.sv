module mmu_csr (
    input                               clk,
    input                               rstn,

    output logic [ `SATP_PPN_WIDTH-1:0] satp_ppn,
    output logic [`SATP_ASID_WIDTH-1:0] satp_asid,
    output logic [`SATP_MODE_WIDTH-1:0] satp_mode,
    // CSR interface
    input                               csr_wr,
    input        [                11:0] csr_waddr,
    input        [                11:0] csr_raddr,
    input        [           `XLEN-1:0] csr_wdata,
    output logic [           `XLEN-1:0] csr_rdata
);

logic [           `XLEN-1:0] satp;

assign satp = {satp_mode, satp_asid, satp_ppn};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        satp_ppn  <= `SATP_PPN_WIDTH'b0;
        satp_asid <= `SATP_ASID_WIDTH'b0;
        satp_mode <= `SATP_MODE_WIDTH'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_SATP_ADDR) begin
        satp_ppn  <= csr_wdata[ `SATP_PPN_BIT];
        satp_asid <= csr_wdata[`SATP_ASID_BIT];
        satp_mode <= csr_wdata[`SATP_MODE_BIT];
    end
end

always_comb begin
    csr_rdata = `XLEN'b0;
    case (csr_raddr) 
        `CSR_SATP_ADDR   : csr_rdata = satp;
    endcase
end

endmodule
