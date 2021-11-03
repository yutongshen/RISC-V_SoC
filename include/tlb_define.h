`ifndef __TLB_DEFINE__
`define __TLB_DEFINE__

`define TLB_WAY_NUM   4
`define TLB_IDX_WIDTH 5
`define TLB_DEPTH     (2 ** `TLB_IDX_WIDTH)
`define TLB_VPN_WIDTH 36
`define TLB_PTE_WIDTH 64
`define TLB_TAG_WIDTH (`TLB_VPN_WIDTH - `TLB_IDX_WIDTH)

`endif
