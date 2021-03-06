`include "axi_define.h"

module axi_rx (
    input               rx_clk,
    input               rx_rstn,

    input               tx_tog,
    input               tx_mem_sector,
    input        [31:0] tx_mem_addr,
    input               tx_mem_write,
    input        [31:0] tx_mem_wdata,
    input        [ 2:0] tx_mem_size,
    input        [ 6:0] tx_mem_prot,
    input               tx_mem_secen,
    output logic        rx_tog,
    output logic [31:0] rx_mem_rdata,
    output logic        rx_mem_slverr,

    output logic        ap_rbuf_push,
    output logic [31:0] ap_rbuf_wdata,
    output logic [ 1:0] ap_rbuf_wresp,

    output logic        ap_wbuf_pop,
    input        [31:0] ap_wbuf_rdata,
    input        [ 5:0] ap_wbuf_rsize,

    axi_intf.master     m_axi_intf
);

logic        tx_rec_dly;
logic        rx_mem_sector;
logic [31:0] rx_mem_addr;
logic        rx_mem_write;
logic [31:0] rx_mem_wdata;
logic [ 2:0] rx_mem_size;
logic [ 6:0] rx_mem_prot;
logic        rx_mem_secen;

logic        rx_tog_pre;
logic        tx_tog_s1;
logic        tx_tog_s2;
logic        tx_tog_s3;
logic [ 3:0] ignore_tx_cnt;
logic        ignore_tx;
logic        tx_rec;

logic [ 5:0] sector_send_cnt;
logic [ 3:0] sector_rec_cnt;

logic        burst;
logic [ 3:0] bmask;

assign ignore_tx = ignore_tx_cnt[3];
assign tx_rec    = (tx_tog_s2 ^ tx_tog_s3) & ~ignore_tx;

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_ignore_tx_cnt
    if (~rx_rstn) ignore_tx_cnt <= 4'hf;
    else          ignore_tx_cnt <= |ignore_tx_cnt ? ignore_tx_cnt - 4'h1 : ignore_tx_cnt;
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_tx_tog
    if (~rx_rstn) begin
        tx_tog_s1 <= 1'b0;
        tx_tog_s2 <= 1'b0;
        tx_tog_s3 <= 1'b0;
    end
    else begin
        tx_tog_s1 <= tx_tog;
        tx_tog_s2 <= tx_tog_s1;
        tx_tog_s3 <= tx_tog_s2;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_tx2rx
    if (~rx_rstn) begin
        rx_mem_sector <= 1'b0;
        rx_mem_addr   <= 32'b0;
        rx_mem_write  <= 1'b0;
        rx_mem_wdata  <= 32'b0;
        rx_mem_size   <= 3'b0;
        rx_mem_prot   <= 7'b0;
        rx_mem_secen  <= 1'b0;
    end
    else if (tx_rec) begin
        rx_mem_sector <= tx_mem_sector;
        rx_mem_addr   <= tx_mem_addr;
        rx_mem_write  <= tx_mem_write;
        rx_mem_wdata  <= tx_mem_wdata;
        rx_mem_size   <= tx_mem_size;
        rx_mem_prot   <= tx_mem_prot;
        rx_mem_secen  <= tx_mem_secen;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_tx_rec_dly
    if (~rx_rstn) tx_rec_dly <= 1'b0;
    else          tx_rec_dly <= tx_rec;
end

assign m_axi_intf.awid    = 8'h0;
assign m_axi_intf.awburst = `AXI_BURST_INCR;
assign m_axi_intf.awsize  = 2'h2;
assign m_axi_intf.awlock  = 2'h0;
assign m_axi_intf.awcache = 4'h0;
assign m_axi_intf.wid     = 8'h0;
assign m_axi_intf.bready  = 1'b1;
assign m_axi_intf.arid    = 8'h0;
assign m_axi_intf.arburst = `AXI_BURST_INCR;
assign m_axi_intf.arsize  = 2'h2;
assign m_axi_intf.arlock  = 2'h0;
assign m_axi_intf.arcache = 4'h0;
assign m_axi_intf.rready  = 1'b1;

assign burst = ({1'b0, rx_mem_addr[1:0]} + (3'h1 << rx_mem_size)) > 3'h4;
assign bmask = ((4'b1 << (3'h1 << rx_mem_size)) - 4'b1);

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_axi_aw
    if (~rx_rstn) begin
        m_axi_intf.awaddr  <= 32'b0;
        m_axi_intf.awlen   <= 8'b0;
        m_axi_intf.awprot  <= 3'b0;
    end
    else if (tx_rec_dly && rx_mem_write) begin
        m_axi_intf.awaddr  <= rx_mem_sector ? {rx_mem_addr[31:4], 4'b0} : {rx_mem_addr[31:2], 2'b0};
        m_axi_intf.awlen   <= rx_mem_sector ? 8'h3 : {7'b0, burst};
        m_axi_intf.awprot  <= rx_mem_prot[2:0] & {1'b1, rx_mem_secen, 1'b1};;
    end
    else if (rx_mem_sector && ((~m_axi_intf.wlast && m_axi_intf.wvalid && m_axi_intf.wready)||
                               (m_axi_intf.awvalid && m_axi_intf.awready))) begin
        m_axi_intf.awaddr  <= m_axi_intf.awaddr + 32'h4;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_axi_aw_vld
    if (~rx_rstn) begin
        m_axi_intf.awvalid <= 1'b0;
    end
    else if ((tx_rec_dly && rx_mem_write) ||
             (rx_mem_sector && (|sector_send_cnt[5:1]) &&
              m_axi_intf.wlast && m_axi_intf.wvalid && m_axi_intf.wready)) begin
        m_axi_intf.awvalid <= 1'b1;
    end
    else if (m_axi_intf.awready) begin
        m_axi_intf.awvalid <= 1'b0;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_axi_w
    if (~rx_rstn) begin
        m_axi_intf.wstrb   <= 4'b0;
        m_axi_intf.wdata   <= 32'b0;
        m_axi_intf.wlast   <= 1'b0;
    end
    else if (~rx_mem_sector) begin
        if (tx_rec_dly && rx_mem_write) begin
            m_axi_intf.wstrb   <= bmask << rx_mem_addr[1:0];
            m_axi_intf.wdata   <= rx_mem_wdata << {rx_mem_addr[1:0], 3'b0};
            m_axi_intf.wlast   <= ~burst;
        end
        else if (~m_axi_intf.wlast && m_axi_intf.wvalid && m_axi_intf.wready) begin
            m_axi_intf.wstrb   <= bmask >> -rx_mem_addr[1:0];
            m_axi_intf.wdata   <= rx_mem_wdata >> {-rx_mem_addr[1:0], 3'b0};
            m_axi_intf.wlast   <= 1'b1;
        end
    end
    else begin
        m_axi_intf.wstrb <= m_axi_intf.awvalid || m_axi_intf.wready ? {4{|sector_send_cnt & ap_wbuf_pop}}:
                                                                      m_axi_intf.wstrb;
        m_axi_intf.wdata <= m_axi_intf.awvalid || m_axi_intf.wready ? ap_wbuf_rdata : m_axi_intf.wdata;
        m_axi_intf.wlast <= m_axi_intf.awaddr[3:2] == 2'h3 && m_axi_intf.wready;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_axi_w_vld
    if (~rx_rstn) begin
        m_axi_intf.wvalid <= 1'b0;
    end
    else if (rx_mem_sector && rx_mem_write && m_axi_intf.awvalid && m_axi_intf.awready) begin
        m_axi_intf.wvalid <= 1'b1;
    end
    else if (tx_rec_dly && ~rx_mem_sector && rx_mem_write) begin
        m_axi_intf.wvalid <= 1'b1;
    end
    else if (m_axi_intf.wlast && m_axi_intf.wready) begin
        m_axi_intf.wvalid <= 1'b0;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_axi_ar
    if (~rx_rstn) begin
        m_axi_intf.araddr  <= 32'b0;
        m_axi_intf.arlen   <= 8'b0;
        m_axi_intf.arprot  <= 3'b0;
    end
    else if (tx_rec_dly && ~rx_mem_write) begin
        m_axi_intf.araddr  <= rx_mem_sector ? {rx_mem_addr[31:4], 4'b0} : {rx_mem_addr[31:2], 2'b0};
        m_axi_intf.arlen   <= rx_mem_sector ? 8'h3 : {7'b0, burst};
        m_axi_intf.arprot  <= rx_mem_prot[2:0] & {1'b1, rx_mem_secen, 1'b1};;
    end
    else if (|sector_send_cnt && m_axi_intf.arready) begin
        m_axi_intf.araddr  <= m_axi_intf.araddr + 32'h10;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_sector_rec_cnt
    if (~rx_rstn) begin
        sector_rec_cnt <= 4'b0;
    end
    else if (tx_rec_dly && ~rx_mem_write) begin
        sector_rec_cnt <= rx_mem_sector ? 4'hf : 4'b0;
    end
    else if (tx_rec_dly &&  rx_mem_write) begin
        sector_rec_cnt <= rx_mem_sector ? ap_wbuf_rsize[5:2] -
                                          (~({2'b0, rx_mem_addr[3:2]} + {2'b0, ap_wbuf_rsize[1:0]}) >> 2):
                                          4'b0;
    end
    else if ((m_axi_intf.rlast && m_axi_intf.rvalid && m_axi_intf.rready) ||
             (                    m_axi_intf.bvalid && m_axi_intf.bready)) begin
        sector_rec_cnt <= |sector_rec_cnt ? sector_rec_cnt - 4'b1 : 4'b0;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_sector_send_cnt
    if (~rx_rstn) begin
        sector_send_cnt <= 6'b0;
    end
    else if (tx_rec_dly && ~rx_mem_write) begin
        sector_send_cnt <= rx_mem_sector ? 6'hf : 6'b0;
    end
    else if (tx_rec_dly &&  rx_mem_write) begin
        sector_send_cnt <= rx_mem_sector ? ap_wbuf_rsize - 6'h1 : 6'b0;
    end
    else if (m_axi_intf.arvalid && m_axi_intf.arready) begin
        sector_send_cnt <= |sector_send_cnt ? sector_send_cnt - 6'b1 : 6'b0;
    end
    else if (m_axi_intf.wvalid && m_axi_intf.wready) begin
        sector_send_cnt <= |sector_send_cnt ? sector_send_cnt - {5'b0, |m_axi_intf.wstrb}:
                                              6'b0;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_axi_ar_vld
    if (~rx_rstn) begin
        m_axi_intf.arvalid <= 1'b0;
    end
    else if (tx_rec_dly && ~rx_mem_write) begin
        m_axi_intf.arvalid <= 1'b1;
    end
    else if (m_axi_intf.arready && ~|sector_send_cnt) begin
        m_axi_intf.arvalid <= 1'b0;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_rx_tog
    if (~rx_rstn) begin
        rx_tog <= 1'b0;
    end
    else begin
        rx_tog <= ((~rx_mem_sector && m_axi_intf.rlast && m_axi_intf.rvalid && m_axi_intf.rready)||
                   ( rx_mem_sector && m_axi_intf.rlast && m_axi_intf.rvalid && m_axi_intf.rready && ~|sector_rec_cnt)||
                   (~rx_mem_sector && m_axi_intf.bvalid && m_axi_intf.bready)||
                   ( rx_mem_sector && m_axi_intf.bvalid && m_axi_intf.bready && ~|sector_rec_cnt)) ^ rx_tog;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_rx_resp
    if (~rx_rstn) begin
        rx_mem_rdata  <= 32'b0;
        rx_mem_slverr <= 1'b0;
    end
    else if (m_axi_intf.rvalid && m_axi_intf.rready) begin
        rx_mem_rdata  <= rx_mem_sector ?
                             (&sector_rec_cnt ? m_axi_intf.rdata : rx_mem_rdata): // record 1st rdata
                         (~m_axi_intf.rlast || ~burst ?
                             m_axi_intf.rdata >> {rx_mem_addr[1:0], 3'b0}:
                             (rx_mem_rdata | (m_axi_intf.rdata << {-rx_mem_addr[1:0], 3'b0}))) &
                             {{8{bmask[3]}}, {8{bmask[2]}}, {8{bmask[1]}}, {8{bmask[0]}}};
        rx_mem_slverr <= ~m_axi_intf.rlast || ~burst ?
                             m_axi_intf.rresp[1]:
                             (rx_mem_slverr || m_axi_intf.rresp[1]);
    end
    else if (m_axi_intf.bvalid && m_axi_intf.bready) begin
        rx_mem_rdata  <= 32'b0;
        rx_mem_slverr <= m_axi_intf.bresp[1];
    end
end

assign ap_rbuf_push  = rx_mem_sector && m_axi_intf.rvalid && m_axi_intf.rready;
assign ap_rbuf_wdata = m_axi_intf.rdata;
assign ap_rbuf_wresp = m_axi_intf.rresp;

assign ap_wbuf_pop   = rx_mem_sector && (m_axi_intf.awaddr >= rx_mem_addr) &&
                       ((~m_axi_intf.wlast && m_axi_intf.wvalid && m_axi_intf.wready)||
                        (m_axi_intf.awvalid && m_axi_intf.awready));

endmodule
