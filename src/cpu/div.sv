module div (
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

localparam STATE_IDLE = 2'b00;
localparam STATE_EXEC = 2'b01;
localparam STATE_OKAY = 2'b10;

logic [        1:0] cur_state;
logic [        1:0] nxt_state;

logic [  `XLEN-1:0] src1_pos;
logic [  `XLEN-1:0] src2_pos;
logic [  `XLEN-1:0] src2_pos_latch;

logic               neg1;
logic               neg2;

logic               neg1_latch;
logic               neg2_latch;

logic [        6:0] src1_clz;
logic [        6:0] src2_clz;

logic [        6:0] sft_bit;
logic [        4:0] sft_bit_div4;
logic [        4:0] cnt;
logic [        4:0] nxt_cnt;
logic               skip;

`define NBIT_DIV 4
logic [    `XLEN-1:0] dividend     [`NBIT_DIV];
logic [    `XLEN-1:0] nxt_dividend [`NBIT_DIV];
logic [`NBIT_DIV-1:0] res;
logic [    `XLEN-1:0] rem;
logic [    `XLEN-1:0] tmp;


assign neg1     = signed1 & src1[`XLEN-1];
assign neg2     = signed2 & src2[`XLEN-1];

assign src1_pos = neg1 ? -src1 : src1;
assign src2_pos = neg2 ? -src2 : src2;

`ifdef RV32
assign src1_clz[6] = 1'b0;
clz_32 u_src1_clz (
    .in  ( src1_pos      ),
    .out ( src1_clz[5:0] )
);

assign src2_clz[6] = 1'b0;
clz_32 u_src2_clz (
    .in  ( src2_pos      ),
    .out ( src2_clz[5:0] )
);
`else
clz_64 u_src1_clz (
    .in  ( src1_pos ),
    .out ( src1_clz )
);

clz_64 u_src2_clz (
    .in  ( src2_pos ),
    .out ( src2_clz )
);
`endif

assign sft_bit      = 7'd`XLEN - src2_clz + src1_clz;
`ifdef RV32
assign sft_bit_div4 = {1'b0, sft_bit[5:2]};
assign nxt_cnt      = 5'd7 - sft_bit_div4;
`else
assign sft_bit_div4 = sft_bit[6:2];
assign nxt_cnt      = 5'd15 - sft_bit_div4;
`endif


always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cur_state <= STATE_IDLE;
    else       cur_state <= nxt_state;
end

always_comb begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE: nxt_state = flush ? STATE_IDLE :
                                trig  ? skip ? STATE_OKAY:
                                               STATE_EXEC:
                                        STATE_IDLE;
        STATE_EXEC: nxt_state = flush | ~|cnt ? STATE_OKAY : STATE_EXEC;
        STATE_OKAY: nxt_state = STATE_IDLE;
    endcase
end

always_comb begin
    okay = 1'b0;
    case (cur_state)
        STATE_IDLE: begin
            okay = 1'b0;
        end
        STATE_EXEC: begin
            okay = 1'b0;
        end
        STATE_OKAY: begin
            okay = 1'b1;
        end
    endcase
end

assign skip = (src2 == `XLEN'b1) || (src2 == -`XLEN'b1 && signed2) || (src2 == `XLEN'b0) || (src1_pos < src2_pos);

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        out            <= {2*`XLEN{1'b0}};
        src2_pos_latch <= `XLEN'b0;
        neg1_latch     <= 1'b0;
        neg2_latch     <= 1'b0;
    end
    else begin
        if (skip) begin
            out[    0+:`XLEN] <= ({`XLEN{src2 ==  `XLEN'b1           }} &  src1) |
                                 ({`XLEN{src2 == -`XLEN'b1 && signed2}} & -src1) |
                                 ({`XLEN{src2 ==  `XLEN'b0           }} & -`XLEN'b1) |
                                 ({`XLEN{src1_pos < src2_pos         }} &  `XLEN'b0);
            out[`XLEN+:`XLEN] <= ({`XLEN{src2 ==  `XLEN'b1           }} &  `XLEN'b0) |
                                 ({`XLEN{src2 == -`XLEN'b1 && signed2}} & -`XLEN'b0) |
                                 ({`XLEN{src2 ==  `XLEN'b0           }} &  src1) |
                                 ({`XLEN{src1_pos < src2_pos         }} &  src1);
        end
        else if (cur_state == STATE_IDLE) begin
            out            <= src1_pos << {sft_bit_div4, 2'b0};
            src2_pos_latch <= src2_pos;
            neg1_latch     <= neg1;
            neg2_latch     <= neg2;
        end
        else begin
            if (~|cnt) begin
                out[    0+:`XLEN] <= neg1_latch ^ neg2_latch ? -{out[`XLEN-1-`NBIT_DIV:0],  res} : {out[`XLEN-1-`NBIT_DIV:0], res};
                out[`XLEN+:`XLEN] <= neg1_latch              ? -rem : rem;
            end
            else out <= {rem, out[`XLEN-1-`NBIT_DIV:0], res};
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        cnt <= 5'b0;
    end
    else begin
        if (cur_state == STATE_IDLE) begin
            cnt <= nxt_cnt;
        end
        else begin
            cnt <= |cnt ? cnt - 5'b1 : cnt;
        end
    end
end

assign tmp = out[`XLEN-`NBIT_DIV+:`XLEN];

genvar g;
generate
    for (g = `NBIT_DIV-1; g >= 0; g = g - 1) begin: g_div_unit
        if (g == `NBIT_DIV-1) begin: g_div_unit_1st
            assign dividend[g] = {{`NBIT_DIV-1{1'b0}}, tmp[`XLEN-1:`NBIT_DIV-1]};
        end
        else begin: g_div_unit_nth
            assign dividend[g] = {nxt_dividend[g+1][`XLEN-2:0], tmp[g]};
        end
        assign res[g]          = src2_pos_latch <= dividend[g];
        assign nxt_dividend[g] = res[g] ? dividend[g] - src2_pos_latch : dividend[g];
    end
endgenerate
assign rem = nxt_dividend[0];

endmodule
