module uart_mdl (
    output logic uart_tx,
    input        uart_rx
);

`define BAUD_RATE      115200
`define UART_BIT_WIDTH (1000000000 / `BAUD_RATE)

logic [7:0] fifo [16];
logic [7:0] rxdata;
logic [7:0] rxparity;
logic [7:0] txdata;
logic [7:0] txparity;
logic [4:0] tx_ptr;
logic [4:0] rx_ptr;

// tx side
initial begin
    tx_ptr   = 1'b0;
    txdata   = 8'b0;
    txparity = 1'b0;
    uart_tx  = 1'b1;
    #(`UART_BIT_WIDTH);
    forever begin
        wait (tx_ptr !== rx_ptr);
        txdata   = fifo[tx_ptr[3:0]];
        txparity = ^txdata;
        tx_ptr   = tx_ptr + 1;
        // start bit
        uart_tx  = 1'b0;
        #(`UART_BIT_WIDTH);
        // data bit0
        uart_tx  = txdata[0];
        txdata   = txdata >> 1;
        #(`UART_BIT_WIDTH);
        // data bit1
        uart_tx  = txdata[0];
        txdata   = txdata >> 1;
        #(`UART_BIT_WIDTH);
        // data bit2
        uart_tx  = txdata[0];
        txdata   = txdata >> 1;
        #(`UART_BIT_WIDTH);
        // data bit3
        uart_tx  = txdata[0];
        txdata   = txdata >> 1;
        #(`UART_BIT_WIDTH);
        // data bit4
        uart_tx  = txdata[0];
        txdata   = txdata >> 1;
        #(`UART_BIT_WIDTH);
        // data bit5
        uart_tx  = txdata[0];
        txdata   = txdata >> 1;
        #(`UART_BIT_WIDTH);
        // data bit6
        uart_tx  = txdata[0];
        txdata   = txdata >> 1;
        #(`UART_BIT_WIDTH);
        // data bit7
        uart_tx  = txdata[0];
        txdata   = txdata >> 1;
        #(`UART_BIT_WIDTH);
`ifdef UART_MDL_PARITY
        uart_tx  = ~txparity;
        #(`UART_BIT_WIDTH);
`endif
        // stop bit
        uart_tx  = 1'b1;
        #(`UART_BIT_WIDTH);
    end
end

// rx side
initial begin
    rx_ptr   = 1'b0;
    rxdata   = 8'b0;
    rxparity = 1'b0;
    #(`UART_BIT_WIDTH);
    forever begin
        wait (uart_rx === 1'b0);
        #(`UART_BIT_WIDTH/2);
        // start bit
        #(`UART_BIT_WIDTH);
        // data bit0
        rxdata  = {uart_rx, rxdata[7:1]};
        #(`UART_BIT_WIDTH);
        // data bit1
        rxdata  = {uart_rx, rxdata[7:1]};
        #(`UART_BIT_WIDTH);
        // data bit2
        rxdata  = {uart_rx, rxdata[7:1]};
        #(`UART_BIT_WIDTH);
        // data bit3
        rxdata  = {uart_rx, rxdata[7:1]};
        #(`UART_BIT_WIDTH);
        // data bit4
        rxdata  = {uart_rx, rxdata[7:1]};
        #(`UART_BIT_WIDTH);
        // data bit5
        rxdata  = {uart_rx, rxdata[7:1]};
        #(`UART_BIT_WIDTH);
        // data bit6
        rxdata  = {uart_rx, rxdata[7:1]};
        #(`UART_BIT_WIDTH);
        // data bit7
        rxdata  = {uart_rx, rxdata[7:1]};
        #(`UART_BIT_WIDTH);
`ifdef UART_MDL_PARITY
        rxparity = uart_rx;
        #(`UART_BIT_WIDTH);
`endif
        // stop bit
        // #(`UART_BIT_WIDTH);
`ifdef UART_MDL_PARITY
        if (rxparity ^ ^rxdata) begin
            $display("[UART_MDL] parity error detect !");
        end
`endif
        $write("%c", rxdata);
        fifo[rx_ptr[3:0]] = rxdata;
        rx_ptr  = rx_ptr + 1;
    end
end

endmodule
