`ifndef __CPU_DEFINE__
`define __CPU_DEFINE__

`define RV32

`ifdef RV32
  `define XLEN 32
  
  `define IM_ADDR_LEN 32
  `define IM_DATA_LEN 32
  
  `define DM_ADDR_LEN 32
  `define DM_DATA_LEN 32
`else
  `define XLEN 64
  
  `define IM_ADDR_LEN 64
  `define IM_DATA_LEN 32
  
  `define DM_ADDR_LEN 64
  `define DM_DATA_LEN 64

`endif


`define ALU_OP_LEN 4
`define CSR_OP_LEN 2

`define PRV_U 2'h0
`define PRV_S 2'h1
`define PRV_H 2'h2
`define PRV_M 2'h3

`define CSR_USTATUS_ADDR        12'h000
`define CSR_UIE_ADDR            12'h004
`define CSR_UTVEC_ADDR          12'h005
`define CSR_USCRATCH_ADDR       12'h040
`define CSR_UEPC_ADDR           12'h041
`define CSR_UCAUSE_ADDR         12'h042
`define CSR_UTVAL_ADDR          12'h043
`define CSR_UIP_ADDR            12'h044
`define CSR_FFLAGS_ADDR         12'h001
`define CSR_FRM_ADDR            12'h002
`define CSR_FCSR_ADDR           12'h003
`define CSR_CYCLE_ADDR          12'hc00
`define CSR_TIME_ADDR           12'hc01
`define CSR_INSTRET_ADDR        12'hc02
`define CSR_HPMCOUNTER3_ADDR    12'hc03
`define CSR_HPMCOUNTER4_ADDR    12'hc04
`define CSR_HPMCOUNTER5_ADDR    12'hc05
`define CSR_HPMCOUNTER6_ADDR    12'hc06
`define CSR_HPMCOUNTER7_ADDR    12'hc07
`define CSR_HPMCOUNTER8_ADDR    12'hc08
`define CSR_HPMCOUNTER9_ADDR    12'hc09
`define CSR_HPMCOUNTER10_ADDR   12'hc0a
`define CSR_HPMCOUNTER11_ADDR   12'hc0b
`define CSR_HPMCOUNTER12_ADDR   12'hc0c
`define CSR_HPMCOUNTER13_ADDR   12'hc0d
`define CSR_HPMCOUNTER14_ADDR   12'hc0e
`define CSR_HPMCOUNTER15_ADDR   12'hc0f
`define CSR_HPMCOUNTER16_ADDR   12'hc10
`define CSR_HPMCOUNTER17_ADDR   12'hc11
`define CSR_HPMCOUNTER18_ADDR   12'hc12
`define CSR_HPMCOUNTER19_ADDR   12'hc13
`define CSR_HPMCOUNTER20_ADDR   12'hc14
`define CSR_HPMCOUNTER21_ADDR   12'hc15
`define CSR_HPMCOUNTER22_ADDR   12'hc16
`define CSR_HPMCOUNTER23_ADDR   12'hc17
`define CSR_HPMCOUNTER24_ADDR   12'hc18
`define CSR_HPMCOUNTER25_ADDR   12'hc19
`define CSR_HPMCOUNTER26_ADDR   12'hc1a
`define CSR_HPMCOUNTER27_ADDR   12'hc1b
`define CSR_HPMCOUNTER28_ADDR   12'hc1c
`define CSR_HPMCOUNTER29_ADDR   12'hc1d
`define CSR_HPMCOUNTER30_ADDR   12'hc1e
`define CSR_HPMCOUNTER31_ADDR   12'hc1f
`define CSR_CYCLEH_ADDR         12'hc80
`define CSR_TIMEH_ADDR          12'hc81
`define CSR_INSTRETH_ADDR       12'hc82
`define CSR_HPMCOUNTER3H_ADDR   12'hc83
`define CSR_HPMCOUNTER4H_ADDR   12'hc84
`define CSR_HPMCOUNTER5H_ADDR   12'hc85
`define CSR_HPMCOUNTER6H_ADDR   12'hc86
`define CSR_HPMCOUNTER7H_ADDR   12'hc87
`define CSR_HPMCOUNTER8H_ADDR   12'hc88
`define CSR_HPMCOUNTER9H_ADDR   12'hc89
`define CSR_HPMCOUNTER10H_ADDR  12'hc8a
`define CSR_HPMCOUNTER11H_ADDR  12'hc8b
`define CSR_HPMCOUNTER12H_ADDR  12'hc8c
`define CSR_HPMCOUNTER13H_ADDR  12'hc8d
`define CSR_HPMCOUNTER14H_ADDR  12'hc8e
`define CSR_HPMCOUNTER15H_ADDR  12'hc8f
`define CSR_HPMCOUNTER16H_ADDR  12'hc90
`define CSR_HPMCOUNTER17H_ADDR  12'hc91
`define CSR_HPMCOUNTER18H_ADDR  12'hc92
`define CSR_HPMCOUNTER19H_ADDR  12'hc93
`define CSR_HPMCOUNTER20H_ADDR  12'hc94
`define CSR_HPMCOUNTER21H_ADDR  12'hc95
`define CSR_HPMCOUNTER22H_ADDR  12'hc96
`define CSR_HPMCOUNTER23H_ADDR  12'hc97
`define CSR_HPMCOUNTER24H_ADDR  12'hc98
`define CSR_HPMCOUNTER25H_ADDR  12'hc99
`define CSR_HPMCOUNTER26H_ADDR  12'hc9a
`define CSR_HPMCOUNTER27H_ADDR  12'hc9b
`define CSR_HPMCOUNTER28H_ADDR  12'hc9c
`define CSR_HPMCOUNTER29H_ADDR  12'hc9d
`define CSR_HPMCOUNTER30H_ADDR  12'hc9e
`define CSR_HPMCOUNTER31H_ADDR  12'hc9f

`define CSR_SSTATUS_ADDR        12'h100
`define CSR_SEDELEG_ADDR        12'h102
`define CSR_SIDELEG_ADDR        12'h103
`define CSR_SIE_ADDR            12'h104
`define CSR_STVEC_ADDR          12'h105
`define CSR_SCOUNTEREN_ADDR     12'h106
`define CSR_SSCRATCH_ADDR       12'h140
`define CSR_SEPC_ADDR           12'h141
`define CSR_SCAUSE_ADDR         12'h142
`define CSR_STVAL_ADDR          12'h143
`define CSR_SIP_ADDR            12'h144
`define CSR_SATP_ADDR           12'h180

`define CSR_MVENDORID_ADDR      12'hf11
`define CSR_MARCHID_ADDR        12'hf12
`define CSR_MIMPID_ADDR         12'hf13
`define CSR_MHARTID_ADDR        12'hf14
`define CSR_MSTATUS_ADDR        12'h300
`define CSR_MISA_ADDR           12'h301
`define CSR_MEDELEG_ADDR        12'h302
`define CSR_MIDELEG_ADDR        12'h303
`define CSR_MIE_ADDR            12'h304
`define CSR_MTVEC_ADDR          12'h305
`define CSR_MCOUNTEREN_ADDR     12'h306
`define CSR_MSCRATCH_ADDR       12'h340
`define CSR_MEPC_ADDR           12'h341
`define CSR_MCAUSE_ADDR         12'h342
`define CSR_MTVAL_ADDR          12'h343
`define CSR_MIP_ADDR            12'h344
`define CSR_PMPCFG0_ADDR        12'h3a0
`define CSR_PMPCFG1_ADDR        12'h3a1
`define CSR_PMPCFG2_ADDR        12'h3a2
`define CSR_PMPCFG3_ADDR        12'h3a3
`define CSR_PMPADDR0_ADDR       12'h3b0
`define CSR_PMPADDR1_ADDR       12'h3b1
`define CSR_PMPADDR2_ADDR       12'h3b2
`define CSR_PMPADDR3_ADDR       12'h3b3
`define CSR_PMPADDR4_ADDR       12'h3b4
`define CSR_PMPADDR5_ADDR       12'h3b5
`define CSR_PMPADDR6_ADDR       12'h3b6
`define CSR_PMPADDR7_ADDR       12'h3b7
`define CSR_PMPADDR8_ADDR       12'h3b8
`define CSR_PMPADDR9_ADDR       12'h3b9
`define CSR_PMPADDR10_ADDR      12'h3ba
`define CSR_PMPADDR11_ADDR      12'h3bb
`define CSR_PMPADDR12_ADDR      12'h3bc
`define CSR_PMPADDR13_ADDR      12'h3bd
`define CSR_PMPADDR14_ADDR      12'h3be
`define CSR_PMPADDR15_ADDR      12'h3bf
`define CSR_PMACFG0_ADDR        12'h3c0
`define CSR_PMACFG1_ADDR        12'h3c1
`define CSR_PMACFG2_ADDR        12'h3c2
`define CSR_PMACFG3_ADDR        12'h3c3
`define CSR_PMAADDR0_ADDR       12'h3d0
`define CSR_PMAADDR1_ADDR       12'h3d1
`define CSR_PMAADDR2_ADDR       12'h3d2
`define CSR_PMAADDR3_ADDR       12'h3d3
`define CSR_PMAADDR4_ADDR       12'h3d4
`define CSR_PMAADDR5_ADDR       12'h3d5
`define CSR_PMAADDR6_ADDR       12'h3d6
`define CSR_PMAADDR7_ADDR       12'h3d7
`define CSR_PMAADDR8_ADDR       12'h3d8
`define CSR_PMAADDR9_ADDR       12'h3d9
`define CSR_PMAADDR10_ADDR      12'h3da
`define CSR_PMAADDR11_ADDR      12'h3db
`define CSR_PMAADDR12_ADDR      12'h3dc
`define CSR_PMAADDR13_ADDR      12'h3dd
`define CSR_PMAADDR14_ADDR      12'h3de
`define CSR_PMAADDR15_ADDR      12'h3df
`define CSR_MCYCLE_ADDR         12'hb00
`define CSR_MINSTRET_ADDR       12'hb02
`define CSR_MHPMCOUNTER3_ADDR   12'hb03
`define CSR_MHPMCOUNTER4_ADDR   12'hb04
`define CSR_MHPMCOUNTER5_ADDR   12'hb05
`define CSR_MHPMCOUNTER6_ADDR   12'hb06
`define CSR_MHPMCOUNTER7_ADDR   12'hb07
`define CSR_MHPMCOUNTER8_ADDR   12'hb08
`define CSR_MHPMCOUNTER9_ADDR   12'hb09
`define CSR_MHPMCOUNTER10_ADDR  12'hb0a
`define CSR_MHPMCOUNTER11_ADDR  12'hb0b
`define CSR_MHPMCOUNTER12_ADDR  12'hb0c
`define CSR_MHPMCOUNTER13_ADDR  12'hb0d
`define CSR_MHPMCOUNTER14_ADDR  12'hb0e
`define CSR_MHPMCOUNTER15_ADDR  12'hb0f
`define CSR_MHPMCOUNTER16_ADDR  12'hb10
`define CSR_MHPMCOUNTER17_ADDR  12'hb11
`define CSR_MHPMCOUNTER18_ADDR  12'hb12
`define CSR_MHPMCOUNTER19_ADDR  12'hb13
`define CSR_MHPMCOUNTER20_ADDR  12'hb14
`define CSR_MHPMCOUNTER21_ADDR  12'hb15
`define CSR_MHPMCOUNTER22_ADDR  12'hb16
`define CSR_MHPMCOUNTER23_ADDR  12'hb17
`define CSR_MHPMCOUNTER24_ADDR  12'hb18
`define CSR_MHPMCOUNTER25_ADDR  12'hb19
`define CSR_MHPMCOUNTER26_ADDR  12'hb1a
`define CSR_MHPMCOUNTER27_ADDR  12'hb1b
`define CSR_MHPMCOUNTER28_ADDR  12'hb1c
`define CSR_MHPMCOUNTER29_ADDR  12'hb1d
`define CSR_MHPMCOUNTER30_ADDR  12'hb1e
`define CSR_MHPMCOUNTER31_ADDR  12'hb1f
`define CSR_MCYCLEH_ADDR        12'hb80
`define CSR_MINSTRETH_ADDR      12'hb82
`define CSR_MHPMCOUNTER3H_ADDR  12'hb83
`define CSR_MHPMCOUNTER4H_ADDR  12'hb84
`define CSR_MHPMCOUNTER5H_ADDR  12'hb85
`define CSR_MHPMCOUNTER6H_ADDR  12'hb86
`define CSR_MHPMCOUNTER7H_ADDR  12'hb87
`define CSR_MHPMCOUNTER8H_ADDR  12'hb88
`define CSR_MHPMCOUNTER9H_ADDR  12'hb89
`define CSR_MHPMCOUNTER10H_ADDR 12'hb8a
`define CSR_MHPMCOUNTER11H_ADDR 12'hb8b
`define CSR_MHPMCOUNTER12H_ADDR 12'hb8c
`define CSR_MHPMCOUNTER13H_ADDR 12'hb8d
`define CSR_MHPMCOUNTER14H_ADDR 12'hb8e
`define CSR_MHPMCOUNTER15H_ADDR 12'hb8f
`define CSR_MHPMCOUNTER16H_ADDR 12'hb90
`define CSR_MHPMCOUNTER17H_ADDR 12'hb91
`define CSR_MHPMCOUNTER18H_ADDR 12'hb92
`define CSR_MHPMCOUNTER19H_ADDR 12'hb93
`define CSR_MHPMCOUNTER20H_ADDR 12'hb94
`define CSR_MHPMCOUNTER21H_ADDR 12'hb95
`define CSR_MHPMCOUNTER22H_ADDR 12'hb96
`define CSR_MHPMCOUNTER23H_ADDR 12'hb97
`define CSR_MHPMCOUNTER24H_ADDR 12'hb98
`define CSR_MHPMCOUNTER25H_ADDR 12'hb99
`define CSR_MHPMCOUNTER26H_ADDR 12'hb9a
`define CSR_MHPMCOUNTER27H_ADDR 12'hb9b
`define CSR_MHPMCOUNTER28H_ADDR 12'hb9c
`define CSR_MHPMCOUNTER29H_ADDR 12'hb9d
`define CSR_MHPMCOUNTER30H_ADDR 12'hb9e
`define CSR_MHPMCOUNTER31H_ADDR 12'hb9f
`define CSR_MHPMEVENT3_ADDR     12'h323
`define CSR_MHPMEVENT4_ADDR     12'h324
`define CSR_MHPMEVENT5_ADDR     12'h325
`define CSR_MHPMEVENT6_ADDR     12'h326
`define CSR_MHPMEVENT7_ADDR     12'h327
`define CSR_MHPMEVENT8_ADDR     12'h328
`define CSR_MHPMEVENT9_ADDR     12'h329
`define CSR_MHPMEVENT10_ADDR    12'h32a
`define CSR_MHPMEVENT11_ADDR    12'h32b
`define CSR_MHPMEVENT12_ADDR    12'h32c
`define CSR_MHPMEVENT13_ADDR    12'h32d
`define CSR_MHPMEVENT14_ADDR    12'h32e
`define CSR_MHPMEVENT15_ADDR    12'h32f
`define CSR_MHPMEVENT16_ADDR    12'h330
`define CSR_MHPMEVENT17_ADDR    12'h331
`define CSR_MHPMEVENT18_ADDR    12'h332
`define CSR_MHPMEVENT19_ADDR    12'h333
`define CSR_MHPMEVENT20_ADDR    12'h334
`define CSR_MHPMEVENT21_ADDR    12'h335
`define CSR_MHPMEVENT22_ADDR    12'h336
`define CSR_MHPMEVENT23_ADDR    12'h337
`define CSR_MHPMEVENT24_ADDR    12'h338
`define CSR_MHPMEVENT25_ADDR    12'h339
`define CSR_MHPMEVENT26_ADDR    12'h33a
`define CSR_MHPMEVENT27_ADDR    12'h33b
`define CSR_MHPMEVENT28_ADDR    12'h33c
`define CSR_MHPMEVENT29_ADDR    12'h33d
`define CSR_MHPMEVENT30_ADDR    12'h33e
`define CSR_MHPMEVENT31_ADDR    12'h33f

`define CSR_TSELECT_ADDR        12'h7a0
`define CSR_TDATA1_ADDR         12'h7a1
`define CSR_TDATA2_ADDR         12'h7a2
`define CSR_TDATA3_ADDR         12'h7a3
`define CSR_DCSR_ADDR           12'h7b0
`define CSR_DPC_ADDR            12'h7b1
`define CSR_DSCRATCH_ADDR       12'h7b2

`define MSTATUS_SIE   (`XLEN'd1 <<  1)
`define MSTATUS_MIE   (`XLEN'd1 <<  3)
`define MSTATUS_SPIE  (`XLEN'd1 <<  5)
`define MSTATUS_MPIE  (`XLEN'd1 <<  7)
`define MSTATUS_SPP   (`XLEN'd1 <<  8)
`define MSTATUS_MPP   (`XLEN'd3 << 11)
`define MSTATUS_FS    (`XLEN'd3 << 13)
`define MSTATUS_XS    (`XLEN'd3 << 15)
`define MSTATUS_MPRV  (`XLEN'd1 << 17)
`define MSTATUS_SUM   (`XLEN'd1 << 18)
`define MSTATUS_MXR   (`XLEN'd1 << 19)
`define MSTATUS_TW    (`XLEN'd1 << 21)
`define MSTATUS_TVM   (`XLEN'd1 << 20)
`define MSTATUS_TSR   (`XLEN'd1 << 22)
`define MSTATUS_UXL   (`XLEN'd3 << 32)
`define MSTATUS_SXL   (`XLEN'd3 << 34)
`define MSTATUS_64_SD (`XLEN'd1 << 63)
`define MSTATUS_32_SD (`XLEN'd1 << 31)

`define MSTATUS_SIE_BIT    1+:1
`define MSTATUS_MIE_BIT    3+:1
`define MSTATUS_SPIE_BIT   5+:1
`define MSTATUS_MPIE_BIT   7+:1
`define MSTATUS_SPP_BIT    8+:1
`define MSTATUS_MPP_BIT   11+:2
`define MSTATUS_FS_BIT    13+:2
`define MSTATUS_XS_BIT    15+:2
`define MSTATUS_MPRV_BIT  17+:1
`define MSTATUS_SUM_BIT   18+:1
`define MSTATUS_MXR_BIT   19+:1
`define MSTATUS_TVM_BIT   20+:1
`define MSTATUS_TW_BIT    21+:1
`define MSTATUS_TSR_BIT   22+:1
`define MSTATUS_UXL_BIT   32+:2
`define MSTATUS_SXL_BIT   34+:2
`define MSTATUS_64_SD_BIT 63+:1
`define MSTATUS_32_SD_BIT 31+:1

`define CAUSE_MISALIGNED_FETCH       `XLEN'h0
`define CAUSE_INSTRUCTION_ACCESS     `XLEN'h1
`define CAUSE_ILLEGAL_INSTRUCTION    `XLEN'h2
`define CAUSE_BREAKPOINT             `XLEN'h3
`define CAUSE_MISALIGNED_LOAD        `XLEN'h4
`define CAUSE_LOAD_ACCESS            `XLEN'h5
`define CAUSE_MISALIGNED_STORE       `XLEN'h6
`define CAUSE_STORE_ACCESS           `XLEN'h7
`define CAUSE_USER_ECALL             `XLEN'h8
`define CAUSE_SUPERVISOR_ECALL       `XLEN'h9
`define CAUSE_HYPERVISOR_ECALL       `XLEN'ha
`define CAUSE_MACHINE_ECALL          `XLEN'hb
`define CAUSE_INSTRUCTION_PAGE_FAULT `XLEN'hc
`define CAUSE_LOAD_PAGE_FAULT        `XLEN'hd
`define CAUSE_STORE_PAGE_FAULT       `XLEN'hf

`define MIP_SSIP_BIT  1
`define MIP_MSIP_BIT  3
`define MIP_STIP_BIT  5
`define MIP_MTIP_BIT  7
`define MIP_SEIP_BIT  9
`define MIP_MEIP_BIT 11

`define MIP_SSIP (`XLEN'b1 <<  1)
`define MIP_MSIP (`XLEN'b1 <<  3)
`define MIP_STIP (`XLEN'b1 <<  5)
`define MIP_MTIP (`XLEN'b1 <<  7)
`define MIP_SEIP (`XLEN'b1 <<  9)
`define MIP_MEIP (`XLEN'b1 << 11)

`define PMPCFG_L_BIT 7
`define PMPCFG_A_BIT 3+:2
`define PMPCFG_X_BIT 2
`define PMPCFG_W_BIT 1
`define PMPCFG_R_BIT 0

`define PMPCFG_A_OFF   2'h0
`define PMPCFG_A_TOR   2'h1
`define PMPCFG_A_NA4   2'h2
`define PMPCFG_A_NAPOT 2'h3

`define PMACFG_L_BIT 7
`define PMACFG_A_BIT 3+:2
`define PMACFG_C_BIT 1
`define PMACFG_E_BIT 0

`define PMACFG_A_OFF   2'h0
`define PMACFG_A_TOR   2'h1
`define PMACFG_A_NA4   2'h2
`define PMACFG_A_NAPOT 2'h3

`ifdef RV32
  `define SATP_PPN_WIDTH  22
  `define SATP_ASID_WIDTH  9
  `define SATP_MODE_WIDTH  1
  `define SATP_PPN_BIT     0+:`SATP_PPN_WIDTH
  `define SATP_ASID_BIT   22+:`SATP_ASID_WIDTH
  `define SATP_MODE_BIT   31+:`SATP_MODE_WIDTH
`else
  `define SATP_PPN_WIDTH  44
  `define SATP_ASID_WIDTH 16
  `define SATP_MODE_WIDTH  4
  `define SATP_PPN_BIT     0+:`SATP_PPN_WIDTH
  `define SATP_ASID_BIT   44+:`SATP_ASID_WIDTH
  `define SATP_MODE_BIT   60+:`SATP_MODE_WIDTH
`endif

`define PADDR_LEN       (`SATP_PPN_WIDTH + 12)

`endif
