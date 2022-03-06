module axi_ap (
    input               tck,
    input               dbgrstn,
    input               sysclk,
    input               sysrstn,

    input               ap_upd,
    input        [31:0] ap_wdata,
    input        [ 7:2] ap_addr,
    input               ap_rnw,
    output logic [31:0] ap_rdata,
    output logic        ap_slverr,
    output logic        ap_busy,

    input               spiden,
    input               deviceen,

    axi_intf.master     m_axi_intf
);

logic        tx_tog;
logic [31:0] tx_mem_addr;
logic        tx_mem_write;
logic [31:0] tx_mem_wdata;
logic [ 2:0] tx_mem_size;
logic [ 6:0] tx_mem_prot;
logic        tx_mem_secen;
logic        rx_tog;
logic [31:0] rx_mem_rdata;
logic        rx_mem_slverr;
logic        rx_rstn_async;
logic        rx_rstn;
logic        rx_en;

assign rstn_async = dbgrstn & sysrstn;

resetn_synchronizer u_resetn_sync (
    .clk        ( sysclk     ),
    .rstn_async ( rstn_async ),
    .rstn_sync  ( rx_rstn    )
);

mem_ap u_mem_ap (
    .tck           ( tck           ),
    .dbgrstn       ( dbgrstn       ),
                                 
    .ap_upd        ( ap_upd        ),
    .ap_wdata      ( ap_wdata      ),
    .ap_addr       ( ap_addr       ),
    .ap_rnw        ( ap_rnw        ),
    .ap_rdata      ( ap_rdata      ),
    .ap_slverr     ( ap_slverr     ),
    .ap_busy       ( ap_busy       ),
                                 
    .tx_tog        ( tx_tog        ),
    .tx_mem_addr   ( tx_mem_addr   ),
    .tx_mem_write  ( tx_mem_write  ),
    .tx_mem_wdata  ( tx_mem_wdata  ),
    .tx_mem_size   ( tx_mem_size   ),
    .tx_mem_prot   ( tx_mem_prot   ),
    .tx_mem_secen  ( tx_mem_secen  ),
    .rx_tog        ( rx_tog        ),
    .rx_mem_rdata  ( rx_mem_rdata  ),
    .rx_mem_slverr ( rx_mem_slverr ),

    .fixedsz       ( 1'b0          ),
    .spiden        ( spiden        ),
    .deviceen      ( deviceen      )
);

axi_rx u_axi_rx (
    .rx_clk        ( sysclk        ),
    .rx_rstn       ( rx_rstn       ),

    .tx_tog        ( tx_tog        ),
    .tx_mem_addr   ( tx_mem_addr   ),
    .tx_mem_write  ( tx_mem_write  ),
    .tx_mem_wdata  ( tx_mem_wdata  ),
    .tx_mem_size   ( tx_mem_size   ),
    .tx_mem_prot   ( tx_mem_prot   ),
    .tx_mem_secen  ( tx_mem_secen  ),
    .rx_tog        ( rx_tog        ),
    .rx_mem_rdata  ( rx_mem_rdata  ),
    .rx_mem_slverr ( rx_mem_slverr ),

    .m_axi_intf    ( m_axi_intf    )
);

endmodule
