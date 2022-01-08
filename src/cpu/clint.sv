`include "soc_define.h"
`include "clint_mmap.h"

module clint (
    input                        clk,
    input                        rstn,
    apb_intf.slave               apb_intf,

    input        [        63: 0] systime,
    output logic [`CPU_NUM-1: 0] msip,
    output logic [`CPU_NUM-1: 0] mtip
);

logic        apb_wr;
logic [31:0] prdata_msip;
logic [31:0] prdata_timecmp;
logic [31:0] prdata_time;
logic [31:0] prdata_t;
logic [63:0] mtimecmp [`CPU_NUM];
logic [63:0] mtime;


always_comb begin: comb_apb_wr
    apb_wr = ~apb_intf.penable && apb_intf.psel && apb_intf.pwrite;
end

genvar g;
generate
    for (g = 0; g < `CPU_NUM; g = g + 1) begin: g_apb_reg
        always_ff @(posedge clk or negedge rstn) begin: reg_msip
            if (~rstn) begin
                msip[g] <= 1'b0;
            end
            else if (apb_wr && apb_intf.paddr[15:0] == `CLINT_MSIP + 16'h4 * g[15:0]) begin
                msip[g] <= apb_intf.pwdata[0];
            end
        end

        always_ff @(posedge clk or negedge rstn) begin: reg_mtimecmp
            if (~rstn) begin
                mtimecmp[g] <= 64'b0;
            end
            else if (apb_wr && apb_intf.paddr[15:0] == `CLINT_TIMECMP + 16'h8 * g[15:0]) begin
                mtimecmp[g][31:0] <= apb_intf.pwdata;
            end
            else if (apb_wr && apb_intf.paddr[15:0] == `CLINT_TIMECMP + 16'h8 * g[15:0] + 16'h4) begin
                mtimecmp[g][63:32] <= apb_intf.pwdata;
            end
        end
        
        always_ff @(posedge clk or negedge rstn) begin: reg_mtip
            if (~rstn) begin
                mtip[g] <= 1'b0;
            end
            else begin
                mtip[g] <= mtime >= mtimecmp[g];
            end
        end
    end
endgenerate

always_comb begin: comb_mtime
    mtime  = systime;
end

always_comb begin: comb_prdata_msip
    integer i;
    prdata_msip = 32'b0;
    for (i = 0; i < `CPU_NUM; i = i + 1) begin
        prdata_msip = prdata_msip | {31'b0, msip[i] & (apb_intf.paddr[7:2] == i[5:0])};
    end
    prdata_msip = prdata_msip & {32{apb_intf.paddr[15:12] == 4'h0}};
end

always_comb begin: comb_prdata_timecmp
    integer i;
    prdata_timecmp = 32'b0;
    for (i = 0; i < `CPU_NUM; i = i + 1) begin
        prdata_timecmp = prdata_timecmp |
                         (mtimecmp[i][31: 0] & {32{apb_intf.paddr[8:3] == i[5:0] && !apb_intf.paddr[2]}})|
                         (mtimecmp[i][63:32] & {32{apb_intf.paddr[8:3] == i[5:0] &&  apb_intf.paddr[2]}});
    end
    prdata_timecmp = prdata_timecmp & {32{apb_intf.paddr[15:12] == 4'h4}};
end


always_comb begin: comb_prdata_time
    prdata_time = (mtime[31: 0] & {32{apb_intf.paddr[15:0] == `CLINT_TIME}})|
                  (mtime[63:32] & {32{apb_intf.paddr[15:0] == `CLINT_TIME + 16'h4}});
end

assign prdata_t = prdata_msip | prdata_timecmp | prdata_time;

always_ff @(posedge clk or negedge rstn) begin: reg_prdata
    if (~rstn) begin
        apb_intf.prdata <= 32'b0;
    end
    else begin
        apb_intf.prdata <= prdata_t;
    end
end

assign apb_intf.pslverr = 1'b0;
assign apb_intf.pready  = 1'b1;


endmodule
