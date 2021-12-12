`include "uart_define.h"
`include "uart_mmap.h"

module uart (
    input                 pclk,
    input                 presetn,
    input                 psel,
    input                 penable,
    input        [ 31: 0] paddr,
    input                 pwrite,
    input        [  3: 0] pstrb,
    input        [ 31: 0] pwdata,
    output logic [ 31: 0] prdata,
    output logic          pslverr,
    output logic          pready,

    input                 uart_rx,
    output logic          uart_tx
);
logic [                31:0] prdata_t;
logic [`UART_DATA_WIDTH-1:0] txdata;
logic [`UART_DATA_WIDTH-1:0] rxdata;

/*
uart_fifo u_tx_fifo (
    .clk,
    .rstn,
    .wr,
    .wdata,
    .rd,
    .rdata,
    .full,
    .empty
);
*/

assign rxdata = 8'b0;

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        txdata <= 8'b0;
    end
    else if (~penable && psel && pwrite && paddr[11:0] == `UART_TXFIFO) begin
        $write("%c", pwdata[7:0]);
        txdata <= pwdata[7:0];
    end
end

always_comb begin
    prdata_t = 32'b0;
    case (paddr[11:0])
        12'h0: prdata_t = {24'b0, txdata};
        12'h4: prdata_t = {24'b0, rxdata};
    endcase
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        prdata <= 32'b0;
    end
    else begin
        prdata <= prdata_t;
    end
end

assign pslverr = 1'b0;
assign pready  = 1'b1;

endmodule

/*
module uart_fifo (
    input                               clk,
    input                               rstn,
    input                               wr,
    input        [`UART_DATA_WIDTH-1:0] wdata,
    input                               rd,
    output logic [`UART_DATA_WIDTH-1:0] rdata,
    output logic                        full,
    output logic                        empty,
    input        [                 2:0] almost_threshold,
    output logic                        almost_full,
    output logic                        almost_empty
);

localparam PTR_WIDTH = $clog2(`UART_FIFO_DEPTH) + 1;

logic [`UART_DATA_WIDTH-1:0] fifo [`UART_FIFO_DEPTH];
logic [       PTR_WIDTH-1:0] wptr;
logic [       PTR_WIDTH-1:0] rptr;

assign rdata = fifo[rptr[0+:PTR_WIDTH-1]];
assign full  = (wptr[PTR_WIDTH-1] ^ rptr[PTR_WIDTH-1]) && wptr[0+:PTR_WIDTH-1] == rptr[0+:PTR_WIDTH-1];
assign empty = wptr == rptr;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        wptr <= {PTR_WIDTH{1'b0}};
    end
    else begin
        if (wr && ~ full) begin
            wptr <= wptr - {PTR_WIDTH{1'b1}}; // mean add 1
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        rptr <= {PTR_WIDTH{1'b0}};
    end
    else begin
        if (rd && ~ empty) begin
            rptr <= rptr - {PTR_WIDTH{1'b1}}; // mean add 1
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        for (i = 0; i < `UART_FIFO_DEPTH; i = i + 1) begin
            fifo[i] <= `UART_DATA_WIDTH'b0;
        end
    end
    else begin
        if (wr && ~ full) begin
            fifo[wptr[0+:PTR_WIDTH-1]] <= wdata;
        end
    end
end

endmodule
*/
