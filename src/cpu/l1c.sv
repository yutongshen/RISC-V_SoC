`include "axi_define.h"
`include "cache_define.h"

module l1c (
    input                                    clk,
    input                                    rstn,
    // Core side
    input                                    core_req,
    input                                    core_wr,
    input        [  `CACHE_ADDR_WIDTH - 1:0] core_addr,
    input        [  `CACHE_DATA_WIDTH - 1:0] core_wdata,
    input        [`CACHE_DATA_WIDTH/8 - 1:0] core_byte,
    output logic [  `CACHE_DATA_WIDTH - 1:0] core_rdata,
    output logic                             core_busy,

    // external
    output logic [                      1:0] m_awburst,
    output logic [                      9:0] m_awid,
    output logic [                     31:0] m_awaddr,
    output logic [                      2:0] m_awsize,
    output logic [                      7:0] m_awlen,
    output logic                             m_awvalid,
    input                                    m_awready,
    output logic [                      3:0] m_wstrb,
    output logic [                      9:0] m_wid,
    output logic [                     31:0] m_wdata,
    output logic                             m_wlast,
    output logic                             m_wvalid,
    input                                    m_wready,
    input        [                      9:0] m_bid,
    input        [                      1:0] m_bresp,
    input                                    m_bvalid,
    output logic                             m_bready,
    output logic [                     31:0] m_araddr,
    output logic [                      1:0] m_arburst,
    output logic [                      2:0] m_arsize,
    output logic [                      9:0] m_arid,
    output logic [                      7:0] m_arlen,
    output logic                             m_arvalid,
    input                                    m_arready,
    input        [                     31:0] m_rdata,
    input        [                      1:0] m_rresp,
    input        [                      9:0] m_rid,
    input                                    m_rlast,
    input                                    m_rvalid,
    output logic                             m_rready
);

parameter [2:0] STATE_IDLE   = 3'b000,
                STATE_CMP    = 3'b001,
                STATE_MREQ   = 3'b010,
                STATE_REFILL = 3'b011,
                STATE_WRITE1 = 3'b100,
                STATE_WRITE2 = 3'b101;

logic [                     2:0] cur_state;
logic [                     2:0] nxt_state;
logic [                     2:0] state_latch;
logic                            hit;

logic                            valid_wr;
logic [                    63:0] valid;
logic [  `CACHE_IDX_WIDTH - 1:0] idx;

logic [ `CACHE_ADDR_WIDTH - 1:0] core_addr_latch;
logic [                     1:0] word_cnt;
logic [ `CACHE_DATA_WIDTH - 1:0] core_rdata_tmp;
logic [  `CACHE_BLK_SIZE/8 -1:0] refill_mask;
logic                            valid_latch;
logic                            aw_done;
logic                            w_done;

logic                            tag_cs;
logic                            tag_we;
logic [  `CACHE_IDX_WIDTH - 1:0] tag_addr;
logic [  `CACHE_TAG_WIDTH - 1:0] tag_in;
logic [  `CACHE_TAG_WIDTH - 1:0] tag_out;

logic                            data_cs;
logic                            data_we;
logic [  `CACHE_IDX_WIDTH - 1:0] data_addr;
logic [  `CACHE_BLK_SIZE/8 -1:0] data_byte;
logic [    `CACHE_BLK_SIZE -1:0] data_in;
logic [    `CACHE_BLK_SIZE -1:0] data_out;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cur_state <= STATE_IDLE;
    else       cur_state <= nxt_state;
end

always_comb begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE  : begin
            nxt_state = core_req ? core_wr ? STATE_WRITE1:
                                             STATE_CMP:
                                   STATE_IDLE;
        end
        STATE_CMP   : begin
            nxt_state = hit ? core_req ? core_wr ? STATE_WRITE1:
                                                   STATE_CMP:
                                         STATE_IDLE:
                              STATE_MREQ;
        end
        STATE_MREQ  : begin
            nxt_state = m_arready ? STATE_REFILL : STATE_MREQ;
        end
        STATE_REFILL: begin
            nxt_state = (m_rlast && m_rvalid) ? STATE_IDLE : STATE_REFILL;
        end
        STATE_WRITE1: begin
            nxt_state = (aw_done && m_wready) || (m_awready && w_done) || (m_awready && m_wready) ?
                        STATE_WRITE2 : STATE_WRITE1;
        end
        STATE_WRITE2: begin
            nxt_state = m_bvalid ? STATE_IDLE : STATE_WRITE2;
        end
    endcase
end

always_comb begin
    valid_wr    = 1'b0;
    core_busy   = 1'b0;
    m_awvalid   = 1'b0;
    m_wvalid    = 1'b0;
    m_arvalid   = 1'b0;
    tag_cs      = 1'b0;
    tag_we      = 1'b0;
    data_cs     = 1'b0;
    data_we     = 1'b0;
    data_byte   = 16'b0;
    data_in     = 128'b0;
    case (cur_state)
        STATE_IDLE  : begin
            core_busy   = 1'b0;
            tag_cs      = core_req;
            data_cs     = core_req;
        end
        STATE_CMP   : begin
            core_busy   = ~hit;
            tag_cs      = 1'b1;
            data_cs     = hit & core_req;
        end
        STATE_MREQ  : begin
            core_busy   = 1'b1;
            m_arvalid   = 1'b1;
        end
        STATE_REFILL: begin
            core_busy   = 1'b1;
            data_cs     = m_rvalid;
            data_we     = m_rvalid;
            data_byte   = refill_mask;
            data_in     = {4{m_rdata}};
            tag_cs      = m_rlast && m_rvalid;
            tag_we      = m_rlast && m_rvalid;
            valid_wr    = m_rlast && m_rvalid;
        end
        STATE_WRITE1: begin
            core_busy   = 1'b1;
            m_awvalid   = ~aw_done;
            m_wvalid    = ~w_done;
            data_cs     = (hit && state_latch != STATE_WRITE1);
            data_we     = (hit && state_latch != STATE_WRITE1);
            data_byte   = {12'b0, {m_wstrb}} << {core_addr_latch[3:2], 2'b0};
            data_in     = {4{m_wdata}};
        end
        STATE_WRITE2: begin
            core_busy   = 1'b1;
        end
    endcase
end

assign idx        = core_addr[`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH];
assign tag_addr   = tag_we ? core_addr_latch[`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH]:
                             core_addr      [`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH];
assign data_addr  = data_we ? core_addr_latch[`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH]:
                              core_addr      [`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH];
assign tag_in     = core_addr_latch[`CACHE_TAG_REGION];
assign hit        = valid_latch && (tag_out == tag_in);
assign core_rdata = cur_state == STATE_IDLE ? core_rdata_tmp : data_out[{core_addr_latch[2+:2], 5'b0}+:32];
assign m_awid     = 10'b0;
assign m_awaddr   = core_addr_latch;
assign m_awburst  = `AXI_BURST_INCR;
assign m_awsize   = 3'h2;
assign m_awlen    = 8'b0;
assign m_wid      = 10'b0;
assign m_wlast    = 1'b1;
assign m_bready   = 1'b1;
assign m_arid     = 10'b0;
assign m_araddr   = {core_addr_latch[`CACHE_ADDR_WIDTH-1:`CACHE_BLK_WIDTH], {`CACHE_BLK_WIDTH{1'b0}}};
assign m_arburst  = `AXI_BURST_INCR;
assign m_arsize   = 3'h2;
assign m_arlen    = 8'h3;
assign m_rready   = 1'b1;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) state_latch <= STATE_IDLE;
    else       state_latch <= cur_state; 
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)           core_addr_latch <= `CACHE_ADDR_WIDTH'b0;
    else if (~core_busy) core_addr_latch <= core_addr;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)           valid_latch <= 1'b0;
    else if (~core_busy) valid_latch <= valid[idx];
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)         refill_mask <= {12'b0, 4'hf};
    else if (m_rvalid) refill_mask <= {refill_mask[11:0], refill_mask[15:12]};
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)         word_cnt <= 2'b0;
    else if (m_rvalid) word_cnt <= word_cnt + 2'b1;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        core_rdata_tmp <= `CACHE_DATA_WIDTH'b0;
    end
    else if (m_rvalid && word_cnt == core_addr_latch[2+:2]) begin
        core_rdata_tmp <= m_rdata;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        valid <= 64'b0;
    end
    else begin
        if (valid_wr) valid[core_addr_latch[`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH]] <= 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        m_wdata <= `CACHE_DATA_WIDTH'b0;
        m_wstrb <= {`CACHE_DATA_WIDTH/8{1'b0}};
    end
    else if (~core_busy) begin
        m_wdata <= core_wdata;
        m_wstrb <= core_byte;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        aw_done <= 1'b0;
        w_done  <= 1'b0;
    end
    else begin
        if (m_bvalid) begin
            aw_done <= 1'b0;
            w_done  <= 1'b0;
        end
        else begin
            if (m_awready) aw_done <= 1'b1;
            if (m_wready ) w_done  <= 1'b1;
        end
    end
end

sram64x22 u_tagram(
    .CK   ( clk      ),
    .CS   ( tag_cs   ),
    .WE   ( tag_we   ),
    .A    ( tag_addr ),
    .DI   ( tag_in   ),
    .DO   ( tag_out  )
);

sram64x128 u_dataram(
    .CK   ( clk       ),
    .CS   ( data_cs   ),
    .WE   ( data_we   ),
    .A    ( data_addr ),
    .BYTE ( data_byte ),
    .DI   ( data_in   ),
    .DO   ( data_out  )
);

endmodule
