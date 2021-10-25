#!/bin/bash

function log2 () {
    value=${1};
    res=0;

    if [ $(( ${value} & 0xffff0000 )) -gt 0 ]; then
        let res+=16;
        let value=$(( ${value} >> 16 ));
    fi
    if [ $(( ${value} & 0xff00 )) -gt 0 ]; then
        let res+=8;
        let value=$(( ${value} >> 8 ));
    fi
    if [ $(( ${value} & 0xf0 )) -gt 0 ]; then
        let res+=4;
        let value=$(( ${value} >> 4 ));
    fi
    if [ $(( ${value} & 0xc )) -gt 0 ]; then
        let res+=2;
        let value=$(( ${value} >> 2 ));
    fi
    if [ $(( ${value} & 0x2 )) -gt 0 ]; then
        let res+=1;
    fi
   
    printf "${res}";
}

function log2_ceil () {
    log2_x=$(log2 ${1});
    if [ $(( 2 ** ${log2_x} )) -ne ${1} ]; then
        printf "`expr ${log2_x} + 1`";
    else
        printf "${log2_x}";
    fi
}

function print_io () {
    io=${1};
    bits=${2};
    name=${3};
    first=${4};

    if [ "${io}" == "i" ]; then
        io="input";
    elif [ "${io}" == "o" ]; then
        io="output logic";
    fi

    if [ "${first}" != "1" ]; then
        printf ",\n";
    fi
    
    if [ "$bits" == "1" ]; then
        printf "%4s%-13s %8s %s"     "" "${io}" ""                   "${name}";
    else
        printf "%4s%-13s [%3s: 0] %s" "" "${io}" "`expr ${bits} - 1`" "${name}";
    fi
}

function print_conn () {
    pname=${1};
    nname=${2};
    first=${3};

    if [ "${first}" != "1" ]; then
        printf ",\n";
    fi
    
    printf "%4s.%-13s ( %-10s )" "" "${pname}" "${nname}";
}

function print_logic_2d () {
    name=${1};

    if [ "`expr ${2} - 1`" == "" ]; then
        d1="${2} - 1";
    else
        d1=`expr ${2} - 1`;
    fi
    if [ "`expr ${3} - 1`" == "" ]; then
        d2="${3} - 1";
    else
        d2=`expr ${3} - 1`;
    fi
    printf "logic [%3s: 0] %-10s [0: %3s];\n" "${d1}" "${name}" "${d2}";
}

function print_logic () {
    name=${1};
    d1=${2};
    if [ "`expr ${d1} - 1`" == "" ]; then
        printf "logic [%3s: 0] %s;\n" "${d1} - 1"        "${name}";
    elif [ "${d1}" == "1" ]; then
        printf "logic          %s;\n"                    "${name}";
    else
        printf "logic [%3d: 0] %s;\n" "`expr ${d1} - 1`" "${name}";
    fi
}
