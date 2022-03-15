`include "soc_define.h"

module peri (
    input             clk,
    input             rstn,
    apb_intf.slave    s_apb_intf,

    // UART interface
    input             uart_rx,
    output            uart_tx,

    // SPI interface
    // inout             sclk,
    // inout             nss,
    // inout             mosi,
    // inout             miso
    output            sclk,
    output            nss,
    output            mosi,
    input             miso,

    // SPI DMA interface
    axi_intf.master   m_dma_axi_intf,

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


spi_core u_spi_core (
    .clk        ( clk            ),
    .rstn       ( rstn           ),
    .s_apb_intf ( spi_apb.slave  ),

    // SPI interface
    .sclk       ( sclk           ),
    .nss        ( nss            ),
    .mosi       ( mosi           ),
    .miso       ( miso           ),

    // DMA
    .m_axi_intf ( m_dma_axi_intf ),

    // Interrupt
    .irq_out    ( spi_irq        )
);

endmodule
