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

    // RMII interface
    input             rmii_refclk,
    input             rmii_crsdv,
    input    [ 1: 0]  rmii_rxd,
    output            rmii_txen,
    output   [ 1: 0]  rmii_txd,

    // IRQ
    output            uart_irq,
    output            spi_irq,
    output            mac_irq
);

apb_intf uart_apb();
apb_intf spi_apb();
apb_intf mac_apb();

peri_apb_conn u_peri_apb_conn (
    .peri_apb ( s_apb_intf      ),
    .uart_apb ( uart_apb.master ),
    .spi_apb  ( spi_apb.master  ),
    .mac_apb  ( mac_apb.master  )
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

mac u_mac (
    .clk         ( clk           ),
    .rstn        ( rstn          ),
    .s_apb_intf  ( mac_apb.slave ),

    // RMII interface
    .rmii_refclk ( rmii_refclk   ),
    .rmii_crsdv  ( rmii_crsdv    ),
    .rmii_rxd    ( rmii_rxd      ),
    .rmii_txen   ( rmii_txen     ),
    .rmii_txd    ( rmii_txd      ),

    // Interrupt 
    .irq_out     ( mac_irq       )
);

endmodule
