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
    output logic [    8-1:0] pmpcfg  [16],
    output logic [`XLEN-1:0] pmpaddr [16],
    output logic [    8-1:0] pmacfg  [16],
    output logic [`XLEN-1:0] pmaaddr [16],

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

always_comb begin
    integer i;
    for (i = 0; i < 16; i = i + 1) begin
        pmpcfg[i] = {pmpcfg_l[i], 2'b0, pmpcfg_a[i], pmpcfg_x[i], pmpcfg_w[i], pmpcfg_r[i]};
    end

    for (i = 0; i < 8; i = i + 1) begin
        pmpcfg0[i*8+:8] = pmpcfg[i  ];
        pmpcfg2[i*8+:8] = pmpcfg[i+8];
    end
end

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
        if (csr_wr && csr_waddr == CSR_PMPADDR_ADDR[15] && !pmpcfg_l[15]) begin
            pmpaddr[15] <= csr_wdata & ((`XLEN'b1 << (`PADDR_LEN-2)) - `XLEN'b1);
        end
    end
end

parameter [11:0] CSR_PMAADDR_ADDR [0:15] = {
    `CSR_PMAADDR0_ADDR ,
    `CSR_PMAADDR1_ADDR ,
    `CSR_PMAADDR2_ADDR ,
    `CSR_PMAADDR3_ADDR ,
    `CSR_PMAADDR4_ADDR ,
    `CSR_PMAADDR5_ADDR ,
    `CSR_PMAADDR6_ADDR ,
    `CSR_PMAADDR7_ADDR ,
    `CSR_PMAADDR8_ADDR ,
    `CSR_PMAADDR9_ADDR ,
    `CSR_PMAADDR10_ADDR,
    `CSR_PMAADDR11_ADDR,
    `CSR_PMAADDR12_ADDR,
    `CSR_PMAADDR13_ADDR,
    `CSR_PMAADDR14_ADDR,
    `CSR_PMAADDR15_ADDR
};

logic [     63:0] pmacfg0;
logic [     63:0] pmacfg2;

logic [     15:0] pmacfg_l;
logic [      1:0] pmacfg_a [16];
logic [     15:0] pmacfg_c;
logic [     15:0] pmacfg_e;

always_comb begin
    integer i;
    for (i = 0; i < 16; i = i + 1) begin
        pmacfg[i] = {pmacfg_l[i], 2'b0, pmacfg_a[i], 1'b0, pmacfg_c[i], pmacfg_e[i]};
    end

    for (i = 0; i < 8; i = i + 1) begin
        pmacfg0[i*8+:8] = pmacfg[i  ];
        pmacfg2[i*8+:8] = pmacfg[i+8];
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < 15; i = i + 1) begin
            pmacfg_l[i] <= 1'b0;
            pmacfg_a[i] <= 2'b0;
            pmacfg_c[i] <= 1'b0;
            pmacfg_e[i] <= 1'b0;
        end
        pmacfg_l[15] <= 1'b1;
        pmacfg_a[15] <= `PMACFG_A_NAPOT;
        pmacfg_c[15] <= 1'b1;
        pmacfg_e[15] <= 1'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_PMACFG0_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmacfg_l[i]) begin
                pmacfg_l[i] <= csr_wdata[(i*8)+`PMACFG_L_BIT];
                pmacfg_a[i] <= csr_wdata[(i*8)+`PMACFG_A_BIT];
                pmacfg_c[i] <= csr_wdata[(i*8)+`PMACFG_C_BIT];
                pmacfg_e[i] <= csr_wdata[(i*8)+`PMACFG_E_BIT];
            end
        end
    end
    else if (csr_wr && csr_waddr == `CSR_PMACFG1_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmacfg_l[i+4]) begin
                pmacfg_l[i+4] <= csr_wdata[(i*8)+`PMACFG_L_BIT];
                pmacfg_a[i+4] <= csr_wdata[(i*8)+`PMACFG_A_BIT];
                pmacfg_c[i+4] <= csr_wdata[(i*8)+`PMACFG_C_BIT];
                pmacfg_e[i+4] <= csr_wdata[(i*8)+`PMACFG_E_BIT];
            end
        end
    end
    else if (csr_wr && csr_waddr == `CSR_PMACFG0_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmacfg_l[i+8]) begin
                pmacfg_l[i+8] <= csr_wdata[(i*8)+`PMACFG_L_BIT];
                pmacfg_a[i+8] <= csr_wdata[(i*8)+`PMACFG_A_BIT];
                pmacfg_c[i+8] <= csr_wdata[(i*8)+`PMACFG_C_BIT];
                pmacfg_e[i+8] <= csr_wdata[(i*8)+`PMACFG_E_BIT];
            end
        end
    end
    else if (csr_wr && csr_waddr == `CSR_PMACFG0_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmacfg_l[i+12]) begin
                pmacfg_l[i+12] <= csr_wdata[(i*8)+`PMACFG_L_BIT];
                pmacfg_a[i+12] <= csr_wdata[(i*8)+`PMACFG_A_BIT];
                pmacfg_c[i+12] <= csr_wdata[(i*8)+`PMACFG_C_BIT];
                pmacfg_e[i+12] <= csr_wdata[(i*8)+`PMACFG_E_BIT];
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < 15; i = i + 1) begin
            pmaaddr[i] <= `XLEN'b0;
        end
        pmaaddr[15] <= `XLEN'hffff;
    end
    else begin
        for (i = 0; i < 15; i = i + 1) begin
            if (csr_wr && csr_waddr == CSR_PMAADDR_ADDR[i] &&
                !pmacfg_l[i] && !(pmacfg_l[i+1] && pmacfg_a[i+1] == `PMACFG_A_TOR)) begin
                pmaaddr[i] <= csr_wdata & ((`XLEN'b1 << (`PADDR_LEN-2)) - `XLEN'b1);
            end
        end
        if (csr_wr && csr_waddr == CSR_PMAADDR_ADDR[15] && !pmacfg_l[15]) begin
            pmaaddr[15] <= csr_wdata & ((`XLEN'b1 << (`PADDR_LEN-2)) - `XLEN'b1);
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
        `CSR_PMACFG0_ADDR  : csr_rdata = pmacfg0[0+:`XLEN];
        `CSR_PMACFG1_ADDR  : csr_rdata = pmacfg0[63:32];
        `CSR_PMACFG2_ADDR  : csr_rdata = pmacfg2[0+:`XLEN];
        `CSR_PMACFG3_ADDR  : csr_rdata = pmacfg2[63:32];
        `CSR_PMAADDR0_ADDR : csr_rdata = pmaaddr[0 ] & ({`XLEN{pmacfg_a[0 ][1]}} | ~(pmaaddr[0 ] & ~(pmaaddr[0 ] + `XLEN'b1)));
        `CSR_PMAADDR1_ADDR : csr_rdata = pmaaddr[1 ] & ({`XLEN{pmacfg_a[1 ][1]}} | ~(pmaaddr[1 ] & ~(pmaaddr[1 ] + `XLEN'b1)));
        `CSR_PMAADDR2_ADDR : csr_rdata = pmaaddr[2 ] & ({`XLEN{pmacfg_a[2 ][1]}} | ~(pmaaddr[2 ] & ~(pmaaddr[2 ] + `XLEN'b1)));
        `CSR_PMAADDR3_ADDR : csr_rdata = pmaaddr[3 ] & ({`XLEN{pmacfg_a[3 ][1]}} | ~(pmaaddr[3 ] & ~(pmaaddr[3 ] + `XLEN'b1)));
        `CSR_PMAADDR4_ADDR : csr_rdata = pmaaddr[4 ] & ({`XLEN{pmacfg_a[4 ][1]}} | ~(pmaaddr[4 ] & ~(pmaaddr[4 ] + `XLEN'b1)));
        `CSR_PMAADDR5_ADDR : csr_rdata = pmaaddr[5 ] & ({`XLEN{pmacfg_a[5 ][1]}} | ~(pmaaddr[5 ] & ~(pmaaddr[5 ] + `XLEN'b1)));
        `CSR_PMAADDR6_ADDR : csr_rdata = pmaaddr[6 ] & ({`XLEN{pmacfg_a[6 ][1]}} | ~(pmaaddr[6 ] & ~(pmaaddr[6 ] + `XLEN'b1)));
        `CSR_PMAADDR7_ADDR : csr_rdata = pmaaddr[7 ] & ({`XLEN{pmacfg_a[7 ][1]}} | ~(pmaaddr[7 ] & ~(pmaaddr[7 ] + `XLEN'b1)));
        `CSR_PMAADDR8_ADDR : csr_rdata = pmaaddr[8 ] & ({`XLEN{pmacfg_a[8 ][1]}} | ~(pmaaddr[8 ] & ~(pmaaddr[8 ] + `XLEN'b1)));
        `CSR_PMAADDR9_ADDR : csr_rdata = pmaaddr[9 ] & ({`XLEN{pmacfg_a[9 ][1]}} | ~(pmaaddr[9 ] & ~(pmaaddr[9 ] + `XLEN'b1)));
        `CSR_PMAADDR10_ADDR: csr_rdata = pmaaddr[10] & ({`XLEN{pmacfg_a[10][1]}} | ~(pmaaddr[10] & ~(pmaaddr[10] + `XLEN'b1)));
        `CSR_PMAADDR11_ADDR: csr_rdata = pmaaddr[11] & ({`XLEN{pmacfg_a[11][1]}} | ~(pmaaddr[11] & ~(pmaaddr[11] + `XLEN'b1)));
        `CSR_PMAADDR12_ADDR: csr_rdata = pmaaddr[12] & ({`XLEN{pmacfg_a[12][1]}} | ~(pmaaddr[12] & ~(pmaaddr[12] + `XLEN'b1)));
        `CSR_PMAADDR13_ADDR: csr_rdata = pmaaddr[13] & ({`XLEN{pmacfg_a[13][1]}} | ~(pmaaddr[13] & ~(pmaaddr[13] + `XLEN'b1)));
        `CSR_PMAADDR14_ADDR: csr_rdata = pmaaddr[14] & ({`XLEN{pmacfg_a[14][1]}} | ~(pmaaddr[14] & ~(pmaaddr[14] + `XLEN'b1)));
        `CSR_PMAADDR15_ADDR: csr_rdata = pmaaddr[15] & ({`XLEN{pmacfg_a[15][1]}} | ~(pmaaddr[15] & ~(pmaaddr[15] + `XLEN'b1)));
    endcase
end


endmodule
