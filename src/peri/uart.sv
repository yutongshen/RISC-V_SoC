`include "clkdef.h"
`include "uart_define.h"
`include "uart_mmap.h"

module uart (
    input                 clk,
    input                 rstn,
    apb_intf.slave        s_apb_intf,

    output logic          irq_out,
    input                 uart_rx,
    output logic          uart_tx
);

logic [                31:0] prdata_t;
logic                        txen;
logic                        nstop;
logic [                 2:0] txcnt;
logic                        rxen;
logic [                 2:0] rxcnt;
logic [                15:0] div;
logic                        apb_wr;
logic                        apb_rd;

logic                        tx_fifo_wr;
logic [`UART_DATA_WIDTH-1:0] tx_fifo_wdata;
logic                        tx_fifo_rd;
logic [`UART_DATA_WIDTH-1:0] tx_fifo_rdata;
logic                        tx_fifo_full;
logic                        tx_fifo_empty;

logic                        rx_fifo_wr;
logic [`UART_DATA_WIDTH-1:0] rx_fifo_wdata;
logic                        rx_fifo_rd;
logic [`UART_DATA_WIDTH-1:0] rx_fifo_rdata;
logic                        rx_fifo_full;
logic                        rx_fifo_empty;

logic                        txwm_ie;
logic                        rxwm_ie;
logic                        perror_ie;
logic                        txwm_ip;
logic                        rxwm_ip;
logic                        perror_ip;
logic                        txwm_ip_tmp;
logic                        rxwm_ip_tmp;
logic                        perror_ip_tmp;

logic [                 2:0] lcr;

assign irq_out    = (txwm_ip   && txwm_ie  ) ||
                    (rxwm_ip   && rxwm_ie  ) ||
                    (perror_ip && perror_ie);

assign apb_wr     = ~s_apb_intf.penable && s_apb_intf.psel &&  s_apb_intf.pwrite;
assign apb_rd     = ~s_apb_intf.penable && s_apb_intf.psel && ~s_apb_intf.pwrite;

`ifndef FAKE_UART
assign tx_fifo_wr    = apb_wr && s_apb_intf.paddr[11:0] == `UART_TXFIFO && ~tx_fifo_full && ~s_apb_intf.pwdata[31];
assign tx_fifo_wdata = s_apb_intf.pwdata[`UART_DATA_WIDTH-1:0];
`else
assign tx_fifo_wr    = 1'b0;
assign tx_fifo_wdata = s_apb_intf.pwdata[`UART_DATA_WIDTH-1:0];
always @(posedge clk or negedge rstn) begin: fake_uart_tx
    if (~rstn) begin
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `UART_TXFIFO && ~s_apb_intf.pwdata[31]) begin
        $write("%c", tx_fifo_wdata[7:0]);
    end
end
`endif

uart_fifo u_tx_fifo(
    .clk          ( clk              ),
    .rstn         ( rstn             ),
    .wr           ( tx_fifo_wr       ),
    .wdata        ( tx_fifo_wdata    ),
    .rd           ( tx_fifo_rd       ),
    .rdata        ( tx_fifo_rdata    ),
    .full         ( tx_fifo_full     ),
    .empty        ( tx_fifo_empty    ),
    .full_th      ( 3'b0             ),
    .empty_th     ( txcnt            ),
    .almost_empty ( txwm_ip_tmp      )
);

tx_ctrl u_tx_ctrl(
    .clk      ( clk              ),
    .rstn     ( rstn             ),
    .enable   ( txen             ),
    .lcr      ( lcr              ),
    .nstop    ( nstop            ),
    .div      ( div              ),
    .data_vld ( ~tx_fifo_empty   ),
    .data_in  ( tx_fifo_rdata    ),
    .pop      ( tx_fifo_rd       ),
    .uart_tx  ( uart_tx          )
);

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        txen  <= 1'b0;
        nstop <= 1'b0;
        txcnt <= 3'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `UART_TXCTRL) begin
        txen  <= s_apb_intf.pwdata[0];
        nstop <= s_apb_intf.pwdata[1];
        txcnt <= s_apb_intf.pwdata[18:16];
    end
end

assign rx_fifo_rd = apb_rd && s_apb_intf.paddr[11:0] == `UART_RXFIFO;

uart_fifo u_rx_fifo(
    .clk          ( clk              ),
    .rstn         ( rstn             ),
    .wr           ( rx_fifo_wr       ),
    .wdata        ( rx_fifo_wdata    ),
    .rd           ( rx_fifo_rd       ),
    .rdata        ( rx_fifo_rdata    ),
    .full         ( rx_fifo_full     ),
    .empty        ( rx_fifo_empty    ),
    .full_th      ( rxcnt            ),
    .almost_full  ( rxwm_ip_tmp      ),
    .empty_th     ( 3'b0             )
);

rx_ctrl u_rx_ctrl (
    .clk      ( clk              ),
    .rstn     ( rstn             ),
    .enable   ( rxen             ),
    .lcr      ( lcr              ),
    .div      ( div              ),
    .push     ( rx_fifo_wr       ),
    .data_out ( rx_fifo_wdata    ),
    .perror   ( perror_ip_tmp    ),
    .uart_rx  ( uart_rx          )
);

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        rxen  <= 1'b0;
        rxcnt <= 3'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `UART_TXCTRL) begin
        rxen  <= s_apb_intf.pwdata[0];
        rxcnt <= s_apb_intf.pwdata[18:16];
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        txwm_ie   <= 1'b0;
        rxwm_ie   <= 1'b0;
        perror_ie <= 1'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `UART_IE) begin
        txwm_ie   <= s_apb_intf.pwdata[0];
        rxwm_ie   <= s_apb_intf.pwdata[1];
        perror_ie <= s_apb_intf.pwdata[2];
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        txwm_ip   <= 1'b0;
        rxwm_ip   <= 1'b0;
        perror_ip <= 1'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `UART_IC) begin
        txwm_ip   <= txwm_ip   && ~s_apb_intf.pwdata[0];
        rxwm_ip   <= rxwm_ip   && ~s_apb_intf.pwdata[1];
        perror_ip <= perror_ip && ~s_apb_intf.pwdata[2];
    end
    else begin
        txwm_ip   <= txwm_ip_tmp;
        rxwm_ip   <= rxwm_ip_tmp;
        perror_ip <= perror_ip_tmp;
        // txwm_ip   <= txwm_ip_tmp   || txwm_ip;
        // rxwm_ip   <= rxwm_ip_tmp   || rxwm_ip;
        // perror_ip <= perror_ip_tmp || perror_ip;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        div <= 1000000000/30/115200; // baurd rate = 115200
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `UART_DIV) begin
        div <= s_apb_intf.pwdata[15:0];
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        lcr <= 3'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[11:0] == `UART_LCR) begin
        lcr <= s_apb_intf.pwdata[5:3];
    end
end

always_comb begin
    prdata_t = 32'b0;
    case (s_apb_intf.paddr[11:0])
        `UART_TXFIFO: prdata_t = {tx_fifo_full,  31'b0};
        `UART_RXFIFO: prdata_t = {rx_fifo_empty, 23'b0, rx_fifo_rdata & {8{~rx_fifo_empty}}};
        `UART_TXCTRL: prdata_t = {13'b0, txcnt, 14'b0, nstop, txen};
        `UART_RXCTRL: prdata_t = {13'b0, rxcnt, 14'b0,  1'b0, rxen};
        `UART_IE    : prdata_t = {29'b0, perror_ie, rxwm_ie, txwm_ie};
        `UART_IP    : prdata_t = {29'b0, perror_ip, rxwm_ip, txwm_ip};
        `UART_IC    : prdata_t = {29'b0, perror_ip, rxwm_ip, txwm_ip};
        `UART_DIV   : prdata_t = {16'b0, div};
    endcase
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        s_apb_intf.prdata <= 32'b0;
    end
    else begin
        s_apb_intf.prdata <= prdata_t;
    end
end

assign s_apb_intf.pslverr = 1'b0;
assign s_apb_intf.pready  = 1'b1;

endmodule

module uart_fifo (
    input                               clk,
    input                               rstn,
    input                               wr,
    input        [`UART_DATA_WIDTH-1:0] wdata,
    input                               rd,
    output logic [`UART_DATA_WIDTH-1:0] rdata,
    output logic                        full,
    output logic                        empty,
    input        [                 2:0] full_th,
    output logic                        almost_full,
    input        [                 2:0] empty_th,
    output logic                        almost_empty
);

localparam PTR_WIDTH = $clog2(`UART_FIFO_DEPTH);

logic [`UART_DATA_WIDTH-1:0] fifo [`UART_FIFO_DEPTH];
logic [       PTR_WIDTH-1:0] wptr;
logic [       PTR_WIDTH-1:0] rptr;
logic [       PTR_WIDTH  :0] ndata;

assign rdata        = fifo[rptr];
assign full         = ndata[PTR_WIDTH];
assign almost_full  = ndata >  {1'b0, full_th, {PTR_WIDTH-3{1'b0}}};
assign empty        = ~|ndata;
assign almost_empty = ndata <= {1'b0, empty_th, {PTR_WIDTH-3{1'b0}}};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        wptr  <= {PTR_WIDTH  {1'b0}};
        rptr  <= {PTR_WIDTH  {1'b0}};
        ndata <= {PTR_WIDTH+1{1'b0}};
    end
    else begin
        wptr  <= wptr  + {{PTR_WIDTH-1{1'b0}}, (wr && ~full)};
        rptr  <= rptr  + {{PTR_WIDTH-1{1'b0}}, (rd && ~empty)};
        ndata <= ndata + {{PTR_WIDTH  {1'b0}}, (wr && ~full)} - {{PTR_WIDTH  {1'b0}}, (rd && ~empty)};
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < `UART_FIFO_DEPTH; i = i + 1) begin
            fifo[i] <= `UART_DATA_WIDTH'b0;
        end
    end
    else begin
        if (wr && ~ full) begin
            fifo[wptr] <= wdata;
        end
    end
end

endmodule

module tx_ctrl (
    input               clk,
    input               rstn,
    input               enable,
    input        [ 2:0] lcr,
    input               nstop,
    input        [15:0] div,
    input               data_vld,
    input        [ 7:0] data_in,
    output logic        pop,
    output logic        uart_tx
);

localparam STATE_IDLE   = 3'b000;
localparam STATE_START  = 3'b001;
localparam STATE_DATA   = 3'b010;
localparam STATE_PARITY = 3'b011;
localparam STATE_STOP   = 3'b100;

logic [ 2:0] cur_state;
logic [ 2:0] nxt_state;

logic [15:0] cnt;
logic [15:0] rept;
logic [15:0] nxt_rept;
logic        uart_tx_tmp;
logic [ 7:0] data_sft;
logic        data_par;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cur_state <= STATE_IDLE;
    else       cur_state <= nxt_state;
end

always_comb begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE  : nxt_state = enable && data_vld ? STATE_START : STATE_IDLE;
        STATE_START : nxt_state = ~|cnt ? STATE_DATA : STATE_START;
        STATE_DATA  : nxt_state = ~|cnt && ~|rept ? lcr[0] ? STATE_PARITY : STATE_STOP : STATE_DATA;
        STATE_PARITY: nxt_state = ~|cnt ? STATE_STOP : STATE_PARITY;
        STATE_STOP  : nxt_state = ~|cnt && ~|rept ? STATE_IDLE : STATE_STOP;
    endcase
end

always_comb begin
    nxt_rept    = 16'b0;
    uart_tx_tmp = 1'b1;
    pop         = 1'b0;
    case (cur_state)
        STATE_IDLE  : begin
            nxt_rept    = 16'b0;
            uart_tx_tmp = 1'b1;
            pop         = enable && data_vld;
        end
        STATE_START : begin
            nxt_rept    = 16'h7;
            uart_tx_tmp = 1'b0;
        end
        STATE_DATA  : begin
            nxt_rept    = nxt_state == STATE_PARITY ? 16'b0 : {15'b0, nstop};
            uart_tx_tmp = data_sft[0];
        end
        STATE_PARITY: begin
            nxt_rept    = {15'b0, nstop};
            uart_tx_tmp = data_par;
        end
        STATE_STOP  : begin
            uart_tx_tmp = 1'b1;
        end
    endcase
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) uart_tx <= 1'b1;
    else       uart_tx <= uart_tx_tmp;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        data_sft <= 8'b0;
        data_par <= 1'b0;
    end
    else begin
        if (pop) begin
            data_sft <=  data_in;
            data_par <= ^data_in;
        end
        else if (cur_state == STATE_DATA && ~|cnt) begin
            data_sft <= {1'b0, data_sft[7:1]};
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        cnt <= 16'b0;
    end
    else begin
        if (cur_state == STATE_IDLE) begin
            cnt <= div;
        end
        else begin
            cnt <= |cnt ? cnt - 16'b1 : div;
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        rept <= 16'b0;
    end
    else begin
        if (~|cnt) begin
            rept <= |rept ? rept - 16'b1 : nxt_rept;
        end
    end
end

endmodule

module rx_ctrl (
    input               clk,
    input               rstn,
    input               enable,
    input        [ 2:0] lcr,
    input        [15:0] div,
    output logic        push,
    output logic [ 7:0] data_out,
    output logic        perror,
    input               uart_rx
);

localparam STATE_IDLE   = 3'b000;
localparam STATE_START  = 3'b001;
localparam STATE_DATA   = 3'b010;
localparam STATE_PARITY = 3'b011;
localparam STATE_STOP   = 3'b100;
localparam STATE_ERROR  = 3'b101;

logic [             2:0] cur_state;
logic [             2:0] nxt_state;

logic [`UART_N_SYNC-1:0] uart_tx_dly;
logic                    uart_tx_sync;

logic [            15:0] cnt;
logic [            15:0] rept;
logic [            15:0] nxt_rept;
logic                    data_par;
logic                    perror_tmp;
logic                    err_detect;
logic                    sample_data;
logic                    sample_parity;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) uart_tx_dly <= `UART_N_SYNC'b0;
    else       uart_tx_dly <= {uart_rx, uart_tx_dly[`UART_N_SYNC-1:1]};
end

assign uart_tx_sync = uart_tx_dly[0];

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cur_state <= STATE_IDLE;
    else       cur_state <= nxt_state;
end

always_comb begin
    nxt_state = cur_state;
    if (err_detect) begin
        nxt_state = STATE_ERROR;
    end
    else begin
        case (cur_state)
            STATE_IDLE  : nxt_state = enable && ~uart_tx_sync ? STATE_START : STATE_IDLE;
            STATE_START : nxt_state = ~|cnt ? STATE_DATA : STATE_START;
            STATE_DATA  : nxt_state = ~|cnt && ~|rept ? lcr[0] ? STATE_PARITY : STATE_STOP : STATE_DATA;
            STATE_PARITY: nxt_state = ~|cnt ? STATE_STOP : STATE_PARITY;
            STATE_STOP  : nxt_state = ~|cnt && ~|rept ? STATE_IDLE : STATE_STOP;
            STATE_ERROR : nxt_state = STATE_IDLE;
        endcase
    end
end

always_comb begin
    push          = 1'b0;
    perror        = 1'b0;
    nxt_rept      = 16'b0;
    err_detect    = 1'b0;
    sample_data   = 1'b0;
    sample_parity = 1'b0;
    case (cur_state)
        STATE_IDLE  : begin
        end
        STATE_START : begin
            err_detect    = (cnt == {1'b0, div[15:1]}) && uart_tx_sync;
            nxt_rept      = 16'h7;
        end
        STATE_DATA  : begin
            sample_data   = cnt == {1'b0, div[15:1]};
        end
        STATE_PARITY: begin
            sample_parity = cnt == {1'b0, div[15:1]};
        end
        STATE_STOP  : begin
            err_detect    = (cnt == {1'b0, div[15:1]}) && ~uart_tx_sync;
            push          = (cnt == {1'b0, div[15:1]}) &&  uart_tx_sync && ~perror_tmp;
            perror        = (cnt == {1'b0, div[15:1]}) &&  perror_tmp;
        end
    endcase
end

assign perror_tmp = lcr[0] && (^data_out ^ data_par);

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        data_out <= 8'b0;
        data_par <= 1'b0;
    end
    else begin
        if (sample_data) begin
            data_out <= {uart_tx_sync, data_out[7:1]};
        end
        if (sample_parity) begin
            data_par <= uart_tx_sync;
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        cnt <= 16'b0;
    end
    else begin
        if (cur_state == STATE_IDLE) begin
            cnt <= div;
        end
        else begin
            cnt <= |cnt ? cnt - 16'b1 : div;
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        rept <= 16'b0;
    end
    else begin
        if (~|cnt) begin
            rept <= |rept ? rept - 16'b1 : nxt_rept;
        end
    end
end


endmodule
