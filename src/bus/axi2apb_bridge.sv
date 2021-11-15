`include "axi_define.h"

module axi2apb_bridge (
    input                  aclk,
    input                  aresetn,
    // AXI slave port
    input         [  1: 0] s_awburst,
    input         [ 11: 0] s_awid,
    input         [ 31: 0] s_awaddr,
    input         [  2: 0] s_awsize,
    input         [  7: 0] s_awlen,
    input                  s_awvalid,
    output logic           s_awready,
    input         [  3: 0] s_wstrb,
    input         [ 11: 0] s_wid,
    input         [ 31: 0] s_wdata,
    input                  s_wlast,
    input                  s_wvalid,
    output logic           s_wready,
    output logic  [ 11: 0] s_bid,
    output logic  [  1: 0] s_bresp,
    output logic           s_bvalid,
    input                  s_bready,
    input         [ 31: 0] s_araddr,
    input         [  1: 0] s_arburst,
    input         [  2: 0] s_arsize,
    input         [ 11: 0] s_arid,
    input         [  7: 0] s_arlen,
    input                  s_arvalid,
    output logic           s_arready,
    output logic  [ 31: 0] s_rdata,
    output logic  [  1: 0] s_rresp,
    output logic  [ 11: 0] s_rid,
    output logic           s_rlast,
    output logic           s_rvalid,
    input                  s_rready,

    // APB master port
    output logic           psel,
    output logic           penable,
    output logic  [ 31: 0] paddr,
    output logic           pwrite,
    output logic  [  3: 0] pstrb,
    output logic  [ 31: 0] pwdata,
    input         [ 31: 0] prdata,
    input                  pslverr,
    input                  pready

);

parameter [2:0] STATE_IDLE  = 3'b000,
                STATE_WR    = 3'b001,
                SIATE_BRESP = 3'b010,
                STATE_RD    = 3'b011,
                STATE_RRESP = 3'b100;

logic [  2: 0] cur_state;
logic [  2: 0] nxt_state;

logic [ 11: 0] id_latch;
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
logic [ 31: 0] rdata_latch;
logic [  1: 0] resp_latch;


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
            nxt_state = ~|cnt & s_wvalid & s_wready ? SIATE_BRESP : STATE_WR;
        end
        SIATE_BRESP: begin
            nxt_state = s_bready ? STATE_IDLE : SIATE_BRESP;
        end
        STATE_RD  : begin
            nxt_state = penable & pready ? STATE_RRESP : STATE_RD;
        end
        STATE_RRESP: begin
            nxt_state = ~|cnt & s_rready ? STATE_IDLE:
                        s_rready         ? STATE_RD:
                                           STATE_RRESP;
        end
    endcase
end

assign s_bid   = id_latch;
assign s_bresp = resp_latch;
assign s_rid   = id_latch;
assign s_rdata = rdata_latch;
assign s_rresp = resp_latch;
assign s_rlast = ~|cnt;
assign paddr   = addr_latch;
assign pstrb   = s_wstrb;
assign pwdata  = s_wdata;



always_comb begin
    s_awready = 1'b0;
    s_wready  = 1'b0;
    s_bvalid  = 1'b0;
    s_arready = 1'b0;
    s_rvalid  = 1'b0;
    psel      = 1'b0;
    pwrite    = 1'b1;
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
            psel     = s_wvalid;
            pwrite   = 1'b1;
            s_wready = pready & penable;
            cnt_nxt  = pready & penable & s_wvalid;
            addr_nxt = pready & penable & s_wvalid;
        end
        SIATE_BRESP: begin
            s_bvalid = 1'b1;
        end
        STATE_RD  : begin
            psel     = 1'b1;
        end
        STATE_RRESP: begin
            s_rvalid = 1'b1;
            cnt_nxt  = s_rready;
            addr_nxt = s_rready;
        end
    endcase
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        resp_latch <= 2'b0;
    end
    else begin
        if (pready & penable & pslverr) begin
            resp_latch <= `AXI_RESP_SLVERR;
        end
        else if ((s_bready & s_bvalid) | (s_rready & s_rvalid)) begin
            resp_latch <= `AXI_RESP_OKAY;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        penable <= 1'b0;
    end
    else begin
        if (pready & penable) begin
            penable <= 1'b0;
        end
        else if (psel) begin
            penable <= 1'b1;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        rdata_latch <= 32'b0;
    end
    else begin
        if (cur_state == STATE_RD) begin
            if (pready & penable) begin
                rdata_latch <= prdata;
            end
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        id_latch <= 12'b0;
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
