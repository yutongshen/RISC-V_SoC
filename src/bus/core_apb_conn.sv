module core_apb_conn (
    apb_intf.slave  core_apb,
    apb_intf.master cfgreg_apb,
    apb_intf.master cpustatreg_apb,
    apb_intf.master intc_apb
);

assign cfgreg_apb.psel        = ~core_apb.paddr[27] && ~core_apb.paddr[12] && core_apb.psel;
assign cfgreg_apb.penable     = ~core_apb.paddr[27] && ~core_apb.paddr[12] && core_apb.penable;
assign cfgreg_apb.paddr       = core_apb.paddr;
assign cfgreg_apb.pwrite      = core_apb.pwrite;
assign cfgreg_apb.pstrb       = core_apb.pstrb;
assign cfgreg_apb.pprot       = core_apb.pprot;
assign cfgreg_apb.pwdata      = core_apb.pwdata;

assign cpustatreg_apb.psel    = ~core_apb.paddr[27] && core_apb.paddr[12] && core_apb.psel;
assign cpustatreg_apb.penable = ~core_apb.paddr[27] && core_apb.paddr[12] && core_apb.penable;
assign cpustatreg_apb.paddr   = core_apb.paddr;
assign cpustatreg_apb.pwrite  = core_apb.pwrite;
assign cpustatreg_apb.pstrb   = core_apb.pstrb;
assign cpustatreg_apb.pprot   = core_apb.pprot;
assign cpustatreg_apb.pwdata  = core_apb.pwdata;

assign intc_apb.psel          = core_apb.paddr[27] && core_apb.psel;
assign intc_apb.penable       = core_apb.paddr[27] && core_apb.penable;
assign intc_apb.paddr         = core_apb.paddr;
assign intc_apb.pwrite        = core_apb.pwrite;
assign intc_apb.pstrb         = core_apb.pstrb;
assign intc_apb.pprot         = core_apb.pprot;
assign intc_apb.pwdata        = core_apb.pwdata;

assign core_apb.prdata        = core_apb.paddr[27] ? intc_apb.prdata:
                                core_apb.paddr[12] ? cpustatreg_apb.prdata:
                                                     cfgreg_apb.prdata;
assign core_apb.pslverr       = core_apb.paddr[27] ? intc_apb.pslverr:
                                core_apb.paddr[12] ? cpustatreg_apb.pslverr:
                                                     cfgreg_apb.pslverr;
assign core_apb.pready        = core_apb.paddr[27] ? intc_apb.pready:
                                core_apb.paddr[12] ? cpustatreg_apb.pready:
                                                     cfgreg_apb.pready;

endmodule
