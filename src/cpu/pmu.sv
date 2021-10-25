`include "cpu_define.h"

module pmu (
    input                    clk_free,
    input                    rstn,
    input        [`XLEN-1:0] cpu_id,
    input                    inst_valid,
    
    // CSR interface
    input                    csr_wr,
    input        [     11:0] csr_waddr,
    input        [     11:0] csr_raddr,
    input        [`XLEN-1:0] csr_wdata,
    output logic [`XLEN-1:0] csr_rdata
);

logic [`XLEN-1:0] mhartid;
logic [     63:0] mcycle;
logic [     63:0] minstret;


always_ff @(posedge clk_free or negedge rstn) begin
    if (~rstn)                                        mcycle            <= 64'b0;
    else if (csr_wr && csr_waddr == `CSR_MCYCLE_ADDR)  mcycle[ 0+:`XLEN] <= csr_wdata;
    else if (csr_wr && csr_waddr == `CSR_MCYCLEH_ADDR) mcycle[32+:   32] <= csr_wdata;
    else                                              mcycle            <= mcycle + 64'b1;
end

always_ff @(posedge clk_free or negedge rstn) begin
    if (~rstn)                                          minstret            <= 64'b0;
    else if (csr_wr && csr_waddr == `CSR_MINSTRET_ADDR)  minstret[ 0+:`XLEN] <= csr_wdata;
    else if (csr_wr && csr_waddr == `CSR_MINSTRETH_ADDR) minstret[32+:   32] <= csr_wdata;
    else                                                minstret            <= minstret + {63'b0, inst_valid};
end

always_ff @(posedge clk_free or negedge rstn) begin
    if (~rstn) mhartid <= `XLEN'b0;
    else       mhartid <= cpu_id;
end

always_comb begin
    csr_rdata = `XLEN'b0;
    case (csr_raddr) 
        `CSR_MCYCLE_ADDR:    csr_rdata = mcycle[ 0+:`XLEN];
        `CSR_MCYCLEH_ADDR:   csr_rdata = mcycle[32+:   32];
        `CSR_MINSTRET_ADDR:  csr_rdata = minstret[ 0+:`XLEN];
        `CSR_MINSTRETH_ADDR: csr_rdata = minstret[32+:   32];
        `CSR_MHARTID_ADDR:   csr_rdata = mhartid;
    endcase
end

endmodule
