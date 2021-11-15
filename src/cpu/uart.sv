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

logic [31:0] prdata_t;
logic [ 7:0] txdata;
logic [ 7:0] rxdata;

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        txdata <= 8'b0;
    end
    else if (penable & psel && paddr[11:0] == 12'b0) begin
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
