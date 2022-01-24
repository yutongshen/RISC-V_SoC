`include "soc_define.h"

module peri (
    input             clk,
    input             rstn,
    apb_intf.slave    s_apb_intf,

    // UART interface
    input             uart_rx,
    output            uart_tx,

    // SPI interface
    inout             sclk,
    inout             nss,
    inout             mosi,
    inout             miso,

    // IRQ
    output            uart_irq,
    output            spi_irq
);

apb_intf uart_apb();
apb_intf spi_apb();

peri_apb_conn u_peri_apb_conn (
    .peri_apb ( s_apb_intf      ),
    .uart_apb ( uart_apb.master ),
    .spi_apb  ( spi_apb.master  )
);

uart u_uart(
    .clk        ( clk            ),
    .rstn       ( rstn           ),
    .s_apb_intf ( uart_apb.slave ),

    .irq_out    ( uart_irq       ),
    .uart_rx    ( uart_rx        ),
    .uart_tx    ( uart_tx        )
);


spi u_spi (
    .clk        ( clk           ),
    .rstn       ( rstn          ),
    .s_apb_intf ( spi_apb.slave ),

    // SPI interface
    .sclk       ( sclk          ),
    .nss        ( nss           ),
    .mosi       ( mosi          ),
    .miso       ( miso          ),

    // Interrupt
    .irq_out    ( spi_irq       )
);

endmodule
