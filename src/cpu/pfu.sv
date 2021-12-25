`include "cpu_define.h"

module pfu (
    input                           clk,
    input                           rstn,
    input                           flush,
    input        [     `XLEN - 1:0] bootvec,
    input                           jump,
    input        [`IM_ADDR_LEN-1:0] jump_addr,
    input                           pop,
    output logic                    jump_token,
    output logic [`IM_ADDR_LEN-1:0] pc,
    output logic [`IM_ADDR_LEN-1:0] badaddr,
    output logic [`IM_DATA_LEN-1:0] inst,
    output logic [             1:0] bad,
    output logic                    empty,

    // Inst Memory
    output logic                    imem_req,
    output logic [`IM_ADDR_LEN-1:0] imem_addr,
    input        [`IM_DATA_LEN-1:0] imem_rdata,
    input        [             1:0] imem_bad,
    input                           imem_busy,

    // for btb
    input                           btb_wr,
    input        [`IM_ADDR_LEN-1:0] btb_addr_in,
    input        [`IM_ADDR_LEN-1:0] btb_target_in
);

`define PFU_FIFO_DEPTH 4

logic [32*`PFU_FIFO_DEPTH-1:0] data_fifo;
logic [ 4*`PFU_FIFO_DEPTH-1:0] flag_fifo;
logic [                   2:0] wptr;
logic [                   2:0] rptr;
logic                          fifo_wr;
logic                          fifo_rd;
logic [                   3:0] _ndata;
logic [      `IM_ADDR_LEN-1:0] inst_len;
logic                          imem_req_latch;
logic [      `IM_ADDR_LEN-1:0] imem_addr_pre;
logic                          jump_latch;
logic [      `IM_ADDR_LEN-1:0] btb_pred;
logic                          btb_token;

always_comb begin
    inst = {data_fifo[{(rptr + 3'b1), 4'b0}+:16] & {16{data_fifo[{rptr, 4'b0}+:2] == 2'b11}}, data_fifo[{rptr, 4'b0}+:16]};
    case (_ndata)
        4'h9: inst = {16'b0, imem_rdata[31:16]};
        4'h8: inst = {imem_rdata[31:16] & {16{imem_rdata[1:0] == 2'b11}}, imem_rdata[15:0]};
        4'h7: inst = {imem_rdata[15: 0] & {16{data_fifo[{rptr, 4'b0}+:2] == 2'b11}}, data_fifo[{rptr, 4'b0}+:16]};
    endcase
end

always_comb begin
    bad = |flag_fifo[{rptr, 1'b0}+:2] ? flag_fifo[{rptr, 1'b0}+:2] : flag_fifo[{(rptr + 3'b1), 1'b0}+:2];
    case (_ndata)
        4'h9: bad = imem_bad;
        4'h8: bad = imem_bad;
        4'h7: bad = |flag_fifo[{rptr, 1'b0}+:2] ? flag_fifo[{rptr, 1'b0}+:2] : imem_bad;
    endcase
end

always_comb begin
    badaddr = |flag_fifo[{rptr, 1'b0}+:2] ? pc : pc + `IM_ADDR_LEN'h2;
    case (_ndata)
        4'h9: badaddr = pc;
        4'h8: badaddr = pc;
    endcase
end

assign inst_len = inst[1:0] == 3'b11 ? `IM_ADDR_LEN'h4 : `IM_ADDR_LEN'h2;

assign fifo_wr = imem_req_latch && ~imem_busy;
assign fifo_rd = pop && ~empty;

always_ff @(posedge clk) begin
    if (~rstn) begin
        wptr   <= 3'b0;
        rptr   <= {2'b0, bootvec[1]};
        _ndata <= 4'h8 + {3'b0, bootvec[1]};
    end
    else begin
        if (jump) begin
            wptr   <= 3'b0;
            rptr   <= {2'b0, jump_addr[1]};
            _ndata <= 4'h8 + {3'b0, jump_addr[1]};
        end
        else if (btb_token & fifo_rd) begin
            wptr   <= 3'b0;
            rptr   <= {2'b0, btb_pred[1]};
            _ndata <= 4'h8 + {3'b0, btb_pred[1]};
        end
        else begin
            wptr   <= wptr   + ({3{fifo_wr}} & 3'h2);
            rptr   <= rptr   + ({3{fifo_rd}} & inst_len[3:1]);
            _ndata <= _ndata + ({3{fifo_rd}} & inst_len[3:1]) - ({3{fifo_wr}} & 3'h2);
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        data_fifo <= {32*`PFU_FIFO_DEPTH{1'b0}};
        flag_fifo <= { 4*`PFU_FIFO_DEPTH{1'b0}};
    end
    else if (fifo_wr) begin
        data_fifo[{wptr, 4'b0}+:32] <= imem_rdata;
        flag_fifo[{wptr, 1'b0}+: 4] <= {2{imem_bad}};
    end
end

assign empty    = ~((_ndata <= 4'h6) ||
                    (_ndata <= 4'h7 && inst[1:0] != 3'b11) ||
                    (_ndata <= 4'h8 && fifo_wr) ||
                    (_ndata <= 4'h9 && fifo_wr && imem_rdata[17:16] != 3'b11));
assign imem_req = ((_ndata >= 4'h4) || (_ndata >= 4'h2 && ~imem_req_latch)) && ~imem_busy;
assign imem_addr = ~jump_latch & btb_token ? {btb_pred[`IM_ADDR_LEN-1:2], 2'b0} : imem_addr_pre;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        imem_req_latch <= 1'b0;
    end
    else if (jump) begin
        imem_req_latch <= 1'b0;
    end
    else if (btb_token & fifo_rd & imem_busy)
        imem_req_latch <= 1'b0;
    else if (~imem_busy) begin
        imem_req_latch <= imem_req;
    end
end

always_ff @(posedge clk) begin
    if (~rstn) begin
        imem_addr_pre <= {bootvec[`IM_ADDR_LEN-1:2], 2'b0};
    end
    else if (jump) begin
        imem_addr_pre <= {jump_addr[`IM_ADDR_LEN-1:2], 2'b0};
    end
    else if (btb_token & fifo_rd) begin
        imem_addr_pre <= imem_busy ? {btb_pred[`IM_ADDR_LEN-1:2], 2'b0} :
                                     {btb_pred[`IM_ADDR_LEN-1:2], 2'b0} + `IM_ADDR_LEN'h4;
    end
    else if (imem_req && ~imem_busy) begin
        imem_addr_pre <= imem_addr + `IM_ADDR_LEN'h4;
    end
end

always_ff @(posedge clk) begin
    if (~rstn) jump_latch <= 1'b0;
    else       jump_latch <= jump;
end

always_ff @(posedge clk) begin
    if (~rstn) begin
        pc <= bootvec;
    end
    else if (jump) begin
        pc <= jump_addr;
    end
    else if (fifo_rd) begin
        pc <= ~btb_token ? pc + inst_len:
                           btb_pred;
    end
end

assign jump_token = btb_token;

btb u_btb (
    .clk       ( clk           ),
    .rstn      ( rstn          ),
    .flush     ( flush         ),
    .pc_in     ( pc            ),
    .pc_out    ( btb_pred      ),
    .token     ( btb_token     ),
    .wr        ( btb_wr        ),
    .addr_in   ( btb_addr_in   ),
    .target_in ( btb_target_in )
);

endmodule
