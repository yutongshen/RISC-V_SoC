`include "axi_define.h"

module axi2apb_bridge (
    input                  aclk,
    input                  aresetn,
    // AXI slave port
    axi_intf.slave         s_axi_intf,

    // APB master port
    apb_intf.master        m_apb_intf
);

parameter [2:0] STATE_IDLE  = 3'b000,
                STATE_WR    = 3'b001,
                SIATE_BRESP = 3'b010,
                STATE_RD    = 3'b011,
                STATE_RRESP = 3'b100;

logic [  2: 0] cur_state;
logic [  2: 0] nxt_state;

logic [ 12: 0] id_latch;
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
            nxt_state = s_axi_intf.arvalid ? STATE_RD:
                        s_axi_intf.awvalid ? STATE_WR:
                                             STATE_IDLE;
        end
        STATE_WR  : begin
            nxt_state = ~|cnt & s_axi_intf.wvalid & s_axi_intf.wready ? SIATE_BRESP : STATE_WR;
        end
        SIATE_BRESP: begin
            nxt_state = s_axi_intf.bready ? STATE_IDLE : SIATE_BRESP;
        end
        STATE_RD  : begin
            nxt_state = m_apb_intf.penable & m_apb_intf.pready ? STATE_RRESP : STATE_RD;
        end
        STATE_RRESP: begin
            nxt_state = ~|cnt & s_axi_intf.rready ? STATE_IDLE:
                        s_axi_intf.rready         ? STATE_RD:
                                                    STATE_RRESP;
        end
    endcase
end

assign s_axi_intf.bid     = id_latch;
assign s_axi_intf.bresp   = resp_latch;
assign s_axi_intf.rid     = id_latch;
assign s_axi_intf.rdata   = rdata_latch;
assign s_axi_intf.rresp   = resp_latch;
assign s_axi_intf.rlast   = ~|cnt;
assign m_apb_intf.paddr   = addr_latch;
assign m_apb_intf.pstrb   = s_axi_intf.wstrb;
assign m_apb_intf.pwdata  = s_axi_intf.wdata;



always_comb begin
    s_axi_intf.awready = 1'b0;
    s_axi_intf.wready  = 1'b0;
    s_axi_intf.bvalid  = 1'b0;
    s_axi_intf.arready = 1'b0;
    s_axi_intf.rvalid  = 1'b0;
    m_apb_intf.psel    = 1'b0;
    m_apb_intf.pwrite  = 1'b0;
    id_upd             = 1'b0;
    cnt_upd            = 1'b0;
    addr_upd           = 1'b0;
    size_upd           = 1'b0;
    cnt_nxt            = 1'b0;
    addr_nxt           = 1'b0;
    case (cur_state)
        STATE_IDLE: begin
            s_axi_intf.awready = ~s_axi_intf.arvalid;
            s_axi_intf.arready = 1'b1;
            id_upd             = s_axi_intf.arvalid | s_axi_intf.awvalid;
            cnt_upd            = s_axi_intf.arvalid | s_axi_intf.awvalid;
            addr_upd           = s_axi_intf.arvalid | s_axi_intf.awvalid;
            size_upd           = s_axi_intf.arvalid | s_axi_intf.awvalid;
        end
        STATE_WR  : begin
            m_apb_intf.psel    = s_axi_intf.wvalid;
            m_apb_intf.pwrite  = 1'b1;
            s_axi_intf.wready  = m_apb_intf.pready & m_apb_intf.penable;
            cnt_nxt            = m_apb_intf.pready & m_apb_intf.penable & s_axi_intf.wvalid;
            addr_nxt           = m_apb_intf.pready & m_apb_intf.penable & s_axi_intf.wvalid;
        end
        SIATE_BRESP: begin
            s_axi_intf.bvalid  = 1'b1;
        end
        STATE_RD  : begin
            m_apb_intf.psel    = 1'b1;
        end
        STATE_RRESP: begin
            s_axi_intf.rvalid  = 1'b1;
            cnt_nxt            = s_axi_intf.rready;
            addr_nxt           = s_axi_intf.rready;
        end
    endcase
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        resp_latch <= 2'b0;
    end
    else begin
        if (m_apb_intf.pready & m_apb_intf.penable & m_apb_intf.pslverr) begin
            resp_latch <= `AXI_RESP_SLVERR;
        end
        else if ((s_axi_intf.bready & s_axi_intf.bvalid) | (s_axi_intf.rready & s_axi_intf.rvalid)) begin
            resp_latch <= `AXI_RESP_OKAY;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        m_apb_intf.penable <= 1'b0;
    end
    else begin
        if (m_apb_intf.pready & m_apb_intf.penable) begin
            m_apb_intf.penable <= 1'b0;
        end
        else if (m_apb_intf.psel) begin
            m_apb_intf.penable <= 1'b1;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        rdata_latch <= 32'b0;
    end
    else begin
        if (cur_state == STATE_RD) begin
            if (m_apb_intf.pready & m_apb_intf.penable) begin
                rdata_latch <= m_apb_intf.prdata;
            end
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        id_latch <= 13'b0;
    end
    else begin
        if (id_upd) begin
            id_latch <= s_axi_intf.arvalid ? s_axi_intf.arid : s_axi_intf.awid;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        cnt <= 8'b0;
    end
    else begin
        if (cnt_upd) begin
            cnt <= s_axi_intf.arvalid ? s_axi_intf.arlen : s_axi_intf.awlen;
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
            if (s_axi_intf.arvalid) begin
                case (s_axi_intf.arburst)
                    `AXI_BURST_FIXED: begin
                        addr_mask_latch <= ~32'b0;
                    end
                    `AXI_BURST_INCR : begin
                        addr_mask_latch <= 32'b0;
                    end
                    `AXI_BURST_WRAP : begin
                        addr_mask_latch <= ~((({{(32-8){1'b0}}, s_axi_intf.arlen} + 32'b1) << s_axi_intf.arsize) - 32'b1);
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
            addr_latch <= s_axi_intf.arvalid ? s_axi_intf.araddr : s_axi_intf.awaddr;
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
            size_latch <= s_axi_intf.arvalid ? s_axi_intf.arsize : s_axi_intf.awsize;
        end
    end
end

endmodule
