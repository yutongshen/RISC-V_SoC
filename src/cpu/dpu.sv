`include "cpu_define.h"

module dpu (
    input                                    clk,
    input                                    rstn,
    
    input                                    amo_i,
    input        [        `AMO_OP_LEN - 1:0] amo_op_i,
    input        [       `IM_ADDR_LEN - 1:0] pc_i,
    input                                    sign_ext_i,
    input                                    req_i,
    input                                    wr_i,
    input                                    ex_i,
    input        [(`DM_DATA_LEN >> 3) - 1:0] byte_i,
    input        [       `DM_ADDR_LEN - 1:0] addr_i,
    input        [       `DM_DATA_LEN - 1:0] wdata_i,

    output logic                             amo_wr_o,
    output logic [       `DM_DATA_LEN - 1:0] rdata_o,
    output logic                             hazard_o,

    output logic                             fault,
    output logic                             load_misaligned,
    output logic                             store_misaligned,
    output logic                             load_pg_fault,
    output logic                             store_pg_fault,
    output logic                             load_xes_fault,
    output logic                             store_xes_fault,

    output logic                             dmem_req,
    output logic [       `DM_ADDR_LEN - 1:0] dmem_addr,
    output logic                             dmem_wr,
    output logic                             dmem_ex,
    output logic [(`DM_DATA_LEN >> 3) - 1:0] dmem_byte,
    output logic [       `DM_DATA_LEN - 1:0] dmem_wdata,
    input        [       `DM_DATA_LEN - 1:0] dmem_rdata,
    input        [                      1:0] dmem_bad,
    input                                    dmem_xstate,
    input                                    dmem_busy
);

logic                              misaligned;
logic                              dmem_req_done;
logic                              dmem_req_latch;
logic                              data_latch_valid;
logic  [       `DM_DATA_LEN - 1:0] data_latch;
logic  [       `DM_DATA_LEN - 1:0] dmem_rdata_shft;
logic  [       `DM_DATA_LEN - 1:0] dmem_rdata_ext;
logic  [       `DM_ADDR_LEN - 1:0] addr_latch;
logic                              sign_ext_latch;
logic  [(`DM_DATA_LEN >> 3) - 1:0] byte_latch;
logic                              load_latch;
logic                              store_latch;
logic                              sc_latch;


logic                              amo_wr;
logic  [          `AMO_OP_LEN-1:0] amo_op;
logic  [                `XLEN-1:0] amo_src;
                                  
logic  [                `XLEN-1:0] amo_mem_rdata;
logic  [                `XLEN-1:0] amo_mem_wdata;


assign dmem_req_done = dmem_req_latch & ~dmem_busy;

assign dmem_req      = (req_i & ~misaligned & ~dmem_busy) | (amo_wr & ~dmem_busy & ~|dmem_bad);
assign dmem_addr     = amo_wr ? addr_latch : addr_i;
assign dmem_wr       = wr_i | amo_wr;
assign dmem_ex       = ex_i | amo_wr;

assign amo_wr_o      = amo_wr;
assign rdata_o       = sc_latch & store_latch ? {{`XLEN-1{1'b0}}, ~dmem_xstate}:
                       data_latch_valid       ? data_latch : dmem_rdata_ext;
assign hazard_o      = (dmem_req_latch & ~dmem_req_done) |
                       (req_i & ~misaligned & dmem_busy)/* |
                       (req_i & amo_i & ~dmem_wr & ~misaligned)*/;

assign misaligned      = ((addr_i[1:0] == 2'd1) && byte_i[1]) ||
                         ((addr_i[1:0] == 2'd2) && byte_i[2]) ||
                         ((addr_i[1:0] == 2'd3) && byte_i[1]);
assign load_pg_fault   = ~dmem_busy & dmem_bad[0] & load_latch;
assign store_pg_fault  = ~dmem_busy & dmem_bad[0] & store_latch;
assign load_xes_fault  = ~dmem_busy & dmem_bad[1] & load_latch;
assign store_xes_fault = ~dmem_busy & dmem_bad[1] & store_latch;
assign fault           = (~dmem_busy & |dmem_bad) || load_misaligned || store_misaligned;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        load_misaligned  <= 1'b0;
        store_misaligned <= 1'b0;
    end
    else begin
        load_misaligned  <= req_i & misaligned & ~wr_i;
        store_misaligned <= req_i & misaligned &  wr_i;
    end
end

always_comb begin
    if (amo_wr) begin
        dmem_byte  = byte_latch;
        dmem_wdata = amo_mem_wdata;
    end
    else begin
        case (dmem_addr[0+:2])
            2'h0: begin
                dmem_byte  = byte_i;
                dmem_wdata = wdata_i;
            end
            2'h1: begin
                dmem_byte  = {byte_i [ 2:0], byte_i [3]};
                dmem_wdata = {wdata_i[23:0], wdata_i[31:24]};
            end
            2'h2: begin
                dmem_byte  = {byte_i [ 1:0], byte_i [3:2]};
                dmem_wdata = {wdata_i[15:0], wdata_i[31:16]};
            end
            2'h3: begin
                dmem_byte  = {byte_i [0],   byte_i [3:1]};
                dmem_wdata = {wdata_i[7:0], wdata_i[31:8]};
            end
        endcase
    end
end

always_comb begin
    case (addr_latch[0+:2])
        2'h0: begin
            dmem_rdata_shft = dmem_rdata;
        end
        2'h1: begin
            dmem_rdata_shft = {dmem_rdata[ 7:0], dmem_rdata[31: 8]};
        end
        2'h2: begin
            dmem_rdata_shft = {dmem_rdata[15:0], dmem_rdata[31:16]};
        end
        2'h3: begin
            dmem_rdata_shft = {dmem_rdata[23:0], dmem_rdata[31:24]};
        end
    endcase
end
always_comb begin
    if (byte_latch[3])      dmem_rdata_ext = {{`XLEN-32{sign_ext_latch & dmem_rdata_shft[31]}}, dmem_rdata_shft[31:0]};
    else if (byte_latch[1]) dmem_rdata_ext = {{`XLEN-16{sign_ext_latch & dmem_rdata_shft[15]}}, dmem_rdata_shft[15:0]};
    else if (byte_latch[0]) dmem_rdata_ext = {{`XLEN- 8{sign_ext_latch & dmem_rdata_shft[ 7]}}, dmem_rdata_shft[ 7:0]};
    else                    dmem_rdata_ext = `XLEN'b0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        data_latch_valid <= 1'b0;
    end
    else if (dmem_req_done & ~amo_wr) begin
        data_latch_valid <= 1'b0;
    end
    else if (~dmem_busy & dmem_req_latch) begin
        data_latch_valid <= 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        data_latch <= `DM_DATA_LEN'b0;
    end
    else if (~dmem_busy & dmem_req_latch & load_latch) begin
        data_latch <= dmem_rdata_ext;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        sc_latch    <= 1'b0;
        load_latch  <= 1'b0;
        store_latch <= 1'b0;
    end
    else if (dmem_req & ~dmem_busy) begin
        sc_latch    <=  ex_i & ~amo_i;
        load_latch  <= ~dmem_wr;
        store_latch <=  dmem_wr;
    end
    else if (~dmem_busy) begin
        sc_latch    <= 1'b0;
        load_latch  <= 1'b0;
        store_latch <= 1'b0;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        dmem_req_latch <= 1'b0;
    end
    else if (dmem_req & ~dmem_busy) begin
        dmem_req_latch <= 1'b1;
    end
    else if (dmem_req_done) begin
        dmem_req_latch <= 1'b0;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        addr_latch     <= `DM_ADDR_LEN'b0;
        sign_ext_latch <= 1'b0;
        byte_latch     <= 4'b0;
    end
    else if (dmem_req & ~dmem_busy) begin
        addr_latch     <= addr_i;
        sign_ext_latch <= sign_ext_i;
        byte_latch     <= byte_i;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        amo_wr  <= 1'b0;
        amo_op  <= `AMO_OP_LEN'b0;
        amo_src <= `XLEN'b0;
    end
    else if (dmem_req & ~dmem_busy) begin
        amo_wr  <= ~amo_wr & amo_i;
        amo_op  <= amo_op_i;
        amo_src <= wdata_i;
    end
end

assign amo_mem_rdata  = dmem_rdata;

amo u_amo (
    .clk            ( clk            ),
    .rstn           ( rstn           ),
    .amo_op         ( amo_op         ),
    .amo_src        ( amo_src        ),
    
    // memory intf
    .amo_mem_rdata  ( amo_mem_rdata  ),
    .amo_mem_wdata  ( amo_mem_wdata  )
);

endmodule
