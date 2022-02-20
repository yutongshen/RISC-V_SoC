module spi_mdl (
    input        rstn,

    inout        SCLK,
    inout        NSS,
    inout        MOSI,
    inout        MISO,

    // Control signal
    input        CPHA,
    input        CPOL,
    input        LSBFIRST,
    input        DFF
);

logic [15:0] tx_data;
logic [15:0] rx_data;
logic [ 4:0] cnt;
logic        cpha_latch;
logic        cpol_latch;
logic        lsbfirst_latch;
logic        dff_latch;
logic        spi_off;
logic        OE;
logic        miso_o;
logic [ 7:0] spi_rdata;
logic        spi_upd;
logic        spi_upd_dly;
logic [ 7:0] txfifo [1024];
logic [10:0] txfifo_wptr;
logic [10:0] txfifo_rptr;

pullup(SCLK);
pullup(NSS);
pullup(MOSI);
pullup(MISO);

assign MISO = OE ? miso_o : 1'bz;

initial begin
    OE      = 1'b0;
    spi_upd = 1'b0;
    wait (rstn === 1'b1);
    spi_off = 1'b1;
    tx_data = 16'b0;
    while (1) begin
        OE      = 1'b0;
        rx_data = 16'b0;
        wait (NSS === 1'b0);
        OE      = 1'b1;
        spi_off = 1'b0;
        if (CPHA === 1'b0) begin
        end
        else begin
            @(posedge SCLK or negedge SCLK or posedge NSS);
            if (NSS === 1'b1) continue;
        end
        ctrl_latch;
        $display("%0d ns: [SPI_MDL] Shift start (CPHA: %0d, CPOL: %0d, LSBFIRST: %0d, DFF: %0d)",
                 $time, cpha_latch, cpol_latch, lsbfirst_latch, dff_latch);
        while (1) begin
            repeat (cnt) begin
                miso_o = next_miso();
                @(posedge SCLK or negedge SCLK or posedge NSS);
                #1;
                spi_upd = 1'b0;
                if (NSS === 1'b1) begin
                    spi_off = 1'b1;
                    break;
                end
                rx_capture;
                @(posedge SCLK or negedge SCLK or posedge NSS);
                if (NSS === 1'b1) begin
                    spi_off = 1'b1;
                    break;
                end
            end
            if (spi_off === 1'b1) break;
            tx_data = {8'b0, txfifo_rdata()};
            // $display("%0d ns: [SPI_MDL] Receive DATA %8x", $time, rx_data);
            spi_rdata = rx_data[7:0];
            spi_upd   = 1'b1;
            rx_data   = 16'b0;
        end
    end
end

task ctrl_latch;
    cpha_latch     = CPHA;
    cpol_latch     = CPOL;
    lsbfirst_latch = LSBFIRST;
    dff_latch      = DFF;
    cnt            = ~DFF ? 5'h8 : 5'h10;
endtask

task rx_capture;
    case ({lsbfirst_latch, dff_latch})
        2'b00: rx_data      = {rx_data[14:0], MOSI};
        2'b01: rx_data      = {rx_data[14:0], MOSI};
        2'b10: rx_data[7:0] = {MOSI, rx_data[ 7:1]};
        2'b11: rx_data      = {MOSI, rx_data[15:1]};
    endcase
endtask

function logic next_miso;
    logic res;
    case ({lsbfirst_latch, dff_latch})
        2'b00: begin
            res = tx_data[7];
            tx_data = {tx_data[14:0], 1'b0};
        end
        2'b01: begin
            res = tx_data[15];
            tx_data = {tx_data[14:0], 1'b0};
        end
        2'b10: begin
            res = tx_data[0];
            tx_data = {1'b0, tx_data[15:1]};
        end
        2'b11: begin
            res = tx_data[0];
            tx_data = {1'b0, tx_data[15:1]};
        end
    endcase
    return res;
endfunction

// SD card state

localparam STATE_SD_OFF       = 3'b000;
localparam STATE_SD_PWR_UP    = 3'b001;
localparam STATE_SD_SDIO_INIT = 3'b010;
localparam STATE_SD_SPI_INIT  = 3'b011;
localparam STATE_SD_SPI_ACMD  = 3'b100;
localparam STATE_SD_SPI_TRAN  = 3'b101;
localparam STATE_SD_SPI_DATA  = 3'b110;

logic [ 2:0] cur_state;
logic [ 2:0] nxt_state;
logic [31:0] rampup_cnt;
logic [47:0] sd_cmd;
logic [ 5:0] sd_cmd_cmd;
logic [31:0] sd_cmd_arg;
logic [ 6:0] sd_cmd_crc;
logic        sd_cmd_vld;
logic        switch_spi_mode;
logic        switch_acmd_mode;
logic        switch_tran_mode;
logic [ 7:0] sd_tmp;
integer      sd_image;
string       sd_image_path;

initial begin
    switch_spi_mode  = 1'b0;
    switch_acmd_mode = 1'b0;
    txfifo_wptr = 11'b0;
    txfifo_rptr = 11'b0;
    #1000000;
    cur_state = STATE_SD_PWR_UP;
end

assign sd_cmd_vld = {sd_cmd[47:46], sd_cmd[0]} == 3'b011;
assign sd_cmd_cmd = sd_cmd[45:40];
assign sd_cmd_arg = sd_cmd[39: 8];
assign sd_cmd_crc = sd_cmd[ 7: 1];

always @(posedge SCLK or negedge rstn) begin
    if (~rstn) begin
        sd_cmd      <= 48'b0;
    end
    else begin
        if (spi_upd) begin
            sd_cmd      <= {sd_cmd_vld ? 40'b0 : sd_cmd[39:0], spi_rdata};
        end
    end
end

always @(posedge SCLK or negedge rstn) begin
    if (~rstn) rampup_cnt <= 'd74;
    else       rampup_cnt <= (cur_state == STATE_SD_PWR_UP) ? rampup_cnt ? rampup_cnt - 1 : 0 :
                                                              rampup_cnt;
end

always @(posedge SCLK or negedge rstn) begin
    if (~rstn) cur_state <= STATE_SD_OFF;
    else       cur_state <= nxt_state;
end

always @(*) begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_SD_PWR_UP   : nxt_state = ~|rampup_cnt     ? STATE_SD_SDIO_INIT : STATE_SD_PWR_UP;
        STATE_SD_SDIO_INIT: nxt_state = switch_spi_mode  ? STATE_SD_SPI_INIT  : STATE_SD_SDIO_INIT;
        STATE_SD_SPI_INIT : nxt_state = switch_acmd_mode ? STATE_SD_SPI_ACMD  :
                                        switch_tran_mode ? STATE_SD_SPI_TRAN  : STATE_SD_SPI_INIT;
        STATE_SD_SPI_ACMD : nxt_state = switch_acmd_mode ? STATE_SD_SPI_ACMD  : STATE_SD_SPI_INIT;
        STATE_SD_SPI_TRAN : nxt_state = switch_spi_mode  ? STATE_SD_SPI_INIT  : STATE_SD_SPI_TRAN;
    endcase
end

always @(posedge SCLK) spi_upd_dly <= spi_upd;

always @(posedge SCLK) begin
    integer i;
    if (sd_cmd_vld && spi_upd_dly) begin
        switch_spi_mode  = 1'b0;
        switch_acmd_mode = 1'b0;
        switch_tran_mode = 1'b0;
        case (cur_state)
            STATE_SD_SDIO_INIT: begin
                case (sd_cmd_cmd)
                    6'd0: begin
                        txfifo_wdata(8'b1);
                        switch_spi_mode = 1'b1;
                    end
                endcase
            end
            STATE_SD_SPI_INIT: begin
                case (sd_cmd_cmd)
                    6'd0: begin
                        txfifo_wdata(8'b1);
                    end
                    6'd8: begin
                        txfifo_wdata(8'b1);
                        txfifo_wdata(sd_cmd_arg[31:24]);
                        txfifo_wdata(sd_cmd_arg[23:16]);
                        txfifo_wdata(sd_cmd_arg[15: 8]);
                        txfifo_wdata(sd_cmd_arg[ 7: 0]);
                    end
                    6'd16: begin
                        if (sd_cmd_arg == 32'd512) begin
                            txfifo_wdata(8'b0);
                            switch_tran_mode = 1'b1;
                        end
                    end
                    6'd55: begin
                        txfifo_wdata(8'b0);
                        switch_acmd_mode = 1'b1;
                    end
                    6'd58: begin
                        txfifo_wdata(8'b00);
                        txfifo_wdata(8'hc0);
                        txfifo_wdata(8'hff);
                        txfifo_wdata(8'h80);
                        txfifo_wdata(8'h00);
                    end
                    6'd59: begin
                        txfifo_wdata(8'b0);
                    end
                endcase
            end
            STATE_SD_SPI_ACMD: begin
                case (sd_cmd_cmd)
                    6'd41: begin
                        txfifo_wdata(8'b0);
                    end
                endcase
            end
            STATE_SD_SPI_TRAN: begin
                case (sd_cmd_cmd)
                    6'd0: begin
                        txfifo_wdata(8'b1);
                        switch_spi_mode = 1'b1;
                    end
                    6'd17: begin
                        txfifo_wdata(8'h0);
                        txfifo_wdata(8'hff);
                        txfifo_wdata(8'hff);
                        txfifo_wdata(8'hfe);
                        $sformat(sd_image_path, "../mdl/sd_image/sd_image_%08x.bin", sd_cmd_arg);
                        $display("%0d ns: [SPI_MDL] READ SD sector: %8x", $time, sd_cmd_arg);
                        sd_image = $fopen(sd_image_path, "rb");
                        for (i = 0; i < 512; i = i + 1) begin
                            if (sd_image) begin
                                $fread(sd_tmp, sd_image);
                                txfifo_wdata(sd_tmp);
                            end
                            else begin
                                if (i & 1) txfifo_wdata(8'had);
                                else       txfifo_wdata(8'hde);
                            end
                        end
                        $fclose(sd_image);
                    end
                endcase
            end
        endcase
    end
end

task txfifo_wdata;
input [7:0] wdata;

if (!(txfifo_wptr[9:0] == txfifo_rptr[9:0] && (txfifo_wptr[10] ^ txfifo_rptr[10]))) begin
    txfifo[txfifo_wptr[9:0]] = wdata;
    txfifo_wptr = txfifo_wptr + 11'b1;
end

endtask

function [7:0] txfifo_rdata;
logic [7:0] rdata;

if (txfifo_wptr != txfifo_rptr) begin
    rdata = txfifo[txfifo_rptr[9:0]];
    txfifo_rptr = txfifo_rptr + 11'b1;
end
else begin
    rdata = 8'hff;
end
return rdata;
endfunction

endmodule
