`include "dma_mmap.h"

module dma (
    input               clk,
    input               rstn,

    output logic        dma_rxreq,
    input               dma_rxne,
    input        [15:0] dma_rxbuff,
    output logic        dma_txreq,
    input               dma_txe,
    output logic [15:0] dma_txbuff,

    axi_intf.master     m_axi_intf,
    apb_intf.slave      s_apb_intf
);

localparam TYPE_FIXED = 2'b00;
localparam TYPE_INCR  = 2'b01;
localparam TYPE_SPI   = 2'b10;
localparam TYPE_CONST = 2'b11;

localparam SIZE_BYTE  = 2'b00;
localparam SIZE_HWORD = 2'b01;
localparam SIZE_WORD  = 2'b10;
localparam SIZE_DWORD = 2'b11;

logic        apb_wr;
logic        apb_rd;
logic [31:0] dma_src;
logic [31:0] dma_dest;
logic [31:0] dma_len;
logic [31:0] dma_con;
logic        dma_con_en;
logic [ 1:0] dma_con_src_type;
logic [ 1:0] dma_con_dest_type;
logic [ 1:0] dma_con_src_size;
logic [ 1:0] dma_con_dest_size;
logic        dma_busy;
logic [31:0] prdata_t;
logic        dma_done;

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
                     dma_con_dest_type == TYPE_CONST ||
                     (dma_con_src_type  == TYPE_FIXED && dma_con_src_size  >= SIZE_HWORD && dma_src [0]) ||
                     (dma_con_src_type  == TYPE_FIXED && dma_con_src_size  >= SIZE_WORD  && dma_src [1]) ||
                     (dma_con_dest_type == TYPE_FIXED && dma_con_dest_size >= SIZE_HWORD && dma_dest[0]) ||
                     (dma_con_dest_type == TYPE_FIXED && dma_con_dest_size >= SIZE_WORD  && dma_dest[1]) ||
                     (dma_con_src_type  == TYPE_SPI   && dma_con_dest_type == TYPE_SPI)   ||
                     (dma_con_src_type  == TYPE_SPI   && dma_con_src_size  >  SIZE_HWORD) ||
                     (dma_con_dest_type == TYPE_SPI   && dma_con_dest_size >  SIZE_HWORD);
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
                  3'b0,
                  dma_con_en};

always_ff @(posedge clk or negedge rstn) begin: reg_dma_con
    if (~rstn) begin
        dma_con_en        <= 1'b0;
        dma_con_src_type  <= 2'b0;
        dma_con_dest_type <= 2'b0;
        dma_con_src_size  <= 2'b0;
        dma_con_dest_size <= 2'b0;
        dma_busy          <= 1'b0;
    end
    else if (~dma_busy && apb_wr && s_apb_intf.paddr[7:0] == `DMA_CON) begin
        dma_con_en        <= s_apb_intf.pwdata[ 0];
        dma_con_src_type  <= s_apb_intf.pwdata[ 5: 4];
        dma_con_dest_type <= s_apb_intf.pwdata[ 7: 6];
        dma_con_src_size  <= s_apb_intf.pwdata[ 9: 8];
        dma_con_dest_size <= s_apb_intf.pwdata[11:10];
        dma_busy          <= s_apb_intf.pwdata[ 0];
    end
    else if (dma_con_err || dma_done) begin
        dma_busy          <= 1'b0;
        dma_con_en        <= 1'b0;
    end
    else begin
        dma_con_en        <= 1'b0;
    end
end

always_comb begin: comb_prdata_t
    prdata_t = 32'b0;
    case (s_apb_intf.paddr[7:0])
        `DMA_SRC:  prdata_t = dma_src;
        `DMA_DEST: prdata_t = dma_dest;
        `DMA_LEN:  prdata_t = dma_len;
        `DMA_CON:  prdata_t = dma_con;
    endcase
end

always_ff @(posedge clk or negedge rstn) begin: reg_prdata
    if (~rstn) s_apb_intf.prdata <= 32'b0;
    else       s_apb_intf.prdata <= prdata_t;
end

assign s_apb_intf.pready  = 1'b1;
assign s_apb_intf.pslverr = 1'b0;

// =========== Data transfer ===========
logic [31:0] dest_burst_byte;
logic [31:0] dest_addr;
logic [31:0] src_addr;
logic [31:0] dest_len_cnt;
logic [31:0] dest_cnt;
logic [ 7:0] dest_len;
logic [31:0] src_len_cnt;
logic [31:0] src_cnt;
logic [ 7:0] src_len;
logic        awvalid;
logic [ 3:0] wstrb;
logic [ 2:0] wburst_cnt;
logic        wvalid;
logic        arvalid;

logic [ 1:0] incr_wsize;
logic [ 1:0] incr_rsize;
logic [ 1:0] othr_wsize;
logic [ 1:0] othr_rsize;
logic        fifo_push;
logic [ 1:0] fifo_wsize;
logic [31:0] fifo_wdata;
logic        fifo_full;
logic [ 6:0] fifo_cnt;
logic        fifo_pop;
logic [ 1:0] fifo_rsize;
logic [31:0] fifo_rdata;
logic        fifo_empty;

assign incr_wsize = ({2{dma_con_src_size == SIZE_BYTE }} & 2'h0)|
                    ({2{dma_con_src_size == SIZE_HWORD}} & ((32'h1 - {31'b0, src_addr[0]}) < src_cnt ?
                                                            (2'h1 - {1'b0, src_addr[0]}):
                                                            (src_cnt[1:0] - 2'h1)))|
                    ({2{dma_con_src_size == SIZE_WORD }} & ((32'h3 - {30'b0, src_addr[1:0]}) < src_cnt ?
                                                            (2'h3 - src_addr[1:0]):
                                                            (src_cnt[1:0] - 2'h1)));
assign incr_rsize = ({2{dma_con_dest_size == SIZE_BYTE }} & 2'h0)|
                    ({2{dma_con_dest_size == SIZE_HWORD}} & ((32'h1 - {31'b0, dest_addr[0]}) < dest_cnt ?
                                                             (2'h1 - {1'b0, dest_addr[0]}):
                                                             (dest_cnt[1:0] - 2'h1)))|
                    ({2{dma_con_dest_size == SIZE_WORD }} & ((32'h3 - {30'b0, dest_addr[1:0]}) < dest_cnt ?
                                                             (2'h3 - dest_addr[1:0]):
                                                             (dest_cnt[1:0] - 2'h1)));
assign othr_wsize = ({2{dma_con_src_size  == SIZE_BYTE }} & 2'h0)|
                    ({2{dma_con_src_size  == SIZE_HWORD}} & 2'h1)|
                    ({2{dma_con_src_size  == SIZE_WORD }} & 2'h3);
assign othr_rsize = ({2{dma_con_dest_size == SIZE_BYTE }} & 2'h0)|
                    ({2{dma_con_dest_size == SIZE_HWORD}} & 2'h1)|
                    ({2{dma_con_dest_size == SIZE_WORD }} & 2'h3);
assign fifo_wsize = ({2{dma_con_src_type  == TYPE_INCR}} & incr_wsize)|
                    //({2{dma_con_src_type  != TYPE_INCR}} & othr_wsize);
                    ({2{dma_con_src_type  != TYPE_INCR}} & incr_wsize);
assign fifo_rsize = ({2{dma_con_dest_type == TYPE_INCR}} & incr_rsize)|
                    //({2{dma_con_dest_type != TYPE_INCR}} & othr_rsize);
                    ({2{dma_con_dest_type != TYPE_INCR}} & incr_rsize);
assign fifo_push  = ((dma_con_src_type  == TYPE_FIXED) & (m_axi_intf.rvalid && m_axi_intf.rready))|
                    ((dma_con_src_type  == TYPE_INCR ) & (m_axi_intf.rvalid && m_axi_intf.rready))|
                    ((dma_con_src_type  == TYPE_SPI  ) & dma_rxreq)|
                    ((dma_con_src_type  == TYPE_CONST) & (dma_busy && |src_cnt && ~fifo_full))|
                    1'b0;
assign fifo_pop   = ((dma_con_dest_type == TYPE_FIXED) & (m_axi_intf.wvalid && m_axi_intf.wready))|
                    ((dma_con_dest_type == TYPE_INCR ) & (m_axi_intf.wvalid && m_axi_intf.wready))|
                    ((dma_con_dest_type == TYPE_SPI  ) & dma_txreq)|
                    1'b0;
assign fifo_wdata = ({32{dma_con_src_type  == TYPE_FIXED}} & m_axi_intf.rdata >> {src_addr[1:0], 3'b0})|
                    ({32{dma_con_src_type  == TYPE_INCR }} & m_axi_intf.rdata >> {src_addr[1:0], 3'b0})|
                    ({32{dma_con_src_type  == TYPE_SPI  }} & {16'b0, dma_rxbuff})|
                    ({32{dma_con_src_type  == TYPE_CONST}} & dma_src);

assign dma_done   = ~|src_cnt && ~|dest_cnt && (m_axi_intf.bvalid && m_axi_intf.bready);

// SPI mode
assign dma_txreq = dma_busy && ~dma_con_en && ~dma_con_err && dma_txe &&
                   ((dma_con_src_type  == TYPE_SPI && |src_cnt  && ~fifo_full )||
                    (dma_con_dest_type == TYPE_SPI && |dest_cnt && ~fifo_empty));
assign dma_rxreq = dma_busy && ~dma_con_en && ~dma_con_err && dma_rxne &&
                   ((dma_con_src_type  == TYPE_SPI && |src_cnt  && ~fifo_full )||
                    (dma_con_dest_type == TYPE_SPI && |dest_cnt && ~fifo_empty));

assign dma_txbuff = dma_con_src_type  == TYPE_SPI  ? 16'hffff:
                    dma_con_dest_size == SIZE_BYTE ? {8'b0, fifo_rdata[7:0]}:
                                                     fifo_rdata[15:0];

// AXI mode
assign m_axi_intf.awid    = 9'b0;
assign m_axi_intf.awaddr  = dest_addr;
assign m_axi_intf.awburst = dma_con_dest_type;
assign m_axi_intf.awsize  = dma_con_dest_size;
assign m_axi_intf.awlen   = {24'b0, dest_len} < dest_len_cnt ? dest_len : (dest_len_cnt[7:0] - 8'h1);
assign m_axi_intf.awlock  = 2'b0;
assign m_axi_intf.awcache = 4'b0;
assign m_axi_intf.awprot  = 3'b0;
assign m_axi_intf.awvalid = awvalid && ({25'b0, fifo_cnt} >= dest_burst_byte || ~|src_cnt);
assign m_axi_intf.wid     = 9'b0;
assign m_axi_intf.wstrb   = (4'b1 << ({1'b0, fifo_rsize} + 3'b1)) - 4'b1 << dest_addr[1:0];
assign m_axi_intf.wdata   = fifo_rdata << {dest_addr[1:0], 3'b0};
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
assign m_axi_intf.arvalid = arvalid && ~fifo_full;
assign m_axi_intf.rready  = ~fifo_full;

always_ff @(posedge clk or negedge rstn) begin: reg_src_addr
    if (~rstn) begin
        src_addr <= 32'b0;
    end
    else if (dma_con_en) begin
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
    else if (dma_con_en) begin
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
    else if (dma_con_en) begin
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
    else if (dma_con_en) begin
        src_len_cnt <= ({32{dma_con_src_size == SIZE_BYTE }} &  dma_len)|
                       ({32{dma_con_src_size == SIZE_HWORD}} & (dma_len + {31'b0, dma_src[0]}   + 32'h1) >> 1)|
                       ({32{dma_con_src_size == SIZE_WORD }} & (dma_len + {30'b0, dma_src[1:0]} + 32'h3) >> 2);
    end
    else if (m_axi_intf.arvalid && m_axi_intf.arready && |src_len_cnt) begin
        src_len_cnt <= src_len_cnt - {24'b0, m_axi_intf.arlen} - 32'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_src_cnt
    if (~rstn) begin
        src_cnt <= 32'b0;
    end
    else if (dma_con_en) begin
        src_cnt <= dma_len;
    end
    else if (fifo_push && |src_cnt) begin
        src_cnt <= src_cnt - {30'b0, fifo_wsize} - 32'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dest_len
    if (~rstn) begin
        dest_len <= 8'b0;
    end
    else if (dma_con_en) begin
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
    else if (dma_con_en) begin
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
    else if (dma_con_en) begin
        dest_cnt <= dma_len;
    end
    else if (fifo_pop && |dest_cnt) begin
        dest_cnt <= dest_cnt - {30'b0, fifo_rsize} - 32'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_dest_burst_byte
    if (~rstn) begin
        dest_burst_byte <= 32'b0;
    end
    else if (dma_con_en) begin
        dest_burst_byte <= 32'h8 << dma_con_dest_size;
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
    else if (dma_con_en) begin
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
    else if (dma_con_en) begin
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
dma_fifo u_dma_fifo (
    .clk   ( clk        ),
    .rstn  ( rstn       ),

    .push  ( fifo_push  ),
    .wsize ( fifo_wsize ),
    .wdata ( fifo_wdata ),
    .full  ( fifo_full  ),
    .cnt   ( fifo_cnt   ),

    .pop   ( fifo_pop   ),
    .rsize ( fifo_rsize ),
    .rdata ( fifo_rdata ),
    .empty ( fifo_empty )
);

endmodule

`define DEPTH 6
`define SIZE  (1 << `DEPTH)

module dma_fifo (
    input                   clk,
    input                   rstn,

    input                   push,
    input        [     1:0] wsize,
    input        [    31:0] wdata,
    output logic            full,
    output logic [`DEPTH:0] cnt,

    input                   pop,
    input        [     1:0] rsize,
    output logic [    31:0] rdata,
    output logic            empty

);


logic [       7:0] buff [`SIZE];
logic [`DEPTH-1:0] rptr;
logic [`DEPTH-1:0] wptr;

assign empty = cnt <= rsize;
assign full  = cnt >= ({{`DEPTH{1'b0}}, 1'b1} << (`DEPTH-1));
assign rdata = {{8{rsize >= 2'h3}} & buff[rptr + `DEPTH'h3],
                {8{rsize >= 2'h2}} & buff[rptr + `DEPTH'h2],
                {8{rsize >= 2'h1}} & buff[rptr + `DEPTH'h1],
                {8{rsize >= 2'h0}} & buff[rptr + `DEPTH'h0]};

always_ff @(posedge clk or negedge rstn) begin: reg_wptr
    if (~rstn) begin
        wptr <= `DEPTH'b0;
    end
    else if (push && ~full) begin
        wptr <= wptr + {{`DEPTH-2{1'b0}}, wsize} + `DEPTH'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_rptr
    if (~rstn) begin
        rptr <= `DEPTH'b0;
    end
    else if (pop && ~empty) begin
        rptr <= rptr + {{`DEPTH-2{1'b0}}, rsize} + `DEPTH'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_cnt
    if (~rstn) begin
        cnt  <= {`DEPTH+1{1'b0}};
    end
    else begin
        cnt  <= cnt +
                ({`DEPTH+1{push && ~full }} & ({{`DEPTH-1{1'b0}}, wsize} + {`DEPTH'b0, 1'b1})) -
                ({`DEPTH+1{pop  && ~empty}} & ({{`DEPTH-1{1'b0}}, rsize} + {`DEPTH'b0, 1'b1}));
    end
end

always_ff @(posedge clk or negedge rstn) begin: reg_buff
    integer i;
    if (~rstn) begin
        for (i = 0; i < `SIZE; i = i + 1) begin
            buff[i] <= 8'b0;
        end
    end
    else begin
        if (push && ~full) begin
            if (wsize >= 2'h0) buff[wptr            ] <= wdata[ 0+:8];
            if (wsize >= 2'h1) buff[wptr + `DEPTH'h1] <= wdata[ 8+:8];
            if (wsize >= 2'h2) buff[wptr + `DEPTH'h2] <= wdata[16+:8];
            if (wsize >= 2'h3) buff[wptr + `DEPTH'h3] <= wdata[24+:8];
        end
    end
end

endmodule
