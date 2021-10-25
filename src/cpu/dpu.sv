`include "cpu_define.h"

module dpu (
    input                                    clk,
    input                                    rstn,
    
    input                                    sign_ext_i,
    input                                    req_i,
    input                                    wr_i,
    input        [(`IM_DATA_LEN >> 3) - 1:0] byte_i,
    input        [       `IM_ADDR_LEN - 1:0] addr_i,
    input        [       `IM_DATA_LEN - 1:0] wdata_i,

    output logic [       `IM_DATA_LEN - 1:0] rdata_o,
    output logic                             hazard_o,

    output logic                             dmem_req,
    output logic [       `IM_ADDR_LEN - 1:0] dmem_addr,
    output logic                             dmem_wr,
    output logic [(`IM_DATA_LEN >> 3) - 1:0] dmem_byte,
    output logic [       `IM_DATA_LEN - 1:0] dmem_wdata,
    input        [       `IM_DATA_LEN - 1:0] dmem_rdata,
    input                                    dmem_busy
);

logic                              dmem_req_done;
logic                              dmem_req_latch;
logic                              data_latch_valid;
logic  [       `IM_DATA_LEN - 1:0] data_latch;
logic  [       `IM_DATA_LEN - 1:0] dmem_rdata_shft;
logic  [       `IM_DATA_LEN - 1:0] dmem_rdata_ext;
logic  [                      1:0] addr_latch;
logic                              sign_ext_latch;
logic  [(`IM_DATA_LEN >> 3) - 1:0] byte_latch;


assign dmem_req_done = dmem_req_latch & ~dmem_busy;

assign dmem_req      = req_i & ~dmem_busy;
assign dmem_addr     = addr_i;
assign dmem_wr       = wr_i;

assign rdata_o       = data_latch_valid ? data_latch : dmem_rdata_ext;
assign hazard_o      = (dmem_req_latch & ~dmem_req_done) | (req_i & dmem_busy);

always_comb begin
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
    if (byte_latch[3])      dmem_rdata_ext = dmem_rdata_shft[31:0];
    else if (byte_latch[1]) dmem_rdata_ext = {{16{sign_ext_latch & dmem_rdata_shft[15]}}, dmem_rdata_shft[15:0]};
    else if (byte_latch[0]) dmem_rdata_ext = {{24{sign_ext_latch & dmem_rdata_shft[ 7]}}, dmem_rdata_shft[ 7:0]};
    else                    dmem_rdata_ext = `XLEN'b0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        data_latch_valid <= 1'b0;
    end
    else if (dmem_req_done) begin
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
    else if (~dmem_busy & dmem_req_latch) begin
        data_latch <= dmem_rdata_ext;
    end
end


always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        dmem_req_latch <= 1'b0;
    end
    else if (dmem_req) begin
        dmem_req_latch <= 1'b1;
    end
    else if (dmem_req_done) begin
        dmem_req_latch <= 1'b0;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        addr_latch     <= 2'b0;
        sign_ext_latch <= 1'b0;
        byte_latch     <= 4'b0;
    end
    else if (dmem_req) begin
        addr_latch     <= addr_i[1:0];
        sign_ext_latch <= sign_ext_i;
        byte_latch     <= byte_i;
    end
end

endmodule
