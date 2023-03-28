`include "dma_mmap.h"

`define DMA_FIFO_DEPTH 5
`define DMA_FIFO_SIZE  (1 << `DMA_FIFO_DEPTH)

module dma (
    input               clk,
    input               rstn,

    input               spi_dff,

    output logic        dma_rxreq,
    input               dma_rxne,
    input        [15:0] dma_rxbuff,
    output logic        dma_txreq,
    input               dma_txe,
    output logic [15:0] dma_txbuff,

    output logic        irq_out,

    axi_intf.master     m_axi_intf,
    apb_intf.slave      s_apb_intf
);

localparam TYPE_FIXED   = 2'b00;
localparam TYPE_INCR    = 2'b01;
// localparam TYPE_SPI     = 2'b10;
localparam TYPE_CONST   = 2'b10;
localparam TYPE_UNKNOWN = 2'b11;

localparam SIZE_BYTE  = 2'b00;
localparam SIZE_HWORD = 2'b01;
localparam SIZE_WORD  = 2'b10;
localparam SIZE_DWORD = 2'b11;

logic        wdt_timeout;
logic [30:0] wdt_cnt;
logic [30:0] wdt_cnt_config;
logic        wdt_trigger;
logic        wdt_rst_b;
logic        apb_wr;
logic        apb_rd;
logic [31:0] dma_src;
logic [31:0] dma_dest;
logic [31:0] dma_len;
logic [31:0] dma_con;
logic        dma_con_en;
logic        dma_con_bypass;
logic [ 1:0] dma_con_src_type;
logic [ 1:0] dma_con_dest_type;
logic [ 1:0] dma_con_src_size;
logic [ 1:0] dma_con_dest_size;
logic        dma_ie;
logic        dma_ip;
logic        dma_busy;
logic [31:0] prdata_t;
logic        dma_done;

assign irq_out = dma_ie & dma_ip;

assign apb_wr = s_apb_intf.psel && ~s_apb_intf.penable &&  s_apb_intf.pwrite;
assign apb_rd = s_apb_intf.psel && ~s_apb_intf.penable && ~s_apb_intf.pwrite;

always_ff @(posedge clk or negedge rstn) begin: reg_dma_src
    if (~rstn) begin
        dma_src <= 32'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[7:0] == `DMA_SRC) begin
        dma_src <= s_apb_intf.pwdata;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dma_dest
    if (~rstn) begin
        dma_dest <= 32'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[7:0] == `DMA_DEST) begin
        dma_dest <= s_apb_intf.pwdata;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dma_src_addr
    if (~rstn) begin
        dma_len <= 32'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[7:0] == `DMA_LEN) begin
        dma_len <= s_apb_intf.pwdata;
    end
end


assign dma_con_err = ~|dma_len ||
                     dma_con_src_size  > SIZE_WORD ||
                     dma_con_dest_size > SIZE_WORD ||
                     // dma_con_dest_type == TYPE_CONST ||
                     dma_con_src_type == TYPE_UNKNOWN || dma_con_dest_type == TYPE_UNKNOWN ||
                     (dma_con_src_type  == TYPE_FIXED && dma_con_src_size  >= SIZE_HWORD && dma_src [0]) ||
                     (dma_con_src_type  == TYPE_FIXED && dma_con_src_size  >= SIZE_WORD  && dma_src [1]) ||
                     (dma_con_dest_type == TYPE_FIXED && dma_con_dest_size >= SIZE_HWORD && dma_dest[0]) ||
                     (dma_con_dest_type == TYPE_FIXED && dma_con_dest_size >= SIZE_WORD  && dma_dest[1]);
                     // (dma_con_src_type  == TYPE_SPI   && dma_con_dest_type == TYPE_SPI)   ||
                     // (dma_con_src_type  == TYPE_SPI   && dma_con_src_size  >  SIZE_HWORD) ||
                     // (dma_con_dest_type == TYPE_SPI   && dma_con_dest_size >  SIZE_HWORD);
                     // (dma_con_src_type  == TYPE_INCR &&
                     //  {20'b0, dma_src [11:0]} + dma_len > 32'h1000) ||
                     // (dma_con_dest_type == TYPE_INCR &&
                     //  {20'b0, dma_dest[11:0]} + dma_len > 32'h1000);
assign dma_con = {dma_busy,
                  19'b0,
                  dma_con_dest_size,
                  dma_con_src_size,
                  dma_con_dest_type,
                  dma_con_src_type,
                  2'b0,
                  dma_con_bypass,
                  dma_con_en};

always_ff @(posedge clk or negedge rstn) begin: reg_dma_con
    if (~rstn) begin
        dma_con_en        <= 1'b0;
        dma_con_src_type  <= 2'b0;
        dma_con_dest_type <= 2'b0;
        dma_con_src_size  <= 2'b0;
        dma_con_dest_size <= 2'b0;
        dma_con_bypass    <= 1'b0;
        dma_busy          <= 1'b0;
    end
    else if (~dma_busy && apb_wr && s_apb_intf.paddr[7:0] == `DMA_CON) begin
        dma_con_en        <= s_apb_intf.pwdata[ 0];
        dma_con_bypass    <= s_apb_intf.pwdata[ 1];
        dma_con_src_type  <= s_apb_intf.pwdata[ 5: 4];
        dma_con_dest_type <= s_apb_intf.pwdata[ 7: 6];
        dma_con_src_size  <= s_apb_intf.pwdata[ 9: 8];
        dma_con_dest_size <= s_apb_intf.pwdata[11:10];
        dma_busy          <= s_apb_intf.pwdata[ 0];
    end
    else if (dma_con_err || dma_done || ~wdt_rst_b) begin
        dma_busy          <= 1'b0;
        dma_con_en        <= 1'b0;
    end
    else begin
        dma_con_en        <= 1'b0;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dma_ie
    if (~rstn) begin
        dma_ie <= 1'b0;
    end
    else if (apb_wr && s_apb_intf.paddr[7:0] == `DMA_IE) begin
        dma_ie <= s_apb_intf.pwdata[0];
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dma_ip
    if (~rstn) begin
        dma_ip <= 1'b0;
    end
    else if (dma_done) begin
        dma_ip <= 1'b1;
    end
    else if (apb_wr && s_apb_intf.paddr[7:0] == `DMA_IC) begin
        dma_ip <= dma_ip & ~s_apb_intf.pwdata[0];
    end
end

always_comb begin: comb_prdata_t
    prdata_t = 32'b0;
    case (s_apb_intf.paddr[7:0])
        `DMA_SRC:     prdata_t = dma_src;
        `DMA_DEST:    prdata_t = dma_dest;
        `DMA_LEN:     prdata_t = dma_len;
        `DMA_CON:     prdata_t = dma_con;
        `DMA_IE:      prdata_t = {31'b0, dma_ie};
        `DMA_IP:      prdata_t = {31'b0, dma_ip};
        `DMA_IC:      prdata_t = {31'b0, dma_ip};
        `DMA_WDT_CNT: prdata_t = {wdt_timeout, wdt_cnt_config[30:0]};
    endcase
end

always_ff @(posedge clk or negedge rstn) begin: reg_prdata
    if (~rstn) s_apb_intf.prdata <= 32'b0;
    else       s_apb_intf.prdata <= prdata_t;
end

assign s_apb_intf.pready  = 1'b1;
assign s_apb_intf.pslverr = 1'b0;

// =========== Data transfer ===========
logic [             31:0] dest_burst_byte;
logic [             31:0] src_burst_byte;
logic [             31:0] dest_addr;
logic [             31:0] src_addr;
logic [             31:0] dest_len_cnt;
logic [             31:0] dest_cnt;
logic [              7:0] dest_len;
logic [             31:0] src_len_cnt;
logic [             31:0] src_cnt;
logic [              7:0] src_len;
logic [             31:0] int_rcnt;
logic [             31:0] int_wcnt;
logic                     awvalid;
logic [              2:0] wburst_cnt;
logic                     wvalid;
logic                     arvalid;

logic                     fifo_push_pre;
logic [              1:0] fifo_wsize_pre;
logic [             31:0] fifo_wdata_pre;
logic                     fifo_full_pre;
logic [`DMA_FIFO_DEPTH:0] fifo_cnt_pre;

logic                     fifo_push_int;
logic [              1:0] fifo_wsize_int;
logic [             31:0] fifo_wdata_int;
logic                     fifo_full_int;
logic [`DMA_FIFO_DEPTH:0] fifo_cnt_int;
logic                     fifo_pop_int;
logic [              1:0] fifo_rsize_int;
logic [             31:0] fifo_rdata_int;
logic                     fifo_empty_int;

logic                     fifo_pop_post;
logic [              1:0] fifo_rsize_post;
logic [             31:0] fifo_rdata_post;
logic                     fifo_empty_post;

assign fifo_wsize_pre = ({2{dma_con_src_size == SIZE_BYTE }} & 2'h0)|
                        ({2{dma_con_src_size == SIZE_HWORD}} & ((32'h1 - {31'b0, src_addr[0]}) < src_cnt ?
                                                                (2'h1 - {1'b0, src_addr[0]}):
                                                                (src_cnt[1:0] - 2'h1)))|
                        ({2{dma_con_src_size == SIZE_WORD }} & ((32'h3 - {30'b0, src_addr[1:0]}) < src_cnt ?
                                                                (2'h3 - src_addr[1:0]):
                                                                (src_cnt[1:0] - 2'h1)));
assign fifo_rsize_post = dma_con_dest_type == TYPE_CONST ?
                         |fifo_cnt_int[`DMA_FIFO_DEPTH:2] ? 2'h3 : (fifo_cnt_int[1:0] - 2'h1) :
                         (({2{dma_con_dest_size == SIZE_BYTE }} & 2'h0)|
                          ({2{dma_con_dest_size == SIZE_HWORD}} & ((32'h1 - {31'b0, dest_addr[0]}) < dest_cnt ?
                                                                   (2'h1 - {1'b0, dest_addr[0]}):
                                                                   (dest_cnt[1:0] - 2'h1)))|
                          ({2{dma_con_dest_size == SIZE_WORD }} & ((32'h3 - {30'b0, dest_addr[1:0]}) < dest_cnt ?
                                                                   (2'h3 - dest_addr[1:0]):
                                                                   (dest_cnt[1:0] - 2'h1))));
assign fifo_push_pre  = (((dma_con_src_type  == TYPE_FIXED) & (m_axi_intf.rvalid && m_axi_intf.rready)) |
                         ((dma_con_src_type  == TYPE_INCR ) & (m_axi_intf.rvalid && m_axi_intf.rready)) |
                         ((dma_con_src_type  == TYPE_CONST) & (|src_cnt && ~fifo_full_pre))) &&
                        dma_busy;
assign fifo_pop_post  = (((dma_con_dest_type == TYPE_FIXED) & (m_axi_intf.wvalid && m_axi_intf.wready)) |
                         ((dma_con_dest_type == TYPE_INCR ) & (m_axi_intf.wvalid && m_axi_intf.wready)) |
                         ((dma_con_dest_type == TYPE_CONST) & (|dest_cnt && ~fifo_empty_post))) &&
                        dma_busy;
assign fifo_wdata_pre = ({32{dma_con_src_type  == TYPE_FIXED}} & m_axi_intf.rdata >> {src_addr[1:0], 3'b0})|
                        ({32{dma_con_src_type  == TYPE_INCR }} & m_axi_intf.rdata >> {src_addr[1:0], 3'b0})|
                        ({32{dma_con_src_type  == TYPE_CONST}} & dma_src);

assign dma_done   = ((dma_con_dest_type == TYPE_CONST && ~dma_con_en && dma_busy) ||
                     (m_axi_intf.bvalid && m_axi_intf.bready)) && ~|dest_cnt;

// SPI mode
assign fifo_wsize_int = dma_con_bypass ? |fifo_cnt_pre[`DMA_FIFO_DEPTH:2] ? 2'h3 : (fifo_cnt_pre[1:0] - 2'h1) :
                        spi_dff & |int_wcnt[31:1] ? 2'h1 : 2'h0;
assign fifo_rsize_int = dma_con_bypass ? |fifo_cnt_pre[`DMA_FIFO_DEPTH:2] ? 2'h3 : (fifo_cnt_pre[1:0] - 2'h1) :
                        spi_dff & |fifo_cnt_pre[`DMA_FIFO_DEPTH:1] ? 2'h1 : 2'h0;
assign fifo_push_int  = (dma_con_bypass && dma_busy &&  ~fifo_full_int && ~fifo_empty_int) || dma_rxreq;
assign fifo_pop_int   = (dma_con_bypass && dma_busy &&  ~fifo_full_int && ~fifo_empty_int) || dma_txreq;
assign fifo_wdata_int =  dma_con_bypass                  ? fifo_rdata_int:
                        ~spi_dff                         ? {16'b0, dma_rxbuff}:
                                                           {16'b0, dma_rxbuff[7:0], dma_rxbuff[15:8]};
assign dma_txreq = dma_busy && ~dma_con_en && ~dma_con_err && dma_txe  &&
                   |int_rcnt && ~dma_con_bypass && ~fifo_empty_int;
assign dma_rxreq = dma_busy && ~dma_con_en && ~dma_con_err && dma_rxne &&
                   |int_wcnt && ~dma_con_bypass && ~fifo_full_int;

assign dma_txbuff[15:8] = fifo_rdata_int[7:0];
assign dma_txbuff[ 7:0] = ~spi_dff                         ? fifo_rdata_int[ 7:0] :
                          |fifo_cnt_pre[`DMA_FIFO_DEPTH:1] ? fifo_rdata_int[15:8] :
                                                             8'hff;

// AXI mode
assign m_axi_intf.awid    = 9'b0;
assign m_axi_intf.awaddr  = dest_addr;
assign m_axi_intf.awburst = dma_con_dest_type;
assign m_axi_intf.awsize  = dma_con_dest_size;
assign m_axi_intf.awlen   = {24'b0, dest_len} < dest_len_cnt ? dest_len : (dest_len_cnt[7:0] - 8'h1);
assign m_axi_intf.awlock  = 2'b0;
assign m_axi_intf.awcache = 4'b0;
assign m_axi_intf.awprot  = 3'b0;
assign m_axi_intf.awvalid = awvalid && ({{(31-`DMA_FIFO_DEPTH){1'b0}}, fifo_cnt_int} >= dest_burst_byte || ~|int_wcnt);
assign m_axi_intf.wid     = 9'b0;
assign m_axi_intf.wstrb   = (4'b1 << ({1'b0, fifo_rsize_post} + 3'b1)) - 4'b1 << dest_addr[1:0];
assign m_axi_intf.wdata   = fifo_rdata_post << {dest_addr[1:0], 3'b0};
assign m_axi_intf.wlast   = ~|wburst_cnt;
assign m_axi_intf.wvalid  = wvalid;
assign m_axi_intf.bready  = 1'b1;
assign m_axi_intf.arid    = 9'b0;
assign m_axi_intf.araddr  = src_addr;
assign m_axi_intf.arburst = dma_con_src_type;
assign m_axi_intf.arsize  = dma_con_src_size;
assign m_axi_intf.arlen   = {24'b0, src_len} < src_len_cnt ? src_len : (src_len_cnt[7:0] - 8'h1);
assign m_axi_intf.arlock  = 2'b0;
assign m_axi_intf.arcache = 4'b0;
assign m_axi_intf.arprot  = 3'b0;
assign m_axi_intf.arvalid = arvalid && ({{(31-`DMA_FIFO_DEPTH){1'b0}}, fifo_cnt_pre} <= (`DMA_FIFO_SIZE - src_burst_byte));
assign m_axi_intf.rready  = ~fifo_full_pre;

always_ff @(posedge clk or negedge rstn) begin: reg_src_addr
    if (~rstn) begin
        src_addr <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        src_addr <= dma_src;
    end
    else if (m_axi_intf.rvalid && m_axi_intf.rready && dma_con_src_type  == TYPE_INCR) begin
        src_addr <= (src_addr + (32'b1 << dma_con_src_size)) & ~((32'b1 << dma_con_src_size) - 32'b1);
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dest_addr
    if (~rstn) begin
        dest_addr <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        dest_addr <= dma_dest;
    end
    else if (m_axi_intf.wvalid && m_axi_intf.wready && dma_con_dest_type  == TYPE_INCR) begin
        dest_addr <= (dest_addr + (32'b1 << dma_con_dest_size)) & ~((32'b1 << dma_con_dest_size) - 32'b1);
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_src_len
    if (~rstn) begin
        src_len <= 8'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        src_len <= 8'h3 - ((dma_src[7:0] >> dma_con_src_size) & 8'h3);
    end
    else if (m_axi_intf.arvalid && m_axi_intf.arready) begin
        src_len <= 8'h3;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_src_len_cnt
    if (~rstn) begin
        src_len_cnt <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        src_len_cnt <= ({32{dma_con_src_size == SIZE_BYTE }} &  dma_len)|
                       ({32{dma_con_src_size == SIZE_HWORD}} & (dma_len + {31'b0, dma_src[0]}   + 32'h1) >> 1)|
                       ({32{dma_con_src_size == SIZE_WORD }} & (dma_len + {30'b0, dma_src[1:0]} + 32'h3) >> 2);
    end
    else if (m_axi_intf.arvalid && m_axi_intf.arready && |src_len_cnt) begin
        src_len_cnt <= src_len_cnt - {24'b0, m_axi_intf.arlen} - 32'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_src_burst_byte
    if (~rstn) begin
        src_burst_byte <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        src_burst_byte <= 32'h4 << dma_con_src_size;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_src_cnt
    if (~rstn) begin
        src_cnt <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        src_cnt <= dma_len;
    end
    else if (fifo_push_pre && |src_cnt) begin
        src_cnt <= src_cnt - {30'b0, fifo_wsize_pre} - 32'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_int_rcnt
    if (~rstn) begin
        int_rcnt <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        int_rcnt <= dma_len;
    end
    else if (fifo_pop_int && |int_rcnt) begin
        int_rcnt <= int_rcnt - {30'b0, fifo_rsize_int} - 32'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_int_cnt
    if (~rstn) begin
        int_wcnt <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        int_wcnt <= dma_len;
    end
    else if (fifo_push_int && |int_wcnt) begin
        int_wcnt <= int_wcnt - {30'b0, fifo_wsize_int} - 32'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dest_len
    if (~rstn) begin
        dest_len <= 8'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        dest_len <= 8'h3 - ((dma_dest[7:0] >> dma_con_dest_size) & 8'h3);
    end
    else if (m_axi_intf.awvalid && m_axi_intf.awready) begin
        dest_len <= 8'h3;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dest_len_cnt
    if (~rstn) begin
        dest_len_cnt <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        dest_len_cnt <= dma_len + {31'b0, dma_con_dest_type == TYPE_INCR && |dma_dest[1:0]};
        dest_len_cnt <= ({32{dma_con_dest_size == SIZE_BYTE }} &  dma_len)|
                        ({32{dma_con_dest_size == SIZE_HWORD}} & (dma_len + {31'b0, dma_dest[0]}   + 32'h1) >> 1)|
                        ({32{dma_con_dest_size == SIZE_WORD }} & (dma_len + {30'b0, dma_dest[1:0]} + 32'h3) >> 2);
    end
    else if (m_axi_intf.awvalid && m_axi_intf.awready && |dest_len_cnt) begin
        dest_len_cnt <= dest_len_cnt - {24'b0, m_axi_intf.awlen} - 32'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dest_cnt
    if (~rstn) begin
        dest_cnt <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        dest_cnt <= dma_len;
    end
    else if (fifo_pop_post && |dest_cnt) begin
        dest_cnt <= dest_cnt - {30'b0, fifo_rsize_post} - 32'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dest_burst_byte
    if (~rstn) begin
        dest_burst_byte <= 32'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        dest_burst_byte <= 32'h4 << dma_con_dest_size;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_wburst_cnt
    if (~rstn) begin
        wburst_cnt <= 3'b0;
    end
    else if (m_axi_intf.awvalid && m_axi_intf.awready) begin
        wburst_cnt <= m_axi_intf.awlen;
    end
    else if (~m_axi_intf.wlast && m_axi_intf.wvalid && m_axi_intf.wready) begin
        wburst_cnt <= wburst_cnt - 3'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_awvalid
    if (~rstn) begin
        awvalid <= 1'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        awvalid <= ~dma_con_err && (dma_con_dest_type == TYPE_INCR || dma_con_dest_type == TYPE_FIXED);
    end
    else if (m_axi_intf.wlast && m_axi_intf.wvalid && m_axi_intf.wready) begin
        awvalid <= |dest_len_cnt;
    end
    else if (m_axi_intf.awvalid && m_axi_intf.awready) begin
        awvalid <= 1'b0;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_wvalid
    if (~rstn) begin
        wvalid <= 1'b0;
    end
    else if (m_axi_intf.awvalid && m_axi_intf.awready) begin
        wvalid <= 1'b1;
    end
    else if (m_axi_intf.wlast && m_axi_intf.wvalid && m_axi_intf.wready) begin
        wvalid <= 1'b0;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_arvalid
    if (~rstn) begin
        arvalid <= 1'b0;
    end
    else if (dma_con_en && ~dma_con_err) begin
        arvalid <= ~dma_con_err && (dma_con_src_type == TYPE_INCR || dma_con_src_type == TYPE_FIXED);
    end
    else if (m_axi_intf.rlast && m_axi_intf.rvalid && m_axi_intf.rready) begin
        arvalid <= |src_len_cnt;
    end
    else if (m_axi_intf.arvalid && m_axi_intf.arready) begin
        arvalid <= 1'b0;
    end
end

// FIFO
dma_fifo u_dma_fifo_1 (
    .clk   ( clk              ),
    .rstn  ( rstn & wdt_rst_b ),

    .push  ( fifo_push_pre    ),
    .wsize ( fifo_wsize_pre   ),
    .wdata ( fifo_wdata_pre   ),
    .full  ( fifo_full_pre    ),
    .cnt   ( fifo_cnt_pre     ),

    .pop   ( fifo_pop_int     ),
    .rsize ( fifo_rsize_int   ),
    .rdata ( fifo_rdata_int   ),
    .empty ( fifo_empty_int   )
);

dma_fifo u_dma_fifo_2 (
    .clk   ( clk              ),
    .rstn  ( rstn & wdt_rst_b ),

    .push  ( fifo_push_int    ),
    .wsize ( fifo_wsize_int   ),
    .wdata ( fifo_wdata_int   ),
    .full  ( fifo_full_int    ),
    .cnt   ( fifo_cnt_int     ),

    .pop   ( fifo_pop_post    ),
    .rsize ( fifo_rsize_post  ),
    .rdata ( fifo_rdata_post  ),
    .empty ( fifo_empty_post  )
);

assign wdt_trigger = dma_con_en | fifo_push_pre | fifo_pop_int | fifo_push_int | fifo_pop_post | ~wdt_rst_b;
assign wdt_rst_b   = ~(dma_busy & ~|wdt_cnt);

always_ff @(posedge clk or negedge rstn) begin: reg_wdt
    if (~rstn) begin
        wdt_cnt <= 31'h1;
    end
    else if (wdt_trigger) begin
        wdt_cnt <= wdt_cnt_config;
    end
    else if (dma_busy && |wdt_cnt) begin
        wdt_cnt <= wdt_cnt - 31'h1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_wdt_config
    if (~rstn) begin
        wdt_cnt_config <= 31'h400;
    end
    else if (apb_wr && s_apb_intf.paddr[7:0] == `DMA_WDT_CNT) begin
        wdt_cnt_config <= s_apb_intf.pwdata[30:0];
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_wdt_timeout
    if (~rstn) begin
        wdt_timeout <= 1'b0;
    end
    else if (~wdt_rst_b) begin
        wdt_timeout <= 1'b1;
    end
    else if (apb_wr && s_apb_intf.paddr[7:0] == `DMA_WDT_CNT) begin
        wdt_timeout <= wdt_timeout && s_apb_intf.pwdata[31];
    end
end

endmodule

module dma_fifo (
    input                            clk,
    input                            rstn,

    input                            push,
    input        [              1:0] wsize,
    input        [             31:0] wdata,
    output logic                     full,
    output logic [`DMA_FIFO_DEPTH:0] cnt,

    input                            pop,
    input        [              1:0] rsize,
    output logic [             31:0] rdata,
    output logic                     empty

);


logic [                7:0] buff [`DMA_FIFO_SIZE];
logic [`DMA_FIFO_DEPTH-1:0] rptr;
logic [`DMA_FIFO_DEPTH-1:0] wptr;

assign empty = cnt <= rsize;
assign full  = cnt >= (({{`DMA_FIFO_DEPTH{1'b0}}, 1'b1} << (`DMA_FIFO_DEPTH)) - wsize);
assign rdata = {{8{rsize >= 2'h3}} & buff[rptr + `DMA_FIFO_DEPTH'h3],
                {8{rsize >= 2'h2}} & buff[rptr + `DMA_FIFO_DEPTH'h2],
                {8{rsize >= 2'h1}} & buff[rptr + `DMA_FIFO_DEPTH'h1],
                {8{rsize >= 2'h0}} & buff[rptr + `DMA_FIFO_DEPTH'h0]};

always_ff @(posedge clk or negedge rstn) begin: reg_wptr
    if (~rstn) begin
        wptr <= `DMA_FIFO_DEPTH'b0;
    end
    else if (push && ~full) begin
        wptr <= wptr + {{`DMA_FIFO_DEPTH-2{1'b0}}, wsize} + `DMA_FIFO_DEPTH'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_rptr
    if (~rstn) begin
        rptr <= `DMA_FIFO_DEPTH'b0;
    end
    else if (pop && ~empty) begin
        rptr <= rptr + {{`DMA_FIFO_DEPTH-2{1'b0}}, rsize} + `DMA_FIFO_DEPTH'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_cnt
    if (~rstn) begin
        cnt  <= {`DMA_FIFO_DEPTH+1{1'b0}};
    end
    else begin
        cnt  <= cnt +
                ({`DMA_FIFO_DEPTH+1{push && ~full }} & ({{`DMA_FIFO_DEPTH-1{1'b0}}, wsize} + {`DMA_FIFO_DEPTH'b0, 1'b1})) -
                ({`DMA_FIFO_DEPTH+1{pop  && ~empty}} & ({{`DMA_FIFO_DEPTH-1{1'b0}}, rsize} + {`DMA_FIFO_DEPTH'b0, 1'b1}));
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_buff
    integer i;
    if (~rstn) begin
        for (i = 0; i < `DMA_FIFO_SIZE; i = i + 1) begin
            buff[i] <= 8'b0;
        end
    end
    else begin
        if (push && ~full) begin
            if (wsize >= 2'h0) buff[wptr            ] <= wdata[ 0+:8];
            if (wsize >= 2'h1) buff[wptr + `DMA_FIFO_DEPTH'h1] <= wdata[ 8+:8];
            if (wsize >= 2'h2) buff[wptr + `DMA_FIFO_DEPTH'h2] <= wdata[16+:8];
            if (wsize >= 2'h3) buff[wptr + `DMA_FIFO_DEPTH'h3] <= wdata[24+:8];
        end
    end
end

endmodule
