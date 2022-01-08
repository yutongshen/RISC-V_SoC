module intc_apb_conn (
    apb_intf.slave  intc_apb,
    apb_intf.master clint_apb,
    apb_intf.master plic_apb
);

assign clint_apb.psel    = ~intc_apb.paddr[26] && intc_apb.psel;
assign clint_apb.penable = ~intc_apb.paddr[26] && intc_apb.penable;
assign clint_apb.paddr   = intc_apb.paddr;
assign clint_apb.pwrite  = intc_apb.pwrite;
assign clint_apb.pstrb   = intc_apb.pstrb;
assign clint_apb.pprot   = intc_apb.pprot;
assign clint_apb.pwdata  = intc_apb.pwdata;

assign plic_apb.psel      = intc_apb.paddr[26] && intc_apb.psel;
assign plic_apb.penable   = intc_apb.paddr[26] && intc_apb.penable;
assign plic_apb.paddr     = intc_apb.paddr;
assign plic_apb.pwrite    = intc_apb.pwrite;
assign plic_apb.pstrb     = intc_apb.pstrb;
assign plic_apb.pprot     = intc_apb.pprot;
assign plic_apb.pwdata    = intc_apb.pwdata;

assign intc_apb.prdata    = intc_apb.paddr[26] ? plic_apb.prdata  : clint_apb.prdata;
assign intc_apb.pslverr   = intc_apb.paddr[26] ? plic_apb.pslverr : clint_apb.pslverr;
assign intc_apb.pready    = intc_apb.paddr[26] ? plic_apb.pready  : clint_apb.pready;

endmodule
