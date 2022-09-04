`include "tlb_define.h"

module tlb (
    input                               clk,
    input                               rstn,

`ifndef RV32
    input        [`SATP_MODE_WIDTH-1:0] satp_mode,
`endif
    input                               cs,
    input        [  `TLB_VPN_WIDTH-1:0] vpn,
    input                               we,
    output logic                        pte_hit,
    input        [                 2:0] spage_in,
    input        [  `TLB_PTE_WIDTH-1:0] pte_in,
    output logic [                 2:0] spage_out,
    output logic [  `TLB_PTE_WIDTH-1:0] pte_out,
    
    input                               tlb_flush_req,
    input                               tlb_flush_all_vaddr,
    input                               tlb_flush_all_asid,
    input        [         `XLEN - 1:0] tlb_flush_vaddr,
    input        [         `XLEN - 1:0] tlb_flush_asid,

    output       [`TLB_IDX_WIDTH - 1:0] idx
);

// logic [      `TLB_IDX_WIDTH-1:0] idx;
logic [          `TLB_DEPTH-1:0] valid   [`TLB_WAY_NUM];
logic [                     2:0] spg_bit [`TLB_WAY_NUM][`TLB_DEPTH];
logic [$clog2(`TLB_WAY_NUM)-1:0] order   [`TLB_WAY_NUM][`TLB_DEPTH];
logic [$clog2(`TLB_WAY_NUM)-1:0] victim_order;
logic [$clog2(`TLB_WAY_NUM)-1:0] hit_order;
logic [        `TLB_WAY_NUM-1:0] hit;
logic [      `TLB_TAG_WIDTH-1:0] tag_in;
logic [      `TLB_TAG_WIDTH-1:0] tag_latch;
logic                            cs_latch;
logic [                    26:0] vpn0_latch;
logic [                     2:0] spg_latch   [`TLB_WAY_NUM];
logic [        `TLB_WAY_NUM-1:0] victim;
logic [      `TLB_PTE_WIDTH-1:0] pte_out_arr [`TLB_WAY_NUM];

assign pte_hit   = |hit;
always_comb begin
    integer i;
    spage_out = 3'b0;
    for (i = 0; i < `TLB_WAY_NUM; i = i + 1) begin
        spage_out = spage_out | ({3{hit[i]}} & spg_latch[i]);
    end
end

`ifdef RV32
assign idx     = vpn[10+:`TLB_IDX_WIDTH];
assign tag_in  = {vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH+10], vpn[0+:10] & {10{~spage_in[0]}}};
`else
assign idx     = ({`TLB_IDX_WIDTH{satp_mode == `SATP_MODE_SV32}} & vpn[10+:`TLB_IDX_WIDTH])|
                 ({`TLB_IDX_WIDTH{satp_mode == `SATP_MODE_SV39}} & vpn[18+:`TLB_IDX_WIDTH])|
                 ({`TLB_IDX_WIDTH{satp_mode == `SATP_MODE_SV48}} & vpn[27+:`TLB_IDX_WIDTH]);
assign tag_in  = ({`TLB_TAG_WIDTH{satp_mode == `SATP_MODE_SV32}} & {vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH+10], vpn[0+10] & {10{~spage_in[0]}}})|
                 ({`TLB_TAG_WIDTH{satp_mode == `SATP_MODE_SV39}} & {vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH+18],
                                                                    vpn[ 9+:9] & {9{~spage_in[1]}},
                                                                    vpn[ 0+:9] & {9{~spage_in[0]}}})|
                 ({`TLB_TAG_WIDTH{satp_mode == `SATP_MODE_SV48}} & {vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH+27],
                                                                    vpn[18+:9] & {9{~spage_in[2]}},
                                                                    vpn[ 9+:9] & {9{~spage_in[1]}},
                                                                    vpn[ 0+:9] & {9{~spage_in[0]}}});
`endif

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) tag_latch <= {`TLB_TAG_WIDTH{1'b0}};
    else       tag_latch <=
`ifdef RV32
                            {vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH+10], vpn[9:0]};
`else
                            ({`TLB_TAG_WIDTH{satp_mode == `SATP_MODE_SV32}} & {vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH+10], vpn[ 9:0]})|
                            ({`TLB_TAG_WIDTH{satp_mode == `SATP_MODE_SV39}} & {vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH+18], vpn[17:0]})|
                            ({`TLB_TAG_WIDTH{satp_mode == `SATP_MODE_SV48}} & {vpn[`TLB_VPN_WIDTH-1:`TLB_IDX_WIDTH+27], vpn[26:0]});
`endif
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) cs_latch <= 1'b0;
    else       cs_latch <= cs && ~we;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) vpn0_latch <= 27'b0;
    else       vpn0_latch <= vpn[26:0];
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

    pte_out = `TLB_PTE_WIDTH'b0;
    for (i = 0; i < `TLB_WAY_NUM; i = i + 1) begin
        pte_out = pte_out | ({`TLB_PTE_WIDTH{hit[i]}} & pte_out_arr[i])
`ifdef RV32
                          | {{`TLB_PTE_WIDTH-10-10{1'b0}}, vpn0_latch[0+:10] & {10{|(hit[i] & spg_latch[i][0])}}, 10'b0};
`else
                          | ({`TLB_PTE_WIDTH{~satp_mode[3]}} &
                             {{`TLB_PTE_WIDTH-10-10{1'b0}}, vpn0_latch[0+:10] & {10{|(hit[i] & spg_latch[i][0])}}, 10'b0})
                          | ({`TLB_PTE_WIDTH{ satp_mode[3]}} &
                             {{`TLB_PTE_WIDTH-10-27{1'b0}},
                               vpn0_latch[18+:9] & {9{|(hit[i] & spg_latch[i][2])}},
                               vpn0_latch[ 9+:9] & {9{|(hit[i] & spg_latch[i][1])}},
                               vpn0_latch[ 0+:9] & {9{|(hit[i] & spg_latch[i][0])}}, 10'b0});
`endif
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
                    spg_bit[g][i] <= 3'b0;
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
                    spg_bit[g][idx] <= spage_in;
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
            if (~rstn) spg_latch[g] <= 3'b0;
            else       spg_latch[g] <= spg_bit[g][idx];
        end

        assign victim[g] = cs && we && ~|(order[g][idx]);
        assign hit[g]    = valid_latch &&
                           tag_out ==
`ifdef RV32
                           {tag_latch[`TLB_TAG_WIDTH-1:10], tag_latch[0+:10] & {10{~spg_latch[g][0]}}};
`else
                           (({`TLB_PTE_WIDTH{~satp_mode[3]}} &
                             {tag_latch[`TLB_TAG_WIDTH-1:10], tag_latch[0+:10] & {10{~spg_latch[g][0]}}})|
                            ({`TLB_PTE_WIDTH{ satp_mode[3]}} &
                             {tag_latch[`TLB_TAG_WIDTH-1:27],
                              tag_latch[18+:9] & {9{~spg_latch[g][2]}},
                              tag_latch[ 9+:9] & {9{~spg_latch[g][1]}},
                              tag_latch[ 0+:9] & {9{~spg_latch[g][0]}}}));
`endif

        // sram32x31 u_tag_array (
        //     .CK ( clk                               ),
        //     .CS ( cs                                ),
        //     .WE ( we & victim[g]                    ),
        //     .A  ( {{(5-`TLB_IDX_WIDTH){1'b0}}, idx} ),
        //     .DI ( tag_in                            ),
        //     .DO ( tag_out                           )
        // );

        // sram32x64 u_pte_array (
        //     .CK ( clk                               ),
        //     .CS ( cs                                ),
        //     .WE ( we & victim[g]                    ),
        //     .A  ( {{(5-`TLB_IDX_WIDTH){1'b0}}, idx} ),
        //     .DI ( pte_in                            ),
        //     .DO ( pte_out_arr[g]                    )
        // );

        logic [`TLB_TAG_WIDTH-1:0] tag_array [`TLB_DEPTH];
        logic [`TLB_PTE_WIDTH-1:0] pte_array [`TLB_DEPTH];

        always_ff @(posedge clk or negedge rstn) begin
            integer i;
            if (~rstn)
                for (i = 0; i < `TLB_DEPTH; i = i + 1)
                    tag_array[i] <= {`TLB_TAG_WIDTH{1'b0}};
            else if (cs & we & victim[g])
                tag_array[idx] <= tag_in;
        end

        always_ff @(posedge clk or negedge rstn) begin
            if (~rstn) tag_out <= {`TLB_TAG_WIDTH{1'b0}};
            else       tag_out <= tag_array[idx];
        end

        always_ff @(posedge clk or negedge rstn) begin
            integer i;
            if (~rstn)
                for (i = 0; i < `TLB_DEPTH; i = i + 1)
                    pte_array[i] <= {`TLB_PTE_WIDTH{1'b0}};
            else if (cs & we & victim[g])
                pte_array[idx] <= pte_in;
        end

        always_ff @(posedge clk or negedge rstn) begin
            if (~rstn) pte_out_arr[g] <= {`TLB_PTE_WIDTH{1'b0}};
            else       pte_out_arr[g] <= pte_array[idx];
        end


    end
endgenerate

endmodule
