`include "intf_define.h"

module mmu (
    input                                    clk,
    input                                    rstn,
    
    // mmu csr
    input        [    `SATP_PPN_WIDTH - 1:0] satp_ppn,
    input        [   `SATP_ASID_WIDTH - 1:0] satp_asid,
    input        [   `SATP_MODE_WIDTH - 1:0] satp_mode,
    input                                    mstatus_tvm,
    input        [                      1:0] prv,

    // virtual address
    input                                    va_valid,
    input        [                     47:0] va,

    // physical address
    output logic                             pa_valid,
    output logic [                     55:0] pa,
    
    // AXI interface
    `AXI_INTF_MST_DEF(m, 10)
);

logic [55:0] va_latch;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) va_latch <= 56'b0;
    else       va_latch <= {8'b0, va};
end

assign pa_valid = ~(mstatus_tvm && prv < `PRV_M);
assign pa       = va_latch;

endmodule
