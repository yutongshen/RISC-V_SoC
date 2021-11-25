`include "cpu_define.h"

module mpu (
    input                         clk,
    input                         rstn,
    input        [           7:0] pmp0cfg,
    input        [           7:0] pmp1cfg,
    input        [           7:0] pmp2cfg,
    input        [           7:0] pmp3cfg,
    input        [           7:0] pmp4cfg,
    input        [           7:0] pmp5cfg,
    input        [           7:0] pmp6cfg,
    input        [           7:0] pmp7cfg,
    input        [           7:0] pmp8cfg,
    input        [           7:0] pmp9cfg,
    input        [           7:0] pmp10cfg,
    input        [           7:0] pmp11cfg,
    input        [           7:0] pmp12cfg,
    input        [           7:0] pmp13cfg,
    input        [           7:0] pmp14cfg,
    input        [           7:0] pmp15cfg,
    input        [     `XLEN-1:0] pmp0addr,
    input        [     `XLEN-1:0] pmp1addr,
    input        [     `XLEN-1:0] pmp2addr,
    input        [     `XLEN-1:0] pmp3addr,
    input        [     `XLEN-1:0] pmp4addr,
    input        [     `XLEN-1:0] pmp5addr,
    input        [     `XLEN-1:0] pmp6addr,
    input        [     `XLEN-1:0] pmp7addr,
    input        [     `XLEN-1:0] pmp8addr,
    input        [     `XLEN-1:0] pmp9addr,
    input        [     `XLEN-1:0] pmp10addr,
    input        [     `XLEN-1:0] pmp11addr,
    input        [     `XLEN-1:0] pmp12addr,
    input        [     `XLEN-1:0] pmp13addr,
    input        [     `XLEN-1:0] pmp14addr,
    input        [     `XLEN-1:0] pmp15addr,
    input        [`PADDR_LEN-1:0] paddr,

    output logic                  pmp_v,
    output logic                  pmp_l,
    output logic                  pmp_x,
    output logic                  pmp_w,
    output logic                  pmp_r
        
);

logic [      7:0] pmpcfg  [16];
logic [`XLEN-1:0] pmpaddr [16];
logic [     15:0] match;

assign pmpcfg [0 ] = pmp0cfg;
assign pmpcfg [1 ] = pmp1cfg;
assign pmpcfg [2 ] = pmp2cfg;
assign pmpcfg [3 ] = pmp3cfg;
assign pmpcfg [4 ] = pmp4cfg;
assign pmpcfg [5 ] = pmp5cfg;
assign pmpcfg [6 ] = pmp6cfg;
assign pmpcfg [7 ] = pmp7cfg;
assign pmpcfg [8 ] = pmp8cfg;
assign pmpcfg [9 ] = pmp9cfg;
assign pmpcfg [10] = pmp10cfg;
assign pmpcfg [11] = pmp11cfg;
assign pmpcfg [12] = pmp12cfg;
assign pmpcfg [13] = pmp13cfg;
assign pmpcfg [14] = pmp14cfg;
assign pmpcfg [15] = pmp15cfg;

assign pmpaddr[0 ] = pmp0addr;
assign pmpaddr[1 ] = pmp1addr;
assign pmpaddr[2 ] = pmp2addr;
assign pmpaddr[3 ] = pmp3addr;
assign pmpaddr[4 ] = pmp4addr;
assign pmpaddr[5 ] = pmp5addr;
assign pmpaddr[6 ] = pmp6addr;
assign pmpaddr[7 ] = pmp7addr;
assign pmpaddr[8 ] = pmp8addr;
assign pmpaddr[9 ] = pmp9addr;
assign pmpaddr[10] = pmp10addr;
assign pmpaddr[11] = pmp11addr;
assign pmpaddr[12] = pmp12addr;
assign pmpaddr[13] = pmp13addr;
assign pmpaddr[14] = pmp14addr;
assign pmpaddr[15] = pmp15addr;

genvar g;
generate
    for (g = 0; g < 16; g = g + 1) begin: g_pmp
        logic [  `XLEN:0] mask_tmp;
        logic [`XLEN+2:0] mask;
        logic             napot_match;
        logic             tor_match;

        assign mask_tmp = {pmpaddr[g], pmp0cfg[`PMPCFG_A_BIT] != `PMPCFG_A_NAPOT};
        assign mask     = {~(mask_tmp & ~(mask_tmp + {`XLEN'b0, 1'b1})), 2'b0};
        
        assign napot_match = ({pmpaddr[g][0+:`PADDR_LEN-2], 2'b0} ^ paddr) & mask[0+:`PADDR_LEN];
        if (g == 0) begin
            assign tor_match = {`PADDR_LEN{1'b0}} <= paddr && paddr < {pmpaddr[g][0+:`PADDR_LEN-2], 2'b0};
        end
        else begin
            assign tor_match = {pmpaddr[g-1][0+:`PADDR_LEN-2], 2'b0} <= paddr &&
                               paddr < {pmpaddr[g][0+:`PADDR_LEN-2], 2'b0};
        end
        
        assign match[g] = (pmp0cfg[`PMPCFG_A_BIT] == `PMPCFG_A_TOR   && tor_match) |
                          (pmp0cfg[`PMPCFG_A_BIT] == `PMPCFG_A_NA4   && napot_match) |
                          (pmp0cfg[`PMPCFG_A_BIT] == `PMPCFG_A_NAPOT && napot_match);
    end
endgenerate

assign pmp_v = |match;

always_comb begin
    integer i;
    pmp_l = 1'b0;
    pmp_x = 1'b0;
    pmp_w = 1'b0;
    pmp_r = 1'b0;
    for (i = 0; i < 16; i = i + 1) begin
        pmp_l = pmp_l | (match[i] & pmp0cfg[`PMPCFG_L_BIT]);
        pmp_x = pmp_x | (match[i] & pmp0cfg[`PMPCFG_X_BIT]);
        pmp_w = pmp_w | (match[i] & pmp0cfg[`PMPCFG_W_BIT]);
        pmp_r = pmp_r | (match[i] & pmp0cfg[`PMPCFG_R_BIT]);
    end
end

endmodule
