module peri_apb_conn (
    apb_intf.slave  peri_apb,
    apb_intf.master uart_apb,
    apb_intf.master spi_apb,
    apb_intf.master mac_apb
);

assign uart_apb.psel    = ~|peri_apb.paddr[13:12] && peri_apb.psel;
assign uart_apb.penable = ~|peri_apb.paddr[13:12] && peri_apb.penable;
assign uart_apb.paddr   =   peri_apb.paddr;
assign uart_apb.pwrite  =   peri_apb.pwrite;
assign uart_apb.pstrb   =   peri_apb.pstrb;
assign uart_apb.pprot   =   peri_apb.pprot;
assign uart_apb.pwdata  =   peri_apb.pwdata;

assign spi_apb.psel     =   peri_apb.paddr[12] && peri_apb.psel;
assign spi_apb.penable  =   peri_apb.paddr[12] && peri_apb.penable;
assign spi_apb.paddr    =   peri_apb.paddr;
assign spi_apb.pwrite   =   peri_apb.pwrite;
assign spi_apb.pstrb    =   peri_apb.pstrb;
assign spi_apb.pprot    =   peri_apb.pprot;
assign spi_apb.pwdata   =   peri_apb.pwdata;

assign mac_apb.psel     =   peri_apb.paddr[13] && peri_apb.psel;
assign mac_apb.penable  =   peri_apb.paddr[13] && peri_apb.penable;
assign mac_apb.paddr    =   peri_apb.paddr;
assign mac_apb.pwrite   =   peri_apb.pwrite;
assign mac_apb.pstrb    =   peri_apb.pstrb;
assign mac_apb.pprot    =   peri_apb.pprot;
assign mac_apb.pwdata   =   peri_apb.pwdata;

assign peri_apb.prdata  =   peri_apb.paddr[12] ? spi_apb.prdata  : peri_apb.paddr[13] ? mac_apb.prdata  : uart_apb.prdata;
assign peri_apb.pslverr =   peri_apb.paddr[12] ? spi_apb.pslverr : peri_apb.paddr[13] ? mac_apb.pslverr : uart_apb.pslverr;
assign peri_apb.pready  =   peri_apb.paddr[12] ? spi_apb.pready  : peri_apb.paddr[13] ? mac_apb.pready  : uart_apb.pready;

endmodule
