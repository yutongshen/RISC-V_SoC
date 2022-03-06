module apb_rx (
    input               rx_clk,
    input               rx_rstn,

    input               tx_tog,
    input        [31:0] tx_mem_addr,
    input               tx_mem_write,
    input        [31:0] tx_mem_wdata,
    input        [ 2:0] tx_mem_size,
    input        [ 6:0] tx_mem_prot,
    input               tx_mem_secen,
    output logic        rx_tog,
    output logic [31:0] rx_mem_rdata,
    output logic        rx_mem_slverr,

    apb_intf.master     m_apb_intf
);

logic        tx_rec_dly;
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
logic        tx_tog_s4;
logic [ 3:0] ignore_tx_cnt;
logic        ignore_tx;
logic        tx_rec;

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
        tx_tog_s4 <= 1'b0;
    end
    else begin
        tx_tog_s1 <= tx_tog;
        tx_tog_s2 <= tx_tog_s1;
        tx_tog_s3 <= tx_tog_s2;
        tx_tog_s4 <= tx_tog_s3;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_tx2rx
    if (~rx_rstn) begin
        rx_mem_addr  <= 32'b0;
        rx_mem_write <= 1'b0;
        rx_mem_wdata <= 32'b0;
        rx_mem_size  <= 3'b0;
        rx_mem_prot  <= 7'b0;
        rx_mem_secen <= 1'b0;
    end
    else if (tx_rec) begin
        rx_mem_addr  <= tx_mem_addr;
        rx_mem_write <= tx_mem_write;
        rx_mem_wdata <= tx_mem_wdata;
        rx_mem_size  <= tx_mem_size;
        rx_mem_prot  <= tx_mem_prot;
        rx_mem_secen <= tx_mem_secen;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_tx_rec_dly
    if (~rx_rstn) tx_rec_dly <= 1'b0;
    else          tx_rec_dly <= tx_rec;
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_psel
    if (~rx_rstn)                   m_apb_intf.psel <= 1'b0;
    else if (tx_rec_dly)            m_apb_intf.psel <= 1'b1;
    else if (m_apb_intf.penable &&
             m_apb_intf.pready)     m_apb_intf.psel <= 1'b0;
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_penable
    if (~rx_rstn)                 m_apb_intf.penable <= 1'b0;
    else if ( m_apb_intf.psel &&
             ~m_apb_intf.penable) m_apb_intf.penable <= 1'b1;
    else if (m_apb_intf.pready)   m_apb_intf.penable <= 1'b0;
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_apb_addr_data
    if (~rx_rstn) begin
        m_apb_intf.paddr  <= 32'b0;
        m_apb_intf.pwrite <= 1'b0;
        m_apb_intf.pstrb  <= 4'b0;
        m_apb_intf.pprot  <= 3'b0;
        m_apb_intf.pwdata <= 32'b0;
    end
    else if (tx_rec_dly) begin
        m_apb_intf.paddr  <= rx_mem_addr;
        m_apb_intf.pwrite <= rx_mem_write;
        m_apb_intf.pstrb  <= 4'hf;
        m_apb_intf.pprot  <= rx_mem_prot[2:0] & {1'b1, rx_mem_secen, 1'b1};
        m_apb_intf.pwdata <= rx_mem_wdata;
    end
end

// always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_rx_tog
//     if (~rx_rstn) begin
//         rx_tog_pre <= 1'b0;
//         rx_tog     <= 1'b0;
//     end
//     else begin
//         rx_tog_pre <= (m_apb_intf.penable && m_apb_intf.pready) ^ rx_tog_pre;
//         rx_tog     <= rx_tog_pre;
//     end
// end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_rx_tog
    if (~rx_rstn) begin
        rx_tog <= 1'b0;
    end
    else begin
        rx_tog <= (m_apb_intf.penable && m_apb_intf.pready) ^ rx_tog;
    end
end

always_ff @(posedge rx_clk or negedge rx_rstn) begin: reg_rx_resp
    if (~rx_rstn) begin
        rx_mem_rdata  <= 32'b0;
        rx_mem_slverr <= 1'b0;
    end
    else if (m_apb_intf.penable && m_apb_intf.pready) begin
        rx_mem_rdata  <= m_apb_intf.prdata;
        rx_mem_slverr <= m_apb_intf.pslverr;
    end
end

endmodule
