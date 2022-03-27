`include "mmap.h"
`include "tmdl_mmap.h"

`define TM_INFO_ADDR   (`TMDL_BASE+`TMDL_TM_INFO)
`define TM_ERROR_ADDR  (`TMDL_BASE+`TMDL_TM_ERROR)
`define TM_ARGS_ADDR   (`TMDL_BASE+`TMDL_TM_ARGS)
`define TM_SIMEND_ADDR (`TMDL_BASE+`TMDL_TM_SIMEND)
`define TM_SD_SECT_ADDR (`TMDL_BASE+`TMDL_TM_SD_SECT)
`define TM_SD_DEST_ADDR (`TMDL_BASE+`TMDL_TM_SD_DEST)
`define TM_SD_RBLK_ADDR (`TMDL_BASE+`TMDL_TM_SD_RBLK)
`define TM_ICACHE_FLUSH_ADDR (`TMDL_BASE+`TMDL_TM_ICACHE_FLUSH)
`define TM_DCACHE_FLUSH_ADDR (`TMDL_BASE+`TMDL_TM_DCACHE_FLUSH)
`define TM_FIFO_DEPTH 16
`define CPU_TOP u_cpu_wrap.u_cpu_top

logic [                      63:0] arg_fifo [`TM_FIFO_DEPTH];
logic [$clog2(`TM_FIFO_DEPTH)-1:0] wptr;
logic [$clog2(`TM_FIFO_DEPTH)-1:0] rptr;
logic [                      31:0] sd_sect;
logic [                      31:0] sd_dest;
logic [                       7:0] sd_tmp;
string tmdl_log [$];
string sd_image_path;
int    sd_image;
int    err_cnt;

initial begin
    string tmp;
    int f;
    f = $fopen("tmdl_msg.log", "r");
    if (f) begin
        while (!$feof(f)) begin
            $fgets(tmp, f);
            tmdl_log.push_back(tmp);
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        wptr <= 0;
        rptr <= 0;
        err_cnt <= 0;
        sd_sect <= 0;
        sd_dest <= 0;
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
            `TM_SD_SECT_ADDR: begin
                sd_sect <= `CPU_TOP.dmem_wdata;
            end
            `TM_SD_DEST_ADDR: begin
                sd_dest <= `CPU_TOP.dmem_wdata;
            end
            `TM_SD_RBLK_ADDR: begin
                $sformat(sd_image_path, "../mdl/sd_image/sd_image_%08x.bin", sd_sect);
                $display("%0d ns: [FAKE_SD] READ SD sector: %8x to SRAM[%8x]", $time, sd_sect, sd_dest);
                sd_image = $fopen(sd_image_path, "rb");
                for (i = 0; i < 512; i = i + 1) begin
                    if (sd_image) begin
                        $fread(sd_tmp, sd_image);
                        `SRAM_DATA((i+sd_dest-`SRAM_BASE)/4)[((i+sd_dest)&3)*8+:8] = sd_tmp;
                    end
                    else begin
                        if (i & 1) `SRAM_DATA((i+sd_dest-`SRAM_BASE)/4)[((i+sd_dest)&3)*8+:8] = 8'had;
                        else       `SRAM_DATA((i+sd_dest-`SRAM_BASE)/4)[((i+sd_dest)&3)*8+:8] = 8'hde;
                    end
                end
                $fclose(sd_image);
            end
            `TM_ICACHE_FLUSH_ADDR: begin
                $display("%6d ns: [TMDL] I-Cache flushed", $time);
                force u_cpu_wrap.u_l1ic.valid = 64'b0;
                #1;
                release u_cpu_wrap.u_l1ic.valid;
            end
            `TM_DCACHE_FLUSH_ADDR: begin
                $display("%6d ns: [TMDL] D-Cache flushed", $time);
                force u_cpu_wrap.u_l1dc.valid = 64'b0;
                #1;
                release u_cpu_wrap.u_l1dc.valid;
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
