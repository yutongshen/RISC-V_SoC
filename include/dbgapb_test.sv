`define ZERO 5'b00000
`define RA   5'b00001
`define SP   5'b00010
`define GP   5'b00011
`define TP   5'b00100
`define T0   5'b00101
`define T1   5'b00110
`define T2   5'b00111
`define S0   5'b01000
`define S1   5'b01001
`define A0   5'b01010
`define A1   5'b01011
`define A2   5'b01100
`define A3   5'b01101
`define A4   5'b01110
`define A5   5'b01111
`define A6   5'b10000
`define A7   5'b10001
`define S2   5'b10010
`define S3   5'b10011
`define S4   5'b10100
`define S5   5'b10101
`define S6   5'b10110
`define S7   5'b10111
`define S8   5'b11000
`define S9   5'b11001
`define S10  5'b11010
`define S11  5'b11011
`define T3   5'b11100
`define T4   5'b11101
`define T5   5'b11110
`define T6   5'b11111
`define JALR(RS1) {12'b0, RS1, 3'b000, 5'b00000, 7'b1100111}
`define ADDI(RD, RS1, IMM) {IMM, RS1, 3'b000, RD, 7'b0010011}

initial begin
    repeat (20000) @(negedge clk);
    dbgapb_wr(`DBGAPB_DBG_EN, 32'b1);
    dbgapb_wr(`DBGAPB_INST, {20'b0, `INST_ATTACH});
    dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
    dbg_rdata = 32'b0;
    dbgapb_status_rd;
    while (dbg_rdata != 32'h3) begin
        @(negedge clk);
        dbgapb_status_rd;
    end
    dbgapb_pc_rd;
    dbgapb_exec(`ADDI(`T0, `ZERO, 12'hcc));
    dbgapb_exec(`JALR(`T0));
    dbgapb_pc_rd;
    dbgapb_pc_rd;
    dbgapb_pc_rd;
    dbgapb_gpr_rd(5'h0);
    dbgapb_gpr_rd(5'h1);
    dbgapb_gpr_rd(5'h2);
    dbgapb_gpr_rd(5'h3);
    dbgapb_gpr_rd(5'h4);
    dbgapb_gpr_rd(5'h5);
    dbgapb_gpr_rd(5'h6);
    dbgapb_gpr_rd(5'h7);
    dbgapb_gpr_rd(5'h8);
    dbgapb_gpr_rd(5'h9);
    dbgapb_gpr_rd(5'ha);
    dbgapb_gpr_rd(5'hb);
    dbgapb_gpr_rd(5'hc);
    dbgapb_gpr_rd(5'hd);
    dbgapb_gpr_rd(5'he);
    dbgapb_gpr_rd(5'hf);
    dbgapb_gpr_rd(5'h10);
    dbgapb_gpr_rd(5'h11);
    dbgapb_gpr_rd(5'h12);
    dbgapb_gpr_rd(5'h13);
    dbgapb_gpr_rd(5'h14);
    dbgapb_gpr_rd(5'h15);
    dbgapb_gpr_rd(5'h16);
    dbgapb_gpr_rd(5'h17);
    dbgapb_gpr_rd(5'h18);
    dbgapb_gpr_rd(5'h19);
    dbgapb_gpr_rd(5'h1a);
    dbgapb_gpr_rd(5'h1b);
    dbgapb_gpr_rd(5'h1c);
    dbgapb_gpr_rd(5'h1d);
    dbgapb_gpr_rd(5'h1e);
    dbgapb_gpr_rd(5'h1f);
    dbgapb_gpr_wr(5'h0 , 32'h0 );
    dbgapb_gpr_wr(5'h1 , 32'h1 );
    dbgapb_gpr_wr(5'h2 , 32'h2 );
    dbgapb_gpr_wr(5'h3 , 32'h3 );
    dbgapb_gpr_wr(5'h4 , 32'h4 );
    dbgapb_gpr_wr(5'h5 , 32'h5 );
    dbgapb_gpr_wr(5'h6 , 32'h6 );
    dbgapb_gpr_wr(5'h7 , 32'h7 );
    dbgapb_gpr_wr(5'h8 , 32'h8 );
    dbgapb_gpr_wr(5'h9 , 32'h9 );
    dbgapb_gpr_wr(5'ha , 32'ha );
    dbgapb_gpr_wr(5'hb , 32'hb );
    dbgapb_gpr_wr(5'hc , 32'hc );
    dbgapb_gpr_wr(5'hd , 32'hd );
    dbgapb_gpr_wr(5'he , 32'he );
    dbgapb_gpr_wr(5'hf , 32'hf );
    dbgapb_gpr_wr(5'h10, 32'h10);
    dbgapb_gpr_wr(5'h11, 32'h11);
    dbgapb_gpr_wr(5'h12, 32'h12);
    dbgapb_gpr_wr(5'h13, 32'h13);
    dbgapb_gpr_wr(5'h14, 32'h14);
    dbgapb_gpr_wr(5'h15, 32'h15);
    dbgapb_gpr_wr(5'h16, 32'h16);
    dbgapb_gpr_wr(5'h17, 32'h17);
    dbgapb_gpr_wr(5'h18, 32'h18);
    dbgapb_gpr_wr(5'h19, 32'h19);
    dbgapb_gpr_wr(5'h1a, 32'h1a);
    dbgapb_gpr_wr(5'h1b, 32'h1b);
    dbgapb_gpr_wr(5'h1c, 32'h1c);
    dbgapb_gpr_wr(5'h1d, 32'h1d);
    dbgapb_gpr_wr(5'h1e, 32'h1e);
    dbgapb_gpr_wr(5'h1f, 32'h1f);
    dbgapb_gpr_rd(5'h0);
    dbgapb_gpr_rd(5'h1);
    dbgapb_gpr_rd(5'h2);
    dbgapb_gpr_rd(5'h3);
    dbgapb_gpr_rd(5'h4);
    dbgapb_gpr_rd(5'h5);
    dbgapb_gpr_rd(5'h6);
    dbgapb_gpr_rd(5'h7);
    dbgapb_gpr_rd(5'h8);
    dbgapb_gpr_rd(5'h9);
    dbgapb_gpr_rd(5'ha);
    dbgapb_gpr_rd(5'hb);
    dbgapb_gpr_rd(5'hc);
    dbgapb_gpr_rd(5'hd);
    dbgapb_gpr_rd(5'he);
    dbgapb_gpr_rd(5'hf);
    dbgapb_gpr_rd(5'h10);
    dbgapb_gpr_rd(5'h11);
    dbgapb_gpr_rd(5'h12);
    dbgapb_gpr_rd(5'h13);
    dbgapb_gpr_rd(5'h14);
    dbgapb_gpr_rd(5'h15);
    dbgapb_gpr_rd(5'h16);
    dbgapb_gpr_rd(5'h17);
    dbgapb_gpr_rd(5'h18);
    dbgapb_gpr_rd(5'h19);
    dbgapb_gpr_rd(5'h1a);
    dbgapb_gpr_rd(5'h1b);
    dbgapb_gpr_rd(5'h1c);
    dbgapb_gpr_rd(5'h1d);
    dbgapb_gpr_rd(5'h1e);
    dbgapb_gpr_rd(5'h1f);
    dbgapb_csr_rd(12'h300);
    dbgapb_csr_wr(12'h300, 32'hffffffff);
    dbgapb_csr_rd(12'h300);
    dbgapb_exec(`ADDI(`ZERO, `ZERO, 12'h000));
    dbgapb_wr(`DBGAPB_INST, {20'b0, `INST_RESUME});
    dbgapb_wr(`DBGAPB_INST_WR, 32'b1);
end
