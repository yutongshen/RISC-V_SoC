`include "cpu_define.h"

module mpu (
    input                         clk,
    input                         rstn,
    input        [           7:0] pmpcfg  [16],
    input        [     `XLEN-1:0] pmpaddr [16],
    input        [`PADDR_LEN-1:0] paddr,

    output logic                  pmp_v,
    output logic                  pmp_l,
    output logic                  pmp_x,
    output logic                  pmp_w,
    output logic                  pmp_r
        
);

logic [     15:0] match;
logic             pmp_v_tmp;
logic             pmp_l_tmp;
logic             pmp_x_tmp;
logic             pmp_w_tmp;
logic             pmp_r_tmp;


genvar g;
generate
    for (g = 0; g < 16; g = g + 1) begin: g_pmp
        logic [  `XLEN:0] mask_tmp;
        logic [`XLEN+2:0] mask;
        logic             napot_match;
        logic             tor_match;

        assign mask_tmp = {pmpaddr[g], pmpcfg[g][`PMPCFG_A_BIT] != `PMPCFG_A_NA4};
        assign mask     = {~(mask_tmp & ~(mask_tmp + {`XLEN'b0, 1'b1})), 2'b0};

        assign napot_match = !(({pmpaddr[g][0+:`PADDR_LEN-2], 2'b0} ^ paddr) & mask[0+:`PADDR_LEN]);
        if (g == 0) begin
            assign tor_match = {`PADDR_LEN{1'b0}} <= paddr && paddr < {pmpaddr[g][0+:`PADDR_LEN-2], 2'b0};
        end
        else begin
            assign tor_match = {pmpaddr[g-1][0+:`PADDR_LEN-2], 2'b0} <= paddr &&
                               paddr < {pmpaddr[g][0+:`PADDR_LEN-2], 2'b0};
        end
        
        assign match[g] = (pmpcfg[g][`PMPCFG_A_BIT] == `PMPCFG_A_TOR   && tor_match) |
                          (pmpcfg[g][`PMPCFG_A_BIT] == `PMPCFG_A_NA4   && napot_match) |
                          (pmpcfg[g][`PMPCFG_A_BIT] == `PMPCFG_A_NAPOT && napot_match);
    end
endgenerate

assign pmp_v_tmp = |match;

always_comb begin
    integer i;
    pmp_l_tmp = 1'b0;
    pmp_x_tmp = 1'b0;
    pmp_w_tmp = 1'b0;
    pmp_r_tmp = 1'b0;
    for (i = 0; i < 16; i = i + 1) begin
        pmp_l_tmp = pmp_l_tmp | (match[i] & pmpcfg[i][`PMPCFG_L_BIT]);
        pmp_x_tmp = pmp_x_tmp | (match[i] & pmpcfg[i][`PMPCFG_X_BIT]);
        pmp_w_tmp = pmp_w_tmp | (match[i] & pmpcfg[i][`PMPCFG_W_BIT]);
        pmp_r_tmp = pmp_r_tmp | (match[i] & pmpcfg[i][`PMPCFG_R_BIT]);
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        pmp_v <= 1'b0;
        pmp_l <= 1'b0;
        pmp_x <= 1'b0;
        pmp_w <= 1'b0;
        pmp_r <= 1'b0;
    end
    else begin
        pmp_v <= pmp_v_tmp;
        pmp_l <= pmp_l_tmp;
        pmp_x <= pmp_x_tmp;
        pmp_w <= pmp_w_tmp;
        pmp_r <= pmp_r_tmp;
    end
end

endmodule
