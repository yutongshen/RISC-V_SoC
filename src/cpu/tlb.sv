`include "tlb_define.h"

module tlb (
    input                             clk,
    input                             rstn,

    input                             cs,
    input        [`TLB_VPN_WIDTH-1:0] vpn,
    input                             we,
    input        [`TLB_PTE_WIDTH-1:0] pte_in,
    output logic                      pte_hit,
    output logic [`TLB_PTE_WIDTH-1:0] pte_out
    
);

logic [      `TLB_IDX_WIDTH-1:0] idx;
logic [          `TLB_DEPTH-1:0] valid [`TLB_WAY_NUM];
logic [$clog2(`TLB_WAY_NUM)-1:0] order [`TLB_WAY_NUM][`TLB_DEPTH];
logic [$clog2(`TLB_WAY_NUM)-1:0] victim_order;
logic [        `TLB_WAY_NUM-1:0] hit;
logic [      `TLB_TAG_WIDTH-1:0] tag;
logic [      `TLB_TAG_WIDTH-1:0] tag_latch;
logic [        `TLB_WAY_NUM-1:0] victim;
logic [      `TLB_PTE_WIDTH-1:0] pte_out_arr [`TLB_WAY_NUM]

assign pte_hit = |hit;

assign idx     = vpn[`TLB_IDX_WIDTH-1:0];
assign tag     = vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH];

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) tag_latch <= {`TLB_TAG_WIDTH{1'b0}};
    else       tag_latch <= tag;
end

always_comb begin
    integer i;

    victim_order = {$clog2(`TLB_WAY_NUM)(1'b0)};
    for (i = 0; i < `TLB_WAY_NUM; i = i + 1) begin
        victim_order = victim_order | {$clog2(`TLB_WAY_NUM){victim[g]}} & order[i][idx];
    end
end

always_comb begin
    integer i;

    pte_out = `TLB_PTE_WIDTH'b0;
    for (i = 0; i < `TLB_WAY_NUM; i = i + 1) begin
        pte_out = pte_out | ({`TLB_PTE_WIDTH{hit[i]}} & pte_out_arr[i]);
    end
end

genvar g;
generate
    for (g = 0; g < `TLB_WAY_NUM; g = g + 1) begin: g_tlb_array
        logic                            valid_latch;
        logic [      `TLB_TAG_WIDTH-1:0] tag_out;

        parameter [$clog2(`TLB_WAY_NUM)-1:0] DEFAULT_ORDER = {$clog2(`TLB_WAY_NUM){1'b0}} - {{($clog2(`TLB_WAY_NUM)-1){1'b0}}, 1'b1};

        always_ff @(posedge clk or negedge rstn) begin
            integer i;
            if (~rstn) begin
                for (i = 0; i < `TLB_DEPTH; i = i + 1) begin
                    valid[g][i] <= 1'b0;
                    order[g][i] <= g;
                end
            end
            else if (cs && we) begin
                if (victim[g]) begin
                    valid[g][idx] <= 1'b1;
                    order[g][idx] <= DEFAULT_ORDER;
                end
                else if (order[g][idx] > victim_order) begin
                    order[g][idx] <= order[g][idx] - {{($clog2(`TLB_WAY_NUM)-1){1'b0}}, 1'b1};
                end
            end
        end

        always_ff @(posedge clk or negedge rstn) begin
            if (~rstn) valid_latch <= 1'b0;
            else       valid_latch <= valid[g][idx];
        end

        assign victim[g] = cs && we && ~|(order[g][idx]);
        assign hit[g]    = valid_latch && tag_out == tag_latch;

        sram32x31 u_tag_array (
            .CK ( clk            ),
            .CS ( cs             ),
            .WE ( we & victim[g] ),
            .A  ( idx            ),
            .DI ( tag            ),
            .DO ( tag_out        )
        );

        sram32x64 u_pte_array (
            .CK ( clk            ),
            .CS ( cs             ),
            .WE ( we & victim[g] ),
            .A  ( idx            ),
            .DI ( pte_in         ),
            .DO ( pte_out_arr[g] )
        );
    end
endgenerate


module
