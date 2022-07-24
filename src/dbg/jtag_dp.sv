`define DAP_VER       'h0
`define DAP_PARTNUM   'h0
`define DAP_MANID     'h0
`define UNPREDICTABLE 32'hdead_dead

module jtag_dp (
    input               tck,
    input               trstn,
    input               tms,
    input               tdi,
    output logic        tdo,

    output logic        ap_upd,
    output logic [ 7:0] ap_sel,
    output logic [31:0] ap_wdata,
    output logic [ 7:2] ap_addr,
    output logic        ap_rnw,
    input               ap_busy,
    input        [31:0] ap_rdata,
    input               ap_slverr,
    input        [ 2:0] ap_ack,

    output logic        ap_rbuf_rrstn,
    output logic        ap_rbuf_dpop,
    input        [31:0] ap_rbuf_rdata,
    output logic        ap_rbuf_rpop,
    input        [31:0] ap_rbuf_rresp,

    output logic        ap_wbuf_wrstn,
    output logic        ap_wbuf_push,
    output logic [31:0] ap_wbuf_wdata,

    output logic        dbgrstn
);

logic [34:0] sfter;
logic [ 4:0] ir;
logic [34:0] dr_abort;

logic        err;
logic [31:0] datain;
logic [ 1:0] addr;
logic        rnw;
logic [34:0] dr_dpacc;
logic [31:0] dpacc_res;
logic [31:0] dpacc_csr;
logic        dpacc_csr_csyspwrupack;
logic        dpacc_csr_csyspwrupreq;
logic        dpacc_csr_cdbgpwrupack;
logic        dpacc_csr_cdbgpwrupreq;
logic        dpacc_csr_cdbgrstack;
logic        dpacc_csr_cdbgrstreq;
logic [11:0] dpacc_csr_trncnt;
logic [ 3:0] dpacc_csr_masklane;
logic        dpacc_csr_stickyerr;
logic        dpacc_csr_stickycmp;
logic [ 1:0] dpacc_csr_trnmode;
logic        dpacc_csr_stickyorun;
logic        dpacc_csr_orundetect;
logic [31:0] dpacc_apsel;
logic [ 7:0] dpacc_apsel_apsel;
logic [ 3:0] dpacc_apsel_apaddrh;

logic [34:0] dapacc_cap_data;
logic        dpacc_sel_latch;
logic        ap_busy_latch;
logic [31:0] ap_cmp_data;
logic        ap_cmp_en;

logic [ 4:0] ap_buf_cnt;
logic        buf_pop;

logic [ 3:0] cur_state;
logic [ 3:0] nxt_state;

logic        rstn_trig;

logic        ap_wbuf_push_pre;

localparam STATE_RESET   = 4'hf,
           STATE_RUN     = 4'hc,
           STATE_SEL_DR  = 4'h7,
           STATE_CAP_DR  = 4'h6,
           STATE_SFT_DR  = 4'h2,
           STATE_EX1_DR  = 4'h1,
           STATE_PAU_DR  = 4'h3,
           STATE_EX2_DR  = 4'h0,
           STATE_UPD_DR  = 4'h5,
           STATE_SEL_IR  = 4'h4,
           STATE_CAP_IR  = 4'he,
           STATE_SFT_IR  = 4'ha,
           STATE_EX1_IR  = 4'h9,
           STATE_PAU_IR  = 4'hb,
           STATE_EX2_IR  = 4'h8,
           STATE_UPD_IR  = 4'hd;

localparam RG_ABORT      = 5'h8,
           RG_DPACC      = 5'ha,
           RG_APACC      = 5'hb,
           RG_IDCODE     = 5'he,
           RG_BYPASS     = 5'hf,
           RG_APDBUF     = 5'h10,
           RG_APRBUF     = 5'h11,
           RG_APWBUF     = 5'h12;

localparam RESP_OK_FAULT = 3'h2,
           RESP_WAIT     = 3'h1;

assign dbgrstn   = ~(~dpacc_csr_cdbgrstack & dpacc_csr_cdbgrstreq) && rstn_trig;
assign rstn_trig = ~(cur_state == STATE_RESET);

always_ff @(posedge tck or negedge trstn) begin: dp_fsm
    if (~trstn) cur_state <= STATE_RESET;
    else        cur_state <= nxt_state;
end

always_comb begin: next_state
    nxt_state = cur_state;
    case (cur_state)
        STATE_RESET : nxt_state = tms ? STATE_RESET  : STATE_RUN;
        STATE_RUN   : nxt_state = tms ? STATE_SEL_DR : STATE_RUN;
        STATE_SEL_DR: nxt_state = tms ? STATE_SEL_IR : STATE_CAP_DR;
        STATE_CAP_DR: nxt_state = tms ? STATE_EX1_DR : STATE_SFT_DR;
        STATE_SFT_DR: nxt_state = tms ? STATE_EX1_DR : STATE_SFT_DR;
        STATE_EX1_DR: nxt_state = tms ? STATE_UPD_DR : STATE_PAU_DR;
        STATE_PAU_DR: nxt_state = tms ? STATE_EX2_DR : STATE_PAU_DR;
        STATE_EX2_DR: nxt_state = tms ? STATE_UPD_DR : STATE_SFT_DR;
        STATE_UPD_DR: nxt_state = tms ? STATE_SEL_DR : STATE_RUN;
        STATE_SEL_IR: nxt_state = tms ? STATE_RESET  : STATE_CAP_IR;
        STATE_CAP_IR: nxt_state = tms ? STATE_EX1_IR : STATE_SFT_IR;
        STATE_SFT_IR: nxt_state = tms ? STATE_EX1_IR : STATE_SFT_IR;
        STATE_EX1_IR: nxt_state = tms ? STATE_UPD_IR : STATE_PAU_IR;
        STATE_PAU_IR: nxt_state = tms ? STATE_EX2_IR : STATE_PAU_IR;
        STATE_EX2_IR: nxt_state = tms ? STATE_UPD_IR : STATE_SFT_IR;
        STATE_UPD_IR: nxt_state = tms ? STATE_SEL_DR : STATE_RUN;
    endcase
end

assign tdo = sfter[0];

always_ff @(posedge tck or negedge trstn) begin: reg_ap_busy_latch
    if (~trstn)                         ap_busy_latch <= 1'b0;
    else if (~rstn_trig)                ap_busy_latch <= 1'b0;
    else if (~tms &&
             cur_state == STATE_SEL_DR) ap_busy_latch <= ap_busy && (ir == RG_DPACC || ir == RG_APACC);
end

always_ff @(posedge tck or negedge trstn) begin: reg_dpacc_sel_latch
    if (~trstn)                         dpacc_sel_latch <= 1'b0;
    else if (~rstn_trig)                dpacc_sel_latch <= 1'b0;
    else if (cur_state == STATE_CAP_DR) dpacc_sel_latch <= ir == RG_DPACC ? 1'b1:
                                                           ir == RG_APACC ? 1'b0:
                                                                            dpacc_sel_latch;
end

assign dapacc_cap_data = {(dpacc_sel_latch ? dpacc_res : ap_rdata), (~ap_busy_latch ? RESP_OK_FAULT : RESP_WAIT)};
always_ff @(posedge tck or negedge trstn) begin: reg_sfter
    if (~trstn)                         sfter      <= 35'b0;
    else if (~rstn_trig)                sfter      <= 35'b0;
    else if (cur_state == STATE_CAP_IR) sfter[4:0] <= 4'b1;
    else if (cur_state == STATE_SFT_IR) sfter[4:0] <= {tdi, sfter[4:1]};
    else if (cur_state == STATE_CAP_DR) sfter      <= ({35{ir == RG_ABORT }} & {3'b0, `UNPREDICTABLE})|
                                                      ({35{ir == RG_DPACC ||
                                                           ir == RG_APACC }} & dapacc_cap_data)|
                                                      ({35{ir == RG_IDCODE}} & {3'b0,
                                                                                4`DAP_VER,
                                                                                16`DAP_PARTNUM,
                                                                                11`DAP_MANID,
                                                                                1'b1})|
                                                      ({35{ir == RG_BYPASS}} & 35'b0)|
                                                      ({35{ir == RG_APDBUF}} & {3'b0, ap_rbuf_rdata})|
                                                      ({35{ir == RG_APRBUF}} & {3'b0, ap_rbuf_rresp})|
                                                      ({35{ir == RG_APWBUF}} & 35'b0);
    else if (cur_state == STATE_SFT_DR) begin
        if (ir == RG_ABORT ||
            ir == RG_DPACC ||
            ir == RG_APACC)             sfter       <= {tdi, sfter[34:1]};
        else if (ir == RG_IDCODE)       sfter[31:0] <= {tdi, sfter[31:1]};
        else if (ir == RG_BYPASS)       sfter[0]    <=  tdi;
        else if (ir == RG_APDBUF)       sfter[31:0] <= ap_rbuf_dpop ? ap_rbuf_rdata:
                                                                      {1'b0, sfter[31:1]};
        else if (ir == RG_APRBUF)       sfter[31:0] <= ap_rbuf_rpop ? ap_rbuf_rresp:
                                                                      {1'b0, sfter[31:1]};
        else if (ir == RG_APWBUF)       sfter[31:0] <= {tdi, sfter[31:1]};
    end
end

always_ff @(posedge tck or negedge trstn) begin: reg_ir
    if (~trstn)                         ir <= RG_IDCODE;
    else if (~rstn_trig)                ir <= RG_IDCODE;
    else if (cur_state == STATE_UPD_IR) ir <= sfter[4:0];
end

always_ff @(posedge tck or negedge trstn) begin: reg_dr_abort
    if (~trstn)                         dr_abort <= 35'b0;
    else if (~rstn_trig)                dr_abort <= 35'b0;
    else if (ir == RG_ABORT &&
             cur_state == STATE_UPD_DR) dr_abort <= sfter[34:0];
end

assign datain = sfter[34:3];
assign addr   = sfter[ 2:1];
assign rnw    = sfter[0];
assign err    = datain[ 3: 2] == 2'b11 && addr == 2'b1;

assign dpacc_csr_stickycmp    = (((dpacc_csr_masklane[0] && ap_cmp_data[ 0+:8] != ap_rdata[ 0+:8])||
                                  (dpacc_csr_masklane[1] && ap_cmp_data[ 8+:8] != ap_rdata[ 8+:8])||
                                  (dpacc_csr_masklane[2] && ap_cmp_data[16+:8] != ap_rdata[16+:8])||
                                  (dpacc_csr_masklane[3] && ap_cmp_data[24+:8] != ap_rdata[24+:8]))
                                 ^ (dpacc_csr_trnmode == 2'h2)) && dpacc_csr_trnmode != 2'h0 && ap_cmp_en;
assign dpacc_csr_stickyerr    = ap_slverr;
assign dpacc_csr_stickyorun   = 1'b0;

assign dpacc_csr = {
    dpacc_csr_csyspwrupack,
    dpacc_csr_csyspwrupreq,
    dpacc_csr_cdbgpwrupack,
    dpacc_csr_cdbgpwrupreq,
    dpacc_csr_cdbgrstack,
    dpacc_csr_cdbgrstreq,
    2'b0,
    dpacc_csr_trncnt,
    dpacc_csr_masklane,
    2'b0,
    dpacc_csr_stickyerr,
    dpacc_csr_stickycmp,
    dpacc_csr_trnmode,
    dpacc_csr_stickyorun,
    dpacc_csr_orundetect
};
assign dpacc_apsel = {dpacc_apsel_apsel, 16'h0, dpacc_apsel_apaddrh, 4'h0};

always_ff @(posedge tck or negedge trstn) begin: reg_dr_dpacc
    if (~trstn) begin
        dpacc_res              <= 32'b0;
        dpacc_csr_csyspwrupack <= 1'b0;
        dpacc_csr_csyspwrupreq <= 1'b0;
        dpacc_csr_cdbgpwrupack <= 1'b0;
        dpacc_csr_cdbgpwrupreq <= 1'b0;
        dpacc_csr_cdbgrstack   <= 1'b0;
        dpacc_csr_cdbgrstreq   <= 1'b0;
        dpacc_csr_trncnt       <= 12'b0;
        dpacc_csr_masklane     <= 4'b0;
        dpacc_csr_trnmode      <= 2'b0;
        dpacc_csr_orundetect   <= 1'b0;
        dpacc_apsel_apsel      <= 8'b0;
        dpacc_apsel_apaddrh    <= 4'b0;
    end
    else if (~rstn_trig) begin
        dpacc_res              <= 32'b0;
        dpacc_csr_csyspwrupack <= 1'b0;
        dpacc_csr_csyspwrupreq <= 1'b0;
        dpacc_csr_cdbgpwrupack <= 1'b0;
        dpacc_csr_cdbgpwrupreq <= 1'b0;
        dpacc_csr_cdbgrstack   <= 1'b0;
        dpacc_csr_cdbgrstreq   <= 1'b0;
        dpacc_csr_trncnt       <= 12'b0;
        dpacc_csr_masklane     <= 4'b0;
        dpacc_csr_trnmode      <= 2'b0;
        dpacc_csr_orundetect   <= 1'b0;
        dpacc_apsel_apsel      <= 8'b0;
        dpacc_apsel_apaddrh    <= 4'b0;
    end
    else if (ir == RG_DPACC && cur_state == STATE_UPD_DR && ~ap_busy_latch) begin
        if (rnw) begin // Read
            dpacc_csr_csyspwrupack <= 1'b0;
            dpacc_csr_cdbgpwrupack <= 1'b0;
            dpacc_csr_cdbgrstack   <= 1'b0;
            dpacc_res              <= ({32{addr == 2'h0}} & `UNPREDICTABLE)|
                                      ({32{addr == 2'h1}} & dpacc_csr     )|
                                      ({32{addr == 2'h2}} & dpacc_apsel   )|
                                      ({32{addr == 2'h3}} & 32'b0         );
        end
        else begin // Write
            dpacc_res              <= `UNPREDICTABLE;
            dpacc_csr_csyspwrupreq <= addr == 2'h1 && datain[30];
            dpacc_csr_cdbgpwrupreq <= addr == 2'h1 && datain[28];
            dpacc_csr_cdbgrstreq   <= addr == 2'h1 && datain[26];
            dpacc_csr_trncnt       <= addr == 2'h1 ? datain[23:12] : dpacc_csr_trncnt;
            dpacc_csr_masklane     <= addr == 2'h1 ? datain[11: 8] : dpacc_csr_masklane;
            dpacc_csr_trnmode      <= datain[ 3: 2] != 2'b11 &&
                                      addr == 2'h1 ? datain[ 3: 2] : dpacc_csr_trnmode;
            dpacc_csr_orundetect   <= addr == 2'h1 ? datain[0]     : dpacc_csr_orundetect;
            dpacc_apsel_apsel      <= addr == 2'h2 ? datain[31:24] : dpacc_apsel_apsel;
            dpacc_apsel_apaddrh    <= addr == 2'h2 ? datain[ 7: 4] : dpacc_apsel_apaddrh;
        end
    end
    else begin
            dpacc_csr_csyspwrupack <= dpacc_csr_csyspwrupreq;
            dpacc_csr_cdbgpwrupack <= dpacc_csr_cdbgpwrupreq;
            dpacc_csr_cdbgrstack   <= dpacc_csr_cdbgrstreq;
            dpacc_csr_csyspwrupreq <= 1'b0;
            dpacc_csr_cdbgpwrupreq <= 1'b0;
            dpacc_csr_cdbgrstreq   <= 1'b0;
    end
end

assign ap_upd       = ir == RG_APACC && cur_state == STATE_UPD_DR && ~ap_busy_latch
                      /* && ~dpacc_csr_stickycmp && ~dpacc_csr_stickyerr && ~dpacc_csr_stickyorun */;
assign ap_sel       = dpacc_apsel_apsel;
assign ap_wdata     = datain;
assign ap_addr[7:4] = dpacc_apsel_apaddrh;
assign ap_addr[3:2] = addr;
assign ap_rnw       = rnw;

always_ff @(posedge tck or negedge trstn) begin: reg_ap_cmp_data
    if (~trstn) begin
        ap_cmp_data <= 32'b0;
        ap_cmp_en   <= 1'b0;
    end
    else if (~rstn_trig) begin
        ap_cmp_data <= 32'b0;
        ap_cmp_en   <= 1'b0;
    end
    else if (ir == RG_APACC && cur_state == STATE_UPD_DR && ~ap_busy_latch) begin
        if (ap_upd && rnw && ap_addr == 6'h3) begin // Read DRW
            ap_cmp_data <= datain;
            ap_cmp_en   <= 1'b1;
        end
        else begin
            ap_cmp_en   <= 1'b0;
        end
    end
    else if (ir == RG_DPACC && cur_state == STATE_UPD_DR && ~ap_busy_latch) begin
        ap_cmp_en   <= 1'b0;
    end
end

assign ap_rbuf_rrstn = ~((ir == RG_APDBUF || ir == RG_APRBUF) && cur_state == STATE_UPD_DR);
assign ap_rbuf_dpop  = (ir == RG_APDBUF && cur_state == STATE_CAP_DR) ||
                       (ir == RG_APDBUF && cur_state == STATE_SFT_DR && ~|ap_buf_cnt);
assign ap_rbuf_rpop  = (ir == RG_APRBUF && cur_state == STATE_CAP_DR) ||
                       (ir == RG_APRBUF && cur_state == STATE_SFT_DR && ~|ap_buf_cnt);

assign ap_wbuf_wrstn     = ~(ir == RG_APWBUF && cur_state == STATE_CAP_DR);
assign ap_wbuf_push_pre  = ir == RG_APWBUF && cur_state == STATE_SFT_DR && ~|ap_buf_cnt;
assign ap_wbuf_wdata     = sfter[31:0];

always_ff @(posedge tck or negedge trstn) begin: reg_ap_wbuf_push
    if (~trstn) ap_wbuf_push <= 1'b0;
    else        ap_wbuf_push <= ap_wbuf_push_pre;
end

always_ff @(posedge tck or negedge trstn) begin: reg_ap_buf
    if (~trstn) begin
        ap_buf_cnt <= 5'b0;
    end
    else if (~rstn_trig) begin
        ap_buf_cnt <= 5'b0;
    end
    else if (ir == RG_APDBUF || ir == RG_APRBUF || ir == RG_APWBUF) begin
        if (cur_state == STATE_CAP_DR) begin
            ap_buf_cnt <= -5'b1;
        end
        else if (cur_state == STATE_SFT_DR) begin
            ap_buf_cnt <= ap_buf_cnt - 5'b1;
        end
        else if (cur_state == STATE_UPD_DR) begin
            ap_buf_cnt <= 5'b0;
        end
    end
end

endmodule
