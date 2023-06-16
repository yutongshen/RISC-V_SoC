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

`define PMP_GRAN_SHIFT 2
`define PMP_TOR_MASK   (-(`XLEN'h1 << (`PMP_GRAN_SHIFT - 2)))

module mpu_csr (
    input                    clk,
    input                    rstn,
    input        [      1:0] misa_mxl,
    output logic [    8-1:0] pmpcfg  [16],
    output logic [`XLEN-1:0] pmpaddr [16],
    output logic [    8-1:0] pmacfg  [16],
    output logic [`XLEN-1:0] pmaaddr [16],

    // CSR interface
    input                    csr_wr,
    input        [     11:0] csr_waddr,
    input        [     11:0] csr_raddr,
    // input        [`XLEN-1:0] csr_wdata,
    input        [`XLEN-1:0] csr_sdata,
    input        [`XLEN-1:0] csr_cdata,
    output logic [`XLEN-1:0] csr_rdata,
    output logic             csr_hit
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
                pmpcfg_l[i] <= `CSR_WDATA(pmpcfg_l[i], (i*8)+`PMPCFG_L_BIT);
                pmpcfg_a[i] <= `CSR_WDATA(pmpcfg_a[i], (i*8)+`PMPCFG_A_BIT);
                pmpcfg_x[i] <= `CSR_WDATA(pmpcfg_x[i], (i*8)+`PMPCFG_X_BIT);
                pmpcfg_w[i] <= `CSR_WDATA(pmpcfg_w[i], (i*8)+`PMPCFG_W_BIT)&
                               `CSR_WDATA(pmpcfg_r[i], (i*8)+`PMPCFG_R_BIT); // if R=0 => W=0
                pmpcfg_r[i] <= `CSR_WDATA(pmpcfg_r[i], (i*8)+`PMPCFG_R_BIT);
            end
        end
`ifndef RV32
        for (i = 4; i < 8; i = i + 1) begin
            if (~pmpcfg_l[i] && misa_mxl == `MISA_MXL_XLEN_64) begin
                pmpcfg_l[i] <= `CSR_WDATA(pmpcfg_l[i], (i*8)+`PMPCFG_L_BIT);
                pmpcfg_a[i] <= `CSR_WDATA(pmpcfg_a[i], (i*8)+`PMPCFG_A_BIT);
                pmpcfg_x[i] <= `CSR_WDATA(pmpcfg_x[i], (i*8)+`PMPCFG_X_BIT);
                pmpcfg_w[i] <= `CSR_WDATA(pmpcfg_w[i], (i*8)+`PMPCFG_W_BIT)&
                               `CSR_WDATA(pmpcfg_r[i], (i*8)+`PMPCFG_R_BIT); // if R=0 => W=0
                pmpcfg_r[i] <= `CSR_WDATA(pmpcfg_r[i], (i*8)+`PMPCFG_R_BIT);
            end
        end
`endif
    end
    else if (csr_wr && csr_waddr == `CSR_PMPCFG1_ADDR && misa_mxl == `MISA_MXL_XLEN_32) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmpcfg_l[i+4]) begin
                pmpcfg_l[i+4] <= `CSR_WDATA(pmpcfg_l[i+4], (i*8)+`PMPCFG_L_BIT);
                pmpcfg_a[i+4] <= `CSR_WDATA(pmpcfg_a[i+4], (i*8)+`PMPCFG_A_BIT);
                pmpcfg_x[i+4] <= `CSR_WDATA(pmpcfg_x[i+4], (i*8)+`PMPCFG_X_BIT);
                pmpcfg_w[i+4] <= `CSR_WDATA(pmpcfg_w[i+4], (i*8)+`PMPCFG_W_BIT)&
                                 `CSR_WDATA(pmpcfg_r[i+4], (i*8)+`PMPCFG_R_BIT); // if R=0 => W=0
                pmpcfg_r[i+4] <= `CSR_WDATA(pmpcfg_r[i+4], (i*8)+`PMPCFG_R_BIT);
            end
        end
    end
    else if (csr_wr && csr_waddr == `CSR_PMPCFG2_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmpcfg_l[i+8]) begin
                pmpcfg_l[i+8] <= `CSR_WDATA(pmpcfg_l[i+8], (i*8)+`PMPCFG_L_BIT);
                pmpcfg_a[i+8] <= `CSR_WDATA(pmpcfg_a[i+8], (i*8)+`PMPCFG_A_BIT);
                pmpcfg_x[i+8] <= `CSR_WDATA(pmpcfg_x[i+8], (i*8)+`PMPCFG_X_BIT);
                pmpcfg_w[i+8] <= `CSR_WDATA(pmpcfg_w[i+8], (i*8)+`PMPCFG_W_BIT)&
                                 `CSR_WDATA(pmpcfg_r[i+8], (i*8)+`PMPCFG_R_BIT); // if R=0 => W=0
                pmpcfg_r[i+8] <= `CSR_WDATA(pmpcfg_r[i+8], (i*8)+`PMPCFG_R_BIT);
            end
        end
`ifndef RV32
        for (i = 4; i < 8; i = i + 1) begin
            if (~pmpcfg_l[i+8] && misa_mxl == `MISA_MXL_XLEN_64) begin
                pmpcfg_l[i+8] <= `CSR_WDATA(pmpcfg_l[i+8], (i*8)+`PMPCFG_L_BIT);
                pmpcfg_a[i+8] <= `CSR_WDATA(pmpcfg_a[i+8], (i*8)+`PMPCFG_A_BIT);
                pmpcfg_x[i+8] <= `CSR_WDATA(pmpcfg_x[i+8], (i*8)+`PMPCFG_X_BIT);
                pmpcfg_w[i+8] <= `CSR_WDATA(pmpcfg_w[i+8], (i*8)+`PMPCFG_W_BIT)&
                                 `CSR_WDATA(pmpcfg_r[i+8], (i*8)+`PMPCFG_R_BIT); // if R=0 => W=0
                pmpcfg_r[i+8] <= `CSR_WDATA(pmpcfg_r[i+8], (i*8)+`PMPCFG_R_BIT);
            end
        end
`endif
    end
    else if (csr_wr && csr_waddr == `CSR_PMPCFG3_ADDR && misa_mxl == `MISA_MXL_XLEN_32) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmpcfg_l[i+12]) begin
                pmpcfg_l[i+12] <= `CSR_WDATA(pmpcfg_l[i+12], (i*8)+`PMPCFG_L_BIT);
                pmpcfg_a[i+12] <= `CSR_WDATA(pmpcfg_a[i+12], (i*8)+`PMPCFG_A_BIT);
                pmpcfg_x[i+12] <= `CSR_WDATA(pmpcfg_x[i+12], (i*8)+`PMPCFG_X_BIT);
                pmpcfg_w[i+12] <= `CSR_WDATA(pmpcfg_w[i+12], (i*8)+`PMPCFG_W_BIT)&
                                  `CSR_WDATA(pmpcfg_r[i+12], (i*8)+`PMPCFG_R_BIT); // if R=0 => W=0
                pmpcfg_r[i+12] <= `CSR_WDATA(pmpcfg_r[i+12], (i*8)+`PMPCFG_R_BIT);
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
                pmpaddr[i] <= `CSR_WDATA(pmpaddr[i], `XLEN-1:0) &
                              ((`XLEN'b1 << (`PADDR_LEN-2)) - `XLEN'b1);
            end
        end
        if (csr_wr && csr_waddr == CSR_PMPADDR_ADDR[15] && !pmpcfg_l[15]) begin
            pmpaddr[15] <= `CSR_WDATA(pmpaddr[15], `XLEN-1:0) &
                           ((`XLEN'b1 << (`PADDR_LEN-2)) - `XLEN'b1);
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
        for (i = 2; i < 16; i = i + 1) begin
            pmacfg_l[i] <= 1'b0;
            pmacfg_a[i] <= 2'b0;
            pmacfg_c[i] <= 1'b0;
            pmacfg_e[i] <= 1'b0;
        end
        pmacfg_l[0] <= 1'b1;
        pmacfg_a[0] <= `PMACFG_A_TOR;
        pmacfg_c[0] <= 1'b1;
        pmacfg_e[0] <= 1'b0;
        pmacfg_l[1] <= 1'b1;
        pmacfg_a[1] <= `PMACFG_A_TOR;
        pmacfg_c[1] <= 1'b0;
        pmacfg_e[1] <= 1'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_PMACFG0_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmacfg_l[i]) begin
                pmacfg_l[i] <= `CSR_WDATA(pmacfg_l[i], (i*8)+`PMACFG_L_BIT);
                pmacfg_a[i] <= `CSR_WDATA(pmacfg_a[i], (i*8)+`PMACFG_A_BIT);
                pmacfg_c[i] <= `CSR_WDATA(pmacfg_c[i], (i*8)+`PMACFG_C_BIT);
                pmacfg_e[i] <= `CSR_WDATA(pmacfg_e[i], (i*8)+`PMACFG_E_BIT);
            end
        end
`ifndef RV32
        for (i = 4; i < 8; i = i + 1) begin
            if (~pmacfg_l[i] && misa_mxl == `MISA_MXL_XLEN_64) begin
                pmacfg_l[i] <= `CSR_WDATA(pmacfg_l[i], (i*8)+`PMACFG_L_BIT);
                pmacfg_a[i] <= `CSR_WDATA(pmacfg_a[i], (i*8)+`PMACFG_A_BIT);
                pmacfg_c[i] <= `CSR_WDATA(pmacfg_c[i], (i*8)+`PMACFG_C_BIT);
                pmacfg_e[i] <= `CSR_WDATA(pmacfg_e[i], (i*8)+`PMACFG_E_BIT);
            end
        end
`endif
    end
    else if (csr_wr && csr_waddr == `CSR_PMACFG1_ADDR && misa_mxl == `MISA_MXL_XLEN_32) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmacfg_l[i+4]) begin
                pmacfg_l[i+4] <= `CSR_WDATA(pmacfg_l[i+4], (i*8)+`PMACFG_L_BIT);
                pmacfg_a[i+4] <= `CSR_WDATA(pmacfg_a[i+4], (i*8)+`PMACFG_A_BIT);
                pmacfg_c[i+4] <= `CSR_WDATA(pmacfg_c[i+4], (i*8)+`PMACFG_C_BIT);
                pmacfg_e[i+4] <= `CSR_WDATA(pmacfg_e[i+4], (i*8)+`PMACFG_E_BIT);
            end
        end
    end
    else if (csr_wr && csr_waddr == `CSR_PMACFG2_ADDR) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmacfg_l[i+8]) begin
                pmacfg_l[i+8] <= `CSR_WDATA(pmacfg_l[i+8], (i*8)+`PMACFG_L_BIT);
                pmacfg_a[i+8] <= `CSR_WDATA(pmacfg_a[i+8], (i*8)+`PMACFG_A_BIT);
                pmacfg_c[i+8] <= `CSR_WDATA(pmacfg_c[i+8], (i*8)+`PMACFG_C_BIT);
                pmacfg_e[i+8] <= `CSR_WDATA(pmacfg_e[i+8], (i*8)+`PMACFG_E_BIT);
            end
        end
`ifndef RV32
        for (i = 4; i < 8; i = i + 1) begin
            if (~pmacfg_l[i+8] && misa_mxl == `MISA_MXL_XLEN_64) begin
                pmacfg_l[i+8] <= `CSR_WDATA(pmacfg_l[i+8], (i*8)+`PMACFG_L_BIT);
                pmacfg_a[i+8] <= `CSR_WDATA(pmacfg_a[i+8], (i*8)+`PMACFG_A_BIT);
                pmacfg_c[i+8] <= `CSR_WDATA(pmacfg_c[i+8], (i*8)+`PMACFG_C_BIT);
                pmacfg_e[i+8] <= `CSR_WDATA(pmacfg_e[i+8], (i*8)+`PMACFG_E_BIT);
            end
        end
`endif
    end
    else if (csr_wr && csr_waddr == `CSR_PMACFG3_ADDR && misa_mxl == `MISA_MXL_XLEN_32) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (~pmacfg_l[i+12]) begin
                pmacfg_l[i+12] <= `CSR_WDATA(pmacfg_l[i+12], (i*8)+`PMACFG_L_BIT);
                pmacfg_a[i+12] <= `CSR_WDATA(pmacfg_a[i+12], (i*8)+`PMACFG_A_BIT);
                pmacfg_c[i+12] <= `CSR_WDATA(pmacfg_c[i+12], (i*8)+`PMACFG_C_BIT);
                pmacfg_e[i+12] <= `CSR_WDATA(pmacfg_e[i+12], (i*8)+`PMACFG_E_BIT);
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 2; i < 16; i = i + 1) begin
            pmaaddr[i] <= `XLEN'b0;
        end
        pmaaddr[0] <= `XLEN'h0100_0000;
        pmaaddr[1] <= `XLEN'h1000_0000;
    end
    else begin
        for (i = 0; i < 15; i = i + 1) begin
            if (csr_wr && csr_waddr == CSR_PMAADDR_ADDR[i] &&
                !pmacfg_l[i] && !(pmacfg_l[i+1] && pmacfg_a[i+1] == `PMACFG_A_TOR)) begin
                pmaaddr[i] <= `CSR_WDATA(pmaaddr[i], `XLEN-1:0) &
                              ((`XLEN'b1 << (`PADDR_LEN-2)) - `XLEN'b1);
            end
        end
        if (csr_wr && csr_waddr == CSR_PMAADDR_ADDR[15] && !pmacfg_l[15]) begin
            pmaaddr[15] <= `CSR_WDATA(pmaaddr[15], `XLEN-1:0) &
                           ((`XLEN'b1 << (`PADDR_LEN-2)) - `XLEN'b1);
        end
    end
end

always_comb begin
    csr_rdata = `XLEN'b0;
    csr_hit   = 1'b1;
    case (csr_raddr) 
        `CSR_PMPCFG0_ADDR  : csr_rdata = pmpcfg0[0+:`XLEN];
        `CSR_PMPCFG1_ADDR  : csr_rdata = pmpcfg0[63:32];
        `CSR_PMPCFG2_ADDR  : csr_rdata = pmpcfg2[0+:`XLEN];
        `CSR_PMPCFG3_ADDR  : csr_rdata = pmpcfg2[63:32];
        `CSR_PMPADDR0_ADDR : csr_rdata = pmpcfg_a[0 ][1] ? (pmpaddr[0 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[0 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR1_ADDR : csr_rdata = pmpcfg_a[1 ][1] ? (pmpaddr[1 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[1 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR2_ADDR : csr_rdata = pmpcfg_a[2 ][1] ? (pmpaddr[2 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[2 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR3_ADDR : csr_rdata = pmpcfg_a[3 ][1] ? (pmpaddr[3 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[3 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR4_ADDR : csr_rdata = pmpcfg_a[4 ][1] ? (pmpaddr[4 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[4 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR5_ADDR : csr_rdata = pmpcfg_a[5 ][1] ? (pmpaddr[5 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[5 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR6_ADDR : csr_rdata = pmpcfg_a[6 ][1] ? (pmpaddr[6 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[6 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR7_ADDR : csr_rdata = pmpcfg_a[7 ][1] ? (pmpaddr[7 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[7 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR8_ADDR : csr_rdata = pmpcfg_a[8 ][1] ? (pmpaddr[8 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[8 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR9_ADDR : csr_rdata = pmpcfg_a[9 ][1] ? (pmpaddr[9 ] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[9 ] & `PMP_TOR_MASK);
        `CSR_PMPADDR10_ADDR: csr_rdata = pmpcfg_a[10][1] ? (pmpaddr[10] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[10] & `PMP_TOR_MASK);
        `CSR_PMPADDR11_ADDR: csr_rdata = pmpcfg_a[11][1] ? (pmpaddr[11] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[11] & `PMP_TOR_MASK);
        `CSR_PMPADDR12_ADDR: csr_rdata = pmpcfg_a[12][1] ? (pmpaddr[12] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[12] & `PMP_TOR_MASK);
        `CSR_PMPADDR13_ADDR: csr_rdata = pmpcfg_a[13][1] ? (pmpaddr[13] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[13] & `PMP_TOR_MASK);
        `CSR_PMPADDR14_ADDR: csr_rdata = pmpcfg_a[14][1] ? (pmpaddr[14] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[14] & `PMP_TOR_MASK);
        `CSR_PMPADDR15_ADDR: csr_rdata = pmpcfg_a[15][1] ? (pmpaddr[15] | (~`PMP_TOR_MASK >> 1)) : (pmpaddr[15] & `PMP_TOR_MASK);
        `CSR_PMACFG0_ADDR  : csr_rdata = pmacfg0[0+:`XLEN];
        `CSR_PMACFG1_ADDR  : csr_rdata = pmacfg0[63:32];
        `CSR_PMACFG2_ADDR  : csr_rdata = pmacfg2[0+:`XLEN];
        `CSR_PMACFG3_ADDR  : csr_rdata = pmacfg2[63:32];
        `CSR_PMAADDR0_ADDR : csr_rdata = pmacfg_a[0 ][1] ? (pmaaddr[0 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[0 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR1_ADDR : csr_rdata = pmacfg_a[1 ][1] ? (pmaaddr[1 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[1 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR2_ADDR : csr_rdata = pmacfg_a[2 ][1] ? (pmaaddr[2 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[2 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR3_ADDR : csr_rdata = pmacfg_a[3 ][1] ? (pmaaddr[3 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[3 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR4_ADDR : csr_rdata = pmacfg_a[4 ][1] ? (pmaaddr[4 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[4 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR5_ADDR : csr_rdata = pmacfg_a[5 ][1] ? (pmaaddr[5 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[5 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR6_ADDR : csr_rdata = pmacfg_a[6 ][1] ? (pmaaddr[6 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[6 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR7_ADDR : csr_rdata = pmacfg_a[7 ][1] ? (pmaaddr[7 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[7 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR8_ADDR : csr_rdata = pmacfg_a[8 ][1] ? (pmaaddr[8 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[8 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR9_ADDR : csr_rdata = pmacfg_a[9 ][1] ? (pmaaddr[9 ] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[9 ] & `PMP_TOR_MASK);
        `CSR_PMAADDR10_ADDR: csr_rdata = pmacfg_a[10][1] ? (pmaaddr[10] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[10] & `PMP_TOR_MASK);
        `CSR_PMAADDR11_ADDR: csr_rdata = pmacfg_a[11][1] ? (pmaaddr[11] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[11] & `PMP_TOR_MASK);
        `CSR_PMAADDR12_ADDR: csr_rdata = pmacfg_a[12][1] ? (pmaaddr[12] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[12] & `PMP_TOR_MASK);
        `CSR_PMAADDR13_ADDR: csr_rdata = pmacfg_a[13][1] ? (pmaaddr[13] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[13] & `PMP_TOR_MASK);
        `CSR_PMAADDR14_ADDR: csr_rdata = pmacfg_a[14][1] ? (pmaaddr[14] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[14] & `PMP_TOR_MASK);
        `CSR_PMAADDR15_ADDR: csr_rdata = pmacfg_a[15][1] ? (pmaaddr[15] | (~`PMP_TOR_MASK >> 1)) : (pmaaddr[15] & `PMP_TOR_MASK);
        default            : csr_hit   = 1'b0;
    endcase
end


endmodule
