module rgu (
    input        clk,
    input        pwr_rstn,
    input        warm_rst_trigger,
    output logic xrstn,
    output logic srstn
);

localparam STATE_IDLE   = 2'b00;
localparam STATE_RSTPRE = 2'b01;
localparam STATE_RST    = 2'b10;

logic [1:0] cur_state;
logic [1:0] nxt_state;

logic [9:0] cnt;
logic [9:0] nxt_cnt;
logic       upd_cnt;

always_ff @(posedge clk or negedge pwr_rstn) begin
    if (~pwr_rstn) cur_state <= STATE_IDLE;
    else           cur_state <= nxt_state;
end

always_comb begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE  : nxt_state = warm_rst_trigger ? STATE_RSTPRE : STATE_IDLE;
        STATE_RSTPRE: nxt_state = ~|cnt            ? STATE_RST    : STATE_RSTPRE;
        STATE_RST   : nxt_state = ~|cnt            ? STATE_IDLE   : STATE_RST;
    endcase
end

always_comb begin
    nxt_cnt       = 10'b0;
    upd_cnt       = 1'b0;
    case (cur_state)
        STATE_IDLE  : begin
            nxt_cnt = 10'h20;
            upd_cnt = warm_rst_trigger;
        end
        STATE_RSTPRE: begin
            nxt_cnt = 10'ha;
            upd_cnt = ~|cnt;
        end
        STATE_RST   : begin
        end
    endcase
end

always_ff @(posedge clk or negedge pwr_rstn) begin
    if (~pwr_rstn) begin
        cnt <= 10'b0;
    end
    else begin
        if (upd_cnt) begin
            cnt <= nxt_cnt;
        end
        else begin
            cnt <= |cnt ? cnt - 10'b1 : cnt;
        end
    end
end

always_ff @(posedge clk or negedge pwr_rstn) begin
    if (~pwr_rstn) begin
        srstn <= 1'b0;
        xrstn <= 1'b0;
    end
    else begin
        srstn <= cur_state != STATE_RST;
        xrstn <= 1'b1;
    end
end

endmodule
