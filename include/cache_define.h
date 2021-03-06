`ifndef __CACHE_DEFINE__
`define __CACHE_DEFINE__

`ifdef RV32
`define CACHE_DATA_WIDTH 32
`define CACHE_ADDR_WIDTH 32
`else
`define CACHE_DATA_WIDTH 64
`define CACHE_ADDR_WIDTH 32
`endif
`define CACHE_BLK_WIDTH  4
`define CACHE_IDX_WIDTH  6
`define CACHE_TAG_WIDTH  (`CACHE_ADDR_WIDTH - `CACHE_BLK_WIDTH - `CACHE_IDX_WIDTH)
`define CACHE_TAG_REGION (`CACHE_BLK_WIDTH + `CACHE_IDX_WIDTH)+:`CACHE_TAG_WIDTH
`define CACHE_BLK_SIZE   2 ** (`CACHE_BLK_WIDTH + 3)

`endif
