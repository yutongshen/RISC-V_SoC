module cpu_tracer (
    input        clk,
    input        valid,
    input [31:0] pc,
    input [31:0] inst,
    input        rd_wr,
    input [ 4:0] rd_addr,
    input [31:0] rd_data,
    input        csr_wr,
    input [11:0] csr_waddr,
    input [31:0] csr_wdata,
    input [31:0] mem_addr,
    input        mem_req,
    input        mem_wr,
    input [ 3:0] mem_byte,
    input [31:0] mem_rdata,
    input [31:0] mem_wdata
);

integer cpu_tracer_file;

`include "cpu_tracer_task.sv"

initial begin
    cpu_tracer_file = $fopen("cpu_tracer.log", "w");
end

always_ff @(posedge clk) begin
    string str, tmp;
    integer i;

    if (valid) begin
        $fdisplay(cpu_tracer_file, "(%0d ns) %08x:%08x %s", $time,  pc, inst, inst_dec(pc, inst));
        if (mem_req & ~mem_wr) begin
            str = "";
            for (i = 3; i >= 0; i = i - 1) begin
                if (mem_byte[i]) $sformat(tmp, "%02x", (mem_rdata >> i*8) & 32'hff);
                else tmp = "--";
                str = {str, tmp};
            end
            $fdisplay(cpu_tracer_file, "  LOAD  MEM[%08x]: %s", mem_addr & ~32'h3, str);
        end
        if (mem_req & mem_wr) begin
            str = "";
            for (i = 3; i >= 0; i = i - 1) begin
                if (mem_byte[i]) $sformat(tmp, "%02x", (mem_wdata >> i*8) & 32'hff);
                else tmp = "--";
                str = {str, tmp};
            end
            $fdisplay(cpu_tracer_file, "  STORE MEM[%08x]: %s", mem_addr & ~32'h3, str);
        end
        if (rd_wr) begin
            $fdisplay(cpu_tracer_file, "  %-8s  %08x", regs_name(rd_addr), rd_addr ? rd_data : 32'b0);
        end
        if (csr_wr) begin
            $fdisplay(cpu_tracer_file, "  %-8s  %08x", csr_name(csr_waddr), csr_wdata);
        end
    end
end

endmodule
