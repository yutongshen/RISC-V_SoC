`include "spi_mmap.h"

module spi (
    input          clk,
    input          rstn,
    apb_intf.slave s_apb_intf,

    // SPI interface
    output logic   sclk,
    output logic   nss,
    output logic   mosi,
    input          miso,

    // Interrupt
    output logic   irq_out
);

localparam STATE_OFF   = 2'b00;
localparam STATE_IDLE  = 2'b01;
localparam STATE_START = 2'b10;
localparam STATE_DATA  = 2'b11;

logic [ 1:0] cur_state;
logic [ 1:0] nxt_state;

logic        sclk_pre;
logic        nss_pre;
logic        mosi_pre;
logic        bsy_pre;
logic [ 7:0] sclk_cnt;
logic        sclk_cnt_rst;
logic        sclk_cnt_zero;
logic        sclk_cnt_half;
logic [ 3:0] sft_cnt;
logic        sft_cnt_zero;
logic [15:0] sft_data_reg1;
logic [15:0] sft_data_reg2;
logic        sft_en1;
logic        sft_en2;
logic        sft_en2_latch;
logic        apb_wr;
logic        apb_rd;
logic [31:0] spi_cr1;
logic        spi_cr1_cpha;
logic        spi_cr1_cpol;
logic        spi_cr1_mstr;
logic [ 2:0] spi_cr1_br;
logic        spi_cr1_spe;
logic        spi_cr1_lsbfirst;
logic        spi_cr1_ssi;
logic        spi_cr1_ssm;
logic        spi_cr1_rxonly;
logic        spi_cr1_dff;
logic        spi_cr1_crcnext;
logic        spi_cr1_crcen;
logic        spi_cr1_bidioe;
logic        spi_cr1_bidimode;
logic [31:0] spi_cr2;
logic        spi_cr2_rxdmaen;
logic        spi_cr2_txdmaen;
logic        spi_cr2_ssoe;
logic        spi_cr2_errie;
logic        spi_cr2_rxneie;
logic        spi_cr2_txeie;
logic [31:0] spi_sr;
logic        spi_sr_txe;
logic        spi_sr_rxne;
logic        spi_sr_chside;
logic        spi_sr_udr;
logic        spi_sr_crcerr;
logic        spi_sr_modf;
logic        spi_sr_ovr;
logic        spi_sr_bsy;
logic        tx_pop;
logic        rx_pop;
logic        rx_pop_latch;
logic [15:0] spi_tx_buff;
logic [15:0] spi_rx_buff;
logic [31:0] prdata_t;

assign apb_wr = ~s_apb_intf.penable && s_apb_intf.psel &&  s_apb_intf.pwrite;
assign apb_rd = ~s_apb_intf.penable && s_apb_intf.psel && ~s_apb_intf.pwrite;

assign spi_cr1 = {16'b0, spi_cr1_bidimode, spi_cr1_bidioe, spi_cr1_crcen, spi_cr1_crcnext,
                         spi_cr1_dff, spi_cr1_rxonly, spi_cr1_ssm, spi_cr1_ssi,
                         spi_cr1_lsbfirst, spi_cr1_spe, spi_cr1_br, spi_cr1_mstr,
                         spi_cr1_cpol, spi_cr1_cpha};

always_ff @(posedge clk or negedge rstn) begin: reg_spi_cr1
    if (~rstn) begin
        spi_cr1_cpha     <= 1'b0;
        spi_cr1_cpol     <= 1'b0;
        spi_cr1_mstr     <= 1'b1;
        spi_cr1_br       <= 2'b0;
        spi_cr1_spe      <= 1'b0;
        spi_cr1_lsbfirst <= 1'b0;
        spi_cr1_ssi      <= 1'b0;
        spi_cr1_ssm      <= 1'b0;
        spi_cr1_rxonly   <= 1'b0;
        spi_cr1_dff      <= 1'b0;
        spi_cr1_crcnext  <= 1'b0;
        spi_cr1_crcen    <= 1'b0;
        spi_cr1_bidioe   <= 1'b0;
        spi_cr1_bidimode <= 1'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `SPI_CR1) begin
        spi_cr1_cpha     <= s_apb_intf.pwdata[0];
        spi_cr1_cpol     <= s_apb_intf.pwdata[1];
        // spi_cr1_mstr     <= s_apb_intf.pwdata[2];
        spi_cr1_br       <= ~spi_cr1_spe ? s_apb_intf.pwdata[5:3] : spi_cr1_br;
        spi_cr1_spe      <= s_apb_intf.pwdata[6];
        spi_cr1_lsbfirst <= ~spi_cr1_spe ? s_apb_intf.pwdata[7] : spi_cr1_lsbfirst;
        // spi_cr1_ssi      <= s_apb_intf.pwdata[8];
        // spi_cr1_ssm      <= s_apb_intf.pwdata[9];
        // spi_cr1_rxonly   <= s_apb_intf.pwdata[10];
        spi_cr1_dff      <= ~spi_cr1_spe ? s_apb_intf.pwdata[11] : spi_cr1_dff;
        // spi_cr1_crcnext  <= s_apb_intf.pwdata[12];
        // spi_cr1_crcen    <= ~spi_cr1_spe ? s_apb_intf.pwdata[13] : spi_cr1_crcen;
        // spi_cr1_bidioe   <= s_apb_intf.pwdata[14];
        // spi_cr1_bidimode <= s_apb_intf.pwdata[15];
    end
end

assign spi_cr2 = {24'b0, spi_cr2_txeie, spi_cr2_rxneie, spi_cr2_errie,
                  2'b0,  spi_cr2_ssoe, spi_cr2_txdmaen, spi_cr2_rxdmaen};

always_ff @(posedge clk or negedge rstn) begin: reg_spi_cr2
    if (~rstn) begin
        spi_cr2_rxdmaen <= 1'b0;
        spi_cr2_txdmaen <= 1'b0;
        spi_cr2_ssoe    <= 1'b0;
        spi_cr2_errie   <= 1'b0;
        spi_cr2_rxneie  <= 1'b0;
        spi_cr2_txeie   <= 1'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `SPI_CR2) begin
        spi_cr2_rxdmaen <= s_apb_intf.pwdata[0];
        spi_cr2_txdmaen <= s_apb_intf.pwdata[1];
        spi_cr2_ssoe    <= s_apb_intf.pwdata[2];
        spi_cr2_errie   <= s_apb_intf.pwdata[5];
        spi_cr2_rxneie  <= s_apb_intf.pwdata[6];
        spi_cr2_txeie   <= s_apb_intf.pwdata[7];
    end
end

assign spi_sr = {24'b0, spi_sr_bsy, spi_sr_ovr,    spi_sr_modf, spi_sr_crcerr,
                        spi_sr_udr, spi_sr_chside, spi_sr_rxne, spi_sr_txe};

assign spi_sr_chside = 1'b0;
assign spi_sr_udr    = 1'b0;
assign spi_sr_crcerr = 1'b0;
assign spi_sr_modf   = 1'b0;
assign spi_sr_ovr    = 1'b0;

always_ff @(posedge clk or negedge rstn) begin: reg_spi_sr
    if (~rstn) begin
        spi_sr_bsy <= 1'b0;
    end
    else begin
        spi_sr_bsy <= bsy_pre;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_spi_dr
    if (~rstn) begin
        spi_tx_buff <= 16'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `SPI_DR && spi_sr_txe) begin
        spi_tx_buff <= s_apb_intf.pwdata[15:0];
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_spi_txe
    if (~rstn) begin
        spi_sr_txe <= 1'b1;
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `SPI_DR) begin
        spi_sr_txe <= 1'b0;
    end
    else if (tx_pop) begin
        spi_sr_txe <= 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: shift_data1
    if (~rstn) begin
        sft_data_reg1 <= 16'b0;
    end
    else if (tx_pop) begin
        sft_data_reg1 <= {spi_tx_buff[15:8] & {8{spi_cr1_dff}}, spi_tx_buff[7:0]};
    end
    else if (sft_en1) begin
        if (~spi_cr1_lsbfirst) begin
            sft_data_reg1[ 7:0] <= {sft_data_reg1[6:0], 1'b0};
            sft_data_reg1[15:8] <= spi_cr1_dff ? sft_data_reg1[14:7] : 8'b0;
        end
        else begin
            sft_data_reg1[ 7:0] <= spi_cr1_dff ? sft_data_reg1[ 8:1]         : {1'b0, sft_data_reg1[7:1]};
            sft_data_reg1[15:8] <= spi_cr1_dff ? {1'b0, sft_data_reg1[15:9]} : 8'b0;
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin: sft_data2_ctrl
    if (~rstn) begin
        sft_en2_latch <= 1'b0;
        rx_pop_latch  <= 1'b0;
    end
    else begin
        sft_en2_latch <= sft_en2;
        rx_pop_latch  <= rx_pop;
    end
end

always_ff @(posedge clk or negedge rstn) begin: shift_data2
    if (~rstn) begin
        sft_data_reg2 <= 16'b0;
    end
    else if (rx_pop_latch) begin
        sft_data_reg2 <= 16'b0;
    end
    else if (sft_en2_latch) begin
        if (~spi_cr1_lsbfirst) begin
            sft_data_reg2[ 7:0] <= {sft_data_reg2[6:0], miso};
            sft_data_reg2[15:8] <= spi_cr1_dff ? sft_data_reg2[14:7] : 8'b0;
        end
        else begin
            sft_data_reg2[ 7:0] <= spi_cr1_dff ? sft_data_reg2[ 8:1]         : {miso, sft_data_reg2[7:1]};
            sft_data_reg2[15:8] <= spi_cr1_dff ? {miso, sft_data_reg2[15:9]} : 8'b0;
        end
    end
end

always_comb begin: mosi_pre_comb
    case ({spi_cr1_lsbfirst, spi_cr1_dff})
        2'b00:   mosi_pre = sft_data_reg1[ 7];
        2'b01:   mosi_pre = sft_data_reg1[15];
        default: mosi_pre = sft_data_reg1[ 0];
    endcase
end

always_ff @(posedge clk or negedge rstn) begin: rx_buff
    if (~rstn) begin
        spi_rx_buff <= 16'b0;
    end
    else if (rx_pop_latch) begin
        spi_rx_buff <= sft_data_reg2;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_spi_rxne
    if (~rstn) begin
        spi_sr_rxne <= 1'b0;
    end
    else if (apb_rd && s_apb_intf.paddr[11:0] == `SPI_DR) begin
        spi_sr_rxne <= 1'b0;
    end
    else if (rx_pop_latch) begin
        spi_sr_rxne <= 1'b1;
    end
end

always_comb begin: prdata_tmp
    prdata_t = 32'b0;
    case (s_apb_intf.paddr[11:0])
        `SPI_CR1: prdata_t = spi_cr1;
        `SPI_CR2: prdata_t = spi_cr2;
        `SPI_SR:  prdata_t = spi_sr;
        `SPI_DR:  prdata_t = {16'b0, spi_rx_buff};
    endcase
end

always_ff @(posedge clk or negedge rstn) begin: apb_rdata
    if (~rstn) s_apb_intf.prdata <= 32'b0;
    else       s_apb_intf.prdata <= apb_rd ? prdata_t : 32'b0;
end

assign s_apb_intf.pslverr = 1'b0;
assign s_apb_intf.pready  = 1'b1;

always_ff @(posedge clk or negedge rstn) begin: baud_rate_cnt
    if (~rstn) begin
        sclk_cnt <= 8'b0;
    end
    else begin
        if (sclk_cnt_rst)
            sclk_cnt <= (8'b1 << {1'b0, spi_cr1_br + 4'b1}) - 8'b1;
        else
            sclk_cnt <= ~sclk_cnt_zero ? sclk_cnt - 8'b1 : 8'b0;
    end
end

always_comb begin: sclk_cnt_zero_comb
    sclk_cnt_zero = ~|sclk_cnt;
end

always_comb begin: sclk_cnt_half_comb
    sclk_cnt_half = sclk_cnt == (8'b1 << spi_cr1_br);
end

always_ff @(posedge clk or negedge rstn) begin: data_shift_cnt
    if (~rstn) begin
        sft_cnt <= 4'b0;
    end
    else begin
        if (tx_pop)
            sft_cnt <= spi_cr1_dff ? 4'hf : 4'h7;
        else if (sclk_cnt_zero && cur_state == STATE_DATA)
            sft_cnt <= ~sft_cnt_zero ? sft_cnt - 4'b1 : 4'b0;
    end
end

always_comb begin: sft_cnt_zero_comb
    sft_cnt_zero = ~|sft_cnt;
end

always_ff @(posedge clk or negedge rstn) begin: sclk_o
    if (~rstn) sclk <= 1'b0;
    else       sclk <= sclk_pre ^ spi_cr1_cpol;
end

always_ff @(posedge clk or negedge rstn) begin: nss_o
    if (~rstn) nss <= 1'b1;
    else       nss <= nss_pre;
end

always_ff @(posedge clk or negedge rstn) begin: mosi_o
    if (~rstn) mosi <= 1'b0;
    else       mosi <= mosi_pre;
end


always_ff @(posedge clk or negedge rstn) begin: fsm
    if (~rstn) cur_state <= STATE_OFF;
    else       cur_state <= nxt_state;
end

always_comb begin: nxt_state_comb
    nxt_state = cur_state;
    case (cur_state)
        STATE_OFF:   nxt_state = spi_cr1_spe ? STATE_IDLE : STATE_OFF;
        STATE_IDLE:  nxt_state = ~spi_cr1_spe                 ? STATE_OFF :
                                 sclk_cnt_zero && ~spi_sr_txe ? ~spi_cr1_cpha ? STATE_START:
                                                                                STATE_START:
                                                                STATE_IDLE;
        STATE_START: nxt_state = sclk_cnt_half ? STATE_DATA : STATE_START;
        STATE_DATA:  nxt_state = sclk_cnt_zero && sft_cnt_zero ? ~spi_sr_txe ? ~spi_cr1_cpha ? STATE_IDLE:
                                                                                               STATE_DATA:
                                                                               STATE_IDLE:
                                                                 STATE_DATA;
    endcase
end

always_comb begin: ctrl_signal
    tx_pop       = 1'b0;
    rx_pop       = 1'b0;
    sft_en1      = 1'b0;
    sft_en2      = 1'b0;
    sclk_cnt_rst = 1'b0;
    sclk_pre     = 1'b0;
    nss_pre      = 1'b0;
    bsy_pre      = 1'b1;
    case (cur_state)
        STATE_OFF:  begin
            sclk_cnt_rst = spi_cr1_spe;
            nss_pre      = 1'b1;
        end
        STATE_IDLE:  begin
            tx_pop       = sclk_cnt_zero && spi_cr1_spe && ~spi_sr_txe;
            sclk_cnt_rst = sclk_cnt_zero && spi_cr1_spe && ~spi_sr_txe;
            bsy_pre      = 1'b0;
        end
        STATE_START: begin
            sclk_cnt_rst = sclk_cnt_half;
            sft_en2      = ~spi_cr1_cpha && sclk_cnt_half;
        end
        STATE_DATA:  begin
            tx_pop       = sclk_cnt_zero && sft_cnt_zero && ~spi_sr_txe && spi_cr1_cpha;
            rx_pop       = sclk_cnt_zero && sft_cnt_zero;
            sft_en1      = ~spi_cr1_cpha ? sclk_cnt_half : sclk_cnt_zero;
            sft_en2      = ~spi_cr1_cpha ? sclk_cnt_zero : sclk_cnt_half;
            sclk_cnt_rst = sclk_cnt_zero;
            sclk_pre     = sclk_cnt[spi_cr1_br];
        end
    endcase
end

assign irq_out = (spi_cr2_txeie  && spi_sr_txe ) ||
                 (spi_cr2_rxneie && spi_sr_rxne) ||
                 (spi_cr2_errie  && (spi_sr_crcerr || spi_sr_ovr || spi_sr_modf));

endmodule
