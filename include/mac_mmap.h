`ifndef __MAC_MMAP__
`define __MAC_MMAP__

// MAC_BASE

`define MAC_RESET  12'h00
`define MAC_TXLEN  12'h04
`define MAC_TXFIFO 12'h08
`define MAC_TXCTRL 12'h0C
`define MAC_TXDIS  12'h10
`define MAC_RXLEN  12'h14
`define MAC_RXFIFO 12'h18
`define MAC_RXCTRL 12'h1C
`define MAC_RXDIS  12'h20
`define MAC_IE     12'h24
`define MAC_IP     12'h28
`define MAC_IC     12'h2C
`define MAC_MAC0   12'h30
`define MAC_MAC1   12'h34

`endif
