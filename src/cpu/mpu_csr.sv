`include "cpu_define.h"

// Machine Memory Protection
// 0x3A0 MRW pmpcfg0 Physical memory protection configuration.
// 0x3A1 MRW pmpcfg1 Physical memory protection configuration, RV32 only.
// 0x3A2 MRW pmpcfg2 Physical memory protection configuration.
// 0x3A3 MRW pmpcfg3 Physical memory protection configuration, RV32 only.
// 0x3B0 MRW pmpaddr0 Physical memory protection address register.
// 0x3B1 MRW pmpaddr1 Physical memory protection address register.
// .
// .
// .
// 0x3BF MRW pmpaddr15 Physical memory protection address register.
// 0x3C0 MRW pmacfg0 Physical memory protection configuration.
// 0x3C1 MRW pmacfg1 Physical memory protection configuration, RV32 only.
// 0x3C2 MRW pmacfg2 Physical memory protection configuration.
// 0x3C3 MRW pmacfg3 Physical memory protection configuration, RV32 only.
// 0x3D0 MRW pmaaddr0 Physical memory protection address register.
// 0x3D1 MRW pmaaddr1 Physical memory protection address register.
// .
// .
// .
// 0x3DF MRW pmaaddr15 Physical memory protection address register.

module mpu_csr (
    input                    clk,
    input                    rstn,
    output logic [      7:0] pmp0cfg,
    output logic [      7:0] pmp1cfg,
    output logic [      7:0] pmp2cfg,
    output logic [      7:0] pmp3cfg,
    output logic [      7:0] pmp4cfg,
    output logic [      7:0] pmp5cfg,
    output logic [      7:0] pmp6cfg,
    output logic [      7:0] pmp7cfg,
    output logic [      7:0] pmp8cfg,
    output logic [      7:0] pmp9cfg,
    output logic [      7:0] pmp10cfg,
    output logic [      7:0] pmp11cfg,
    output logic [      7:0] pmp12cfg,
    output logic [      7:0] pmp13cfg,
    output logic [      7:0] pmp14cfg,
    output logic [      7:0] pmp15cfg,
    output logic [`XLEN-1:0] pmp0addr,
    output logic [`XLEN-1:0] pmp1addr,
    output logic [`XLEN-1:0] pmp2addr,
    output logic [`XLEN-1:0] pmp3addr,
    output logic [`XLEN-1:0] pmp4addr,
    output logic [`XLEN-1:0] pmp5addr,
    output logic [`XLEN-1:0] pmp6addr,
    output logic [`XLEN-1:0] pmp7addr,
    output logic [`XLEN-1:0] pmp8addr,
    output logic [`XLEN-1:0] pmp9addr,
    output logic [`XLEN-1:0] pmp10addr,
    output logic [`XLEN-1:0] pmp11addr,
    output logic [`XLEN-1:0] pmp12addr,
    output logic [`XLEN-1:0] pmp13addr,
    output logic [`XLEN-1:0] pmp14addr,
    output logic [`XLEN-1:0] pmp15addr,

    // CSR interface
    input                    csr_wr,
    input        [     11:0] csr_waddr,
    input        [     11:0] csr_raddr,
    input        [`XLEN-1:0] csr_wdata,
    output logic [`XLEN-1:0] csr_rdata

);

parameter [11:0] CSR_PMPADDR_ADDR [0:15] = {
    `CSR_PMPADDR0_ADDR ,
    `CSR_PMPADDR1_ADDR ,
    `CSR_PMPADDR2_ADDR ,
    `CSR_PMPADDR3_ADDR ,
    `CSR_PMPADDR4_ADDR ,
    `CSR_PMPADDR5_ADDR ,
    `CSR_PMPADDR6_ADDR ,
    `CSR_PMPADDR7_ADDR ,
    `CSR_PMPADDR8_ADDR ,
    `CSR_PMPADDR9_ADDR ,
    `CSR_PMPADDR10_ADDR,
    `CSR_PMPADDR11_ADDR,
    `CSR_PMPADDR12_ADDR,
    `CSR_PMPADDR13_ADDR,
    `CSR_PMPADDR14_ADDR,
    `CSR_PMPADDR15_ADDR
};

logic [     63:0] pmpcfg0;
logic [     63:0] pmpcfg2;

logic [     15:0] pmpcfg_l;
logic [      1:0] pmpcfg_a [16];
logic [     15:0] pmpcfg_x;
logic [     15:0] pmpcfg_w;
logic [     15:0] pmpcfg_r;
logic [`XLEN-1:0] pmpaddr  [16];

assign pmp0cfg  = {pmpcfg_l[0 ], 2'b0, pmpcfg_a[0 ], pmpcfg_x[0 ], pmpcfg_w[0 ], pmpcfg_r[0 ]};
assign pmp1cfg  = {pmpcfg_l[1 ], 2'b0, pmpcfg_a[1 ], pmpcfg_x[1 ], pmpcfg_w[1 ], pmpcfg_r[1 ]};
assign pmp2cfg  = {pmpcfg_l[2 ], 2'b0, pmpcfg_a[2 ], pmpcfg_x[2 ], pmpcfg_w[2 ], pmpcfg_r[2 ]};
assign pmp3cfg  = {pmpcfg_l[3 ], 2'b0, pmpcfg_a[3 ], pmpcfg_x[3 ], pmpcfg_w[3 ], pmpcfg_r[3 ]};
assign pmp4cfg  = {pmpcfg_l[4 ], 2'b0, pmpcfg_a[4 ], pmpcfg_x[4 ], pmpcfg_w[4 ], pmpcfg_r[4 ]};
assign pmp5cfg  = {pmpcfg_l[5 ], 2'b0, pmpcfg_a[5 ], pmpcfg_x[5 ], pmpcfg_w[5 ], pmpcfg_r[5 ]};
assign pmp6cfg  = {pmpcfg_l[6 ], 2'b0, pmpcfg_a[6 ], pmpcfg_x[6 ], pmpcfg_w[6 ], pmpcfg_r[6 ]};
assign pmp7cfg  = {pmpcfg_l[7 ], 2'b0, pmpcfg_a[7 ], pmpcfg_x[7 ], pmpcfg_w[7 ], pmpcfg_r[7 ]};
assign pmp8cfg  = {pmpcfg_l[8 ], 2'b0, pmpcfg_a[8 ], pmpcfg_x[8 ], pmpcfg_w[8 ], pmpcfg_r[8 ]};
assign pmp9cfg  = {pmpcfg_l[9 ], 2'b0, pmpcfg_a[9 ], pmpcfg_x[9 ], pmpcfg_w[9 ], pmpcfg_r[9 ]};
assign pmp10cfg = {pmpcfg_l[10], 2'b0, pmpcfg_a[10], pmpcfg_x[10], pmpcfg_w[10], pmpcfg_r[10]};
assign pmp11cfg = {pmpcfg_l[11], 2'b0, pmpcfg_a[11], pmpcfg_x[11], pmpcfg_w[11], pmpcfg_r[11]};
assign pmp12cfg = {pmpcfg_l[12], 2'b0, pmpcfg_a[12], pmpcfg_x[12], pmpcfg_w[12], pmpcfg_r[12]};
assign pmp13cfg = {pmpcfg_l[13], 2'b0, pmpcfg_a[13], pmpcfg_x[13], pmpcfg_w[13], pmpcfg_r[13]};
assign pmp14cfg = {pmpcfg_l[14], 2'b0, pmpcfg_a[14], pmpcfg_x[14], pmpcfg_w[14], pmpcfg_r[14]};
assign pmp15cfg = {pmpcfg_l[15], 2'b0, pmpcfg_a[15], pmpcfg_x[15], pmpcfg_w[15], pmpcfg_r[15]};

assign pmp0addr  = pmpaddr[0 ];
assign pmp1addr  = pmpaddr[1 ];
assign pmp2addr  = pmpaddr[2 ];
assign pmp3addr  = pmpaddr[3 ];
assign pmp4addr  = pmpaddr[4 ];
assign pmp5addr  = pmpaddr[5 ];
assign pmp6addr  = pmpaddr[6 ];
assign pmp7addr  = pmpaddr[7 ];
assign pmp8addr  = pmpaddr[8 ];
assign pmp9addr  = pmpaddr[9 ];
assign pmp10addr = pmpaddr[10];
assign pmp11addr = pmpaddr[11];
assign pmp12addr = pmpaddr[12];
assign pmp13addr = pmpaddr[13];
assign pmp14addr = pmpaddr[14];
assign pmp15addr = pmpaddr[15];

assign pmpcfg0 = {pmp7cfg,  pmp6cfg,  pmp5cfg,  pmp4cfg,  pmp3cfg,  pmp2cfg,  pmp1cfg, pmp0cfg};
assign pmpcfg2 = {pmp15cfg, pmp14cfg, pmp13cfg, pmp12cfg, pmp11cfg, pmp10cfg, pmp9cfg, pmp8cfg};

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < 16; i = i + 1) begin
            pmpcfg_l[i] <= 1'b0;
            pmpcfg_a[i] <= 2'b0;
            pmpcfg_x[i] <= 1'b0;
            pmpcfg_w[i] <= 1'b0;
            pmpcfg_r[i] <= 1'b0;
        end
    end
    else if (csr_wr && csr_waddr == `CSR_PMPCFG0_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmpcfg_l[i]) begin
                pmpcfg_l[i] <= csr_wdata[(i*8)+`PMPCFG_L_BIT];
                pmpcfg_a[i] <= csr_wdata[(i*8)+`PMPCFG_A_BIT];
                pmpcfg_x[i] <= csr_wdata[(i*8)+`PMPCFG_X_BIT];
                pmpcfg_w[i] <= csr_wdata[(i*8)+`PMPCFG_W_BIT] & csr_wdata[(i*8)+`PMPCFG_R_BIT]; // if R=0 => W=0
                pmpcfg_r[i] <= csr_wdata[(i*8)+`PMPCFG_R_BIT];
            end
        end
    end
    else if (csr_wr && csr_waddr == `CSR_PMPCFG1_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmpcfg_l[i+4]) begin
                pmpcfg_l[i+4] <= csr_wdata[(i*8)+`PMPCFG_L_BIT];
                pmpcfg_a[i+4] <= csr_wdata[(i*8)+`PMPCFG_A_BIT];
                pmpcfg_x[i+4] <= csr_wdata[(i*8)+`PMPCFG_X_BIT];
                pmpcfg_w[i+4] <= csr_wdata[(i*8)+`PMPCFG_W_BIT] & csr_wdata[(i*8)+`PMPCFG_R_BIT]; // if R=0 => W=0
                pmpcfg_r[i+4] <= csr_wdata[(i*8)+`PMPCFG_R_BIT];
            end
        end
    end
    else if (csr_wr && csr_waddr == `CSR_PMPCFG0_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmpcfg_l[i+8]) begin
                pmpcfg_l[i+8] <= csr_wdata[(i*8)+`PMPCFG_L_BIT];
                pmpcfg_a[i+8] <= csr_wdata[(i*8)+`PMPCFG_A_BIT];
                pmpcfg_x[i+8] <= csr_wdata[(i*8)+`PMPCFG_X_BIT];
                pmpcfg_w[i+8] <= csr_wdata[(i*8)+`PMPCFG_W_BIT] & csr_wdata[(i*8)+`PMPCFG_R_BIT]; // if R=0 => W=0
                pmpcfg_r[i+8] <= csr_wdata[(i*8)+`PMPCFG_R_BIT];
            end
        end
    end
    else if (csr_wr && csr_waddr == `CSR_PMPCFG0_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmpcfg_l[i+12]) begin
                pmpcfg_l[i+12] <= csr_wdata[(i*8)+`PMPCFG_L_BIT];
                pmpcfg_a[i+12] <= csr_wdata[(i*8)+`PMPCFG_A_BIT];
                pmpcfg_x[i+12] <= csr_wdata[(i*8)+`PMPCFG_X_BIT];
                pmpcfg_w[i+12] <= csr_wdata[(i*8)+`PMPCFG_W_BIT] & csr_wdata[(i*8)+`PMPCFG_R_BIT]; // if R=0 => W=0
                pmpcfg_r[i+12] <= csr_wdata[(i*8)+`PMPCFG_R_BIT];
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < 16; i = i + 1) begin
            pmpaddr[i] <= `XLEN'b0;
        end
    end
    else begin
        for (i = 0; i < 15; i = i + 1) begin
            if (csr_wr && csr_waddr == CSR_PMPADDR_ADDR[i] &&
                !pmpcfg_l[i] && !(pmpcfg_l[i+1] && pmpcfg_a[i+1] == `PMPCFG_A_TOR)) begin
                pmpaddr[i] <= csr_wdata & ((`XLEN'b1 << (`PADDR_LEN-2)) - `XLEN'b1);
            end
        end
        if (csr_wr && csr_waddr == CSR_PMPADDR_ADDR[16] && !pmpcfg_l[16]) begin
            pmpaddr[16] <= csr_wdata & ((`XLEN'b1 << (`PADDR_LEN-2)) - `XLEN'b1);
        end
    end
end

always_comb begin
    csr_rdata = `XLEN'b0;
    case (csr_raddr) 
        `CSR_PMPCFG0_ADDR  : csr_rdata = pmpcfg0[0+:`XLEN];
        `CSR_PMPCFG1_ADDR  : csr_rdata = pmpcfg0[63:32];
        `CSR_PMPCFG2_ADDR  : csr_rdata = pmpcfg2[0+:`XLEN];
        `CSR_PMPCFG3_ADDR  : csr_rdata = pmpcfg2[63:32];
        `CSR_PMPADDR0_ADDR : csr_rdata = pmpaddr[0 ] & ({`XLEN{pmpcfg_a[0 ][1]}} | ~(pmpaddr[0 ] & ~(pmpaddr[0 ] + `XLEN'b1)));
        `CSR_PMPADDR1_ADDR : csr_rdata = pmpaddr[1 ] & ({`XLEN{pmpcfg_a[1 ][1]}} | ~(pmpaddr[1 ] & ~(pmpaddr[1 ] + `XLEN'b1)));
        `CSR_PMPADDR2_ADDR : csr_rdata = pmpaddr[2 ] & ({`XLEN{pmpcfg_a[2 ][1]}} | ~(pmpaddr[2 ] & ~(pmpaddr[2 ] + `XLEN'b1)));
        `CSR_PMPADDR3_ADDR : csr_rdata = pmpaddr[3 ] & ({`XLEN{pmpcfg_a[3 ][1]}} | ~(pmpaddr[3 ] & ~(pmpaddr[3 ] + `XLEN'b1)));
        `CSR_PMPADDR4_ADDR : csr_rdata = pmpaddr[4 ] & ({`XLEN{pmpcfg_a[4 ][1]}} | ~(pmpaddr[4 ] & ~(pmpaddr[4 ] + `XLEN'b1)));
        `CSR_PMPADDR5_ADDR : csr_rdata = pmpaddr[5 ] & ({`XLEN{pmpcfg_a[5 ][1]}} | ~(pmpaddr[5 ] & ~(pmpaddr[5 ] + `XLEN'b1)));
        `CSR_PMPADDR6_ADDR : csr_rdata = pmpaddr[6 ] & ({`XLEN{pmpcfg_a[6 ][1]}} | ~(pmpaddr[6 ] & ~(pmpaddr[6 ] + `XLEN'b1)));
        `CSR_PMPADDR7_ADDR : csr_rdata = pmpaddr[7 ] & ({`XLEN{pmpcfg_a[7 ][1]}} | ~(pmpaddr[7 ] & ~(pmpaddr[7 ] + `XLEN'b1)));
        `CSR_PMPADDR8_ADDR : csr_rdata = pmpaddr[8 ] & ({`XLEN{pmpcfg_a[8 ][1]}} | ~(pmpaddr[8 ] & ~(pmpaddr[8 ] + `XLEN'b1)));
        `CSR_PMPADDR9_ADDR : csr_rdata = pmpaddr[9 ] & ({`XLEN{pmpcfg_a[9 ][1]}} | ~(pmpaddr[9 ] & ~(pmpaddr[9 ] + `XLEN'b1)));
        `CSR_PMPADDR10_ADDR: csr_rdata = pmpaddr[10] & ({`XLEN{pmpcfg_a[10][1]}} | ~(pmpaddr[10] & ~(pmpaddr[10] + `XLEN'b1)));
        `CSR_PMPADDR11_ADDR: csr_rdata = pmpaddr[11] & ({`XLEN{pmpcfg_a[11][1]}} | ~(pmpaddr[11] & ~(pmpaddr[11] + `XLEN'b1)));
        `CSR_PMPADDR12_ADDR: csr_rdata = pmpaddr[12] & ({`XLEN{pmpcfg_a[12][1]}} | ~(pmpaddr[12] & ~(pmpaddr[12] + `XLEN'b1)));
        `CSR_PMPADDR13_ADDR: csr_rdata = pmpaddr[13] & ({`XLEN{pmpcfg_a[13][1]}} | ~(pmpaddr[13] & ~(pmpaddr[13] + `XLEN'b1)));
        `CSR_PMPADDR14_ADDR: csr_rdata = pmpaddr[14] & ({`XLEN{pmpcfg_a[14][1]}} | ~(pmpaddr[14] & ~(pmpaddr[14] + `XLEN'b1)));
        `CSR_PMPADDR15_ADDR: csr_rdata = pmpaddr[15] & ({`XLEN{pmpcfg_a[15][1]}} | ~(pmpaddr[15] & ~(pmpaddr[15] + `XLEN'b1)));
    endcase
end


endmodule
