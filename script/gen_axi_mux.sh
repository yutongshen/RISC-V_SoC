#!/bin/bash
source ./$(dirname ${0})/util.sh;

slvnum=${1};

fname="axi_${1}to1_mux.sv";
module="axi_${1}to1_mux";
sbfile="${2}";

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
w_chn_sideband["wid"]=${aw_chn_sideband["awid"]};
b_chn_sideband["bid"]=${aw_chn_sideband["awid"]};
ar_chn_sideband["arid"]=${aw_chn_sideband["awid"]};
r_chn_sideband["rid"]=${aw_chn_sideband["awid"]};

declare -p aw_chn_sideband
declare -p w_chn_sideband
declare -p b_chn_sideband
declare -p ar_chn_sideband
declare -p r_chn_sideband

rm -f ${fname};
touch ${fname};


echo   "/*-----------------------------------------------------*/" >> ${fname};
printf "// %s is generated by %s\n" ${fname} gen_axi_mux.sh        >> ${fname};
echo   "//"                                                        >> ${fname};
printf "// %50s\n" $(date +"%Y-%m-%d %H:%M:%S")                    >> ${fname};
echo   "/*-----------------------------------------------------*/" >> ${fname};
echo   ""                                                          >> ${fname};
printf "module %s (\n" "${module}" >> ${fname};
print_io i 1 aclk 1                >> ${fname};
print_io i 1 aresetn               >> ${fname};
# slave port
for (( i=0; i<${slvnum}; i++ )); do
    for item in "${!aw_chn_sideband[@]}"; do
        print_io i ${aw_chn_sideband[${item}]} s${i}_${item} >> ${fname};
    done
    print_io i 1 s${i}_awvalid          >> ${fname};
    print_io o 1 s${i}_awready          >> ${fname};
    for item in "${!w_chn_sideband[@]}"; do
        print_io i ${w_chn_sideband[${item}]} s${i}_${item} >> ${fname};
    done
    print_io i 1 s${i}_wlast            >> ${fname};
    print_io i 1 s${i}_wvalid           >> ${fname};
    print_io o 1 s${i}_wready           >> ${fname};
    for item in "${!b_chn_sideband[@]}"; do
        print_io o ${b_chn_sideband[${item}]} s${i}_${item} >> ${fname};
    done
    print_io o 1 s${i}_bvalid           >> ${fname};
    print_io i 1 s${i}_bready           >> ${fname};
    for item in "${!ar_chn_sideband[@]}"; do
        print_io i ${ar_chn_sideband[${item}]} s${i}_${item} >> ${fname};
    done
    print_io i 1 s${i}_arvalid          >> ${fname};
    print_io o 1 s${i}_arready          >> ${fname};
    for item in "${!r_chn_sideband[@]}"; do
        print_io o ${r_chn_sideband[${item}]} s${i}_${item} >> ${fname};
    done
    print_io o 1 s${i}_rlast            >> ${fname};
    print_io o 1 s${i}_rvalid           >> ${fname};
    print_io i 1 s${i}_rready           >> ${fname};
done
# master port
for item in "${!aw_chn_sideband[@]}"; do
    if [ "${item}" == "awid" ]; then
        print_io o `expr ${aw_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m_${item} >> ${fname};
    else
        print_io o ${aw_chn_sideband[${item}]} m_${item} >> ${fname};
    fi
done
print_io o 1 m_awvalid          >> ${fname};
print_io i 1 m_awready          >> ${fname};
for item in "${!w_chn_sideband[@]}"; do
    if [ "${item}" == "wid" ]; then
        print_io o `expr ${w_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m_${item} >> ${fname};
    else
        print_io o ${w_chn_sideband[${item}]} m_${item} >> ${fname};
    fi
done
print_io o 1 m_wlast            >> ${fname};
print_io o 1 m_wvalid           >> ${fname};
print_io i 1 m_wready           >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    if [ "${item}" == "bid" ]; then
        print_io i `expr ${b_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m_${item} >> ${fname};
    else
        print_io i ${b_chn_sideband[${item}]} m_${item} >> ${fname};
    fi
done
print_io i 1 m_bvalid           >> ${fname};
print_io o 1 m_bready           >> ${fname};
for item in "${!ar_chn_sideband[@]}"; do
    if [ "${item}" == "arid" ]; then
        print_io o `expr ${ar_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m_${item} >> ${fname};
    else
        print_io o ${ar_chn_sideband[${item}]} m_${item} >> ${fname};
    fi
done
print_io o 1 m_arvalid          >> ${fname};
print_io i 1 m_arready          >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    if [ "${item}" == "rid" ]; then
        print_io i `expr ${r_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m_${item} >> ${fname};
    else
        print_io i ${r_chn_sideband[${item}]} m_${item} >> ${fname};
    fi
done
print_io i 1 m_rlast            >> ${fname};
print_io i 1 m_rvalid           >> ${fname};
print_io o 1 m_rready           >> ${fname};
printf "\n);\n\n"               >> ${fname};

for item in "${!aw_chn_sideband[@]}"; do
    print_logic_2d s_${item} ${aw_chn_sideband[${item}]} ${slvnum} >> ${fname};
done
for item in "${!w_chn_sideband[@]}"; do
    print_logic_2d s_${item} ${w_chn_sideband[${item}]} ${slvnum} >> ${fname};
done
for item in "${!b_chn_sideband[@]}"; do
    print_logic_2d s_${item} ${b_chn_sideband[${item}]} ${slvnum} >> ${fname};
done
for item in "${!ar_chn_sideband[@]}"; do
    print_logic_2d s_${item} ${ar_chn_sideband[${item}]} ${slvnum} >> ${fname};
done
for item in "${!r_chn_sideband[@]}"; do
    print_logic_2d s_${item} ${r_chn_sideband[${item}]} ${slvnum} >> ${fname};
done
echo "" >> ${fname};
print_logic s_arsel    ${slvnum} >> ${fname};
print_logic s_awsel    ${slvnum} >> ${fname};
print_logic s_wsel     ${slvnum} >> ${fname};
echo "" >> ${fname};
print_logic s_arvalid  ${slvnum} >> ${fname};
print_logic s_arready  ${slvnum} >> ${fname};
print_logic s_rlast    ${slvnum} >> ${fname};
print_logic s_rvalid   ${slvnum} >> ${fname};
print_logic s_rready   ${slvnum} >> ${fname};
print_logic s_awvalid  ${slvnum} >> ${fname};
print_logic s_awready  ${slvnum} >> ${fname};
print_logic s_wlast    ${slvnum} >> ${fname};
print_logic s_wvalid   ${slvnum} >> ${fname};
print_logic s_wready   ${slvnum} >> ${fname};
print_logic s_bvalid   ${slvnum} >> ${fname};
print_logic s_bready   ${slvnum} >> ${fname};
echo "" >> ${fname};
for (( i=0; i<${slvnum}; i++ )); do
    for item in "${!aw_chn_sideband[@]}"; do
        printf "assign %-10s[%d] = %s;\n" s_${item} ${i} s${i}_${item} >> ${fname};
    done
    for item in "${!w_chn_sideband[@]}"; do
        printf "assign %-10s[%d] = %s;\n" s_${item} ${i} s${i}_${item} >> ${fname};
    done
    for item in "${!ar_chn_sideband[@]}"; do
        printf "assign %-10s[%d] = %s;\n" s_${item} ${i} s${i}_${item} >> ${fname};
    done
done
echo "" >> ${fname};
for (( i=0; i<${slvnum}; i++ )); do
    for item in "${!b_chn_sideband[@]}"; do
        printf "assign %-10s = %-10s[%d];\n" s${i}_${item} s_${item} ${i} >> ${fname};
    done                                                                 
    for item in "${!r_chn_sideband[@]}"; do                              
        printf "assign %-10s = %-10s[%d];\n" s${i}_${item} s_${item} ${i} >> ${fname};
    done
done
echo "" >> ${fname};
for (( i=0; i<${slvnum}; i++ )); do
    printf "assign %-10s[%d] = %s;\n" s_arvalid ${i} s${i}_arvalid >> ${fname};
    printf "assign %-10s[%d] = %s;\n" s_awvalid ${i} s${i}_awvalid >> ${fname};
    printf "assign %-10s[%d] = %s;\n" s_wvalid  ${i} s${i}_wvalid  >> ${fname};
    printf "assign %-10s[%d] = %s;\n" s_wlast   ${i} s${i}_wlast   >> ${fname};
    printf "assign %-10s[%d] = %s;\n" s_bready  ${i} s${i}_bready  >> ${fname};
    printf "assign %-10s[%d] = %s;\n" s_rready  ${i} s${i}_rready  >> ${fname};
done
echo "" >> ${fname};
for (( i=0; i<${slvnum}; i++ )); do
    printf "assign %-10s = %-10s[%d];\n" s${i}_arready s_arready ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" s${i}_awready s_awready ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" s${i}_wready  s_wready  ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" s${i}_bvalid  s_bvalid  ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" s${i}_rlast   s_rlast   ${i} >> ${fname};
    printf "assign %-10s = %-10s[%d];\n" s${i}_rvalid  s_rvalid  ${i} >> ${fname};
done
echo "" >> ${fname};

printf "%s %s (\n" "axi_arbitrator_${slvnum}s" "u_axi_arbitrator" >> ${fname};
print_conn aclk      aclk 1    >> ${fname};
print_conn aresetn   aresetn   >> ${fname};
print_conn s_arsel   s_arsel   >> ${fname};
print_conn s_awsel   s_awsel   >> ${fname};
print_conn s_wsel    s_wsel    >> ${fname};
print_conn s_arvalid s_arvalid >> ${fname};
print_conn s_arready s_arready >> ${fname};
print_conn s_awvalid s_awvalid >> ${fname};
print_conn s_awready s_awready >> ${fname};
print_conn s_wlast   s_wlast   >> ${fname};
print_conn s_wvalid  s_wvalid  >> ${fname};
print_conn s_wready  s_wready  >> ${fname};
print_conn m_arvalid m_arvalid >> ${fname};
print_conn m_arready m_arready >> ${fname};
print_conn m_awvalid m_awvalid >> ${fname};
print_conn m_awready m_awready >> ${fname};
print_conn m_wlast   m_wlast   >> ${fname};
print_conn m_wvalid  m_wvalid  >> ${fname};
print_conn m_wready  m_wready  >> ${fname};
printf "\n);\n\n"              >> ${fname};
printf "always_comb begin\n"   >> ${fname};
printf "%4sinteger i;\n\n"     >> ${fname};
for item in "${!aw_chn_sideband[@]}"; do
    if [ "${item}" == "awid" ]; then
        printf "%4s%-10s = {(%3d + %3d){1'b0}};\n" "" m_${item} ${aw_chn_sideband[${item}]} $(log2_ceil ${slvnum}) >> ${fname};
    else
        printf "%4s%-10s = {%11d{1'b0}};\n"       "" m_${item} ${aw_chn_sideband[${item}]} >> ${fname};
    fi
done
printf "%4sfor (i = 0; i < %d; i = i + 1) begin\n" "" ${slvnum} >> ${fname};
for item in "${!aw_chn_sideband[@]}"; do
    if [ "${item}" == "awid" ]; then
        printf "%8s%-10s[  0+:%3d] = m_awid[  0+:%3d] | ({%3d{s_awsel[i]}} & %-12s );\n" \
               "" "m_awid" $(log2_ceil ${slvnum}) $(log2_ceil ${slvnum}) \
                           $(log2_ceil ${slvnum}) "i[0+:$(log2_ceil ${slvnum})]" >> ${fname};
        printf "%8s%-10s[%3d+:%3d] = m_awid[%3d+:%3d] | ({%3d{s_awsel[i]}} & %-10s[i]);\n" \
               "" "m_awid" $(log2_ceil ${slvnum}) ${aw_chn_sideband[${item}]} \
                           $(log2_ceil ${slvnum}) ${aw_chn_sideband[${item}]} \
                           ${aw_chn_sideband[${item}]} s_awid >> ${fname};
    else
        printf "%8s%-10s           = %-10s       | ({%3d{s_awsel[i]}} & %-10s[i]);\n" \
               "" m_${item} m_${item} ${aw_chn_sideband[${item}]} s_${item} >> ${fname};
    fi
done
printf "%4send\n\n" >> ${fname};

for item in "${!w_chn_sideband[@]}"; do
    if [ "${item}" == "wid" ]; then
        printf "%4s%-10s = {(%3d + %3d){1'b0}};\n" "" m_${item} ${w_chn_sideband[${item}]} $(log2_ceil ${slvnum}) >> ${fname};
    else
        printf "%4s%-10s = {%11d{1'b0}};\n"       "" m_${item} ${w_chn_sideband[${item}]} >> ${fname};
    fi
done
printf "%4sfor (i = 0; i < %d; i = i + 1) begin\n" "" ${slvnum} >> ${fname};
for item in "${!w_chn_sideband[@]}"; do
    if [ "${item}" == "wid" ]; then
        printf "%8s%-10s[  0+:%3d] = m_wid [  0+:%3d] | ({%3d{s_wsel[i]}} & %-12s );\n" \
               "" "m_wid" $(log2_ceil ${slvnum}) $(log2_ceil ${slvnum}) \
                           $(log2_ceil ${slvnum}) "i[0+:$(log2_ceil ${slvnum})]" >> ${fname};
        printf "%8s%-10s[%3d+:%3d] = m_wid [%3d+:%3d] | ({%3d{s_wsel[i]}} & %-10s[i]);\n" \
               "" "m_wid" $(log2_ceil ${slvnum}) ${w_chn_sideband[${item}]} \
                           $(log2_ceil ${slvnum}) ${w_chn_sideband[${item}]} \
                           ${w_chn_sideband[${item}]} s_wid >> ${fname};
    else
        printf "%8s%-10s           = %-10s       | ({%3d{s_wsel[i]}} & %-10s[i]);\n" \
               "" m_${item} m_${item} ${w_chn_sideband[${item}]} s_${item} >> ${fname};
    fi
done
printf "%4send\n\n" >> ${fname};

for item in "${!ar_chn_sideband[@]}"; do
    if [ "${item}" == "arid" ]; then
        printf "%4s%-10s = {(%3d + %3d){1'b0}};\n" "" m_${item} ${ar_chn_sideband[${item}]} $(log2_ceil ${slvnum}) >> ${fname};
    else
        printf "%4s%-10s = {%11d{1'b0}};\n"       "" m_${item} ${ar_chn_sideband[${item}]} >> ${fname};
    fi
done
printf "%4sfor (i = 0; i < %d; i = i + 1) begin\n" "" ${slvnum} >> ${fname};
for item in "${!ar_chn_sideband[@]}"; do
    if [ "${item}" == "arid" ]; then
        printf "%8s%-10s[  0+:%3d] = m_arid[  0+:%3d] | ({%3d{s_arsel[i]}} & %-12s );\n" \
               "" "m_arid" $(log2_ceil ${slvnum}) $(log2_ceil ${slvnum}) \
                           $(log2_ceil ${slvnum}) "i[0+:$(log2_ceil ${slvnum})]" >> ${fname};
        printf "%8s%-10s[%3d+:%3d] = m_arid[%3d+:%3d] | ({%3d{s_arsel[i]}} & %-10s[i]);\n" \
               "" "m_arid" $(log2_ceil ${slvnum}) ${ar_chn_sideband[${item}]} \
                           $(log2_ceil ${slvnum}) ${ar_chn_sideband[${item}]} \
                           ${ar_chn_sideband[${item}]} s_arid >> ${fname};
    else
        printf "%8s%-10s           = %-10s       | ({%3d{s_arsel[i]}} & %-10s[i]);\n" \
               "" m_${item} m_${item} ${ar_chn_sideband[${item}]} s_${item} >> ${fname};
    fi
done
printf "%4send\n" >> ${fname};
printf "end\n\n" >> ${fname};

print_logic bsel $(log2_ceil ${slvnum})                                    >> ${fname};
print_logic rsel $(log2_ceil ${slvnum})                                    >> ${fname};
echo ""                                                                    >> ${fname};
printf "always_comb begin\n"                                               >> ${fname};
printf "%4sinteger i;\n\n"                                                 >> ${fname};
printf "%4sfor (i = 0; i < %d; i = i + 1) begin\n" "" ${slvnum} >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    if [ "${item}" == "bid" ]; then
        printf "%8s%-10s[i] = {%3d{bsel == i[0+:%3d]}} & %-5s[%3d+:%3d];\n" \
               "" s_${item} ${b_chn_sideband[${item}]} $(log2_ceil ${slvnum}) \
               m_${item} $(log2_ceil ${slvnum}) ${b_chn_sideband[${item}]} >> ${fname};
    else
        printf "%8s%-10s[i] = {%3d{bsel == i[0+:%3d]}} & %s;\n" \
               "" s_${item} ${b_chn_sideband[${item}]} $(log2_ceil ${slvnum}) \
               m_${item}                                                   >> ${fname};
    fi
done
printf "%8s%-10s[i] = {%3d{bsel == i[0+:%3d]}} & %s;\n" \
       "" s_bvalid 1 $(log2_ceil ${slvnum}) m_bvalid                       >> ${fname};
echo ""                                                                    >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    if [ "${item}" == "rid" ]; then
        printf "%8s%-10s[i] = {%3d{rsel == i[0+:%3d]}} & %-5s[%3d+:%3d];\n" \
               "" s_${item} ${r_chn_sideband[${item}]} $(log2_ceil ${slvnum}) \
               m_${item} $(log2_ceil ${slvnum}) ${r_chn_sideband[${item}]} >> ${fname};
    else
        printf "%8s%-10s[i] = {%3d{rsel == i[0+:%3d]}} & %s;\n" \
               "" s_${item} ${r_chn_sideband[${item}]} $(log2_ceil ${slvnum}) \
               m_${item}                                                   >> ${fname};
    fi
done
printf "%8s%-10s[i] = {%3d{rsel == i[0+:%3d]}} & %s;\n" \
       "" s_rlast  1 $(log2_ceil ${slvnum}) m_rlast                        >> ${fname};
printf "%8s%-10s[i] = {%3d{rsel == i[0+:%3d]}} & %s;\n" \
       "" s_rvalid 1 $(log2_ceil ${slvnum}) m_rvalid                       >> ${fname};
printf "%4send\n" >> ${fname};
printf "end\n\n"                                                           >> ${fname};
printf "assign %-4s = %-5s[  0+:%3d];\n" bsel m_bid $(log2_ceil ${slvnum}) >> ${fname};
printf "assign %-4s = %-5s[  0+:%3d];\n" rsel m_rid $(log2_ceil ${slvnum}) >> ${fname};
echo ""                                                                    >> ${fname};
printf "assign m_bready = s_bready[bsel];\n"                               >> ${fname};
printf "assign m_rready = s_rready[rsel];\n"                               >> ${fname};
echo ""                                                                    >> ${fname};

printf "endmodule\n\n"                             >> ${fname};

printf "module %s (\n" "axi_arbitrator_${slvnum}s" >> ${fname};
print_io i 1         aclk 1                        >> ${fname};
print_io i 1         aresetn                       >> ${fname};
print_io o ${slvnum} s_arsel                       >> ${fname};
print_io o ${slvnum} s_awsel                       >> ${fname};
print_io o ${slvnum} s_wsel                        >> ${fname};
print_io i ${slvnum} s_arvalid                     >> ${fname};
print_io o ${slvnum} s_arready                     >> ${fname};
print_io i ${slvnum} s_awvalid                     >> ${fname};
print_io o ${slvnum} s_awready                     >> ${fname};
print_io i ${slvnum} s_wlast                       >> ${fname};
print_io i ${slvnum} s_wvalid                      >> ${fname};
print_io o ${slvnum} s_wready                      >> ${fname};
print_io o 1         m_arvalid                     >> ${fname};
print_io i 1         m_arready                     >> ${fname};
print_io o 1         m_awvalid                     >> ${fname};
print_io i 1         m_awready                     >> ${fname};
print_io o 1         m_wlast                       >> ${fname};
print_io o 1         m_wvalid                      >> ${fname};
print_io i 1         m_wready                      >> ${fname};
printf "\n);\n\n"                                  >> ${fname};
printf "parameter SLV_NUM = %d;\n\n" ${slvnum}     >> ${fname};
echo "// AR arbitrator"                            >> ${fname};
echo "logic [SLV_NUM - 1:0] ar_prior;"             >> ${fname};
echo "logic [SLV_NUM - 1:0] ar_prior_nxt;"         >> ${fname};
echo ""                                            >> ${fname};

echo "assign ar_prior_nxt = {ar_prior[SLV_NUM - 2:0], ar_prior[SLV_NUM - 1]};" >> ${fname};
echo ""                                                                        >> ${fname};
echo "always_ff @(posedge aclk or negedge aresetn) begin"                      >> ${fname};
echo "    if (~aresetn) begin"                                                 >> ${fname};
echo "        ar_prior <= {{(SLV_NUM-1){1'b0}}, 1'b1};"                        >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "    else begin"                                                          >> ${fname};
echo "        if (m_arvalid & m_arready) begin"                                >> ${fname};
echo "            ar_prior <= ar_prior_nxt;"                                   >> ${fname};
echo "        end"                                                             >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "end"                                                                     >> ${fname};
echo ""                                                                        >> ${fname};
echo "logic [SLV_NUM - 1:0] ar_grant_matrix [0:SLV_NUM - 1];"                  >> ${fname};
echo ""                                                                        >> ${fname};
echo "always_comb begin"                                                       >> ${fname};
echo "    integer i, j, k;"                                                    >> ${fname};
echo "    for (i = 0; i < SLV_NUM; i = i + 1) begin"                           >> ${fname};
echo "        ar_grant_matrix[i] = ar_prior;"                                  >> ${fname};
echo "        for (j = 0; j < SLV_NUM - 1; j = j + 1) begin"                   >> ${fname};
echo "            for (k = 1; k < SLV_NUM - j; k = k + 1) begin"               >> ${fname};
echo "                ar_grant_matrix[i][(i + j + 1) % SLV_NUM] = ar_grant_matrix[i][(i + j + 1) % SLV_NUM] &" >> ${fname};
echo "                                                            ~s_arvalid[(i - k + SLV_NUM) % SLV_NUM];" >> ${fname};
echo "            end"                                                         >> ${fname};
echo "        end"                                                             >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "end"                                                                     >> ${fname};
echo ""                                                                        >> ${fname};
echo "always_comb begin"                                                       >> ${fname};
echo "    integer i;"                                                          >> ${fname};
echo "    for (i = 0; i < SLV_NUM; i = i + 1) begin"                           >> ${fname};
echo "        s_arready[i]  = s_arvalid[i] & (|ar_grant_matrix[i]) & m_arready;" >> ${fname};
echo "        s_arsel  [i]  = s_arvalid[i] & (|ar_grant_matrix[i]);"           >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "end"                                                                     >> ${fname};
echo ""                                                                        >> ${fname};
echo "assign m_arvalid = |s_arvalid;"                                          >> ${fname};
echo ""                                                                        >> ${fname};
echo "// AW arbitrator"                                                        >> ${fname};
echo "logic [SLV_NUM - 1:0] aw_prior;"                                         >> ${fname};
echo "logic [SLV_NUM - 1:0] aw_prior_nxt;"                                     >> ${fname};
echo ""                                                                        >> ${fname};
echo "assign aw_prior_nxt = {aw_prior[SLV_NUM - 2:0], aw_prior[SLV_NUM - 1]};" >> ${fname};
echo ""                                                                        >> ${fname};
echo "always_ff @(posedge aclk or negedge aresetn) begin"                      >> ${fname};
echo "    if (~aresetn) begin"                                                 >> ${fname};
echo "        aw_prior <= {{(SLV_NUM-1){1'b0}}, 1'b1};"                        >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "    else begin"                                                          >> ${fname};
echo "        if (m_wlast & m_wvalid & m_wready) begin"                        >> ${fname};
echo "            aw_prior <= aw_prior_nxt;"                                   >> ${fname};
echo "        end"                                                             >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "end"                                                                     >> ${fname};
echo "logic [SLV_NUM - 1:0] aw_grant_matrix [0:SLV_NUM - 1];"                  >> ${fname};
echo ""                                                                        >> ${fname};
echo "always_comb begin"                                                       >> ${fname};
echo "    integer i, j, k;"                                                    >> ${fname};
echo "    for (i = 0; i < SLV_NUM; i = i + 1) begin"                           >> ${fname};
echo "        aw_grant_matrix[i] = aw_prior;"                                  >> ${fname};
echo "        for (j = 0; j < SLV_NUM - 1; j = j + 1) begin"                   >> ${fname};
echo "            for (k = 1; k < SLV_NUM - j; k = k + 1) begin"               >> ${fname};
echo "                aw_grant_matrix[i][(i + j + 1) % SLV_NUM] =  aw_grant_matrix[i][(i + j + 1) % SLV_NUM] &" >> ${fname};
echo "                                                            ~s_awvalid[(i - k + SLV_NUM) % SLV_NUM];" >> ${fname};
echo "            end"                                                         >> ${fname};
echo "        end"                                                             >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "end"                                                                     >> ${fname};
echo ""                                                                        >> ${fname};
echo "always_comb begin"                                                       >> ${fname};
echo "    integer i;"                                                          >> ${fname};
echo "    for (i = 0; i < SLV_NUM; i = i + 1) begin"                           >> ${fname};
echo "        s_awready[i]  = s_awvalid[i] & (|aw_grant_matrix[i]) & ~|s_wsel & m_awready;" >> ${fname};
echo "        s_awsel  [i]  = s_awvalid[i] & (|aw_grant_matrix[i]);"           >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "end"                                                                     >> ${fname};
echo ""                                                                        >> ${fname};
echo "assign m_awvalid = |s_awvalid;"                                          >> ${fname};
echo ""                                                                        >> ${fname};
echo "always_ff @(posedge aclk or negedge aresetn) begin"                      >> ${fname};
echo "    if (~aresetn) begin"                                                 >> ${fname};
echo "        s_wsel <= {SLV_NUM{1'b0}};"                                      >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "    else begin"                                                          >> ${fname};
echo "        if (m_wready & m_wvalid & m_wlast) begin"                        >> ${fname};
echo "            s_wsel <= {SLV_NUM{1'b0}};"                                  >> ${fname};
echo "        end"                                                             >> ${fname};
echo "        else if (~|s_wsel & m_awvalid & m_awready) begin"                >> ${fname};
echo "            s_wsel <= s_awready;"                                        >> ${fname};
echo "        end"                                                             >> ${fname};
echo "    end"                                                                 >> ${fname};
echo "end"                                                                     >> ${fname};
echo ""                                                                        >> ${fname};
echo "assign s_wready = s_wsel & {SLV_NUM{m_wready}};"                         >> ${fname};
echo ""                                                                        >> ${fname};
echo "assign m_wvalid = |(s_wsel & s_wvalid);"                                 >> ${fname};
echo "assign m_wlast  = |(s_wsel & s_wlast);"                                  >> ${fname};
echo ""                                                                        >> ${fname};
echo "endmodule"                                                               >> ${fname};
