module cpu_tracer (
    input               clk,
    input               srstn,
    input               xrstn,
    input               valid,
    input [        1:0] misa_mxl,
    input               len_64,
    input [  `XLEN-1:0] pc,
    input [  `XLEN-1:0] epc,
    input [       31:0] inst,
    input [        1:0] prv,
    input               rd_wr,
    input [        4:0] rd_addr,
    input [  `XLEN-1:0] rd_data,
    input               csr_wr,
    input [       11:0] csr_waddr,
    input [  `XLEN-1:0] csr_wdata,
    input [  `XLEN-1:0] mem_addr,
    input               mem_req,
    input               mem_wr,
    input [`XLEN/8-1:0] mem_byte,
    input [  `XLEN-1:0] mem_rdata,
    input [  `XLEN-1:0] mem_wdata,
    input               trap_en,
    input [       31:0] mcause,
    input [       31:0] mtval,
    input               halted
);

integer cpu_tracer_file;
logic   halted_dly;
logic   srstn_dly;
logic   xrstn_dly;

`include "cpu_tracer_task.sv"

initial begin
    cpu_tracer_file = $fopen("cpu_tracer.log", "w");
end

always_ff @(posedge clk) begin
    halted_dly <= halted;
end

always_ff @(posedge clk) begin
    srstn_dly <= srstn;
    xrstn_dly <= xrstn;
end

always_ff @(posedge clk) begin
    string str, tmp;
    logic [`XLEN-1:0] tmp_data;
    integer i;

    if (~srstn_dly & srstn) begin
        if (~xrstn_dly & xrstn)
            $fdisplay(cpu_tracer_file, "(%0d ns) Cold reset assert", $time);
        else 
            $fdisplay(cpu_tracer_file, "(%0d ns) Warm reset assert", $time);
    end
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
        $fwrite(cpu_tracer_file, "(%0d ns) %0s[%s]", $time, halted ? "[DBG]" : "", str);
        if (misa_mxl[1]) $fwrite(cpu_tracer_file, " %016x:", pc);
        else             $fwrite(cpu_tracer_file, " %08x:", pc[31:0]);
        if (inst[1:0] == 2'b11) $fwrite(cpu_tracer_file, "%08x", inst);
        else                    $fwrite(cpu_tracer_file, "----%04x", inst[15:0]);
        $fwrite(cpu_tracer_file, " %s\n", inst_dec(pc, inst, misa_mxl));
    end
    if (valid & mem_req & ~mem_wr) begin
        str = "";
        tmp_data = mem_rdata;
        for (i = 0; i < `XLEN/8; i = i + 1) begin
            if (mem_byte[i]) begin
                $sformat(tmp, "%02x", tmp_data & `XLEN'hff);
                tmp_data = tmp_data >> 8;
            end
            else tmp = "--";
            if (i == 4) str = {" ", str};
            str = {tmp, str};
        end
        $fdisplay(cpu_tracer_file, "  LOAD  MEM[%08x]: %s", mem_addr & ~32'h3, str);
    end
    if (valid & mem_req & mem_wr) begin
        str = "";
        tmp_data = mem_wdata;
        for (i = 0; i < `XLEN/8; i = i + 1) begin
            if (mem_byte[i]) begin
                $sformat(tmp, "%02x", tmp_data & `XLEN'hff);
                tmp_data = tmp_data >> 8;
            end
            else begin
                tmp = "--";
                tmp_data = tmp_data >> 8;
            end
            if (i == 4) str = {" ", str};
            str = {tmp, str};
        end
        $fdisplay(cpu_tracer_file, "  STORE MEM[%08x]: %s", mem_addr & ~32'h3, str);
    end
    if (rd_wr) begin
        if (misa_mxl[1]) $fdisplay(cpu_tracer_file, "  %-8s  %016x", regs_name(rd_addr), rd_addr ? len_64 ? rd_data : {{32{rd_data[31]}}, rd_data[31:0]} : 64'b0);
        else             $fdisplay(cpu_tracer_file, "  %-8s  %08x",  regs_name(rd_addr), rd_addr ? rd_data : 32'b0);
    end
    if (csr_wr) begin
        if (misa_mxl[1]) $fdisplay(cpu_tracer_file, "  %-8s  %016x", csr_name(csr_waddr), csr_wdata);
        else             $fdisplay(cpu_tracer_file, "  %-8s  %08x", csr_name(csr_waddr), csr_wdata);
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
