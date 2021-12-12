`include "soc_define.h"
`include "plic_mmap.h"

module plic (
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

    output logic [`CPU_NUM-1: 0] meip,
    input        [`INT_NUM-1: 0] ints
);

logic [        31:0] claim_id    [`CPU_NUM];
logic [        31:0] cmplet_id   [`CPU_NUM];

logic [`INT_NUM-1:1] claim;
logic [`INT_NUM-1:1] cmplet;

logic [`INT_NUM-1:0] int_pend;
logic [`INT_NUM-1:0] int_type;
logic [`INT_NUM-1:0] int_pol;
logic [        31:0] int_prior   [`INT_NUM];
logic [`INT_NUM-1:0] int_en      [`CPU_NUM];
logic [        31:0] int_id      [`CPU_NUM];
logic [        31:0] threshold   [`CPU_NUM];

logic [        31:0] int_id_tmp  [`CPU_NUM];
logic [        31:0] int_max_pri [`CPU_NUM];

logic                apb_wr;

logic [        31:0] prdata_t;
logic [        31:0] prdata_pri;
logic [        31:0] prdata_ip;
logic [        31:0] prdata_ityp;
logic [        31:0] prdata_ipol;
logic [        31:0] prdata_ie;
logic [        31:0] prdata_id;
logic [        31:0] prdata_th;

`define CMP_TREE_L0_NUM  (`INT_NUM)                                  // MAX: 1024
`define CMP_TREE_L1_NUM  (`CMP_TREE_L0_NUM/2 + `CMP_TREE_L0_NUM%2)   // MAX:  512
`define CMP_TREE_L2_NUM  (`CMP_TREE_L1_NUM/2 + `CMP_TREE_L1_NUM%2)   // MAX:  256
`define CMP_TREE_L3_NUM  (`CMP_TREE_L2_NUM/2 + `CMP_TREE_L2_NUM%2)   // MAX:  128
`define CMP_TREE_L4_NUM  (`CMP_TREE_L3_NUM/2 + `CMP_TREE_L3_NUM%2)   // MAX:   64
`define CMP_TREE_L5_NUM  (`CMP_TREE_L4_NUM/2 + `CMP_TREE_L4_NUM%2)   // MAX:   32
`define CMP_TREE_L6_NUM  (`CMP_TREE_L5_NUM/2 + `CMP_TREE_L5_NUM%2)   // MAX:   16
`define CMP_TREE_L7_NUM  (`CMP_TREE_L6_NUM/2 + `CMP_TREE_L6_NUM%2)   // MAX:    8
`define CMP_TREE_L8_NUM  (`CMP_TREE_L7_NUM/2 + `CMP_TREE_L7_NUM%2)   // MAX:    4
`define CMP_TREE_L9_NUM  (`CMP_TREE_L8_NUM/2 + `CMP_TREE_L8_NUM%2)   // MAX:    2
`define CMP_TREE_L10_NUM (`CMP_TREE_L9_NUM/2 + `CMP_TREE_L9_NUM%2)   // MAX:    1

parameter int CMP_TREE_NUM [0:10] = {
    `CMP_TREE_L0_NUM, 
    `CMP_TREE_L1_NUM, 
    `CMP_TREE_L2_NUM, 
    `CMP_TREE_L3_NUM, 
    `CMP_TREE_L4_NUM, 
    `CMP_TREE_L5_NUM, 
    `CMP_TREE_L6_NUM, 
    `CMP_TREE_L7_NUM, 
    `CMP_TREE_L8_NUM, 
    `CMP_TREE_L9_NUM, 
    `CMP_TREE_L10_NUM
};

genvar gvar_i;
genvar gvar_j;
genvar gvar_k;
generate
    for (gvar_i = 1; gvar_i < `INT_NUM; gvar_i = gvar_i + 1) begin: g_gateway

        always_comb begin
            integer i;
            claim [gvar_i] = 1'b0;
            cmplet[gvar_i] = 1'b0;
            for (i = 0; i < `CPU_NUM; i = i + 1) begin
                claim [gvar_i] = claim [gvar_i] | (claim_id [i][0+:$clog2(`INT_NUM)] == gvar_i[0+:$clog2(`INT_NUM)]);
                cmplet[gvar_i] = cmplet[gvar_i] | (cmplet_id[i][0+:$clog2(`INT_NUM)] == gvar_i[0+:$clog2(`INT_NUM)]);
            end
        end

        gateway u_gateway(
            .clk      ( clk              ),
            .rstn     ( rstn             ),
            .src      ( ints    [gvar_i] ),
            .src_type ( int_type[gvar_i] ), // 0: edge, 1: level
            .src_pol  ( int_pol [gvar_i] ), // 0: high, 1: low
            .claim    ( claim   [gvar_i] ),
            .cmplet   ( cmplet  [gvar_i] ),
            .pend     ( int_pend[gvar_i] )
        );
    end

    assign int_pend[0] = 1'b0;

    for (gvar_i = 0; gvar_i < `CPU_NUM; gvar_i = gvar_i + 1) begin: g_target
        logic [`INT_NUM-1:0] ip_ie_ints;
        logic [        31:0] en_ints_pri [11][`CMP_TREE_L0_NUM];
        logic [         9:0] id_sel      [11][`CMP_TREE_L0_NUM];
        
        assign ip_ie_ints = int_pend & int_en[gvar_i];

        always_comb begin
            integer i;
            for (i = 0; i < `INT_NUM; i = i + 1) begin
                en_ints_pri[0][i] = {32{ip_ie_ints[i]}} & int_prior[i];
            end
        end

        for (gvar_j = 0; gvar_j < 10; gvar_j = gvar_j + 1) begin: g_cmp_tree_lvl
            if (gvar_j % 3 == 2) begin: g_pipelining
                for (gvar_k = 0; gvar_k <= CMP_TREE_NUM[gvar_j] - 1; gvar_k = gvar_k + 2) begin: g_cmp
                    if (gvar_k == CMP_TREE_NUM[gvar_j] - 1) begin: g_remainder
                        always_ff @(posedge clk or negedge rstn) begin
                            if (~rstn) begin
                                en_ints_pri[gvar_j+1][gvar_k>>1]     <= 32'b0;
                                id_sel[gvar_j+1][gvar_k>>1][gvar_j]  <= 1'b0;
                            end
                            else begin
                                en_ints_pri[gvar_j+1][gvar_k>>1]     <= en_ints_pri[gvar_j][gvar_k];
                                id_sel[gvar_j+1][gvar_k>>1][gvar_j]  <= 1'b0;
                            end
                        end
                        if (gvar_j > 0) begin: g_non_first
                            always_ff @(posedge clk or negedge rstn) begin
                                if (~rstn) begin
                                    id_sel[gvar_j+1][gvar_k>>1][0+:gvar_j] <= {gvar_j{1'b0}};
                                end
                                else begin
                                    id_sel[gvar_j+1][gvar_k>>1][0+:gvar_j] <= id_sel[gvar_j][gvar_k][0+:gvar_j];
                                end
                            end
                        end
                    end
                    else begin: g_cmp
                        always_ff @(posedge clk or negedge rstn) begin
                            if (~rstn) begin
                                en_ints_pri[gvar_j+1][gvar_k>>1]     <= 32'b0;
                                id_sel[gvar_j+1][gvar_k>>1][gvar_j]  <= 1'b0;
                            end
                            else begin
                                if (en_ints_pri[gvar_j][gvar_k] < en_ints_pri[gvar_j][gvar_k + 1]) begin
                                    en_ints_pri[gvar_j+1][gvar_k>>1]     <= en_ints_pri[gvar_j][gvar_k + 1];
                                    id_sel[gvar_j+1][gvar_k>>1][gvar_j]  <= 1'b1;
                                end
                                else begin
                                    en_ints_pri[gvar_j+1][gvar_k>>1]     <= en_ints_pri[gvar_j][gvar_k];
                                    id_sel[gvar_j+1][gvar_k>>1][gvar_j]  <= 1'b0;
                                end
                            end
                        end
                        if (gvar_j > 0) begin: g_non_first
                            always_ff @(posedge clk or negedge rstn) begin
                                if (~rstn) begin
                                    id_sel[gvar_j+1][gvar_k>>1][0+:gvar_j] <= {gvar_j{1'b0}};
                                end
                                else begin
                                    if (en_ints_pri[gvar_j][gvar_k] < en_ints_pri[gvar_j][gvar_k + 1]) begin
                                        id_sel[gvar_j+1][gvar_k>>1][0+:gvar_j] <= id_sel[gvar_j][gvar_k+1][0+:gvar_j];
                                    end
                                    else begin
                                        id_sel[gvar_j+1][gvar_k>>1][0+:gvar_j] <= id_sel[gvar_j][gvar_k][0+:gvar_j];
                                    end
                                end
                            end
                        end
                    end
                end
            end
            else begin: g_non_pipelining
                for (gvar_k = 0; gvar_k <= CMP_TREE_NUM[gvar_j] - 1; gvar_k = gvar_k + 2) begin: g_cmp
                    if (gvar_k == CMP_TREE_NUM[gvar_j] - 1) begin: g_remainder
                        assign en_ints_pri[gvar_j+1][gvar_k>>1]     = en_ints_pri[gvar_j][gvar_k];
                        assign id_sel[gvar_j+1][gvar_k>>1][gvar_j]  = 1'b0;
                        if (gvar_j > 0) begin: g_non_first
                            assign id_sel[gvar_j+1][gvar_k>>1][0+:gvar_j] = id_sel[gvar_j][gvar_k][0+:gvar_j];
                        end
                    end
                    else begin: g_cmp
                        always_comb begin
                            if (en_ints_pri[gvar_j][gvar_k] < en_ints_pri[gvar_j][gvar_k + 1]) begin
                                en_ints_pri[gvar_j+1][gvar_k>>1]     = en_ints_pri[gvar_j][gvar_k + 1];
                                id_sel[gvar_j+1][gvar_k>>1][gvar_j]  = 1'b1;
                            end
                            else begin
                                en_ints_pri[gvar_j+1][gvar_k>>1]     = en_ints_pri[gvar_j][gvar_k];
                                id_sel[gvar_j+1][gvar_k>>1][gvar_j]  = 1'b0;
                            end
                        end
                        if (gvar_j > 0) begin: g_non_first
                            always_comb begin
                                if (en_ints_pri[gvar_j][gvar_k] < en_ints_pri[gvar_j][gvar_k + 1]) begin
                                    id_sel[gvar_j+1][gvar_k>>1][0+:gvar_j] = id_sel[gvar_j][gvar_k+1][0+:gvar_j];
                                end
                                else begin
                                    id_sel[gvar_j+1][gvar_k>>1][0+:gvar_j] = id_sel[gvar_j][gvar_k][0+:gvar_j];
                                end
                            end
                        end
                    end
                end
            end
        end
        
        assign int_id_tmp[gvar_i]  = {22'b0, id_sel[10][0][9:0]};
        assign int_max_pri[gvar_i] = en_ints_pri[10][0];
    end
endgenerate

always_comb begin
    integer i;
    for (i = 0; i < `CPU_NUM; i = i + 1) begin
        meip[i] = claim_id[i] != int_id[i];
    end
end

assign apb_wr = ~penable & psel & pwrite;

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < `INT_NUM; i = i + 1) begin
            int_prior[i] <= 32'b0;
        end
    end
    else if (apb_wr) begin
        for (i = 1; i < `INT_NUM; i = i + 1) begin
            if (paddr[25:0] == `PLIC_INT_PRIOR + 26'h4 * i[25:0]) begin
                int_prior[i] <= pwdata;
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        int_type <= `INT_NUM'b0;
    end
    else if (apb_wr) begin
        for (i = 0; i < `INT_NUM; i = i + 32) begin
            if (paddr[25:0] == `PLIC_INT_TYPE + i[28:3]) begin
                int_type[i+:32] <= pwdata;
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        int_pol <= `INT_NUM'b0;
    end
    else if (apb_wr) begin
        for (i = 0; i < `INT_NUM; i = i + 32) begin
            if (paddr[25:0] == `PLIC_INT_POL + i[28:3]) begin
                int_pol[i+:32] <= pwdata;
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i, j;
    if (~rstn) begin
        for (j = 0; j < `CPU_NUM; j = j + 1) begin
            int_en[j] <= `INT_NUM'b0;
        end
    end
    else if (apb_wr) begin
        for (j = 0; j < `CPU_NUM; j = j + 1) begin
            for (i = 0; i < `INT_NUM; i = i + 32) begin
                if (paddr[25:0] == `PLIC_INT_EN + i[28:3] + 26'h80 * j[25:0]) begin
                    int_en[j][i+:32] <= pwdata;
                end
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < `CPU_NUM; i = i + 1) begin
            threshold[i] <= 32'b0;
        end
    end
    else if (apb_wr) begin
        for (i = 0; i < `CPU_NUM; i = i + 1) begin
            if (paddr[25:0] == `PLIC_PRIOR_TH + 26'h1000 * i[25:0]) begin
                threshold[i] <= pwdata;
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < `CPU_NUM; i = i + 1) begin
            int_id   [i] <= 32'b0;
        end
    end
    else begin
        for (i = 0; i < `CPU_NUM; i = i + 1) begin
            if (!(~penable && psel && paddr[25:0] == `PLIC_PRIOR_TH + 26'h1000 * i[25:0] + 26'h4)) begin
                if (~|claim_id[i]) begin // non-preemptive
                    int_id   [i] <= int_max_pri[i] > threshold[i] ? int_id_tmp[i] : 32'b0;
                end
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < `CPU_NUM; i = i + 1) begin
            claim_id [i] <= 32'b0;
        end
    end
    else begin
        for (i = 0; i < `CPU_NUM; i = i + 1) begin
            if (~penable && psel && paddr[25:0] == `PLIC_PRIOR_TH + 26'h1000 * i[25:0] + 26'h4) begin
                claim_id [i] <= pwrite ? 32'b0 : int_id[i];
            end
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < `CPU_NUM; i = i + 1) begin
            cmplet_id[i] <= 32'b0;
        end
    end
    else begin
        for (i = 0; i < `CPU_NUM; i = i + 1) begin
            if (apb_wr && paddr[25:0] == `PLIC_PRIOR_TH + 26'h1000 * i[25:0] + 26'h4) begin
                cmplet_id[i] <= claim_id[i];
            end
            else begin
                cmplet_id[i] <= 32'b0;
            end
        end
    end
end

always_comb begin
    integer i;
    prdata_pri = 32'b0;
    for (i = 0; i < `INT_NUM; i = i + 1) begin
        prdata_pri = prdata_pri | (int_prior[i] & {32{paddr[25:0] == `PLIC_INT_PRIOR + 26'h4 * i[25:0]}});
    end
end

always_comb begin
    integer i;
    prdata_ip = 32'b0;
    for (i = 0; i < `INT_NUM; i = i + 32) begin
        prdata_ip = prdata_ip | (int_pend[i+:32] & {32{paddr[25:0] == `PLIC_INT_PEND + i[28:3]}});
    end
end

always_comb begin
    integer i;
    prdata_ityp = 32'b0;
    for (i = 0; i < `INT_NUM; i = i + 32) begin
        prdata_ityp = prdata_ityp | (int_type[i+:32] & {32{paddr[25:0] == `PLIC_INT_TYPE + i[28:3]}});
    end
end

always_comb begin
    integer i;
    prdata_ipol = 32'b0;
    for (i = 0; i < `INT_NUM; i = i + 32) begin
        prdata_ipol = prdata_ipol | (int_pol[i+:32] & {32{paddr[25:0] == `PLIC_INT_POL + i[28:3]}});
    end
end

always_comb begin
    integer i, j;
    prdata_ie = 32'b0;
    for (j = 0; j < `CPU_NUM; j = j + 1) begin
        for (i = 0; i < `INT_NUM; i = i + 32) begin
            prdata_ie = prdata_ie | (int_en[j][i+:32] & {32{paddr[25:0] == `PLIC_INT_EN + i[28:3] + 26'h80 * j[25:0]}});
        end
    end
end

always_comb begin
    integer i;
    prdata_th = 32'b0;
    for (i = 0; i < `CPU_NUM; i = i + 1) begin
        prdata_th = prdata_th | (threshold[i] & {32{paddr[25:0] == `PLIC_PRIOR_TH + 26'h1000 * i[25:0]}});
    end
end

always_comb begin
    integer i;
    prdata_id = 32'b0;
    for (i = 0; i < `CPU_NUM; i = i + 1) begin
        prdata_id = prdata_id | (int_id[i] & {32{paddr[25:0] == `PLIC_PRIOR_TH + 26'h1000 * i[25:0] + 26'h4}});
    end
end

assign prdata_t = prdata_pri | prdata_ip | prdata_ityp | prdata_ipol | prdata_ie | prdata_id | prdata_th;

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


module gateway (
    input        clk,
    input        rstn,
    input        src,
    input        src_type, // 0: edge, 1: level
    input        src_pol,  // 0: high, 1: low
    input        claim,
    input        cmplet,
    output logic pend
);

parameter [1:0] STATE_IDLE  = 2'b00,
                STATE_PEND  = 2'b01,
                STATE_CLAIM = 2'b10;

logic [1:0] cur_state;
logic [1:0] nxt_state;

logic       src_pol_dly;
logic       src_lvl;
logic       src_edge;
logic       is_pend;
logic       is_claim;
logic       is_cancel;
logic       is_cmplet;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        cur_state <= STATE_IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end

always_comb begin
    nxt_state = cur_state;
    case (cur_state)
        STATE_IDLE : nxt_state = is_pend   ? STATE_PEND  : STATE_IDLE;
        STATE_PEND : nxt_state = is_claim  ? STATE_CLAIM :
                                 is_cancel ? STATE_IDLE  : STATE_PEND;
        STATE_CLAIM: nxt_state = is_cmplet ? STATE_IDLE  : STATE_CLAIM;
    endcase
end

assign src_tmp = src ^ src_pol;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        src_pol_dly  <= 1'b0;
    end
    else begin
        src_pol_dly  <= src_pol;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        src_lvl <= 1'b0;
    end
    else begin
        src_lvl <= src_tmp;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        src_edge <= 1'b0;
    end
    else begin
        src_edge <= ~src_lvl & src_tmp;
    end
end

assign is_pend   = src_type ?  src_lvl : src_edge;
assign is_claim  = claim;
assign is_cancel = (src_type ? ~src_lvl : 1'b0) | (src_pol ^ src_pol_dly);
assign is_cmplet = cmplet;

assign pend      = cur_state == STATE_PEND;

endmodule
