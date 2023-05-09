#!/bin/bash

filelist=${1};
infile=${2};
outfile=${3};

incdir=();

rand()
{
    echo $(python3 -c "from random import randint; print(randint(0, 0xffffffff))");
}

rm -f ${outfile};
touch ${outfile};

printf "\`define RISCV_VER 64'h%s\n" $(date +"%Y_%m_%d_00_%H_%M_%S") >> ${outfile};


function get_path () {
    incfile=${1};
    res=""
    
    for dir in ${incdir[@]}; do
        if [ -f "${dir}/${incfile}" ]; then
            printf "${dir}/${incfile}";
            return;
        fi
    done
}

while IFS= read -r line; do
    if [[ "${line}" =~ ^\+incdir\+(.*)$ ]]; then 
        incdir+=(${BASH_REMATCH[1]});
    fi
done < "${filelist}"

while IFS= read -r line; do
    if [[ "${line}" =~ ^\`include\ \"(.*)\"$ ]]; then 
        path=$(get_path ${BASH_REMATCH[1]});
        if [ "${path}" != "" ]; then
            cat ${path} >> ${outfile};
        else
            echo "${line}" >> ${outfile};
        fi
    else
        echo "${line}" >> ${outfile};
    fi
done < "${infile}"

