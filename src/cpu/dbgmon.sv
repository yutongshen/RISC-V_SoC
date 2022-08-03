`include "dbgmon_mmap.h"

module dbgmon (
    input                 clk,
    input                 rstn,
    input                 srstn,

    apb_intf.slave        apb_intf,

    input         [ 63:0] pc,
    input         [ 63:0] gpr [32],

    input                 pkg_valid,
    input         [255:0] pkg
);

logic [ 31:0] prdata_trace;
logic [ 31:0] prdata_t;
logic [ 31:0] prdata_t_latch;

logic [ 63:0] breakpoint;

logic [255:0] pkg_out;
logic [  6:0] trace_ptr;
logic         trace_sram_we;
logic [  6:0] trace_sram_addr;
logic         stop_trace;
logic         stop_hit;

always_ff @(posedge clk or negedge rstn) begin: reg_bp
    if (~rstn) breakpoint <= 64'h21d62;
    else if (apb_intf.pwrite && apb_intf.psel && ~apb_intf.penable) begin
        if (apb_intf.paddr[12:0] == `DBGMON_BP)
            breakpoint[ 0+:32] <= apb_intf.pwdata;
        if (apb_intf.paddr[12:0] == `DBGMON_BP + 13'h4)
            breakpoint[32+:32] <= apb_intf.pwdata;
    end
end

assign stop_hit        = (breakpoint == pkg[160+:64]) && !pkg[255] && pkg_valid;
assign trace_sram_we   = pkg_valid && ~stop_trace;
assign trace_sram_addr = ({7{stop_trace}} & apb_intf.paddr[11:5]) + trace_ptr;

always_ff @(posedge clk or negedge rstn) begin: reg_trace_ptr
    if (~rstn)              trace_ptr <= 7'b0;
    else if (trace_sram_we) trace_ptr <= trace_ptr + 7'b1;
end

always_ff @(posedge clk or negedge srstn) begin: reg_stop_trace
    if (~srstn)        stop_trace <= 1'b0;
    else if (stop_hit) stop_trace <= 1'b1;
end

sram128x64 u_sram_0 (
    .CK   ( clk               ),
    .CS   ( 1'b1              ),
    .WE   ( trace_sram_we     ),
    .A    ( trace_sram_addr   ),
    .BYTE ( 8'hff             ),
    .DI   ( pkg[0+:64]        ),
    .DO   ( pkg_out[0+:64]    )
);

sram128x64 u_sram_1 (
    .CK   ( clk               ),
    .CS   ( 1'b1              ),
    .WE   ( trace_sram_we     ),
    .A    ( trace_sram_addr   ),
    .BYTE ( 8'hff             ),
    .DI   ( pkg[64+:64]       ),
    .DO   ( pkg_out[64+:64]   )
);

sram128x64 u_sram_2 (
    .CK   ( clk               ),
    .CS   ( 1'b1              ),
    .WE   ( trace_sram_we     ),
    .A    ( trace_sram_addr   ),
    .BYTE ( 8'hff             ),
    .DI   ( pkg[128+:64]      ),
    .DO   ( pkg_out[128+:64]  )
);

sram128x64 u_sram_3 (
    .CK   ( clk               ),
    .CS   ( 1'b1              ),
    .WE   ( trace_sram_we     ),
    .A    ( trace_sram_addr   ),
    .BYTE ( 8'hff             ),
    .DI   ( pkg[192+:64]      ),
    .DO   ( pkg_out[192+:64]  )
);

always_comb begin: comb_prdata_trace
    prdata_trace = 32'b0;
    case (apb_intf.paddr[4:2])
        3'h0: prdata_trace = pkg_out[  0+:32];
        3'h1: prdata_trace = pkg_out[ 32+:32];
        3'h2: prdata_trace = pkg_out[ 64+:32];
        3'h3: prdata_trace = pkg_out[ 96+:32];
        3'h4: prdata_trace = pkg_out[128+:32];
        3'h5: prdata_trace = pkg_out[160+:32];
        3'h6: prdata_trace = pkg_out[192+:32];
        3'h7: prdata_trace = pkg_out[224+:32];
    endcase
end

always_comb begin: comb_prdata_t
    prdata_t = 32'b0;
    case (apb_intf.paddr[12:0])
        `DBGMON_PC  + 13'h0: prdata_t = pc[31: 0];
        `DBGMON_PC  + 13'h4: prdata_t = pc[63:32];
        `DBGMON_X1  + 13'h0: prdata_t = gpr[1 ][31: 0];
        `DBGMON_X1  + 13'h4: prdata_t = gpr[1 ][63:32];
        `DBGMON_X2  + 13'h0: prdata_t = gpr[2 ][31: 0];
        `DBGMON_X2  + 13'h4: prdata_t = gpr[2 ][63:32];
        `DBGMON_X3  + 13'h0: prdata_t = gpr[3 ][31: 0];
        `DBGMON_X3  + 13'h4: prdata_t = gpr[3 ][63:32];
        `DBGMON_X4  + 13'h0: prdata_t = gpr[4 ][31: 0];
        `DBGMON_X4  + 13'h4: prdata_t = gpr[4 ][63:32];
        `DBGMON_X5  + 13'h0: prdata_t = gpr[5 ][31: 0];
        `DBGMON_X5  + 13'h4: prdata_t = gpr[5 ][63:32];
        `DBGMON_X6  + 13'h0: prdata_t = gpr[6 ][31: 0];
        `DBGMON_X6  + 13'h4: prdata_t = gpr[6 ][63:32];
        `DBGMON_X7  + 13'h0: prdata_t = gpr[7 ][31: 0];
        `DBGMON_X7  + 13'h4: prdata_t = gpr[7 ][63:32];
        `DBGMON_X8  + 13'h0: prdata_t = gpr[8 ][31: 0];
        `DBGMON_X8  + 13'h4: prdata_t = gpr[8 ][63:32];
        `DBGMON_X9  + 13'h0: prdata_t = gpr[9 ][31: 0];
        `DBGMON_X9  + 13'h4: prdata_t = gpr[9 ][63:32];
        `DBGMON_X10 + 13'h0: prdata_t = gpr[10][31: 0];
        `DBGMON_X10 + 13'h4: prdata_t = gpr[10][63:32];
        `DBGMON_X11 + 13'h0: prdata_t = gpr[11][31: 0];
        `DBGMON_X11 + 13'h4: prdata_t = gpr[11][63:32];
        `DBGMON_X12 + 13'h0: prdata_t = gpr[12][31: 0];
        `DBGMON_X12 + 13'h4: prdata_t = gpr[12][63:32];
        `DBGMON_X13 + 13'h0: prdata_t = gpr[13][31: 0];
        `DBGMON_X13 + 13'h4: prdata_t = gpr[13][63:32];
        `DBGMON_X14 + 13'h0: prdata_t = gpr[14][31: 0];
        `DBGMON_X14 + 13'h4: prdata_t = gpr[14][63:32];
        `DBGMON_X15 + 13'h0: prdata_t = gpr[15][31: 0];
        `DBGMON_X15 + 13'h4: prdata_t = gpr[15][63:32];
        `DBGMON_X16 + 13'h0: prdata_t = gpr[16][31: 0];
        `DBGMON_X16 + 13'h4: prdata_t = gpr[16][63:32];
        `DBGMON_X17 + 13'h0: prdata_t = gpr[17][31: 0];
        `DBGMON_X17 + 13'h4: prdata_t = gpr[17][63:32];
        `DBGMON_X18 + 13'h0: prdata_t = gpr[18][31: 0];
        `DBGMON_X18 + 13'h4: prdata_t = gpr[18][63:32];
        `DBGMON_X19 + 13'h0: prdata_t = gpr[19][31: 0];
        `DBGMON_X19 + 13'h4: prdata_t = gpr[19][63:32];
        `DBGMON_X20 + 13'h0: prdata_t = gpr[20][31: 0];
        `DBGMON_X20 + 13'h4: prdata_t = gpr[20][63:32];
        `DBGMON_X21 + 13'h0: prdata_t = gpr[21][31: 0];
        `DBGMON_X21 + 13'h4: prdata_t = gpr[21][63:32];
        `DBGMON_X22 + 13'h0: prdata_t = gpr[22][31: 0];
        `DBGMON_X22 + 13'h4: prdata_t = gpr[22][63:32];
        `DBGMON_X23 + 13'h0: prdata_t = gpr[23][31: 0];
        `DBGMON_X23 + 13'h4: prdata_t = gpr[23][63:32];
        `DBGMON_X24 + 13'h0: prdata_t = gpr[24][31: 0];
        `DBGMON_X24 + 13'h4: prdata_t = gpr[24][63:32];
        `DBGMON_X25 + 13'h0: prdata_t = gpr[25][31: 0];
        `DBGMON_X25 + 13'h4: prdata_t = gpr[25][63:32];
        `DBGMON_X26 + 13'h0: prdata_t = gpr[26][31: 0];
        `DBGMON_X26 + 13'h4: prdata_t = gpr[26][63:32];
        `DBGMON_X27 + 13'h0: prdata_t = gpr[27][31: 0];
        `DBGMON_X27 + 13'h4: prdata_t = gpr[27][63:32];
        `DBGMON_X28 + 13'h0: prdata_t = gpr[28][31: 0];
        `DBGMON_X28 + 13'h4: prdata_t = gpr[28][63:32];
        `DBGMON_X29 + 13'h0: prdata_t = gpr[29][31: 0];
        `DBGMON_X29 + 13'h4: prdata_t = gpr[29][63:32];
        `DBGMON_X30 + 13'h0: prdata_t = gpr[30][31: 0];
        `DBGMON_X30 + 13'h4: prdata_t = gpr[30][63:32];
        `DBGMON_X31 + 13'h0: prdata_t = gpr[31][31: 0];
        `DBGMON_X31 + 13'h4: prdata_t = gpr[31][63:32];
        `DBGMON_BP  + 13'h0: prdata_t = breakpoint[31: 0];
        `DBGMON_BP  + 13'h4: prdata_t = breakpoint[63:32];
    endcase
end

always_ff @(posedge clk or negedge rstn) begin: reg_prdata
    if (~rstn) prdata_t_latch <= 32'b0;
    else       prdata_t_latch <= prdata_t;
end

assign apb_intf.pslverr = 1'b0;
assign apb_intf.pready  = 1'b1;
assign apb_intf.prdata  = ~apb_intf.paddr[12] ? prdata_trace : prdata_t_latch;


endmodule
