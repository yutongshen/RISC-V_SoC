#!/bin/bash
source ./$(dirname ${0})/util.sh;

slvnum=${1};
mstnum=${2};

fname="axi_${1}to${2}_biu.sv";
module="axi_${1}to${2}_biu";
mux="axi_${1}to1_mux";
dec="axi_1to${2}_dec";
outstanding="${3}";
sbfile="${4}";
mapfile="${5}";

./$(dirname ${0})/gen_axi_mux.sh ${slvnum} ${sbfile};
./$(dirname ${0})/gen_axi_dec.sh ${mstnum} ${outstanding} ${sbfile} ${mapfile} $(log2_ceil ${slvnum});

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
for (( i = 0; i < ${mstnum}; i++ )); do
    for item in "${!aw_chn_sideband[@]}"; do
        if [ "${item}" == "awid" ]; then
            print_io o `expr ${aw_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m${i}_${item} >> ${fname};
        else
            print_io o ${aw_chn_sideband[${item}]} m${i}_${item} >> ${fname};
        fi
    done
    print_io o 1 m${i}_awvalid          >> ${fname};
    print_io i 1 m${i}_awready          >> ${fname};
    for item in "${!w_chn_sideband[@]}"; do
        if [ "${item}" == "wid" ]; then
            print_io o `expr ${w_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m${i}_${item} >> ${fname};
        else
            print_io o ${w_chn_sideband[${item}]} m${i}_${item} >> ${fname};
        fi
    done
    print_io o 1 m${i}_wlast            >> ${fname};
    print_io o 1 m${i}_wvalid           >> ${fname};
    print_io i 1 m${i}_wready           >> ${fname};
    for item in "${!b_chn_sideband[@]}"; do
        if [ "${item}" == "bid" ]; then
            print_io i `expr ${b_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m${i}_${item} >> ${fname};
        else
            print_io i ${b_chn_sideband[${item}]} m${i}_${item} >> ${fname};
        fi
    done
    print_io i 1 m${i}_bvalid           >> ${fname};
    print_io o 1 m${i}_bready           >> ${fname};
    for item in "${!ar_chn_sideband[@]}"; do
        if [ "${item}" == "arid" ]; then
            print_io o `expr ${ar_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m${i}_${item} >> ${fname};
        else
            print_io o ${ar_chn_sideband[${item}]} m${i}_${item} >> ${fname};
        fi
    done
    print_io o 1 m${i}_arvalid          >> ${fname};
    print_io i 1 m${i}_arready          >> ${fname};
    for item in "${!r_chn_sideband[@]}"; do
        if [ "${item}" == "rid" ]; then
            print_io i `expr ${r_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` m${i}_${item} >> ${fname};
        else
            print_io i ${r_chn_sideband[${item}]} m${i}_${item} >> ${fname};
        fi
    done
    print_io i 1 m${i}_rlast            >> ${fname};
    print_io i 1 m${i}_rvalid           >> ${fname};
    print_io o 1 m${i}_rready           >> ${fname};
done
printf "\n);\n\n"               >> ${fname};

for item in "${!aw_chn_sideband[@]}"; do
    if [ "${item}" == "awid" ]; then
        print_logic i_${item} `expr ${aw_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
    else
        print_logic i_${item} ${aw_chn_sideband[${item}]} >> ${fname};
    fi
done
print_logic i_awvalid 1 >> ${fname};
print_logic i_awready 1 >> ${fname};
for item in "${!w_chn_sideband[@]}"; do
    if [ "${item}" == "wid" ]; then
        print_logic i_${item} `expr ${w_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
    else
        print_logic i_${item} ${w_chn_sideband[${item}]} >> ${fname};
    fi
done
print_logic i_wlast  1 >> ${fname};
print_logic i_wvalid 1 >> ${fname};
print_logic i_wready 1 >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    if [ "${item}" == "bid" ]; then
        print_logic i_${item} `expr ${b_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
    else
        print_logic i_${item} ${b_chn_sideband[${item}]} >> ${fname};
    fi
done
print_logic i_bvalid 1 >> ${fname};
print_logic i_bready 1 >> ${fname};
for item in "${!ar_chn_sideband[@]}"; do
    if [ "${item}" == "arid" ]; then
        print_logic i_${item} `expr ${ar_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
    else
        print_logic i_${item} ${ar_chn_sideband[${item}]} >> ${fname};
    fi
done
print_logic i_arvalid 1 >> ${fname};
print_logic i_arready 1 >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    if [ "${item}" == "rid" ]; then
        print_logic i_${item} `expr ${r_chn_sideband[${item}]} + $(log2_ceil ${slvnum})` >> ${fname};
    else
        print_logic i_${item} ${r_chn_sideband[${item}]} >> ${fname};
    fi
done
print_logic i_rlast  1 >> ${fname};
print_logic i_rvalid 1 >> ${fname};
print_logic i_rready 1 >> ${fname};

printf "\n%s u_mux (\n" ${mux}                                     >> ${fname};
print_conn aclk    aclk 1                                          >> ${fname};
print_conn aresetn aresetn                                         >> ${fname};
for (( i = 0; i < ${slvnum}; i++ )); do
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
   for item in "${!aw_chn_sideband[@]}"; do
       print_conn m_${item} i_${item} >> ${fname};
   done
   print_conn m_awvalid i_awvalid  >> ${fname};
   print_conn m_awready i_awready  >> ${fname};
   for item in "${!w_chn_sideband[@]}"; do
       print_conn m_${item} i_${item} >> ${fname};
   done
   print_conn m_wlast  i_wlast   >> ${fname};
   print_conn m_wvalid i_wvalid  >> ${fname};
   print_conn m_wready i_wready  >> ${fname};
   for item in "${!b_chn_sideband[@]}"; do
       print_conn m_${item} i_${item} >> ${fname};
   done
   print_conn m_bvalid i_bvalid  >> ${fname};
   print_conn m_bready i_bready  >> ${fname};
   for item in "${!ar_chn_sideband[@]}"; do
       print_conn m_${item} i_${item} >> ${fname};
   done
   print_conn m_arvalid i_arvalid  >> ${fname};
   print_conn m_arready i_arready  >> ${fname};
   for item in "${!r_chn_sideband[@]}"; do
       print_conn m_${item} i_${item} >> ${fname};
   done
   print_conn m_rlast  i_rlast   >> ${fname};
   print_conn m_rvalid i_rvalid  >> ${fname};
   print_conn m_rready i_rready  >> ${fname};
printf "\n);\n\n"                             >> ${fname};

printf "%s u_dec (\n" ${dec}                                       >> ${fname};
print_conn aclk    aclk 1                                          >> ${fname};
print_conn aresetn aresetn                                         >> ${fname};
for item in "${!aw_chn_sideband[@]}"; do
    print_conn s_${item} i_${item} >> ${fname};
done
print_conn s_awvalid i_awvalid  >> ${fname};
print_conn s_awready i_awready  >> ${fname};
for item in "${!w_chn_sideband[@]}"; do
    print_conn s_${item} i_${item} >> ${fname};
done
print_conn s_wlast  i_wlast   >> ${fname};
print_conn s_wvalid i_wvalid  >> ${fname};
print_conn s_wready i_wready  >> ${fname};
for item in "${!b_chn_sideband[@]}"; do
    print_conn s_${item} i_${item} >> ${fname};
done
print_conn s_bvalid i_bvalid  >> ${fname};
print_conn s_bready i_bready  >> ${fname};
for item in "${!ar_chn_sideband[@]}"; do
    print_conn s_${item} i_${item} >> ${fname};
done
print_conn s_arvalid i_arvalid  >> ${fname};
print_conn s_arready i_arready  >> ${fname};
for item in "${!r_chn_sideband[@]}"; do
    print_conn s_${item} i_${item} >> ${fname};
done
print_conn s_rlast  i_rlast   >> ${fname};
print_conn s_rvalid i_rvalid  >> ${fname};
print_conn s_rready i_rready  >> ${fname};
for (( i = 0; i < ${mstnum}; i++ )); do
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
printf "\n);\n\n"                             >> ${fname};

echo "endmodule" >> ${fname};
