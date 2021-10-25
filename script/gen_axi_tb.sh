#!/bin/bash

source ./$(dirname ${0})/util.sh;

slvnum=${1};
mstnum=${2};
sbfile="${3}";

fname="test_axi.sv";

if [ ${slvnum} -eq 1  ]; then
    dut="axi_1to${2}_dec";
elif [ ${mstnum} -eq 1 ]; then
    dut="axi_${1}to1_mux";
else
    dut="axi_${1}to${2}_biu";
fi

monitor="axi_${1}to${2}_mon";

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

declare -p aw_chn_sideband;
declare -p w_chn_sideband;
declare -p b_chn_sideband;
declare -p ar_chn_sideband;
declare -p r_chn_sideband;

rm -f ${fname};
touch ${fname};


printf "module test_axi;\n\n" >> ${fname};
printf '`define CYCLE 10'     >> ${fname};
printf "\n\n"                 >> ${fname};
print_logic aclk    1         >> ${fname};
print_logic aresetn 1         >> ${fname};
for (( i = 0; i < ${slvnum}; i++ )); do
    for item in "${!aw_chn_sideband[@]}"; do
        print_logic m${i}_${item} ${aw_chn_sideband[${item}]} >> ${fname};
    done
    print_logic m${i}_awvalid 1 >> ${fname};
    print_logic m${i}_awready 1 >> ${fname};
    for item in "${!w_chn_sideband[@]}"; do
        print_logic m${i}_${item} ${w_chn_sideband[${item}]} >> ${fname};
    done
    print_logic m${i}_wlast  1 >> ${fname};
    print_logic m${i}_wvalid 1 >> ${fname};
    print_logic m${i}_wready 1 >> ${fname};
    for item in "${!b_chn_sideband[@]}"; do
        print_logic m${i}_${item} ${b_chn_sideband[${item}]} >> ${fname};
    done
    print_logic m${i}_bvalid 1 >> ${fname};
    print_logic m${i}_bready 1 >> ${fname};
    for item in "${!ar_chn_sideband[@]}"; do
        print_logic m${i}_${item} ${ar_chn_sideband[${item}]} >> ${fname};
    done
    print_logic m${i}_arvalid 1 >> ${fname};
    print_logic m${i}_arready 1 >> ${fname};
    for item in "${!r_chn_sideband[@]}"; do
        print_logic m${i}_${item} ${r_chn_sideband[${item}]} >> ${fname};
    done
    print_logic m${i}_rlast  1 >> ${fname};
    print_logic m${i}_rvalid 1 >> ${fname};
    print_logic m${i}_rready 1 >> ${fname};
done
for (( i = 0; i < ${mstnum}; i++ )); do
    for item in "${!aw_chn_sideband[@]}"; do
        if [ "${item}" == "awid" ]; then
            print_logic s${i}_${item} `expr ${aw_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
        else
            print_logic s${i}_${item} ${aw_chn_sideband[${item}]} >> ${fname};
        fi
    done
    print_logic s${i}_awvalid 1 >> ${fname};
    print_logic s${i}_awready 1 >> ${fname};
    for item in "${!w_chn_sideband[@]}"; do
        if [ "${item}" == "wid" ]; then
            print_logic s${i}_${item} `expr ${w_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
        else
            print_logic s${i}_${item} ${w_chn_sideband[${item}]} >> ${fname};
        fi
    done
    print_logic s${i}_wlast  1 >> ${fname};
    print_logic s${i}_wvalid 1 >> ${fname};
    print_logic s${i}_wready 1 >> ${fname};
    for item in "${!b_chn_sideband[@]}"; do
        if [ "${item}" == "bid" ]; then
            print_logic s${i}_${item} `expr ${b_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
        else
            print_logic s${i}_${item} ${b_chn_sideband[${item}]} >> ${fname};
        fi
    done
    print_logic s${i}_bvalid 1 >> ${fname};
    print_logic s${i}_bready 1 >> ${fname};
    for item in "${!ar_chn_sideband[@]}"; do
        if [ "${item}" == "arid" ]; then
            print_logic s${i}_${item} `expr ${ar_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
        else
            print_logic s${i}_${item} ${ar_chn_sideband[${item}]} >> ${fname};
        fi
    done
    print_logic s${i}_arvalid 1 >> ${fname};
    print_logic s${i}_arready 1 >> ${fname};
    for item in "${!r_chn_sideband[@]}"; do
        if [ "${item}" == "rid" ]; then
            print_logic s${i}_${item} `expr ${r_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
        else
            print_logic s${i}_${item} ${r_chn_sideband[${item}]} >> ${fname};
        fi
    done
    print_logic s${i}_rlast  1 >> ${fname};
    print_logic s${i}_rvalid 1 >> ${fname};
    print_logic s${i}_rready 1 >> ${fname};
done
echo ""                        >> ${fname};
printf "initial begin\n"       >> ${fname};
printf "    aclk    = 1'b0;\n" >> ${fname};
printf "    aresetn = 1'b0;\n" >> ${fname};
printf "    #(\`CYCLE*10)\n"   >> ${fname};
printf "    aresetn = 1'b1;\n" >> ${fname};
printf "    #(\`CYCLE*1000)\n" >> ${fname};
printf "    \$finish;\n"       >> ${fname};
printf "end\n\n"               >> ${fname};
printf "always #(\`CYCLE/2) aclk = ~aclk;\n\n" >> ${fname};

printf "initial begin\n"                                           >> ${fname};
printf "    \$fsdbDumpfile(\"axi.fsdb\");\n"                       >> ${fname};
printf "    \$fsdbDumpvars(0, test_axi, \"+struct\", \"+mda\");\n" >> ${fname};
printf "end\n\n"                                                   >> ${fname};

printf "%s DUT (\n" ${dut}                                         >> ${fname};
print_conn aclk    aclk 1                                          >> ${fname};
print_conn aresetn aresetn                                         >> ${fname};
if [ "${slvnum}" == "1" ]; then
   for item in "${!aw_chn_sideband[@]}"; do
       print_conn s_${item} m0_${item} >> ${fname};
   done
   print_conn s_awvalid m0_awvalid  >> ${fname};
   print_conn s_awready m0_awready  >> ${fname};
   for item in "${!w_chn_sideband[@]}"; do
       print_conn s_${item} m0_${item} >> ${fname};
   done
   print_conn s_wlast  m0_wlast   >> ${fname};
   print_conn s_wvalid m0_wvalid  >> ${fname};
   print_conn s_wready m0_wready  >> ${fname};
   for item in "${!b_chn_sideband[@]}"; do
       print_conn s_${item} m0_${item} >> ${fname};
   done
   print_conn s_bvalid m0_bvalid  >> ${fname};
   print_conn s_bready m0_bready  >> ${fname};
   for item in "${!ar_chn_sideband[@]}"; do
       print_conn s_${item} m0_${item} >> ${fname};
   done
   print_conn s_arvalid m0_arvalid  >> ${fname};
   print_conn s_arready m0_arready  >> ${fname};
   for item in "${!r_chn_sideband[@]}"; do
       print_conn s_${item} m0_${item} >> ${fname};
   done
   print_conn s_rlast  m0_rlast   >> ${fname};
   print_conn s_rvalid m0_rvalid  >> ${fname};
   print_conn s_rready m0_rready  >> ${fname};
else
    for (( i = 0; i < ${slvnum}; i++ )); do
        for item in "${!aw_chn_sideband[@]}"; do
            print_conn s${i}_${item} m${i}_${item} >> ${fname};
        done
        print_conn s${i}_awvalid m${i}_awvalid  >> ${fname};
        print_conn s${i}_awready m${i}_awready  >> ${fname};
        for item in "${!w_chn_sideband[@]}"; do
            print_conn s${i}_${item} m${i}_${item} >> ${fname};
        done
        print_conn s${i}_wlast  m${i}_wlast   >> ${fname};
        print_conn s${i}_wvalid m${i}_wvalid  >> ${fname};
        print_conn s${i}_wready m${i}_wready  >> ${fname};
        for item in "${!b_chn_sideband[@]}"; do
            print_conn s${i}_${item} m${i}_${item} >> ${fname};
        done
        print_conn s${i}_bvalid m${i}_bvalid  >> ${fname};
        print_conn s${i}_bready m${i}_bready  >> ${fname};
        for item in "${!ar_chn_sideband[@]}"; do
            print_conn s${i}_${item} m${i}_${item} >> ${fname};
        done
        print_conn s${i}_arvalid m${i}_arvalid  >> ${fname};
        print_conn s${i}_arready m${i}_arready  >> ${fname};
        for item in "${!r_chn_sideband[@]}"; do
            print_conn s${i}_${item} m${i}_${item} >> ${fname};
        done
        print_conn s${i}_rlast  m${i}_rlast   >> ${fname};
        print_conn s${i}_rvalid m${i}_rvalid  >> ${fname};
        print_conn s${i}_rready m${i}_rready  >> ${fname};
    done
fi
if [ "${mstnum}" == "1" ]; then
   for item in "${!aw_chn_sideband[@]}"; do
       print_conn m_${item} s0_${item} >> ${fname};
   done
   print_conn m_awvalid s0_awvalid  >> ${fname};
   print_conn m_awready s0_awready  >> ${fname};
   for item in "${!w_chn_sideband[@]}"; do
       print_conn m_${item} s0_${item} >> ${fname};
   done
   print_conn m_wlast  s0_wlast   >> ${fname};
   print_conn m_wvalid s0_wvalid  >> ${fname};
   print_conn m_wready s0_wready  >> ${fname};
   for item in "${!b_chn_sideband[@]}"; do
       print_conn m_${item} s0_${item} >> ${fname};
   done
   print_conn m_bvalid s0_bvalid  >> ${fname};
   print_conn m_bready s0_bready  >> ${fname};
   for item in "${!ar_chn_sideband[@]}"; do
       print_conn m_${item} s0_${item} >> ${fname};
   done
   print_conn m_arvalid s0_arvalid  >> ${fname};
   print_conn m_arready s0_arready  >> ${fname};
   for item in "${!r_chn_sideband[@]}"; do
       print_conn m_${item} s0_${item} >> ${fname};
   done
   print_conn m_rlast  s0_rlast   >> ${fname};
   print_conn m_rvalid s0_rvalid  >> ${fname};
   print_conn m_rready s0_rready  >> ${fname};
else
    for (( i = 0; i < ${mstnum}; i++ )); do
        for item in "${!aw_chn_sideband[@]}"; do
            print_conn m${i}_${item} s${i}_${item} >> ${fname};
        done
        print_conn m${i}_awvalid s${i}_awvalid  >> ${fname};
        print_conn m${i}_awready s${i}_awready  >> ${fname};
        for item in "${!w_chn_sideband[@]}"; do
            print_conn m${i}_${item} s${i}_${item} >> ${fname};
        done
        print_conn m${i}_wlast  s${i}_wlast   >> ${fname};
        print_conn m${i}_wvalid s${i}_wvalid  >> ${fname};
        print_conn m${i}_wready s${i}_wready  >> ${fname};
        for item in "${!b_chn_sideband[@]}"; do
            print_conn m${i}_${item} s${i}_${item} >> ${fname};
        done
        print_conn m${i}_bvalid s${i}_bvalid  >> ${fname};
        print_conn m${i}_bready s${i}_bready  >> ${fname};
        for item in "${!ar_chn_sideband[@]}"; do
            print_conn m${i}_${item} s${i}_${item} >> ${fname};
        done
        print_conn m${i}_arvalid s${i}_arvalid  >> ${fname};
        print_conn m${i}_arready s${i}_arready  >> ${fname};
        for item in "${!r_chn_sideband[@]}"; do
            print_conn m${i}_${item} s${i}_${item} >> ${fname};
        done
        print_conn m${i}_rlast  s${i}_rlast   >> ${fname};
        print_conn m${i}_rvalid s${i}_rvalid  >> ${fname};
        print_conn m${i}_rready s${i}_rready  >> ${fname};
    done
fi
printf "\n);\n\n"                             >> ${fname};
echo "" >> ${fname};
printf "%s u_mon (\n" ${monitor}                                   >> ${fname};
print_conn aclk    aclk 1                                          >> ${fname};
print_conn aresetn aresetn                                         >> ${fname};
for (( i = 0; i < ${slvnum}; i++ )); do
    for item in "${!aw_chn_sideband[@]}"; do
        print_conn m${i}_${item} m${i}_${item} >> ${fname};
    done
    print_conn m${i}_awvalid m${i}_awvalid  >> ${fname};
    print_conn m${i}_awready m${i}_awready  >> ${fname};
    for item in "${!w_chn_sideband[@]}"; do
        print_conn m${i}_${item} m${i}_${item} >> ${fname};
    done
    print_conn m${i}_wlast  m${i}_wlast   >> ${fname};
    print_conn m${i}_wvalid m${i}_wvalid  >> ${fname};
    print_conn m${i}_wready m${i}_wready  >> ${fname};
    for item in "${!b_chn_sideband[@]}"; do
        print_conn m${i}_${item} m${i}_${item} >> ${fname};
    done
    print_conn m${i}_bvalid m${i}_bvalid  >> ${fname};
    print_conn m${i}_bready m${i}_bready  >> ${fname};
    for item in "${!ar_chn_sideband[@]}"; do
        print_conn m${i}_${item} m${i}_${item} >> ${fname};
    done
    print_conn m${i}_arvalid m${i}_arvalid  >> ${fname};
    print_conn m${i}_arready m${i}_arready  >> ${fname};
    for item in "${!r_chn_sideband[@]}"; do
        print_conn m${i}_${item} m${i}_${item} >> ${fname};
    done
    print_conn m${i}_rlast  m${i}_rlast   >> ${fname};
    print_conn m${i}_rvalid m${i}_rvalid  >> ${fname};
    print_conn m${i}_rready m${i}_rready  >> ${fname};
done
for (( i = 0; i < ${mstnum}; i++ )); do
    for item in "${!aw_chn_sideband[@]}"; do
        print_conn s${i}_${item} s${i}_${item} >> ${fname};
    done
    print_conn s${i}_awvalid s${i}_awvalid  >> ${fname};
    print_conn s${i}_awready s${i}_awready  >> ${fname};
    for item in "${!w_chn_sideband[@]}"; do
        print_conn s${i}_${item} s${i}_${item} >> ${fname};
    done
    print_conn s${i}_wlast  s${i}_wlast   >> ${fname};
    print_conn s${i}_wvalid s${i}_wvalid  >> ${fname};
    print_conn s${i}_wready s${i}_wready  >> ${fname};
    for item in "${!b_chn_sideband[@]}"; do
        print_conn s${i}_${item} s${i}_${item} >> ${fname};
    done
    print_conn s${i}_bvalid s${i}_bvalid  >> ${fname};
    print_conn s${i}_bready s${i}_bready  >> ${fname};
    for item in "${!ar_chn_sideband[@]}"; do
        print_conn s${i}_${item} s${i}_${item} >> ${fname};
    done
    print_conn s${i}_arvalid s${i}_arvalid  >> ${fname};
    print_conn s${i}_arready s${i}_arready  >> ${fname};
    for item in "${!r_chn_sideband[@]}"; do
        print_conn s${i}_${item} s${i}_${item} >> ${fname};
    done
    print_conn s${i}_rlast  s${i}_rlast   >> ${fname};
    print_conn s${i}_rvalid s${i}_rvalid  >> ${fname};
    print_conn s${i}_rready s${i}_rready  >> ${fname};
done
printf "\n);\n\n"                             >> ${fname};
echo "" >> ${fname};
for (( i = 0; i < ${slvnum}; i++ )); do
    printf "axi_vip_master #(\n"                               >> ${fname};
    print_conn ID ${i} 1                                       >> ${fname};
    print_conn AXI_AXID_WIDTH    ${aw_chn_sideband["awid"]}    >> ${fname};
    print_conn AXI_AXADDR_WIDTH  ${aw_chn_sideband["awaddr"]}  >> ${fname};
    print_conn AXI_AXLEN_WIDTH   ${aw_chn_sideband["awlen"]}   >> ${fname};
    print_conn AXI_AXSIZE_WIDTH  ${aw_chn_sideband["awsize"]}  >> ${fname};
    print_conn AXI_AXBURST_WIDTH ${aw_chn_sideband["awburst"]} >> ${fname};
    print_conn AXI_DATA_WIDTH    ${w_chn_sideband["wdata"]}    >> ${fname};
    print_conn AXI_RESP_WIDTH    ${r_chn_sideband["rresp"]}    >> ${fname};
    printf "\n) u_axi_vip_master%d (\n" ${i}                   >> ${fname};
    print_conn aclk    aclk 1                                  >> ${fname};
    print_conn aresetn aresetn                                 >> ${fname};
    for item in "${!aw_chn_sideband[@]}"; do
        print_conn m_${item} m${i}_${item}                     >> ${fname};
    done
    print_conn m_awvalid m${i}_awvalid                         >> ${fname};
    print_conn m_awready m${i}_awready                         >> ${fname};
    for item in "${!w_chn_sideband[@]}"; do
        print_conn m_${item} m${i}_${item}                     >> ${fname};
    done
    print_conn m_wlast  m${i}_wlast                            >> ${fname};
    print_conn m_wvalid m${i}_wvalid                           >> ${fname};
    print_conn m_wready m${i}_wready                           >> ${fname};
    for item in "${!b_chn_sideband[@]}"; do
        print_conn m_${item} m${i}_${item}                     >> ${fname};
    done
    print_conn m_bvalid m${i}_bvalid                           >> ${fname};
    print_conn m_bready m${i}_bready                           >> ${fname};
    for item in "${!ar_chn_sideband[@]}"; do
        print_conn m_${item} m${i}_${item}                     >> ${fname};
    done
    print_conn m_arvalid m${i}_arvalid                         >> ${fname};
    print_conn m_arready m${i}_arready                         >> ${fname};
    for item in "${!r_chn_sideband[@]}"; do
        print_conn m_${item} m${i}_${item}                     >> ${fname};
    done
    print_conn m_rlast  m${i}_rlast                            >> ${fname};
    print_conn m_rvalid m${i}_rvalid                           >> ${fname};
    print_conn m_rready m${i}_rready                           >> ${fname};
    printf "\n);\n\n"                                          >> ${fname};
done
echo "" >> ${fname};
for (( i = 0; i < ${mstnum}; i++ )); do
    printf "axi_vip_slave #(\n"                                >> ${fname};
    print_conn ID ${i} 1                                       >> ${fname};
    print_conn AXI_AXID_WIDTH    `expr ${aw_chn_sideband["awid"]} + $(log2_ceil ${slvnum})` >> ${fname};
    print_conn AXI_AXADDR_WIDTH  ${aw_chn_sideband["awaddr"]}  >> ${fname};
    print_conn AXI_AXLEN_WIDTH   ${aw_chn_sideband["awlen"]}   >> ${fname};
    print_conn AXI_AXSIZE_WIDTH  ${aw_chn_sideband["awsize"]}  >> ${fname};
    print_conn AXI_AXBURST_WIDTH ${aw_chn_sideband["awburst"]} >> ${fname};
    print_conn AXI_DATA_WIDTH    ${w_chn_sideband["wdata"]}    >> ${fname};
    print_conn AXI_RESP_WIDTH    ${r_chn_sideband["rresp"]}    >> ${fname};
    printf "\n) u_axi_vip_slave%d (\n" ${i}                    >> ${fname};
    print_conn aclk    aclk 1                                  >> ${fname};
    print_conn aresetn aresetn                                 >> ${fname};
    for item in "${!aw_chn_sideband[@]}"; do
        print_conn s_${item} s${i}_${item}                     >> ${fname};
    done
    print_conn s_awvalid s${i}_awvalid                         >> ${fname};
    print_conn s_awready s${i}_awready                         >> ${fname};
    for item in "${!w_chn_sideband[@]}"; do
        print_conn s_${item} s${i}_${item}                     >> ${fname};
    done
    print_conn s_wlast  s${i}_wlast                            >> ${fname};
    print_conn s_wvalid s${i}_wvalid                           >> ${fname};
    print_conn s_wready s${i}_wready                           >> ${fname};
    for item in "${!b_chn_sideband[@]}"; do
        print_conn s_${item} s${i}_${item}                     >> ${fname};
    done
    print_conn s_bvalid s${i}_bvalid                           >> ${fname};
    print_conn s_bready s${i}_bready                           >> ${fname};
    for item in "${!ar_chn_sideband[@]}"; do
        print_conn s_${item} s${i}_${item}                     >> ${fname};
    done
    print_conn s_arvalid s${i}_arvalid                         >> ${fname};
    print_conn s_arready s${i}_arready                         >> ${fname};
    for item in "${!r_chn_sideband[@]}"; do
        print_conn s_${item} s${i}_${item}                     >> ${fname};
    done
    print_conn s_rlast  s${i}_rlast                            >> ${fname};
    print_conn s_rvalid s${i}_rvalid                           >> ${fname};
    print_conn s_rready s${i}_rready                           >> ${fname};
    printf "\n);\n\n"                                          >> ${fname};
done
printf "endmodule\n"                                           >> ${fname};
