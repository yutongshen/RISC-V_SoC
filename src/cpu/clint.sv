`define CPU_NUM 1
`define CLINT_MSIP    16'h0000
`define CLINT_TIMECMP 16'h4000
`define CLINT_TIME    16'hbff8

module clint (
    input                        clk,
    input                        rstn,
    input                        psel,
    input                        penable,
    input        [        31: 0] paddr,
    input                        pwrite,
    input        [         3: 0] pstrb,
    input        [        31: 0] pwdata,
    output logic [        31: 0] prdata,
    output logic                 pslverr,
    output logic                 pready,

    output logic [`CPU_NUM-1: 0] msip,
    output logic [`CPU_NUM-1: 0] mtip
);

logic [31:0] prdata_msip;
logic [31:0] prdata_timecmp;
logic [31:0] prdata_time;
logic [31:0] prdata_t;
logic [63:0] mtimecmp [`CPU_NUM];
logic [63:0] mtime;

genvar g;
generate
    for (g = 0; g < `CPU_NUM; g = g + 1) begin: g_msip_reg
        always_ff @(posedge clk or negedge rstn) begin
            if (~rstn) begin
                msip[g] <= 1'b0;
            end
            else if (penable & psel && paddr[15:0] == `CLINT_MSIP + 16'h4 * g[15:0]) begin
                msip[g] <= pwdata[0];
            end
        end
        always_ff @(posedge clk or negedge rstn) begin
            if (~rstn) begin
                mtimecmp[g] <= 64'b0;
            end
            else if (penable & psel && paddr[15:0] == `CLINT_TIMECMP + 16'h8 * g[15:0]) begin
                mtimecmp[g][31:0] <= pwdata;
            end
            else if (penable & psel && paddr[15:0] == `CLINT_TIMECMP + 16'h8 * g[15:0] + 16'h4) begin
                mtimecmp[g][63:32] <= pwdata;
            end
        end
        always_ff @(posedge clk or negedge rstn) begin
            if (~rstn) begin
                mtip[g] <= 1'b0;
            end
            else begin
                mtip[g] <= mtime >= mtimecmp[g];
            end
        end
    end
endgenerate

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        mtime <= 64'b0;
    end
    else if (penable & psel && paddr[15:0] == `CLINT_TIME) begin
        mtime[31:0] <= pwdata;
    end
    else if (penable & psel && paddr[15:0] == `CLINT_TIME + 16'h4) begin
        mtime[63:32] <= pwdata;
    end
    else begin
        mtime <= mtime + 64'b1;
    end
end

always_comb begin
    integer i;
    prdata_msip = 32'b0;
    for (i = 0; i < `CPU_NUM; i = i + 1) begin
        prdata_msip = prdata_msip | {31'b0, msip[i] & (paddr[7:2] == i[5:0])};
    end
    prdata_msip = prdata_msip & {32{paddr[15:12] == 4'h0}};
end

always_comb begin
    integer i;
    prdata_timecmp = 32'b0;
    for (i = 0; i < `CPU_NUM; i = i + 1) begin
        prdata_timecmp = prdata_timecmp |
                         (mtimecmp[i][31: 0] & {32{paddr[8:3] == i[5:0] && !paddr[2]}})|
                         (mtimecmp[i][63:32] & {32{paddr[8:3] == i[5:0] &&  paddr[2]}});
    end
    prdata_timecmp = prdata_timecmp & {32{paddr[15:12] == 4'h4}};
end

assign prdata_time = (mtime[31: 0] & {32{paddr[15:0] == `CLINT_TIME}})|
                     (mtime[63:32] & {32{paddr[15:0] == `CLINT_TIME + 16'h4}});

assign prdata_t = prdata_msip | prdata_timecmp | prdata_time;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        prdata <= 32'b0;
    end
    else begin
        prdata <= prdata_t;
    end
end

assign pslverr = 1'b0;
assign pready  = 1'b1;


endmodule
