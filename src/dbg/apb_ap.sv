module apb_ap (
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

    output logic        ap_buf_push,
    output logic [31:0] ap_buf_wdata,
    output logic [ 1:0] ap_buf_wresp,

    input               spiden,
    input               deviceen,

    apb_intf.master     m_apb_intf
);

logic        tx_tog;
logic        tx_mem_sector;
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
    .tx_mem_sector ( tx_mem_sector ),
    .tx_mem_addr   ( tx_mem_addr   ),
    .tx_mem_write  ( tx_mem_write  ),
    .tx_mem_wdata  ( tx_mem_wdata  ),
    .tx_mem_size   ( tx_mem_size   ),
    .tx_mem_prot   ( tx_mem_prot   ),
    .tx_mem_secen  ( tx_mem_secen  ),
    .rx_tog        ( rx_tog        ),
    .rx_mem_rdata  ( rx_mem_rdata  ),
    .rx_mem_slverr ( rx_mem_slverr ),

    .fixedsz       ( 1'b1          ),
    .spiden        ( spiden        ),
    .deviceen      ( deviceen      )
);

apb_rx u_apb_rx (
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

    .m_apb_intf    ( m_apb_intf    )
);

assign ap_buf_push  = 1'b0;
assign ap_buf_wdata = 32'b0;
assign ap_buf_wresp = 2'b0;

endmodule
