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

pullup(SCLK);
pullup(NSS);
pullup(MOSI);
pullup(MISO);

assign MISO = OE ? miso_o : 1'bz;

initial begin
    OE      = 1'b0;
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
            tx_data = rx_data;
            $display("%0d ns: [SPI_MDL] Receive DATA %8x", $time, rx_data);
            rx_data = 16'b0;
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


endmodule
