`include "axi_define.h"

module axi2mem_bridge (
    input                  aclk,
    input                  aresetn,
    // AXI slave port
    input         [  1: 0] s_awburst,
    input         [ 10: 0] s_awid,
    input         [ 31: 0] s_awaddr,
    input         [  2: 0] s_awsize,
    input         [  7: 0] s_awlen,
    input                  s_awvalid,
    output logic           s_awready,
    input         [  3: 0] s_wstrb,
    input         [ 10: 0] s_wid,
    input         [ 31: 0] s_wdata,
    input                  s_wlast,
    input                  s_wvalid,
    output logic           s_wready,
    output logic  [ 10: 0] s_bid,
    output logic  [  1: 0] s_bresp,
    output logic           s_bvalid,
    input                  s_bready,
    input         [ 31: 0] s_araddr,
    input         [  1: 0] s_arburst,
    input         [  2: 0] s_arsize,
    input         [ 10: 0] s_arid,
    input         [  7: 0] s_arlen,
    input                  s_arvalid,
    output logic           s_arready,
    output logic  [ 31: 0] s_rdata,
    output logic  [  1: 0] s_rresp,
    output logic  [ 10: 0] s_rid,
    output logic           s_rlast,
    output logic           s_rvalid,
    input                  s_rready,

    // Memory intface master port
    output logic           m_cs, 
    output logic           m_we, 
    output logic  [ 31: 0] m_addr,
    output logic  [  3: 0] m_byte,
    output logic  [ 31: 0] m_di,
    input         [ 31: 0] m_do,
    input                  m_busy

);

parameter [1:0] STATE_IDLE = 2'b00,
                STATE_WR   = 2'b01,
                SIATE_RESP = 2'b10,
                STATE_RD   = 2'b11;

logic [  1: 0] cur_state;
logic [  1: 0] nxt_state;

logic          req_latch;
logic [ 10: 0] id_latch;
logic [  7: 0] cnt;
logic [ 31: 0] addr_latch;
logic [ 31: 0] addr_mask_latch;
logic [  2: 0] size_latch;
logic          id_upd;
logic          cnt_upd;
logic          addr_upd;
logic          size_upd;
logic          cnt_nxt;
logic          addr_nxt;
logic          rdata_latch_en;
logic [ 31: 0] rdata_latch;


always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        cur_state <= STATE_IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end

always_comb begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE: begin
            nxt_state = s_arvalid ? STATE_RD:
                        s_awvalid ? STATE_WR:
                                    STATE_IDLE;
        end
        STATE_WR  : begin
            nxt_state = ~|cnt & s_wvalid & s_wready ? SIATE_RESP : STATE_WR;
        end
        SIATE_RESP: begin
            nxt_state = s_bready ? STATE_IDLE : SIATE_RESP;
        end
        STATE_RD  : begin
            nxt_state = ~|cnt & s_rready & s_rvalid ? STATE_IDLE : STATE_RD;
        end
    endcase
end

assign s_bid   = id_latch;
assign s_bresp = `AXI_RESP_OKAY;
assign s_rid   = id_latch;
assign s_rdata = rdata_latch_en ? rdata_latch : m_do;
assign s_rresp = `AXI_RESP_OKAY;
assign s_rlast = ~|cnt;
assign m_addr  = addr_latch;
assign m_byte  = s_wstrb;
assign m_di    = s_wdata;

always_comb begin
    s_awready = 1'b0;
    s_wready  = 1'b0;
    s_bvalid  = 1'b0;
    s_arready = 1'b0;
    s_rvalid  = 1'b0;
    m_cs      = 1'b0;
    m_we      = 1'b0;
    id_upd    = 1'b0;
    cnt_upd   = 1'b0;
    addr_upd  = 1'b0;
    size_upd  = 1'b0;
    cnt_nxt   = 1'b0;
    addr_nxt  = 1'b0;
    case (cur_state)
        STATE_IDLE: begin
            s_awready = ~s_arvalid;
            s_arready = 1'b1;
            id_upd    = s_arvalid | s_awvalid;
            cnt_upd   = s_arvalid | s_awvalid;
            addr_upd  = s_arvalid | s_awvalid;
            size_upd  = s_arvalid | s_awvalid;
        end
        STATE_WR  : begin
            s_wready = ~m_busy;
            m_cs     = ~m_busy & s_wvalid;
            m_we     = 1'b1;
            cnt_nxt  = ~m_busy & s_wvalid;
            addr_nxt = ~m_busy & s_wvalid;
        end
        SIATE_RESP: begin
            s_bvalid = 1'b1;
        end
        STATE_RD  : begin
            s_rvalid = (~m_busy & req_latch) | rdata_latch_en;
            m_cs     = ~m_busy & ~(s_rlast & req_latch) & ~rdata_latch_en;
            cnt_nxt  = ~m_busy & req_latch & s_rready;
            addr_nxt = ~m_busy & req_latch & s_rready;
        end
    endcase
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        req_latch <= 1'b0;
    end
    else begin
        if (cur_state == STATE_RD) begin
            if (~m_busy) req_latch <= m_cs;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        rdata_latch_en <= 1'b0;
    end
    else begin
        if (cur_state == STATE_RD) begin
            if (s_rvalid & s_rready) begin
                rdata_latch_en <= 1'b0;
            end
            else if (req_latch & ~m_busy) begin
                rdata_latch_en <= 1'b1;
            end
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        rdata_latch <= 32'b0;
    end
    else begin
        if (cur_state == STATE_RD) begin
            if (req_latch & ~m_busy) begin
                rdata_latch <= m_do;
            end
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        id_latch <= 11'b0;
    end
    else begin
        if (id_upd) begin
            id_latch <= s_arvalid ? s_arid : s_awid;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        cnt <= 8'b0;
    end
    else begin
        if (cnt_upd) begin
            cnt <= s_arvalid ? s_arlen : s_awlen;
        end
        else if (cnt_nxt) begin
            cnt <= cnt - 8'b1;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        addr_mask_latch <= 32'b0;
    end
    else begin
        if (addr_upd) begin
            if (s_arvalid) begin
                case (s_arburst)
                    `AXI_BURST_FIXED: begin
                        addr_mask_latch <= ~32'b0;
                    end
                    `AXI_BURST_INCR : begin
                        addr_mask_latch <= 32'b0;
                    end
                    `AXI_BURST_WRAP : begin
                        addr_mask_latch <= ~((({{(32-8){1'b0}}, s_arlen} + 32'b1) << s_arsize) - 32'b1);
                    end
                endcase
            end
            else begin
            end
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        addr_latch <= 32'b0;
    end
    else begin
        if (addr_upd) begin
            addr_latch <= s_arvalid ? s_araddr : s_awaddr;
        end
        else if (addr_nxt) begin
            addr_latch <= (addr_latch & addr_mask_latch) | ((addr_latch + (32'b1 << size_latch)) & ~addr_mask_latch);
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        size_latch <= 3'b0;
    end
    else begin
        if (id_upd) begin
            size_latch <= s_arvalid ? s_arsize : s_awsize;
        end
    end
end



endmodule
