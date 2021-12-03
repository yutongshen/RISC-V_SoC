`ifndef __DBGAPB_DEFINE__
`define __DBGAPB_DEFINE__

`define INST_ATTACH     12'h000
`define INST_RESUME     12'h001

`define INST_INSTREG_WR 12'h002
`define INST_EXECUTE    12'h003
`define INST_STATUS_RD  12'h004
`define INST_PC_RD      12'h005
`define INST_GPR_RD     12'h006
`define INST_CSR_RD     12'h007
`define INST_GPR_WR     12'h008
`define INST_CSR_WR     12'h009

`endif
