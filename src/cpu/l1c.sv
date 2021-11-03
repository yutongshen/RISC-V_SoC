`include "axi_define.h"
`include "cache_define.h"

module l1c (
    input                                    clk,
    input                                    rstn,
    // Core side
    input                                    core_req,
    input                                    core_pa_vld,
    input        [  `CACHE_ADDR_WIDTH - 1:0] core_paddr,
    input                                    core_bypass,
    input                                    core_wr,
    input        [  `CACHE_ADDR_WIDTH - 1:0] core_vaddr,
    input        [  `CACHE_DATA_WIDTH - 1:0] core_wdata,
    input        [`CACHE_DATA_WIDTH/8 - 1:0] core_byte,
    output logic [  `CACHE_DATA_WIDTH - 1:0] core_rdata,
    output logic                             core_err,
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
                STATE_WRITE  = 3'b100,
                STATE_READ   = 3'b101;

logic [                     2:0] cur_state;
logic [                     2:0] nxt_state;
logic [                     2:0] state_latch;
logic                            hit;

logic                            valid_wr;
logic [                    63:0] valid;
logic [  `CACHE_IDX_WIDTH - 1:0] idx;

logic [ `CACHE_ADDR_WIDTH - 1:0] core_vaddr_latch;
logic [                     1:0] word_cnt;
logic [ `CACHE_DATA_WIDTH - 1:0] core_rdata_tmp;
logic [  `CACHE_BLK_SIZE/8 -1:0] refill_mask;
logic                            valid_latch;
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

logic                            rdata_tmp_wr;
logic                            core_bypass_latch;
logic                            ar_done;
logic                            aw_done;
logic                            w_done;


always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cur_state <= STATE_IDLE;
    else       cur_state <= nxt_state;
end

always_comb begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE  : begin
            nxt_state = core_req ? core_wr     ? STATE_WRITE:
                                   core_bypass ? STATE_READ:
                                                 STATE_CMP:
                                   STATE_IDLE;
        end
        STATE_CMP   : begin
            nxt_state = hit ? core_req ? core_wr     ? STATE_WRITE:
                                         core_bypass ? STATE_READ:
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
        STATE_WRITE : begin
            nxt_state = m_bvalid ? STATE_IDLE : STATE_WRITE;
        end
        STATE_READ  : begin
            nxt_state = (m_rlast && m_rvalid) ? STATE_IDLE : STATE_READ;
        end
    endcase
end

always_comb begin
    rdata_tmp_wr = 1'b0;
    valid_wr     = 1'b0;
    core_busy    = 1'b0;
    m_awvalid    = 1'b0;
    m_wvalid     = 1'b0;
    m_arvalid    = 1'b0;
    tag_cs       = 1'b0;
    tag_we       = 1'b0;
    data_cs      = 1'b0;
    data_we      = 1'b0;
    data_byte    = 16'b0;
    data_in      = 128'b0;
    case (cur_state)
        STATE_IDLE  : begin
            core_busy    = 1'b0;
            tag_cs       = core_req && ~core_bypass;
            data_cs      = core_req && ~core_bypass;
        end
        STATE_CMP   : begin
            core_busy    = ~hit;
            tag_cs       = hit && core_req && ~core_bypass;
            data_cs      = hit && core_req && ~core_bypass;
        end
        STATE_MREQ  : begin
            core_busy    = 1'b1;
            m_arvalid    = 1'b1;
        end
        STATE_REFILL: begin
            core_busy    = 1'b1;
            data_cs      = m_rvalid;
            data_we      = m_rvalid;
            data_byte    = refill_mask;
            data_in      = {4{m_rdata}};
            tag_cs       = m_rlast && m_rvalid;
            tag_we       = m_rlast && m_rvalid;
            valid_wr     = m_rlast && m_rvalid && ~m_rresp[1] && ~core_err;
            rdata_tmp_wr = m_rvalid && word_cnt == core_vaddr_latch[2+:2];
        end
        STATE_WRITE : begin
            core_busy    = 1'b1;
            m_awvalid    = ~aw_done;
            m_wvalid     = ~w_done;
            data_cs      = (hit && state_latch != STATE_WRITE) && ~core_bypass_latch;
            data_we      = (hit && state_latch != STATE_WRITE);
            data_byte    = {12'b0, {m_wstrb}} << {core_vaddr_latch[3:2], 2'b0};
            data_in      = {4{m_wdata}};
        end
        STATE_READ  : begin
            core_busy    = 1'b1;
            rdata_tmp_wr = m_rvalid;
            m_arvalid    = ~ar_done;
        end
    endcase
end

assign idx        = core_vaddr[`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH];
assign tag_addr   = tag_we ? core_vaddr_latch[`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH]:
                             core_vaddr      [`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH];
assign data_addr  = data_we ? core_vaddr_latch[`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH]:
                              core_vaddr      [`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH];
assign tag_in     = core_vaddr_latch[`CACHE_TAG_REGION];
assign hit        = valid_latch && (tag_out == tag_in);
assign core_rdata = cur_state == STATE_IDLE ? core_rdata_tmp : data_out[{core_vaddr_latch[2+:2], 5'b0}+:32];
assign m_awid     = 10'b0;
assign m_awaddr   = core_vaddr_latch;
assign m_awburst  = `AXI_BURST_INCR;
assign m_awsize   = 3'h2;
assign m_awlen    = 8'b0;
assign m_wid      = 10'b0;
assign m_wlast    = 1'b1;
assign m_bready   = 1'b1;
assign m_arid     = 10'b0;
assign m_araddr   = cur_state == STATE_READ ? core_vaddr_latch :
                        {core_vaddr_latch[`CACHE_ADDR_WIDTH-1:`CACHE_BLK_WIDTH], {`CACHE_BLK_WIDTH{1'b0}}};
assign m_arburst  = `AXI_BURST_INCR;
assign m_arsize   = 3'h2;
assign m_arlen    = cur_state == STATE_MREQ ? 8'h3 : 8'h0;
assign m_rready   = 1'b1;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) state_latch <= STATE_IDLE;
    else       state_latch <= cur_state; 
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)                        core_err <= 1'b0;
    else if (cur_state == STATE_IDLE) core_err <= 1'b0;
    else if (m_bresp[1] && m_bvalid)  core_err <= 1'b1;
    else if (m_rresp[1] && m_rvalid)  core_err <= 1'b1;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)           core_bypass_latch <= 1'b0;
    else if (~core_busy) core_bypass_latch <= core_bypass;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)           core_vaddr_latch <= `CACHE_ADDR_WIDTH'b0;
    else if (~core_busy) core_vaddr_latch <= core_vaddr;
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
    else if (rdata_tmp_wr) begin
        core_rdata_tmp <= m_rdata;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        valid <= 64'b0;
    end
    else begin
        if (valid_wr) valid[core_vaddr_latch[`CACHE_BLK_WIDTH+:`CACHE_IDX_WIDTH]] <= 1'b1;
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

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        ar_done <= 1'b0;
    end
    else begin
        if (m_rvalid) begin
            ar_done <= 1'b0;
        end
        else begin
            if (m_arready) ar_done <= 1'b1;
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
