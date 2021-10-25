`include "axi_define.h"

module axi_dfslv #(
    parameter AXI_AXID_WIDTH    = 10,
    parameter AXI_AXADDR_WIDTH  = 32,
    parameter AXI_AXLEN_WIDTH   = 8,
    parameter AXI_AXSIZE_WIDTH  = 3,
    parameter AXI_AXBURST_WIDTH = 2,
    parameter AXI_DATA_WIDTH    = 32,
    parameter AXI_RESP_WIDTH    = 2
)(
    input                                                     aclk,
    input                                                     aresetn,
    // Slave
    // Write Address Channel
    input        [                     AXI_AXID_WIDTH - 1: 0] s_awid,
    input        [                   AXI_AXADDR_WIDTH - 1: 0] s_awaddr,
    input        [                    AXI_AXLEN_WIDTH - 1: 0] s_awlen,
    input        [                   AXI_AXSIZE_WIDTH - 1: 0] s_awsize,
    input        [                  AXI_AXBURST_WIDTH - 1: 0] s_awburst,
    input                                                     s_awvalid,
    output logic                                              s_awready,
    // Write Data Channel
    input        [                     AXI_AXID_WIDTH - 1: 0] s_wid,
    input        [                     AXI_DATA_WIDTH - 1: 0] s_wdata,
    input        [                   AXI_DATA_WIDTH/8 - 1: 0] s_wstrb,
    input                                                     s_wlast,
    input                                                     s_wvalid,
    output logic                                              s_wready,
    // Write Response Channel
    output logic [                     AXI_AXID_WIDTH - 1: 0] s_bid,
    output logic [                     AXI_RESP_WIDTH - 1: 0] s_bresp,
    output logic                                              s_bvalid,
    input                                                     s_bready,
    // Read Address Channel
    input        [                     AXI_AXID_WIDTH - 1: 0] s_arid,
    input        [                   AXI_AXADDR_WIDTH - 1: 0] s_araddr,
    input        [                    AXI_AXLEN_WIDTH - 1: 0] s_arlen,
    input        [                   AXI_AXSIZE_WIDTH - 1: 0] s_arsize,
    input        [                  AXI_AXBURST_WIDTH - 1: 0] s_arburst,
    input                                                     s_arvalid,
    output logic                                              s_arready,
    //  Read Data Channel
    output logic [                     AXI_AXID_WIDTH - 1: 0] s_rid,
    output logic [                     AXI_DATA_WIDTH - 1: 0] s_rdata,
    output logic [                     AXI_RESP_WIDTH - 1: 0] s_rresp,
    output logic                                              s_rlast, 
    output logic                                              s_rvalid,
    input                                                     s_rready
);

// READ
logic [AXI_AXLEN_WIDTH - 1: 0] rlen;

assign s_rdata   = {AXI_DATA_WIDTH{1'b0}};
assign s_rresp   = `AXI_RESP_DECERR;
assign s_rlast   = ~|rlen;
assign s_arready = ~s_rvalid | (s_rlast & s_rvalid & s_rready);

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_rid <= {AXI_AXID_WIDTH{1'b0}};
    end
    else begin
        if (s_arvalid & s_arready) begin
            s_rid <= s_arid;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_rvalid <= 1'b0;
    end
    else begin
        if (s_arvalid & s_arready) begin
            s_rvalid <= 1'b1;
        end
        else if (s_rlast & s_rvalid & s_rready) begin
            s_rvalid <= 1'b0;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        rlen <= {AXI_AXLEN_WIDTH{1'b0}};
    end
    else begin
        if (s_arvalid & s_arready) begin
            rlen <= s_arlen;
        end
        else if (~s_rlast & s_rvalid & s_rready) begin
            rlen <= rlen - 1;
        end
    end
end

// WRITE
assign s_awready = (~s_wready & ~s_bvalid) | (s_bvalid & s_bready);
assign s_bresp   = `AXI_RESP_DECERR;

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_wready = 1'b0;
    end
    else begin
        if (s_awvalid & s_awready) begin
            s_wready <= 1'b1;
        end
        else if (s_wvalid & s_wlast) begin
            s_wready <= 1'b0;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_bid <= {AXI_AXID_WIDTH{1'b0}};
    end
    else begin
        if (s_awvalid & s_awready) begin
            s_bid <= s_awid;
        end
    end
end

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_bvalid = 1'b0;
    end
    else begin
        if (s_wvalid & s_wlast & s_wready) begin
            s_bvalid <= 1'b1;
        end
        else if (s_bready) begin
            s_bvalid <= 1'b0;
        end
    end
end

endmodule
