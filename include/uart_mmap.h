`ifndef __UART_MMAP__
`define __UART_MMAP__

`define UART_TXFIFO 12'h00
`define UART_RXFIFO 12'h04
`define UART_TXCTRL 12'h08
`define UART_RXCTRL 12'h0C
`define UART_IE     12'h10
`define UART_IP     12'h14
`define UART_IC     12'h18
`define UART_DIV    12'h1C
`define UART_LCR    12'h20

`endif
