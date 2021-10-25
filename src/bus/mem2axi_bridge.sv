`include "axi_define.h"

module mem2axi_bridge (
    input                  aclk,
    input                  aresetn,

    // Memory intface slave port
    input                  s_cs, 
    input                  s_we, 
    input         [ 31: 0] s_addr,
    input         [  3: 0] s_byte,
    input         [ 31: 0] s_di,
    output logic  [ 31: 0] s_do,
    output logic           s_busy,
    output logic           s_err,

    // AXI master port
    output logic  [  1: 0] m_awburst,
    output logic  [  9: 0] m_awid,
    output logic  [ 31: 0] m_awaddr,
    output logic  [  2: 0] m_awsize,
    output logic  [  7: 0] m_awlen,
    output logic           m_awvalid,
    input                  m_awready,
    output logic  [  3: 0] m_wstrb,
    output logic  [  9: 0] m_wid,
    output logic  [ 31: 0] m_wdata,
    output logic           m_wlast,
    output logic           m_wvalid,
    input                  m_wready,
    input         [  9: 0] m_bid,
    input         [  1: 0] m_bresp,
    input                  m_bvalid,
    output logic           m_bready,
    output logic  [ 31: 0] m_araddr,
    output logic  [  1: 0] m_arburst,
    output logic  [  2: 0] m_arsize,
    output logic  [  9: 0] m_arid,
    output logic  [  7: 0] m_arlen,
    output logic           m_arvalid,
    input                  m_arready,
    input         [ 31: 0] m_rdata,
    input         [  1: 0] m_rresp,
    input         [  9: 0] m_rid,
    input                  m_rlast,
    input                  m_rvalid,
    output logic           m_rready

);

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_err <= 1'b0;
    end
    else begin
        s_err <= m_bvalid & m_bready ? m_bresp[1]:
                 m_rvalid & m_rready ? m_rresp[1]:
                                       s_err;
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_do <= 32'b0;
    end
    else begin
        if (m_rvalid) begin
            s_do <= m_rdata;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_busy <= 1'b0;
    end
    else begin
        s_busy <= s_cs               ? 1'b1:
                  m_bvalid           ? 1'b0:
                  m_rvalid & m_rlast ? 1'b0:
                                       s_busy;
    end
end

assign m_awburst = `AXI_BURST_FIXED;
assign m_awid    = 10'b0;
assign m_awsize  = 3'd2;
assign m_awlen   = 8'b0;

assign m_wid     = 10'b0;
assign m_wlast   = 1'b1;


assign m_arid    = 10'b0;
assign m_arburst = `AXI_BURST_FIXED;
assign m_arsize  = 3'd2;
assign m_arlen   = 8'b0;

assign m_bready  = 1'b1;

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        m_wdata <= 32'b0;
        m_wstrb <= 4'b0;
    end
    else begin
        if (~s_busy) begin
            m_wdata <= s_di;
            m_wstrb <= s_byte;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        m_awaddr <= 32'b0;
        m_araddr <= 32'b0;
    end
    else begin
        if (~s_busy) begin
            m_awaddr <= s_addr;
            m_araddr <= s_addr;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        m_awvalid <= 1'b0;
    end
    else begin
        if (~s_busy) begin
            m_awvalid <= s_cs & s_we;
        end
        else if (m_awready) begin
            m_awvalid <= 1'b0;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        m_wvalid  <= 1'b0;
    end
    else begin
        if (~s_busy) begin
            m_wvalid  <= s_cs & s_we;
        end
        else if (m_wready) begin
            m_wvalid  <= 1'b0;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        m_arvalid <= 1'b0;
    end
    else begin
        if (~s_busy) begin
            m_arvalid <= s_cs & ~s_we;
        end
        else if (m_arready) begin
            m_arvalid <= 1'b0;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        m_rready <= 1'b0;
    end
    else begin
        if (m_arvalid & m_arready) begin
            m_rready <= 1'b1;
        end
        else if (m_rlast & m_rvalid & m_rready) begin
            m_rready <= 1'b0;
        end
    end
end

endmodule
