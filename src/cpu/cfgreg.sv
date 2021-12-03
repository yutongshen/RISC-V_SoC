`include "cfgreg_mmap.h"

module cfgreg (
    input                 pclk,
    input                 presetn,
    input                 psel,
    input                 penable,
    input        [ 31: 0] paddr,
    input                 pwrite,
    input        [  3: 0] pstrb,
    input        [ 31: 0] pwdata,
    output logic [ 31: 0] prdata,
    output logic          pslverr,
    output logic          pready,

    output logic          core_rstn
);


logic [31:0] reserve_reg0;
logic [31:0] reserve_reg1;

logic [31:0] prdata_t;
logic        apb_wr;

assign apb_wr = ~penable && psel && pwrite;

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        core_rstn <= 1'b0;
    end
    else if (apb_wr && paddr[11:0] == `CFGREG_RSTN) begin
        core_rstn <= pwdata[0];
    end
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        reserve_reg0 <= 32'b0;
    end
    else if (apb_wr && paddr[11:0] == `CFGREG_RSVREG0) begin
        reserve_reg0 <= pwdata;
    end
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        reserve_reg1 <= 32'b0;
    end
    else if (apb_wr && paddr[11:0] == `CFGREG_RSVREG1) begin
        reserve_reg1 <= pwdata;
    end
end

always_comb begin
    prdata_t = 32'b0;
    case (paddr[11:0])
        `CFGREG_RSTN:    prdata_t = {31'b0, core_rstn};
        `CFGREG_RSVREG0: prdata_t = reserve_reg0;
        `CFGREG_RSVREG1: prdata_t = reserve_reg1;
    endcase
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        prdata <= 32'b0;
    end
    else begin
        prdata <= prdata_t;
    end
end

assign pslverr = 1'b0;
assign pready  = 1'b1;

endmodule
