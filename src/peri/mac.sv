`include "mac_mmap.h"

module mac #(
    parameter [47:0] MAC_ADDR = {8'hfe,
                                 8'hca,
                                 8'hfe,
                                 8'hca,
                                 8'h50,
                                 8'h00}
)(
    input               clk,
    input               rstn,
    apb_intf.slave      s_apb_intf,

    // RMII interface
    input               rmii_refclk,
    input               rmii_crsdv,
    input        [1:0]  rmii_rxd,
    output logic        rmii_txen,
    output logic [1:0]  rmii_txd,

    // Interrupt
    output logic        irq_out
);

logic        apb_wr;
logic        apb_rd;
logic [31:0] prdata_t;

logic        rmii_rstn;
logic        afifo_rx_wr;
logic [34:0] afifo_rx_wdata;
logic        afifo_rx_empty;
logic [34:0] afifo_rx_rdata;

logic        afifo_tx_wr;
logic        afifo_tx_full;
logic        afifo_tx_nxt_full;
logic [34:0] afifo_tx_wdata;
logic        afifo_tx_empty;
logic        afifo_tx_nxt_empty;
logic        afifo_tx_rd;
logic [34:0] afifo_tx_rdata;

logic        rx_en;
logic        rx_en_pre;
logic        rx_busy_async;
logic        rx_busy_d1;
logic        rx_busy_d2;
logic        rx_busy;
logic        rx_ovf;
logic        rx_discar;
logic        rx_len_cnt_upd;
logic        rx_len_cnt_upd_dly;
logic [10:0] rx_len;
logic [10:0] rx_len_cnt;
logic [ 9:0] rx_ram_wptr;
logic [ 9:0] rx_ram_rptr;
logic [ 9:0] rx_ram_rptr_tail;
logic        rx_ram_read_busy;
logic        rx_ram_do_valid;
logic        rx_ram_wr;
logic        rx_ram_rd;
logic        rx_ram_rd_dly;
logic        rx_ram_cs;
logic        rx_ram_we;
logic [ 8:0] rx_ram_a;
logic [31:0] rx_ram_di;
logic [31:0] rx_ram_do;
logic [31:0] rx_data;
logic        rx_len_fifo_full;
logic        rx_len_fifo_wr;
logic [10:0] rx_len_fifo_wdata;
logic        rx_len_fifo_empty;
logic        rx_len_fifo_rd;
logic [10:0] rx_len_fifo_rdata;
logic        rx_len_illegal;

logic        afifo_tx_empty_d1;
logic        afifo_tx_empty_d2;
logic        tx_done;
logic        tx_busy;
logic        tx_en;
logic [10:0] tx_len;
logic        tx_discar;
logic [ 8:0] tx_ram_rptr;
logic [ 8:0] tx_ram_wptr;
logic [ 8:0] tx_ram_wlen;
logic        tx_ram_rd;
logic        tx_ram_wr;
logic        tx_ram_cs;
logic        tx_ram_we;
logic [ 8:0] tx_ram_a;
logic [31:0] tx_ram_di;
logic [31:0] tx_ram_do;
logic [10:0] tx_len_cnt;
logic [10:0] tx_len_cnt_nxt;

logic        txeie;
logic        rxneie;

logic        txe;
logic        rxne;

logic        sw_rstn;
logic [ 3:0] rst_cnt;

assign apb_wr = ~s_apb_intf.penable && s_apb_intf.psel &&  s_apb_intf.pwrite;
assign apb_rd = ~s_apb_intf.penable && s_apb_intf.psel && ~s_apb_intf.pwrite;

always_comb begin
    prdata_t = 32'b0;
    case (s_apb_intf.paddr[11:0])
        `MAC_RESET : prdata_t = {tx_busy, rx_busy, 30'b0};
        `MAC_TXLEN : prdata_t = {21'b0, tx_len};
        `MAC_TXFIFO: prdata_t = {32{~|tx_len}};
        `MAC_TXCTRL: prdata_t = {31'b0, tx_en};
        `MAC_RXLEN : prdata_t = {21'b0, rx_len};
        `MAC_RXFIFO: prdata_t = rx_data;
        `MAC_RXCTRL: prdata_t = {31'b0, rx_en};
        `MAC_IE    : prdata_t = {30'b0, rxneie, txeie};
        `MAC_IP    : prdata_t = {30'b0, rxne, txe};
        `MAC_IC    : prdata_t = {30'b0, rxne, txe};
        `MAC_MAC0  : prdata_t = MAC_ADDR[32:0];
        `MAC_MAC1  : prdata_t = {16'b0, MAC_ADDR[47:32]};
        12'h38     : prdata_t = {7'b0, tx_ram_wptr, 7'b0, tx_ram_rptr};
        12'h3c     : prdata_t = {rx_len_fifo_full, rx_len_fifo_empty, 4'b0, rx_ram_wptr, 6'b0, rx_ram_rptr};
    endcase
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) s_apb_intf.prdata <= 32'b0;
    else       s_apb_intf.prdata <= prdata_t;
end

assign s_apb_intf.pslverr = 1'b0;
assign s_apb_intf.pready = 1'b1;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) rst_cnt <= 4'b0;
    else begin
        if (apb_wr && s_apb_intf.paddr[11:0] == `MAC_RESET && s_apb_intf.pwdata[0])
            rst_cnt <= 4'h1;
        else if (|rst_cnt)
            rst_cnt <= rst_cnt - 4'b1;
    end
end
assign sw_rstn = ~|rst_cnt && rstn;

assign rxne = !rx_len_fifo_empty;
assign txe  = !tx_busy;

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) begin
        txeie  <= 1'b0;
        rxneie <= 1'b0;
    end
    else begin
        if (apb_wr && s_apb_intf.paddr[11:0] == `MAC_IE) begin
            txeie  <= s_apb_intf.pwdata[0];
            rxneie <= s_apb_intf.pwdata[1];
        end
    end
end

assign irq_out = (rxne && rxneie) || (txe && txeie);

resetn_synchronizer u_sync_rstn (
    .clk        ( rmii_refclk ),
    .rstn_async ( sw_rstn     ),
    .rstn_sync  ( rmii_rstn   )
);

mac_rmii_intf u_mac_rmii_intf (
    // reset
    .rstn              ( rmii_rstn          ),

    // RMII interface
    .rmii_refclk       ( rmii_refclk        ),
    .rmii_crsdv        ( rmii_crsdv         ),
    .rmii_rxd          ( rmii_rxd           ),
    .rmii_txen         ( rmii_txen          ),
    .rmii_txd          ( rmii_txd           ),

    .fifo_rx_wr        ( afifo_rx_wr        ),
    .fifo_rx_wdata     ( afifo_rx_wdata     ),
    .fifo_tx_empty     ( afifo_tx_empty     ),
    .fifo_tx_nxt_empty ( afifo_tx_nxt_empty ),
    .fifo_tx_rd        ( afifo_tx_rd        ),
    .fifo_tx_rdata     ( afifo_tx_rdata     ),

    .rx_busy_o         ( rx_busy_async      )
);

mac_afifo u_mac_afifo_rx (
    .rclk      ( clk            ),
    .rrstn     ( sw_rstn        ),
    .wclk      ( rmii_refclk    ),
    .wrstn     ( rmii_rstn      ),

    .write     ( afifo_rx_wr    ),
    .wdata     ( afifo_rx_wdata ),

    .empty     ( afifo_rx_empty ),
    .read      ( 1'b1           ),
    .rdata     ( afifo_rx_rdata )
);

mac_afifo u_mac_afifo_tx (
    .rclk      ( rmii_refclk        ),
    .rrstn     ( rmii_rstn          ),
    .wclk      ( clk                ),
    .wrstn     ( sw_rstn            ),

    .full      ( afifo_tx_full      ),
    .nxt_full  ( afifo_tx_nxt_full  ),
    .write     ( afifo_tx_wr        ),
    .wdata     ( afifo_tx_wdata     ),

    .empty     ( afifo_tx_empty     ),
    .nxt_empty ( afifo_tx_nxt_empty ),
    .read      ( afifo_tx_rd        ),
    .rdata     ( afifo_tx_rdata     )
);

// RX
assign rx_discar = apb_wr && s_apb_intf.paddr[11:0] == `MAC_RXDIS;
assign rx_len    = {11{!rx_len_fifo_empty && rx_ram_read_busy}} & rx_len_fifo_rdata;

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) begin
        rx_busy_d1 <= 1'b0;
        rx_busy_d2 <= 1'b0;
    end
    else begin
        rx_busy_d1 <= rx_busy_async;
        rx_busy_d2 <= rx_busy_d1;
    end
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) begin
        rx_busy <= 1'b0;
    end
    else begin
        rx_busy <= rx_busy_d2;
        // if (rx_busy && rx_len_cnt_upd) rx_busy <= 1'b0;
        // else if (rx_busy_d2)           rx_busy <= 1'b1;
    end
end


always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_en_pre <= 1'b0;
    else begin
        if (apb_wr && s_apb_intf.paddr[11:0] == `MAC_RXCTRL)
            rx_en_pre <= s_apb_intf.pwdata[0];
    end
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_en <= 1'b0;
    else          rx_en <= !rx_busy ? rx_en_pre : rx_en;
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn)           rx_data <= 32'b0;
    else if (rx_ram_rd_dly) rx_data <= rx_ram_do;
end

// always_ff @(posedge clk or negedge sw_rstn) begin
//     if (~sw_rstn) rx_busy <= 1'b0;
//     else          rx_busy <= !rx_en || rx_len_cnt_upd_dly ? 1'b0:
//                              rx_ram_wr                    ? 1'b1:
//                                                             rx_busy;
// end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_ram_read_busy <= 1'b0;
    else          rx_ram_read_busy <= rx_len_fifo_rd                          ? 1'b0:
                                      !rx_ram_read_busy && !rx_len_fifo_empty ? 1'b1:
                                                                                rx_ram_read_busy;
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_ram_rptr_tail <= 10'b0;
    else begin
        if (!rx_ram_read_busy && !rx_len_fifo_empty)
            rx_ram_rptr_tail <= rx_ram_rptr_tail +
                                {1'b0, rx_len_fifo_rdata[10:2]} + {9'b0, |rx_len_fifo_rdata[1:0]};
    end
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_ram_wptr <= 10'b0;
    else begin
        if (rx_len_cnt_upd && rx_ovf && rx_en)
            rx_ram_wptr <= rx_ram_wptr - {1'b0, rx_len_cnt[10:2]} - {9'b0, |rx_len_cnt[1:0]};
        else
            rx_ram_wptr <= rx_ram_wptr + {9'b0, rx_ram_wr};
    end
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_ram_rptr <= 10'b0;
    else begin
        if (rx_len_fifo_rd) rx_ram_rptr <= rx_ram_rptr_tail;
        else                rx_ram_rptr <= rx_ram_rptr + {9'b0, rx_ram_rd & ~rx_ram_wr};
    end
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_ram_do_valid <= 1'b0;
    else          rx_ram_do_valid <= rx_ram_rd && !rx_ram_wr                         ? 1'b1:
                                     apb_rd && s_apb_intf.paddr[11:0] == `MAC_RXFIFO ? 1'b0:
                                                                                       rx_ram_do_valid;
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_ram_rd_dly <= 1'b0;
    else          rx_ram_rd_dly <= rx_ram_rd && !rx_ram_wr;
end

assign rx_ram_full = rx_ram_wptr[8:0] == rx_ram_rptr[8:0] && (rx_ram_wptr[9] ^ rx_ram_rptr[9]);
assign rx_ram_rd   = !rx_ram_do_valid && rx_ram_rptr_tail != rx_ram_rptr;
assign rx_ram_wr   = rx_en && !afifo_rx_empty && |afifo_rx_rdata[34:32] &&
                     !(&afifo_rx_rdata[34:32]) && !rx_ram_full && !rx_ovf;
assign rx_ram_cs   = rx_ram_wr || rx_ram_rd;
assign rx_ram_we   = rx_ram_wr;
assign rx_ram_a    = rx_ram_wr ? rx_ram_wptr[8:0] : rx_ram_rptr[8:0];
assign rx_ram_di   = afifo_rx_rdata[31:0];

sram512x32 u_rx_ram (
    .CK ( clk       ),
    .CS ( rx_ram_cs ),
    .WE ( rx_ram_we ),
    .A  ( rx_ram_a  ),
    .DI ( rx_ram_di ),
    .DO ( rx_ram_do )
);

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) begin
        rx_len_cnt_upd     <= 1'b0;
        rx_len_cnt_upd_dly <= 1'b0;
    end
    else begin
        rx_len_cnt_upd     <= !afifo_rx_empty && (!afifo_rx_rdata[34] || &afifo_rx_rdata[34:32]);
        rx_len_cnt_upd_dly <= rx_len_cnt_upd;
    end
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_len_cnt <= 11'b0;
    else          rx_len_cnt <= rx_len_cnt_upd_dly ? 11'b0:
                                rx_ram_wr          ? rx_len_cnt + {8'b0, afifo_rx_rdata[34:32]}:
                                                     rx_len_cnt;
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) rx_ovf <= 1'b0;
    else          rx_ovf <= rx_len_cnt_upd                              ? 1'b0:
                            !afifo_rx_empty && (rx_ram_full      ||
                                                rx_len_fifo_full ||
                                                rx_len_illegal   ||
                                                &afifo_rx_rdata[34:32]) ? 1'b1: rx_ovf;
end

assign rx_len_fifo_rd    = rx_discar && !rx_len_fifo_empty;
assign rx_len_fifo_wr    = rx_en && rx_len_cnt_upd && !rx_ovf;
assign rx_len_fifo_wdata = rx_len_cnt;
assign rx_len_illegal    = (!afifo_rx_rdata[34] && rx_len_cnt + {9'b0, afifo_rx_rdata[33:32]} < 11'd60) ||
                           rx_len_cnt + {8'b0, afifo_rx_rdata[34:32]} > 11'd1518;

mac_fifo u_rx_len_fifo (
    .clk   ( clk               ),
    .rstn  ( sw_rstn           ),

    // Write side
    .full  ( rx_len_fifo_full  ),
    .write ( rx_len_fifo_wr    ),
    .wdata ( rx_len_fifo_wdata ),

    // Read side
    .empty ( rx_len_fifo_empty ),
    .read  ( rx_len_fifo_rd    ),
    .rdata ( rx_len_fifo_rdata )
);

// TX
assign tx_done   = tx_busy && ~|tx_len_cnt && afifo_tx_empty_d2;
assign tx_discar = !tx_busy && apb_wr && s_apb_intf.paddr[11:0] == `MAC_TXDIS;

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) begin
        tx_en <= 1'b0;
    end
    else begin
        if (~|tx_len && apb_wr && s_apb_intf.paddr[11:0] == `MAC_TXCTRL)
            tx_en <= s_apb_intf.pwdata[0];
    end
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) begin
        tx_len <= 11'b0;
    end
    else begin
        if (~|tx_len && apb_wr && s_apb_intf.paddr[11:0] == `MAC_TXLEN)
            tx_len <= s_apb_intf.pwdata[10:0];
        else if (tx_done || tx_discar)
            tx_len <= 11'b0;
    end
end

assign tx_ram_wr = tx_en && |tx_ram_wlen && apb_wr && s_apb_intf.paddr[11:0] == `MAC_TXFIFO;
always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) tx_ram_wlen <= 9'b0;
    else begin
        if (tx_en && ~|tx_len && apb_wr && s_apb_intf.paddr[11:0] == `MAC_TXLEN)
            tx_ram_wlen <= s_apb_intf.pwdata[10:2] + {8'b0, |s_apb_intf.pwdata[1:0]};
        else if (tx_discar)
            tx_ram_wlen <= 9'b0;
        else
            tx_ram_wlen <= tx_ram_wlen - {8'b0, tx_ram_wr};
    end
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) tx_ram_wptr <= 9'b0;
    else          tx_ram_wptr <= tx_discar ? tx_ram_rptr:
                                             tx_ram_wptr + {8'b0, tx_ram_wr};
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) tx_ram_rptr <= 9'b0;
    else          tx_ram_rptr <= tx_ram_rptr + {8'b0, tx_ram_rd};
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) tx_len_cnt <= 11'b0;
    else begin
        if (tx_en && ~|tx_len && apb_wr && s_apb_intf.paddr[11:0] == `MAC_TXLEN)
            tx_len_cnt <= s_apb_intf.pwdata[10:0];
        else if (tx_discar)
            tx_len_cnt <= 11'b0;
        else
            tx_len_cnt <= !afifo_tx_wr ? tx_len_cnt : tx_len_cnt_nxt;
    end
end
assign tx_len_cnt_nxt = |tx_len_cnt[10:2] ? tx_len_cnt - 11'h4 : 11'b0;

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) begin
        afifo_tx_empty_d1 <= 1'b0;
        afifo_tx_empty_d2 <= 1'b0;
    end
    else begin
        afifo_tx_empty_d1 <= afifo_tx_empty;
        afifo_tx_empty_d2 <= afifo_tx_empty_d1;
    end
end

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) tx_busy <= 1'b0;
    else          tx_busy <= |tx_len_cnt && ~|tx_ram_wlen && !tx_discar ? 1'b1:
                             tx_done                                    ? 1'b0:
                                                                          tx_busy;
end

assign afifo_tx_wdata[34:32] = |tx_len_cnt[10:2] ? 3'h4 : {1'b0, tx_len_cnt[1:0]};
assign afifo_tx_wdata[31: 0] = tx_ram_do;
assign tx_ram_rd             = ((afifo_tx_wr && |tx_len_cnt_nxt) || (!afifo_tx_wr && |tx_len_cnt)) &&
                               (!afifo_tx_nxt_full || !(afifo_tx_full || afifo_tx_wr)) &&
                               tx_busy;

always_ff @(posedge clk or negedge sw_rstn) begin
    if (~sw_rstn) afifo_tx_wr <= 1'b0;
    else          afifo_tx_wr <= tx_ram_rd;
end

assign tx_ram_cs = tx_ram_rd || tx_ram_wr;
assign tx_ram_we = tx_ram_wr;
assign tx_ram_a  = tx_ram_wr ? tx_ram_wptr : tx_ram_rptr;
assign tx_ram_di = s_apb_intf.pwdata;

sram512x32 u_tx_ram (
    .CK ( clk       ),
    .CS ( tx_ram_cs ),
    .WE ( tx_ram_we ),
    .A  ( tx_ram_a  ),
    .DI ( tx_ram_di ),
    .DO ( tx_ram_do )
);

endmodule
