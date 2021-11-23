`timescale 1ns / 10ps

`define CLK_PRIOD 100
`define TEST_END_ADDR 32'hffc

module test;

integer     i;

logic       clk;
logic       rstn;
logic       simend;

logic [7:0] prog_byte0 [32768];
logic [7:0] prog_byte1 [32768];
logic [7:0] prog_byte2 [32768];
logic [7:0] prog_byte3 [32768];

string      prog_path;

// clock and reset
initial begin
    simend <= 1'b0;
    clk    <= 1'b0;
    rstn   <= 1'b0;
    #(`CLK_PRIOD * 10)
    rstn   <= 1'b1;
    #(`CLK_PRIOD * 100000)
    simend <= 1'b1;
end

// Simulation end check
always @(posedge clk) begin
    if (u_cpu_wrap.u_sram_1.memory[`TEST_END_ADDR >> 2] === 32'b1) begin
        $display("TEST_END flag detected");
        $display("Simulation end!");
        $display("END CODE: %x", u_cpu_wrap.u_sram_1.memory[(`TEST_END_ADDR >> 2) - 1]);
        simend <= 1'b1;
    end
end

always @(posedge simend) begin
    $display("mcycle:   %0d", u_cpu_wrap.u_cpu_top.u_pmu.mcycle);
    $display("minstret: %0d", u_cpu_wrap.u_cpu_top.u_pmu.minstret);
    $finish;
end

initial begin
    // wait (u_cpu_wrap.u_intc.u_plic.int_en[0] != 32'b0);
    #(`CLK_PRIOD * 5);
    force u_cpu_wrap.u_intc.ints  = -32'b1;
    // force u_cpu_wrap.u_plic.int_en[0] = 32'h55555555;
    // force u_cpu_wrap.u_plic.int_prior[0]  = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[1]  = 32'h1;
    // force u_cpu_wrap.u_plic.int_prior[2]  = 32'h2;
    // force u_cpu_wrap.u_plic.int_prior[3]  = 32'h3;
    // force u_cpu_wrap.u_plic.int_prior[4]  = 32'h4;
    // force u_cpu_wrap.u_plic.int_prior[5]  = 32'h5;
    // force u_cpu_wrap.u_plic.int_prior[6]  = 32'h6;
    // force u_cpu_wrap.u_plic.int_prior[7]  = 32'h7;
    // force u_cpu_wrap.u_plic.int_prior[8]  = 32'h8;
    // force u_cpu_wrap.u_plic.int_prior[9]  = 32'h9;
    // force u_cpu_wrap.u_plic.int_prior[10] = 32'h9;
    // force u_cpu_wrap.u_plic.int_prior[11] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[12] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[13] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[14] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[15] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[16] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[17] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[18] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[19] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[20] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[21] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[22] = 32'hA;
    // force u_cpu_wrap.u_plic.int_prior[23] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[24] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[25] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[26] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[27] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[28] = 32'hA;
    // force u_cpu_wrap.u_plic.int_prior[29] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[30] = 32'h0;
    // force u_cpu_wrap.u_plic.int_prior[31] = 32'h0;
    // wait (u_cpu_wrap.u_cpu_top.id2exe_wfi === 1'b1);
    // #1;
    // #(`CLK_PRIOD * 5)
    // force u_cpu_wrap.u_cpu_top.msip = 1'b1;
    // #(`CLK_PRIOD * 10)
    // release u_cpu_wrap.u_cpu_top.msip;
end

// sram initial
initial begin
    #(`CLK_PRIOD * 5)
    // Random initial
    $value$plusargs("prog=%s", prog_path);
    for (i = 0; i < 16384; i = i + 1) begin
        prog_byte0[i] = 8'h0; // $random();
        prog_byte1[i] = 8'h0; // $random();
        prog_byte2[i] = 8'h0; // $random();
        prog_byte3[i] = 8'h0; // $random();
    end
    $readmemh({prog_path, "/sram_0_0.hex"}, prog_byte0);
    $readmemh({prog_path, "/sram_0_1.hex"}, prog_byte1);
    $readmemh({prog_path, "/sram_0_2.hex"}, prog_byte2);
    $readmemh({prog_path, "/sram_0_3.hex"}, prog_byte3);
    $readmemh({prog_path, "/sram_1_0.hex"}, prog_byte0);
    $readmemh({prog_path, "/sram_1_1.hex"}, prog_byte1);
    $readmemh({prog_path, "/sram_1_2.hex"}, prog_byte2);
    $readmemh({prog_path, "/sram_1_3.hex"}, prog_byte3);
    #(`CLK_PRIOD)
    for (i = 0; i < 16384; i = i + 1) begin
        u_cpu_wrap.u_sram_0.memory[i] <= {prog_byte3[i], prog_byte2[i], prog_byte1[i], prog_byte0[i]};
        u_cpu_wrap.u_sram_1.memory[i] <= {prog_byte3[i+16384], prog_byte2[i+16384], prog_byte1[i+16384], prog_byte0[i+16384]};
    end
end

always #(`CLK_PRIOD / 2) clk <= ~clk;

`ifdef FSDB
initial begin
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, test, "+struct", "+mda");
end
`endif

cpu_wrap u_cpu_wrap (
    .clk  ( clk  ),
    .rstn ( rstn )
);

// For riscv-tests used
logic [31:0] arg;
logic [31:0] cmd;
logic [ 1:0] _flag;

always @(posedge clk) begin
    if (~rstn) begin
        arg <= 32'b0;
        cmd <= 32'b0;
    end
    else if (u_cpu_wrap.u_sram_0.CS && u_cpu_wrap.u_sram_0.WE) begin
        if (u_cpu_wrap.u_sram_0.A == 14'h400) begin
            arg <= u_cpu_wrap.u_sram_0.DI;
        end
        else if (u_cpu_wrap.u_sram_0.A == 14'h401) begin
            cmd <= u_cpu_wrap.u_sram_0.DI;
        end
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        _flag <= 2'b0;
    end
    else if (u_cpu_wrap.u_sram_0.CS && u_cpu_wrap.u_sram_0.WE) begin
        if (_flag) begin
            _flag <= {_flag[0], 1'b0};
        end
        else if (u_cpu_wrap.u_sram_0.A == 14'h400) begin
            _flag <= 2'b1;
        end
    end
    else if (_flag[1]) begin
        case (cmd)
            32'h00000000: begin
                $display("ENDCODE = %x", arg);
                $finish;
            end
            32'h01010000: $write("%c", arg);
        endcase
        _flag <= 2'b0;
        u_cpu_wrap.u_sram_0.memory[14'h400] = 32'b0;
        u_cpu_wrap.u_sram_0.memory[14'h401] = 32'b0;
    end
end


endmodule
