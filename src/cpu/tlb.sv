`include "tlb_define.h"

module tlb (
    input                             clk,
    input                             rstn,

    input                             cs,
    input        [`TLB_VPN_WIDTH-1:0] vpn,
    input                             we,
    input                             spage,
    output logic                      pte_hit,
    input        [`TLB_PTE_WIDTH-1:0] pte_in,
    input                             pmp_v_in,
    input                             pmp_l_in,
    input                             pmp_x_in,
    input                             pmp_w_in,
    input                             pmp_r_in,
    output logic [`TLB_PTE_WIDTH-1:0] pte_out,
    output logic                      pmp_v_out,
    output logic                      pmp_l_out,
    output logic                      pmp_x_out,
    output logic                      pmp_w_out,
    output logic                      pmp_r_out,
    
    input                             tlb_flush_req,
    input                             tlb_flush_all_vaddr,
    input                             tlb_flush_all_asid,
    input        [       `XLEN - 1:0] tlb_flush_vaddr,
    input        [       `XLEN - 1:0] tlb_flush_asid

);

logic [      `TLB_IDX_WIDTH-1:0] idx;
logic [          `TLB_DEPTH-1:0] valid [`TLB_WAY_NUM];
logic [          `TLB_DEPTH-1:0] spg_bit [`TLB_WAY_NUM];
logic [$clog2(`TLB_WAY_NUM)-1:0] order [`TLB_WAY_NUM][`TLB_DEPTH];
logic [$clog2(`TLB_WAY_NUM)-1:0] victim_order;
logic [$clog2(`TLB_WAY_NUM)-1:0] hit_order;
logic [        `TLB_WAY_NUM-1:0] hit;
logic [      `TLB_TAG_WIDTH-1:0] tag;
logic [      `TLB_TAG_WIDTH-1:0] tag_latch;
logic                            cs_latch;
logic [                     9:0] vpn0_latch;
logic [        `TLB_WAY_NUM-1:0] spg_latch;
logic [        `TLB_WAY_NUM-1:0] victim;
logic [      `TLB_PTE_WIDTH-1:0] pte_out_arr [`TLB_WAY_NUM];

assign pte_hit = |hit;

assign idx     = vpn[10+:`TLB_IDX_WIDTH];
assign tag     = {vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH+10], vpn[9:0] & {10{~spage}}};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) tag_latch <= {`TLB_TAG_WIDTH{1'b0}};
    else       tag_latch <= tag;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cs_latch <= 1'b0;
    else       cs_latch <= cs && ~we;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) vpn0_latch <= 10'b0;
    else       vpn0_latch <= vpn[9:0];
end

always_comb begin
    integer i;

    victim_order = {$clog2(`TLB_WAY_NUM){1'b0}};
    for (i = 0; i < `TLB_WAY_NUM; i = i + 1) begin
        victim_order = victim_order | {$clog2(`TLB_WAY_NUM){victim[i]}} & order[i][idx];
    end

    hit_order    = {$clog2(`TLB_WAY_NUM){1'b0}};
    for (i = 0; i < `TLB_WAY_NUM; i = i + 1) begin
        hit_order    = hit_order    | {$clog2(`TLB_WAY_NUM){hit[i]}}    & order[i][idx];
    end
end

always_comb begin
    integer i;

    // pte_out = `TLB_PTE_WIDTH'b0;
    pte_out = {{`TLB_PTE_WIDTH-10-10{1'b0}}, vpn0_latch & {10{|(hit & spg_latch)}}, 10'b0};
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
                    valid[g][i]   <= 1'b0;
                    spg_bit[g][i] <= 1'b0;
                    order[g][i]   <= g[$clog2(`TLB_WAY_NUM)-1:0];
                end
            end
            else if (tlb_flush_req) begin
                for (i = 0; i < `TLB_DEPTH; i = i + 1) begin
                    valid[g][i]   <= 1'b0;
                    order[g][i]   <= g[$clog2(`TLB_WAY_NUM)-1:0];
                end
            end
            else if (cs && we) begin
                if (victim[g]) begin
                    valid[g][idx]   <= 1'b1;
                    spg_bit[g][idx] <= spage;
                    order[g][idx]   <= DEFAULT_ORDER;
                end
                else if (order[g][idx] > victim_order) begin
                    order[g][idx] <= order[g][idx] - {{($clog2(`TLB_WAY_NUM)-1){1'b0}}, 1'b1};
                end
            end
            else if (cs_latch && pte_hit) begin
                if (hit[g]) begin
                    order[g][idx] <= DEFAULT_ORDER;
                end
                else if (order[g][idx] > hit_order) begin
                    order[g][idx] <= order[g][idx] - {{($clog2(`TLB_WAY_NUM)-1){1'b0}}, 1'b1};
                end
            end
        end

        always_ff @(posedge clk or negedge rstn) begin
            if (~rstn) valid_latch <= 1'b0;
            else       valid_latch <= valid[g][idx] && ~tlb_flush_req;
        end

        always_ff @(posedge clk or negedge rstn) begin
            if (~rstn) spg_latch[g] <= 1'b0;
            else       spg_latch[g] <= spg_bit[g][idx];
        end

        assign victim[g] = cs && we && ~|(order[g][idx]);
        assign hit[g]    = valid_latch &&
                           tag_out == {tag_latch[`TLB_TAG_WIDTH-1:10], tag_latch[9:0] & {10{~spg_latch[g]}}};

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

assign pmp_v_out = 1'b1;
assign pmp_l_out = 1'b0;
assign pmp_x_out = 1'b1;
assign pmp_w_out = 1'b1;
assign pmp_r_out = 1'b1;

endmodule
