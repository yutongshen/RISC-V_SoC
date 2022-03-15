module spi_core_apb_conn (
    apb_intf.slave  spi_core_apb,
    apb_intf.master spi_apb,
    apb_intf.master dma_apb
);

assign spi_apb.psel         = ~spi_core_apb.paddr[11] && spi_core_apb.psel;
assign spi_apb.penable      = ~spi_core_apb.paddr[11] && spi_core_apb.penable;
assign spi_apb.paddr        =  spi_core_apb.paddr;
assign spi_apb.pwrite       =  spi_core_apb.pwrite;
assign spi_apb.pstrb        =  spi_core_apb.pstrb;
assign spi_apb.pprot        =  spi_core_apb.pprot;
assign spi_apb.pwdata       =  spi_core_apb.pwdata;

assign dma_apb.psel         =  spi_core_apb.paddr[11] && spi_core_apb.psel;
assign dma_apb.penable      =  spi_core_apb.paddr[11] && spi_core_apb.penable;
assign dma_apb.paddr        =  spi_core_apb.paddr;
assign dma_apb.pwrite       =  spi_core_apb.pwrite;
assign dma_apb.pstrb        =  spi_core_apb.pstrb;
assign dma_apb.pprot        =  spi_core_apb.pprot;
assign dma_apb.pwdata       =  spi_core_apb.pwdata;

assign spi_core_apb.prdata  =  spi_core_apb.paddr[11] ? dma_apb.prdata  : spi_apb.prdata;
assign spi_core_apb.pslverr =  spi_core_apb.paddr[11] ? dma_apb.pslverr : spi_apb.pslverr;
assign spi_core_apb.pready  =  spi_core_apb.paddr[11] ? dma_apb.pready  : spi_apb.pready;

endmodule
