module mul (
    input                      clk,
    input                      rstn,
    input                      trig,
    input                      flush,
    input                      signed1,
    input        [  `XLEN-1:0] src1,
    input                      signed2,
    input        [  `XLEN-1:0] src2,
    output logic [2*`XLEN-1:0] out,
    output logic               okay
);

logic [2*`XLEN-1:0] src1_ext;
logic [2*`XLEN-1:0] src2_ext;

logic [        1:0] cur_state;
logic [        1:0] nxt_state;

parameter[1:0] STATE_IDLE = 2'h0,
               STATE_EXEC = 2'h1,
               STATE_DONE = 2'h2;

always_ff @(posedge clk or negedge rstn) begin: reg_src
    if (~rstn) begin
        src1_ext <= 2*`XLEN'b0;
        src2_ext <= 2*`XLEN'b0;
    end
    else if (trig) begin
        src1_ext <= {{`XLEN{signed1 & src1[`XLEN-1]}}, src1};
        src2_ext <= {{`XLEN{signed2 & src2[`XLEN-1]}}, src2};
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_out
    if (~rstn) begin
        out <= {2*`XLEN{1'b0}};
    end
    else begin
        out <= src1_ext * src2_ext;;
    end
end

// assign src1_ext = {{`XLEN{signed1 & src1[`XLEN-1]}}, src1};
// assign src2_ext = {{`XLEN{signed2 & src2[`XLEN-1]}}, src2};

// assign out  = src1_ext * src2_ext;

always_ff @(posedge clk or negedge rstn) begin: fsm
    if (~rstn) cur_state <= STATE_IDLE;
    else       cur_state <= nxt_state;
end

always_comb begin: next_state
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE: nxt_state = trig ? STATE_EXEC : STATE_IDLE;
        STATE_EXEC: nxt_state = STATE_DONE;
        STATE_DONE: nxt_state = STATE_IDLE;
    endcase
end

assign okay = cur_state == STATE_DONE;

endmodule
