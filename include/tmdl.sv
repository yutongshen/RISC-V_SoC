`include "mmap.h"
`include "tmdl_mmap.h"

`define TM_INFO_ADDR   (`TMDL_BASE+`TMDL_TM_INFO)
`define TM_ERROR_ADDR  (`TMDL_BASE+`TMDL_TM_ERROR)
`define TM_ARGS_ADDR   (`TMDL_BASE+`TMDL_TM_ARGS)
`define TM_SIMEND_ADDR (`TMDL_BASE+`TMDL_TM_SIMEND)
`define TM_FIFO_DEPTH 16
`define CPU_TOP u_cpu_wrap.u_cpu_top

logic [                      64:0] arg_fifo [`TM_FIFO_DEPTH];
logic [$clog2(`TM_FIFO_DEPTH)-1:0] wptr;
logic [$clog2(`TM_FIFO_DEPTH)-1:0] rptr;
string tmdl_log [$];
int    err_cnt;

initial begin
    string tmp;
    int f;
    f = $fopen("tmdl_msg.log", "r");
    while (!$feof(f)) begin
        $fgets(tmp, f);
        tmdl_log.push_back(tmp);
    end
end

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        wptr <= 0;
        rptr <= 0;
        err_cnt <= 0;
    end
    else if (`CPU_TOP.dmem_en && `CPU_TOP.dmem_write) begin
        case (`CPU_TOP.dmem_addr)
            `TM_INFO_ADDR: begin
                $write("%6d ns: [TM_INFO] ", $time);
                tm_print(tmdl_log[`CPU_TOP.dmem_wdata]);
                $write("\n");
            end
            `TM_ERROR_ADDR: begin
                err_cnt <= err_cnt + 1;
                $write("%6d ns: [TM_ERROR] **ERROR** ", $time);
                tm_print(tmdl_log[`CPU_TOP.dmem_wdata]);
                $write("\n");
            end
            `TM_ARGS_ADDR: begin
                arg_fifo[wptr] <= `CPU_TOP.dmem_wdata;
                wptr           <= wptr + 1;
            end
            `TM_SIMEND_ADDR: begin
                $display("\n### Simulation end ###\n");
                if (err_cnt) begin
                    $display("There ars %0d error", err_cnt);
                    $display("'########::::'###::::'####:'##:::::::");
                    $display(" ##.....::::'## ##:::. ##:: ##:::::::");
                    $display(" ##::::::::'##:. ##::: ##:: ##:::::::");
                    $display(" ######:::'##:::. ##:: ##:: ##:::::::");
                    $display(" ##...:::: #########:: ##:: ##:::::::");
                    $display(" ##::::::: ##.... ##:: ##:: ##:::::::");
                    $display(" ##::::::: ##:::: ##:'####: ########:");
                    $display("..::::::::..:::::..::....::........::"); 
                end
                else begin
                    $display("'########:::::'###:::::'######:::'######::");
                    $display(" ##.... ##:::'## ##:::'##... ##:'##... ##:");
                    $display(" ##:::: ##::'##:. ##:: ##:::..:: ##:::..::");
                    $display(" ########::'##:::. ##:. ######::. ######::");
                    $display(" ##.....::: #########::..... ##::..... ##:");
                    $display(" ##:::::::: ##.... ##:'##::: ##:'##::: ##:");
                    $display(" ##:::::::: ##:::: ##:. ######::. ######::");
                    $display("..:::::::::..:::::..:::......::::......:::");
                end
                simend = 1'b1;
            end
        endcase
    end
end

task tm_print;
    input string fmt;
    
    int i;
    int cont_flag;
    int loop_flag;
    int sfp_fmt;
    string label;
    string str;
    string qualifier;
    string tmp;

    label = "";
    str   = "";

    for (i = 0; fmt[i] != "\n"; i = i + 1) begin
        if (fmt[i] != "%") begin
            if (fmt[i] == "\\") begin
                case (fmt[i+1])
                    "n": str = {str, "\n"};
                endcase
                i = i + 1;
            end
            else begin
                str = {str, fmt[i]};
            end
            continue;
        end
        else begin
            $write("%s", str);
            str = "";
            i = i + 1;
        end
        qualifier = "";
        loop_flag = 0;
        while (!loop_flag) begin
            cont_flag = 0;
            case (fmt[i])
                "\n": return;
                "%": begin
                    $write("%");
                    cont_flag = 1;
                end
                "l": begin
                    qualifier = fmt[i];
                    i = i + 1;
                    continue;
                end
                "h": begin
                    qualifier = fmt[i];
                    i = i + 1;
                    continue;
                end
                "s": $write("[!! TMODEL CANNOT SUPPORT %%%s !!]", fmt[i]);
                "n": $write("[!! TMODEL CANNOT SUPPORT %%%s !!]", fmt[i]);
                "p": $write("0x%16x", arg_fifo[rptr]);
                "c": $write("%c", arg_fifo[rptr][7:0]);
                "d":
                    if (qualifier == "l")
                        $write("%0d", $signed(arg_fifo[rptr]));
                    else if (qualifier == "h")
                        $write("%0d", $signed(arg_fifo[rptr][15:0]));
                    else
                        $write("%0d", $signed(arg_fifo[rptr][31:0]));
                "i":
                    if (qualifier == "l")
                        $write("%0d", $signed(arg_fifo[rptr]));
                    else if (qualifier == "h")
                        $write("%0d", $signed(arg_fifo[rptr][15:0]));
                    else
                        $write("%0d", $signed(arg_fifo[rptr][31:0]));
                "u":
                    if (qualifier == "l")
                        $write("%0d", arg_fifo[rptr]);
                    else if (qualifier == "h")
                        $write("%0d", arg_fifo[rptr][15:0]);
                    else
                        $write("%0d", arg_fifo[rptr][31:0]);
                "o":
                    if (qualifier == "l")
                        $write("%o", arg_fifo[rptr]);
                    else if (qualifier == "h")
                        $write("%o", arg_fifo[rptr][15:0]);
                    else
                        $write("%o", arg_fifo[rptr][31:0]);
                "x":
                    if (qualifier == "l")
                        $write("%16x", arg_fifo[rptr]);
                    else if (qualifier == "h")
                        $write("%4x",  arg_fifo[rptr][15:0]);
                    else
                        $write("%8x",  arg_fifo[rptr][31:0]);
                "X": begin
                    if (qualifier == "l")
                        $sformat(tmp, "%16x", arg_fifo[rptr]);
                    else if (qualifier == "h")
                        $sformat(tmp, "%4x",  arg_fifo[rptr][15:0]);
                    else
                        $sformat(tmp, "%8x",  arg_fifo[rptr][31:0]);
                    $write(tmp.toupper);
                end
                "f": $write("%f", $bitstoshortreal(arg_fifo[rptr][31:0]));
                default: begin
                    i = i + 1;
                    continue;
                end
            endcase
            if (cont_flag) break;
            rptr = rptr + 1;
            loop_flag = 1;
        end
    end
    $write("%s", str);
endtask
