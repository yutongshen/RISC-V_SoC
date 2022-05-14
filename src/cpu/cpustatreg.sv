`include "cpustatreg_mmap.h"

module cpustatreg (
    input                 clk,
    input                 rstn,
    apb_intf.slave        apb_intf,

    input          [63:0] pc,
    input          [63:0] gpr [32]
);

logic [31:0] prdata_t;

always_comb begin: comb_prdata_t
    prdata_t = 32'b0;
    case (apb_intf.paddr[11:0])
        `CPUSTATREG_PC  + 0: prdata_t = pc[31: 0];
        `CPUSTATREG_PC  + 4: prdata_t = pc[63:32];
        `CPUSTATREG_X1  + 0: prdata_t = gpr[1 ][31: 0];
        `CPUSTATREG_X1  + 4: prdata_t = gpr[1 ][63:32];
        `CPUSTATREG_X2  + 0: prdata_t = gpr[2 ][31: 0];
        `CPUSTATREG_X2  + 4: prdata_t = gpr[2 ][63:32];
        `CPUSTATREG_X3  + 0: prdata_t = gpr[3 ][31: 0];
        `CPUSTATREG_X3  + 4: prdata_t = gpr[3 ][63:32];
        `CPUSTATREG_X4  + 0: prdata_t = gpr[4 ][31: 0];
        `CPUSTATREG_X4  + 4: prdata_t = gpr[4 ][63:32];
        `CPUSTATREG_X5  + 0: prdata_t = gpr[5 ][31: 0];
        `CPUSTATREG_X5  + 4: prdata_t = gpr[5 ][63:32];
        `CPUSTATREG_X6  + 0: prdata_t = gpr[6 ][31: 0];
        `CPUSTATREG_X6  + 4: prdata_t = gpr[6 ][63:32];
        `CPUSTATREG_X7  + 0: prdata_t = gpr[7 ][31: 0];
        `CPUSTATREG_X7  + 4: prdata_t = gpr[7 ][63:32];
        `CPUSTATREG_X8  + 0: prdata_t = gpr[8 ][31: 0];
        `CPUSTATREG_X8  + 4: prdata_t = gpr[8 ][63:32];
        `CPUSTATREG_X9  + 0: prdata_t = gpr[9 ][31: 0];
        `CPUSTATREG_X9  + 4: prdata_t = gpr[9 ][63:32];
        `CPUSTATREG_X10 + 0: prdata_t = gpr[10][31: 0];
        `CPUSTATREG_X10 + 4: prdata_t = gpr[10][63:32];
        `CPUSTATREG_X11 + 0: prdata_t = gpr[11][31: 0];
        `CPUSTATREG_X11 + 4: prdata_t = gpr[11][63:32];
        `CPUSTATREG_X12 + 0: prdata_t = gpr[12][31: 0];
        `CPUSTATREG_X12 + 4: prdata_t = gpr[12][63:32];
        `CPUSTATREG_X13 + 0: prdata_t = gpr[13][31: 0];
        `CPUSTATREG_X13 + 4: prdata_t = gpr[13][63:32];
        `CPUSTATREG_X14 + 0: prdata_t = gpr[14][31: 0];
        `CPUSTATREG_X14 + 4: prdata_t = gpr[14][63:32];
        `CPUSTATREG_X15 + 0: prdata_t = gpr[15][31: 0];
        `CPUSTATREG_X15 + 4: prdata_t = gpr[15][63:32];
        `CPUSTATREG_X16 + 0: prdata_t = gpr[16][31: 0];
        `CPUSTATREG_X16 + 4: prdata_t = gpr[16][63:32];
        `CPUSTATREG_X17 + 0: prdata_t = gpr[17][31: 0];
        `CPUSTATREG_X17 + 4: prdata_t = gpr[17][63:32];
        `CPUSTATREG_X18 + 0: prdata_t = gpr[18][31: 0];
        `CPUSTATREG_X18 + 4: prdata_t = gpr[18][63:32];
        `CPUSTATREG_X19 + 0: prdata_t = gpr[19][31: 0];
        `CPUSTATREG_X19 + 4: prdata_t = gpr[19][63:32];
        `CPUSTATREG_X20 + 0: prdata_t = gpr[20][31: 0];
        `CPUSTATREG_X20 + 4: prdata_t = gpr[20][63:32];
        `CPUSTATREG_X21 + 0: prdata_t = gpr[21][31: 0];
        `CPUSTATREG_X21 + 4: prdata_t = gpr[21][63:32];
        `CPUSTATREG_X22 + 0: prdata_t = gpr[22][31: 0];
        `CPUSTATREG_X22 + 4: prdata_t = gpr[22][63:32];
        `CPUSTATREG_X23 + 0: prdata_t = gpr[23][31: 0];
        `CPUSTATREG_X23 + 4: prdata_t = gpr[23][63:32];
        `CPUSTATREG_X24 + 0: prdata_t = gpr[24][31: 0];
        `CPUSTATREG_X24 + 4: prdata_t = gpr[24][63:32];
        `CPUSTATREG_X25 + 0: prdata_t = gpr[25][31: 0];
        `CPUSTATREG_X25 + 4: prdata_t = gpr[25][63:32];
        `CPUSTATREG_X26 + 0: prdata_t = gpr[26][31: 0];
        `CPUSTATREG_X26 + 4: prdata_t = gpr[26][63:32];
        `CPUSTATREG_X27 + 0: prdata_t = gpr[27][31: 0];
        `CPUSTATREG_X27 + 4: prdata_t = gpr[27][63:32];
        `CPUSTATREG_X28 + 0: prdata_t = gpr[28][31: 0];
        `CPUSTATREG_X28 + 4: prdata_t = gpr[28][63:32];
        `CPUSTATREG_X29 + 0: prdata_t = gpr[29][31: 0];
        `CPUSTATREG_X29 + 4: prdata_t = gpr[29][63:32];
        `CPUSTATREG_X30 + 0: prdata_t = gpr[30][31: 0];
        `CPUSTATREG_X30 + 4: prdata_t = gpr[30][63:32];
        `CPUSTATREG_X31 + 0: prdata_t = gpr[31][31: 0];
        `CPUSTATREG_X31 + 4: prdata_t = gpr[31][63:32];
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
