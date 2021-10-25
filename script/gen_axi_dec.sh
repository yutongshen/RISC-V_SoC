#!/bin/bash
source ./$(dirname ${0})/util.sh;

mstnum=${1};

fname="axi_1to${1}_dec.sv";
module="axi_1to${1}_dec";
outstanding="${2}";
sbfile="${3}";
mapfile="${4}";
id_ext="${5}"
if [ "${id_ext}" == "" ]; then
    id_ext="0";
fi

declare -A aw_chn_sideband;
declare -A  w_chn_sideband;
declare -A  b_chn_sideband;
declare -A ar_chn_sideband;
declare -A  r_chn_sideband;

# get sideband
echo "Get sideband"
while read -r line
do
    case $line in
        aw* ) 
            echo "[AW] ${line}";
            read -r name width <<< ${line};
            aw_chn_sideband["${name}"]=${width};
            ;;
        w*  ) 
            echo "[W]  ${line}"
            read -r name width <<< ${line};
            w_chn_sideband["${name}"]=${width};
            ;;
        b*  )
            echo "[B]  ${line}"
            read -r name width <<< ${line};
            b_chn_sideband["${name}"]=${width};
            ;;
        ar* )
            echo "[AR] ${line}"
            read -r name width <<< ${line};
            ar_chn_sideband["${name}"]=${width};
            ;;
        r*  )
            echo "[R]  ${line}"
            read -r name width <<< ${line};
            r_chn_sideband["${name}"]=${width};
            ;;
        \#* ) ;; # ignore
        ""  ) ;; # ignore
        *   ) echo "[ERROR] unknown sideband ${line}";;
    esac
done < ${sbfile}

# remove handshake signal
unset aw_chn_sideband["awvalid"];
unset aw_chn_sideband["awready"];

unset w_chn_sideband["wlast"];
unset w_chn_sideband["wvalid"];
unset w_chn_sideband["wready"];

unset b_chn_sideband["bvalid"];
unset b_chn_sideband["bready"];

unset ar_chn_sideband["arvalid"];
unset ar_chn_sideband["arready"];

unset r_chn_sideband["rlast"];
unset r_chn_sideband["rvalid"];
unset r_chn_sideband["rready"];

if [ "${aw_chn_sideband["awid"]+1}" != "1" ]; then
    aw_chn_sideband["awid"]=10;
fi
aw_chn_sideband["awid"]=`expr ${aw_chn_sideband["awid"]} + ${id_ext}`;
w_chn_sideband["wid"]=${aw_chn_sideband["awid"]};
b_chn_sideband["bid"]=${aw_chn_sideband["awid"]};
ar_chn_sideband["arid"]=${aw_chn_sideband["awid"]};
r_chn_sideband["rid"]=${aw_chn_sideband["awid"]};

declare -p aw_chn_sideband
declare -p w_chn_sideband
declare -p b_chn_sideband
declare -p ar_chn_sideband
declare -p r_chn_sideband

# get slave mapping
tmp=0;
slvbase=();
slvsize=();
echo "Get memory map"
while read -r line
do
    case $line in
        [0-9]* ) 
            read -r base size <<< ${line};
            slvbase+=(${base});
            slvsize+=(${size});
            echo "slv${tmp} base: 0x${slvbase[${tmp}]}, size: 0x${slvsize[${tmp}]}";
            tmp=`expr ${tmp} + 1`;
            ;;
        \#* ) ;; # ignore
        ""  ) ;; # ignore
        *   ) echo "[ERROR] unknown sideband ${line}";;
    esac
done < ${mapfile}

rm -f ${fname};
touch ${fname};


echo   "/*-----------------------------------------------------*/" >> ${fname};
printf "// %s is generated by %s\n" ${fname} ${0}                  >> ${fname};
echo   "//"                                                        >> ${fname};
printf "// %50s\n" $(date +"%Y-%m-%d %H:%M:%S")                    >> ${fname};
echo   "/*-----------------------------------------------------*/" >> ${fname};
echo   ""                                                          >> ${fname};
printf "module %s (\n" "${module}" >> ${fname};
print_io i 1 aclk 1                >> ${fname};
print_io i 1 aresetn               >> ${fname};
# slave port
for item in "${!aw_chn_sideband[@]}"; do
    print_io i ${aw_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io i 1 s_awvalid          >> ${fname};
print_io o 1 s_awready          >> ${fname};
for item in "${!w_chn_sideband[@]}"; do
    print_io i ${w_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io i 1 s_wlast            >> ${fname};
print_io i 1 s_wvalid           >> ${fname};
print_io o 1 s_wready           >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    print_io o ${b_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io o 1 s_bvalid           >> ${fname};
print_io i 1 s_bready           >> ${fname};
for item in "${!ar_chn_sideband[@]}"; do
    print_io i ${ar_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io i 1 s_arvalid          >> ${fname};
print_io o 1 s_arready          >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    print_io o ${r_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io o 1 s_rlast            >> ${fname};
print_io o 1 s_rvalid           >> ${fname};
print_io i 1 s_rready           >> ${fname};

# master port
for (( i = 0; i < ${mstnum}; i++ )); do
    for item in "${!aw_chn_sideband[@]}"; do
        print_io o ${aw_chn_sideband[${item}]} m${i}_${item} >> ${fname};
    done
    print_io o 1 m${i}_awvalid          >> ${fname};
    print_io i 1 m${i}_awready          >> ${fname};
    for item in "${!w_chn_sideband[@]}"; do
        print_io o ${w_chn_sideband[${item}]} m${i}_${item} >> ${fname};
    done
    print_io o 1 m${i}_wlast            >> ${fname};
    print_io o 1 m${i}_wvalid           >> ${fname};
    print_io i 1 m${i}_wready           >> ${fname};
    for item in "${!b_chn_sideband[@]}"; do
        print_io i ${b_chn_sideband[${item}]} m${i}_${item} >> ${fname};
    done
    print_io i 1 m${i}_bvalid           >> ${fname};
    print_io o 1 m${i}_bready           >> ${fname};
    for item in "${!ar_chn_sideband[@]}"; do
        print_io o ${ar_chn_sideband[${item}]} m${i}_${item} >> ${fname};
    done
    print_io o 1 m${i}_arvalid          >> ${fname};
    print_io i 1 m${i}_arready          >> ${fname};
    for item in "${!r_chn_sideband[@]}"; do
        print_io i ${r_chn_sideband[${item}]} m${i}_${item} >> ${fname};
    done
    print_io i 1 m${i}_rlast            >> ${fname};
    print_io i 1 m${i}_rvalid           >> ${fname};
    print_io o 1 m${i}_rready           >> ${fname};
done
printf "\n);\n\n"               >> ${fname};

for item in "${!aw_chn_sideband[@]}"; do
    print_logic_2d m_${item} ${aw_chn_sideband[${item}]} `expr ${mstnum} + 1` >> ${fname};
done
for item in "${!w_chn_sideband[@]}"; do
    print_logic_2d m_${item} ${w_chn_sideband[${item}]}  `expr ${mstnum} + 1` >> ${fname};
done
for item in "${!b_chn_sideband[@]}"; do
    print_logic_2d m_${item} ${b_chn_sideband[${item}]}  `expr ${mstnum} + 1` >> ${fname};
done
for item in "${!ar_chn_sideband[@]}"; do
    print_logic_2d m_${item} ${ar_chn_sideband[${item}]} `expr ${mstnum} + 1` >> ${fname};
done
for item in "${!r_chn_sideband[@]}"; do
    print_logic_2d m_${item} ${r_chn_sideband[${item}]}  `expr ${mstnum} + 1` >> ${fname};
done
echo "" >> ${fname};
print_logic m_arvalid  `expr ${mstnum} + 1` >> ${fname};
print_logic m_arready  `expr ${mstnum} + 1` >> ${fname};
print_logic m_rlast    `expr ${mstnum} + 1` >> ${fname};
print_logic m_rvalid   `expr ${mstnum} + 1` >> ${fname};
print_logic m_rready   `expr ${mstnum} + 1` >> ${fname};
print_logic m_awvalid  `expr ${mstnum} + 1` >> ${fname};
print_logic m_awready  `expr ${mstnum} + 1` >> ${fname};
print_logic m_wlast    `expr ${mstnum} + 1` >> ${fname};
print_logic m_wvalid   `expr ${mstnum} + 1` >> ${fname};
print_logic m_wready   `expr ${mstnum} + 1` >> ${fname};
print_logic m_bvalid   `expr ${mstnum} + 1` >> ${fname};
print_logic m_bready   `expr ${mstnum} + 1` >> ${fname};
echo "" >> ${fname};
for (( i=0; i<${mstnum}; i++ )); do
    for item in "${!aw_chn_sideband[@]}"; do
        printf "assign %-10s = %-10s[%d];\n" m${i}_${item} m_${item} ${i} >> ${fname};
    done                                                   
    for item in "${!w_chn_sideband[@]}"; do                
        printf "assign %-10s = %-10s[%d];\n" m${i}_${item} m_${item} ${i} >> ${fname};
    done                                                   
    for item in "${!ar_chn_sideband[@]}"; do               
        printf "assign %-10s = %-10s[%d];\n" m${i}_${item} m_${item} ${i} >> ${fname};
    done
done
echo "" >> ${fname};
for (( i=0; i<${mstnum}; i++ )); do
    for item in "${!b_chn_sideband[@]}"; do
        printf "assign %-10s[%d] = %s;\n" m_${item} ${i} m${i}_${item} >> ${fname};
    done                                                                 
    for item in "${!r_chn_sideband[@]}"; do                              
        printf "assign %-10s[%d] = %s;\n" m_${item} ${i} m${i}_${item} >> ${fname};
    done
done
echo "" >> ${fname};
for (( i=0; i<${mstnum}; i++ )); do
    printf "assign %-10s = %-10s[%d];\n" m${i}_arvalid m_arvalid ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" m${i}_awvalid m_awvalid ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" m${i}_wvalid  m_wvalid  ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" m${i}_wlast   m_wlast   ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" m${i}_bready  m_bready  ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" m${i}_rready  m_rready  ${i} >> ${fname};
done
echo "" >> ${fname};
for (( i=0; i<${mstnum}; i++ )); do
    printf "assign %-10s[%d] = %s;\n" m_arready ${i} m${i}_arready >> ${fname};
    printf "assign %-10s[%d] = %s;\n" m_awready ${i} m${i}_awready >> ${fname};
    printf "assign %-10s[%d] = %s;\n" m_wready  ${i} m${i}_wready  >> ${fname};
    printf "assign %-10s[%d] = %s;\n" m_bvalid  ${i} m${i}_bvalid  >> ${fname};
    printf "assign %-10s[%d] = %s;\n" m_rlast   ${i} m${i}_rlast   >> ${fname};
    printf "assign %-10s[%d] = %s;\n" m_rvalid  ${i} m${i}_rvalid  >> ${fname};
done
echo "" >> ${fname};

print_logic awsel `expr ${mstnum} + 1` >> ${fname};
print_logic wsel  `expr ${mstnum} + 1` >> ${fname};
print_logic bsel  `expr ${mstnum} + 1` >> ${fname};
print_logic arsel `expr ${mstnum} + 1` >> ${fname};
print_logic rsel  `expr ${mstnum} + 1` >> ${fname};
echo "" >> ${fname};
print_logic b_fifo_wr    1      >> ${fname};
print_logic b_fifo_rd    1      >> ${fname};
print_logic b_fifo_empty 1      >> ${fname};
print_logic b_fifo_full  1      >> ${fname};
print_logic r_fifo_wr    1      >> ${fname};
print_logic r_fifo_rd    1      >> ${fname};
print_logic r_fifo_empty 1      >> ${fname};
print_logic r_fifo_full  1      >> ${fname};
echo "" >> ${fname};

for ch in aw ar; do
    for (( i = 0; i < ${mstnum}; i++ )); do
        printf "assign ${ch}sel[%3d] = s_${ch}addr >= %s && s_${ch}addr < %s + %s;\n" \
               ${i} ${aw_chn_sideband[awaddr]}\'h${slvbase[${i}]} \
               ${aw_chn_sideband[awaddr]}\'h${slvbase[${i}]} \
               ${aw_chn_sideband[awaddr]}\'h${slvsize[${i}]} >> ${fname};
    done
    printf "assign ${ch}sel[%3d] = ~|${ch}sel[%d:0]; // default slv\n" ${mstnum} `expr ${mstnum} - 1` >> ${fname};
    echo "" >> ${fname};
done

printf "assign b_fifo_wr = s_awvalid & s_awready;\n" >> ${fname};
printf "assign b_fifo_rd = s_bvalid  & s_bready;\n"  >> ${fname};
echo "" >> ${fname};

printf "assign r_fifo_wr = s_arvalid & s_arready;\n" >> ${fname};
printf "assign r_fifo_rd = s_rlast  & s_rvalid & s_rready;\n"  >> ${fname};
echo "" >> ${fname};

printf "axi_dec_fifo u_b_fifo (\n"       >> ${fname};
print_conn clk   aclk 1                  >> ${fname};
print_conn rstn  aresetn                 >> ${fname};
print_conn wr    b_fifo_wr               >> ${fname};
print_conn wdata awsel                   >> ${fname};
print_conn rd    b_fifo_rd               >> ${fname};
print_conn rdata bsel                    >> ${fname};
print_conn empty b_fifo_empty            >> ${fname};
print_conn full  b_fifo_full             >> ${fname};
printf "\n);\n\n"                        >> ${fname};
printf "axi_dec_fifo u_r_fifo (\n"       >> ${fname};
print_conn clk   aclk 1                  >> ${fname};
print_conn rstn  aresetn                 >> ${fname};
print_conn wr    r_fifo_wr               >> ${fname};
print_conn wdata arsel                   >> ${fname};
print_conn rd    r_fifo_rd               >> ${fname};
print_conn rdata rsel                    >> ${fname};
print_conn empty r_fifo_empty            >> ${fname};
print_conn full  r_fifo_full             >> ${fname};
printf "\n);\n\n"                        >> ${fname};
printf "always_ff @(posedge aclk or negedge aresetn) begin\n" >> ${fname};
printf "    if (~aresetn) begin\n" >> ${fname};
printf "        wsel <= %d'b0;\n" `expr ${mstnum} + 1` >> ${fname};
printf "    end\n" >> ${fname};
printf "    else begin\n" >> ${fname};
printf "        if (s_awvalid & s_awready & ~|wsel) begin\n" >> ${fname};
printf "            wsel <= awsel;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "        else if (s_wlast & s_wvalid & s_wready) begin\n" >> ${fname};
printf "            wsel <= %d'b0;\n" `expr ${mstnum} + 1` >> ${fname};
printf "        end\n" >> ${fname};
printf "    end\n" >> ${fname};
printf "end\n" >> ${fname};
echo "" >> ${fname};
printf "always_comb begin\n" >> ${fname};
printf "    integer i;\n\n" >> ${fname};
printf "    for (i = 0; i <= %d; i = i + 1) begin\n" ${mstnum} >> ${fname};
for item in "${!aw_chn_sideband[@]}"; do
    printf "        %-10s[i] = {%5d{awsel[i]}} & %s;\n" m_${item} ${aw_chn_sideband[${item}]} s_${item} >> ${fname};
done
echo "" >> ${fname};
for item in "${!w_chn_sideband[@]}"; do
    printf "        %-10s[i] = {%5d{ wsel[i]}} & %s;\n" m_${item} ${w_chn_sideband[${item}]} s_${item} >> ${fname};
done
echo "" >> ${fname};
for item in "${!ar_chn_sideband[@]}"; do
    printf "        %-10s[i] = {%5d{arsel[i]}} & %s;\n" m_${item} ${ar_chn_sideband[${item}]} s_${item} >> ${fname};
done
printf "    end\n" >> ${fname};
printf "end\n\n" >> ${fname};
printf "always_comb begin\n" >> ${fname};
printf "    integer i;\n\n" >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    printf "    %-10s = %3d'b0;\n" s_${item} ${b_chn_sideband[${item}]} >> ${fname};
done
echo "" >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    printf "    %-10s = %3d'b0;\n" s_${item} ${r_chn_sideband[${item}]} >> ${fname};
done
printf "    for (i = 0; i <= %d; i = i + 1) begin\n" ${mstnum} >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    printf "        %-10s = %-10s | ({%5d{bsel[i]}} & %-10s[i]);\n" s_${item} s_${item} ${b_chn_sideband[${item}]} m_${item} >> ${fname};
done
echo "" >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    printf "        %-10s = %-10s | ({%5d{rsel[i]}} & %-10s[i]);\n" s_${item} s_${item} ${r_chn_sideband[${item}]} m_${item} >> ${fname};
done
printf "    end\n" >> ${fname};
printf "end\n\n" >> ${fname};

printf "assign m_awvalid = awsel & {%d{s_awvalid & ~b_fifo_full}};\n" `expr ${mstnum} + 1` >> ${fname};
printf "assign s_awready = |(awsel & m_awready) & ~b_fifo_full;\n" >> ${fname};
echo "" >> ${fname};
printf "assign m_wlast   = wsel & {%d{s_wlast }};\n" `expr ${mstnum} + 1` >> ${fname};
printf "assign m_wvalid  = wsel & {%d{s_wvalid}};\n" `expr ${mstnum} + 1` >> ${fname};
printf "assign s_wready  = |(wsel  & m_wready );\n" >> ${fname};
echo "" >> ${fname};
printf "assign s_bvalid  = |(bsel  & m_bvalid) & ~b_fifo_empty;\n" >> ${fname};
printf "assign m_bready  = bsel & {%d{s_bready}};\n" `expr ${mstnum} + 1` >> ${fname};
echo "" >> ${fname};
printf "assign m_arvalid = arsel & {%d{s_arvalid & ~r_fifo_full}};\n" `expr ${mstnum} + 1` >> ${fname};
printf "assign s_arready = |(arsel & m_arready) & ~r_fifo_full;\n" >> ${fname};
echo "" >> ${fname};
printf "assign s_rlast   = |(rsel  & m_rlast ) & ~r_fifo_empty;\n" >> ${fname};
printf "assign s_rvalid  = |(rsel  & m_rvalid) & ~r_fifo_empty;\n" >> ${fname};
printf "assign m_rready  = rsel & {%d{s_rready}};\n" `expr ${mstnum} + 1` >> ${fname};
echo "" >> ${fname};

printf "axi_dfslv u_axi_dfslv (\n" >> ${fname};
print_conn aclk    aclk 1          >> ${fname};
print_conn aresetn aresetn         >> ${fname};
for item in "${!aw_chn_sideband[@]}"; do
    print_conn s_${item} "m_${item}[${mstnum}]" >> ${fname};
done
print_conn s_awvalid "m_awvalid[${mstnum}]" >> ${fname};
print_conn s_awready "m_awready[${mstnum}]" >> ${fname};
for item in "${!w_chn_sideband[@]}"; do
    print_conn s_${item} "m_${item}[${mstnum}]" >> ${fname};
done
print_conn s_wlast  "m_wlast[${mstnum}]" >> ${fname};
print_conn s_wvalid "m_wvalid[${mstnum}]" >> ${fname};
print_conn s_wready "m_wready[${mstnum}]" >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    print_conn s_${item} "m_${item}[${mstnum}]" >> ${fname};
done
print_conn s_bvalid "m_bvalid[${mstnum}]" >> ${fname};
print_conn s_bready "m_bready[${mstnum}]" >> ${fname};
for item in "${!ar_chn_sideband[@]}"; do
    print_conn s_${item} "m_${item}[${mstnum}]" >> ${fname};
done
print_conn s_arvalid "m_arvalid[${mstnum}]" >> ${fname};
print_conn s_arready "m_arready[${mstnum}]" >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    print_conn s_${item} "m_${item}[${mstnum}]" >> ${fname};
done
print_conn s_rlast  "m_rlast[${mstnum}]" >> ${fname};
print_conn s_rvalid "m_rvalid[${mstnum}]" >> ${fname};
print_conn s_rready "m_rready[${mstnum}]" >> ${fname};
printf "\n);\n\n" >> ${fname};

printf "endmodule\n\n"                >> ${fname};

printf "module axi_dec_fifo (\n"      >> ${fname};
print_io i 1 clk 1                    >> ${fname};
print_io i 1 rstn                     >> ${fname};
print_io i 1 wr                       >> ${fname};
print_io i `expr ${mstnum} + 1` wdata >> ${fname};
print_io i 1 rd                       >> ${fname};
print_io o `expr ${mstnum} + 1` rdata >> ${fname};
print_io o 1 empty                    >> ${fname};
print_io o 1 full                     >> ${fname};
printf "\n);\n\n"                     >> ${fname};
printf "parameter FIFO_DEPTH = %d;\n" ${outstanding} >> ${fname};
echo ""                               >> ${fname};
print_logic_2d fifo `expr ${mstnum} + 1` FIFO_DEPTH >> ${fname};
echo "" >> ${fname};
print_logic wptr `expr $(log2_ceil ${outstanding}) + 1` >> ${fname};
print_logic rptr `expr $(log2_ceil ${outstanding}) + 1` >> ${fname};
echo "" >> ${fname};
printf "assign empty = wptr == rptr;\n" >> ${fname};
if [ "$(log2_ceil ${outstanding})" == "0" ]; then
    printf "assign full  = wptr ^ rptr;\n" >> ${fname};
else
    printf "assign full  = (wptr[%d] ^ rptr[%d]) && (wptr[0+:%d] == rptr[0+:%d]);\n" \
           $(log2_ceil ${outstanding}) $(log2_ceil ${outstanding}) \
           $(log2_ceil ${outstanding}) $(log2_ceil ${outstanding}) >> ${fname};
fi
echo "" >> ${fname};
if [ "$(log2_ceil ${outstanding})" == "0" ]; then
    printf "assign rdata = fifo[0];\n" >> ${fname};
else
    printf "assign rdata = fifo[rptr[0+:%d]];\n" $(log2_ceil ${outstanding}) >> ${fname};
fi
echo "" >> ${fname};
printf "always_ff @(posedge clk or negedge rstn) begin\n" >> ${fname};
printf "    integer i;\n\n" >> ${fname};
printf "    if (~rstn) begin\n" >> ${fname};
printf "        wptr <= %d'b0;\n" `expr $(log2_ceil ${outstanding}) + 1` >> ${fname};
printf "        rptr <= %d'b0;\n" `expr $(log2_ceil ${outstanding}) + 1` >> ${fname};
printf "    end\n" >> ${fname};
printf "    else begin\n" >> ${fname};
printf "        if (wr & ~full)  wptr <= wptr + %d'b1;\n" `expr $(log2_ceil ${outstanding}) + 1` >> ${fname};
printf "        if (rd & ~empty) rptr <= rptr + %d'b1;\n" `expr $(log2_ceil ${outstanding}) + 1` >> ${fname};
printf "    end\n\n" >> ${fname};
printf "    if (~rstn) begin\n" >> ${fname};
printf "        for (i = 0; i < FIFO_DEPTH; i = i + 1)\n" >> ${fname};
printf "            fifo[i] <= %d'b0;\n" `expr ${mstnum} + 1` >> ${fname};
printf "    end\n" >> ${fname};
printf "    else begin\n" >> ${fname};
if [ "$(log2_ceil ${outstanding})" == "0" ]; then
    printf "        if (wr & ~full) fifo[0] <= wdata;\n" >> ${fname};
else
    printf "        if (wr & ~full) fifo[wptr[0+:%d]] <= wdata;\n" $(log2_ceil ${outstanding}) >> ${fname};
fi
printf "    end\n" >> ${fname};
printf "end\n" >> ${fname};
echo "endmodule" >> ${fname};
echo "" >> ${fname};
printf "module axi_dfslv (\n" >> ${fname};
print_io i 1 aclk 1           >> ${fname};
print_io i 1 aresetn          >> ${fname};
# slave port
for item in "${!aw_chn_sideband[@]}"; do
    print_io i ${aw_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io i 1 s_awvalid          >> ${fname};
print_io o 1 s_awready          >> ${fname};
for item in "${!w_chn_sideband[@]}"; do
    print_io i ${w_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io i 1 s_wlast            >> ${fname};
print_io i 1 s_wvalid           >> ${fname};
print_io o 1 s_wready           >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    print_io o ${b_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io o 1 s_bvalid           >> ${fname};
print_io i 1 s_bready           >> ${fname};
for item in "${!ar_chn_sideband[@]}"; do
    print_io i ${ar_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io i 1 s_arvalid          >> ${fname};
print_io o 1 s_arready          >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    print_io o ${r_chn_sideband[${item}]} s_${item} >> ${fname};
done
print_io o 1 s_rlast            >> ${fname};
print_io o 1 s_rvalid           >> ${fname};
print_io i 1 s_rready           >> ${fname};
printf "\n);\n\n" >> ${fname};
printf "\`define AXI_RESP_OKAY   2'b00\n" >> ${fname};
printf "\`define AXI_RESP_EXOKAY 2'b01\n" >> ${fname};
printf "\`define AXI_RESP_SLVERR 2'b10\n" >> ${fname};
printf "\`define AXI_RESP_DECERR 2'b11\n" >> ${fname};
echo "" >> ${fname};
printf "// READ\n" >> ${fname};
print_logic rlen ${ar_chn_sideband["arlen"]} >> ${fname};
echo "" >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    if [ "${item}" != "rresp" ] && [ "${item}" != "rid" ]; then
        printf "assign %-10s = %3d'b0;\n" s_${item} ${r_chn_sideband[${item}]} >> ${fname};
    fi
done
printf "assign s_rresp    = \`AXI_RESP_DECERR;\n" >> ${fname};
printf "assign s_rlast    = ~|rlen;\n" >> ${fname};
printf "assign s_arready  = ~s_rvalid | (s_rlast & s_rvalid & s_rready);\n" >> ${fname};
echo "" >> ${fname};
printf "always_ff @(posedge aclk or negedge aresetn) begin\n" >> ${fname};
printf "    if (~aresetn) begin\n" >> ${fname};
printf "        s_rid <= %3d'b0;\n" ${r_chn_sideband["rid"]} >> ${fname};
printf "    end\n" >> ${fname};
printf "    else begin\n" >> ${fname};
printf "        if (s_arvalid & s_arready) begin\n" >> ${fname};
printf "            s_rid <= s_arid;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "    end\n" >> ${fname};
echo "" >> ${fname};
printf "    if (~aresetn) begin\n" >> ${fname};
printf "        rlen <= %d'b0;\n" ${ar_chn_sideband["arlen"]} >> ${fname};
printf "    end\n" >> ${fname};
printf "    else begin\n" >> ${fname};
printf "        if (s_arvalid & s_arready) begin\n" >> ${fname};
printf "            rlen <= s_arlen;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "        else if (~s_rlast & s_rvalid & s_rready) begin\n" >> ${fname};
printf "            rlen <= rlen - %d'b1;\n" ${ar_chn_sideband["arlen"]} >> ${fname};
printf "        end\n" >> ${fname};
printf "    end\n" >> ${fname};
echo "" >> ${fname};
printf "    if (~aresetn) begin\n" >> ${fname};
printf "        s_rvalid <= 1'b0;\n" >> ${fname};
printf "    end\n" >> ${fname};
printf "    else begin\n" >> ${fname};
printf "        if (s_arvalid & s_arready) begin\n" >> ${fname};
printf "            s_rvalid <= 1'b1;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "        else if (s_rlast & s_rvalid & s_rready) begin\n" >> ${fname};
printf "            s_rvalid <= 1'b0;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "    end\n" >> ${fname};
printf "end\n" >> ${fname};
echo "" >> ${fname};

printf "// WRITE\n" >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    if [ "${item}" != "bresp" ] && [ "${item}" != "bid" ]; then
        printf "assign %-10s = %3d'b0;\n" s_${item} ${b_chn_sideband[${item}]} >> ${fname};
    fi
done
printf "assign s_bresp    = \`AXI_RESP_DECERR;\n" >> ${fname};
printf "assign s_awready  = (~s_wready & ~s_bvalid) | (s_bvalid & s_bready);\n" >> ${fname};
echo "" >> ${fname};
printf "always_ff @(posedge aclk or negedge aresetn) begin\n" >> ${fname};
printf "    if (~aresetn) begin\n" >> ${fname};
printf "        s_wready <= 1'b0;\n" >> ${fname};
printf "    end\n" >> ${fname};
printf "    else begin\n" >> ${fname};
printf "        if (s_awvalid & s_awready) begin\n" >> ${fname};
printf "            s_wready <= 1'b1;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "        else if (s_wvalid & s_wlast) begin\n" >> ${fname};
printf "            s_wready <= 1'b0;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "    end\n" >> ${fname};
echo "" >> ${fname};
printf "    if (~aresetn) begin\n" >> ${fname};
printf "        s_bid <= %d'b0;\n" ${b_chn_sideband["bid"]} >> ${fname};
printf "    end\n" >> ${fname};
printf "    else begin\n" >> ${fname};
printf "        if (s_awvalid & s_awready) begin\n" >> ${fname};
printf "            s_bid <= s_awid;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "    end\n" >> ${fname};
echo "" >> ${fname};
printf "    if (~aresetn) begin\n" >> ${fname};
printf "        s_bvalid <= 1'b0;\n" >> ${fname};
printf "    end\n" >> ${fname};
printf "    else begin\n" >> ${fname};
printf "        if (s_wvalid & s_wlast & s_wready) begin\n" >> ${fname};
printf "            s_bvalid <= 1'b1;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "        else if (s_bready) begin\n" >> ${fname};
printf "            s_bvalid <= 1'b0;\n" >> ${fname};
printf "        end\n" >> ${fname};
printf "    end\n" >> ${fname};
printf "end\n" >> ${fname};
echo "" >> ${fname};
echo "endmodule" >> ${fname};
