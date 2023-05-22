`include "cfgreg_mmap.h"

`ifndef RISCV_VER
`define RISCV_VER 64'h00000000_00000000
`endif

module cfgreg (
    input                     clk,
    input                     rstn,
    apb_intf.slave            apb_intf,

    output logic [`XLEN-1: 0] core_bootvec,
    output logic [     31: 0] ddr_offset,
    output logic              core_rstn
);

parameter [63:0] RISCV_VER = `RISCV_VER;

logic [31:0] reserved_reg0;
logic [31:0] reserved_reg1;
logic        core_pwron;
logic        core_srstn;

logic [31:0] prdata_t;
logic        apb_wr;

// always_ff @(posedge clk or negedge rstn) begin: reg_core_rstn
//     if (~rstn) core_rstn <= 1'b0;
//     else       core_rstn <= core_pwron & core_srstn;
// end
assign core_rstn = core_pwron & core_srstn;

always_comb begin: comb_apb_wr
    apb_wr = ~apb_intf.penable & apb_intf.psel & apb_intf.pwrite;
end

always_ff @(posedge clk or negedge rstn) begin: reg_core_pwr
    if (~rstn) begin
        core_pwron <= 1'b0;
        core_srstn <= 1'b1;
    end
    else if (apb_wr && apb_intf.paddr[11:0] == `CFGREG_RSTN) begin
        core_pwron <=  apb_intf.pwdata[ 0];
        core_srstn <= ~apb_intf.pwdata[31];
    end
    else begin
        core_srstn <= 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_core_bootvec
    if (~rstn) begin
        core_bootvec <= 32'b0;
    end
    else if (apb_wr && apb_intf.paddr[11:0] == `CFGREG_BOOTVEC) begin
        core_bootvec <= apb_intf.pwdata;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_ddr_offset
    if (~rstn) begin
        ddr_offset <= 32'h2000_0000;
    end
    else if (apb_wr && apb_intf.paddr[11:0] == `CFGREG_DDROFFSET) begin
        ddr_offset <= apb_intf.pwdata;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_reserved_reg0
    if (~rstn) begin
        reserved_reg0 <= 32'b0;
    end
    else if (apb_wr && apb_intf.paddr[11:0] == `CFGREG_RSVREG0) begin
        reserved_reg0 <= apb_intf.pwdata;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_reserved_reg1
    if (~rstn) begin
        reserved_reg1 <= 32'b0;
    end
    else if (apb_wr && apb_intf.paddr[11:0] == `CFGREG_RSVREG1) begin
        reserved_reg1 <= apb_intf.pwdata;
    end
end

always_comb begin: comb_prdata_t
    prdata_t = 32'b0;
    case (apb_intf.paddr[11:0])
        `CFGREG_RSTN:        prdata_t = {31'b0, core_rstn};
        `CFGREG_BOOTVEC:     prdata_t = core_bootvec;
        `CFGREG_DDROFFSET:   prdata_t = ddr_offset;
        `CFGREG_RSVREG0:     prdata_t = reserved_reg0;
        `CFGREG_RSVREG1:     prdata_t = reserved_reg1;
        `CFGREG_VER:         prdata_t = RISCV_VER[63:32];
        `CFGREG_VER + 12'h4: prdata_t = RISCV_VER[31: 0];
    endcase
end

always_ff @(posedge clk or negedge rstn) begin: reg_prdata
    if (~rstn) begin
        apb_intf.prdata <= 32'b0;
    end
    else begin
        apb_intf.prdata <= prdata_t;
    end
end

assign apb_intf.pslverr = 1'b0;
assign apb_intf.pready  = 1'b1;

endmodule
