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
