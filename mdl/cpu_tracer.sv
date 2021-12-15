module cpu_tracer (
    input        clk,
    input        valid,
    input [31:0] pc,
    input [31:0] epc,
    input [31:0] inst,
    input [ 1:0] prv,
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
    input [31:0] mem_wdata,
    input        trap_en,
    input [31:0] mcause,
    input [31:0] mtval,
    input        halted
);

integer cpu_tracer_file;
logic   halted_dly;

`include "cpu_tracer_task.sv"

initial begin
    cpu_tracer_file = $fopen("cpu_tracer.log", "w");
end

always_ff @(posedge clk) begin
    halted_dly <= halted;
end

always_ff @(posedge clk) begin
    string str, tmp;
    integer i;

    if (halted_dly === 1'b0 && halted === 1'b1) begin
        $fdisplay(cpu_tracer_file, "(%0d ns) Enter halted mode", $time);
    end
    else if (halted_dly === 1'b1 && halted === 1'b0) begin
        $fdisplay(cpu_tracer_file, "(%0d ns) Leave halted mode", $time);
    end

    if (valid) begin
        str = prv === `PRV_M ? "M":
              prv === `PRV_H ? "H":
              prv === `PRV_S ? "S":
              prv === `PRV_U ? "U":
                               "X";
        if (inst[1:0] == 2'b11)
            $fdisplay(cpu_tracer_file, "(%0d ns) %0s[%s] %08x:%08x %s", $time, halted ? "[DBG]" : "",
                      str, pc, inst, inst_dec(pc, inst));
        else
            $fdisplay(cpu_tracer_file, "(%0d ns) %0s[%s] %08x:----%04x %s", $time, halted ? "[DBG]" : "",
                      str, pc, inst[15:0], inst_dec(pc, inst));
    end
    if (valid & mem_req & ~mem_wr) begin
        str = "";
        for (i = 3; i >= 0; i = i - 1) begin
            if (mem_byte[i]) $sformat(tmp, "%02x", (mem_rdata >> i*8) & 32'hff);
            else tmp = "--";
            str = {str, tmp};
        end
        $fdisplay(cpu_tracer_file, "  LOAD  MEM[%08x]: %s", mem_addr & ~32'h3, str);
    end
    if (valid & mem_req & mem_wr) begin
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
    if (trap_en) begin
        if (mcause[31]) begin
            $fdisplay(cpu_tracer_file, "(%0d ns) Interrupt #%0d, epc = 0x%08x, tval = 0x%08x",
                      $time, mcause[30:0], epc, mtval);
        end
        else begin
            str = "";
            case (mcause)
                `CAUSE_MISALIGNED_FETCH      : str = "InstructionAddressMisaligned"; 
                `CAUSE_INSTRUCTION_ACCESS    : str = "InstructionAccessFault";
                `CAUSE_ILLEGAL_INSTRUCTION   : str = "IllegalInstruction";
                `CAUSE_BREAKPOINT            : str = "Breakpoint";
                `CAUSE_MISALIGNED_LOAD       : str = "LoadAddressMisaligned";
                `CAUSE_LOAD_ACCESS           : str = "LoadAccessFault";
                `CAUSE_MISALIGNED_STORE      : str = "StoreAddressMisaligned";
                `CAUSE_STORE_ACCESS          : str = "StoreAccessFault";
                `CAUSE_USER_ECALL            : str = "UserEcall";
                `CAUSE_SUPERVISOR_ECALL      : str = "SupervisorEcall";
                `CAUSE_HYPERVISOR_ECALL      : str = "HypervisorEcall";
                `CAUSE_MACHINE_ECALL         : str = "MachineEcall";
                `CAUSE_INSTRUCTION_PAGE_FAULT: str = "InstructionPageFault";
                `CAUSE_LOAD_PAGE_FAULT       : str = "LoadPageFault";
                `CAUSE_STORE_PAGE_FAULT      : str = "StorePageFault";
                default:
                    $sformat(str, "Unknown exception #%0d", mcause);
            endcase
            $fdisplay(cpu_tracer_file, "(%0d ns) %s, epc = 0x%08x, tval = 0x%08x",
                      $time, str, epc, mtval);
        end
    end
end

endmodule
