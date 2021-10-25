#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2018.03
# platform  : Linux 2.6.32-431.el6.x86_64
# version   : 2018.03p001 64 bits
# build date: 2018.04.24 18:13:05 PDT
#----------------------------------------
# started Sat Oct 09 18:02:56 CST 2021
# hostname  : ideal125
# pid       : 22559
# arguments : '-label' 'session_0' '-console' 'ideal125:50330' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/fred2/RISCV/build/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/fred2/RISCV/build/jgproject/.tmp/.initCmds.tcl' '../script/superlint.tcl'
check_superlint -init
clear -all

# Config rules
config_rtlds -rule -enable -domain { LINT AUTO_FORMAL }
config_rtlds -rule -disable -tag { CAS_IS_DFRC SIG_IS_DLCK SIG_NO_TGFL SIG_NO_TGRS SIG_NO_TGST FSM_NO_MTRN FSM_NO_TRRN }
# vsd2018_constrain //
config_rtlds -rule  -disable -category { NAMING AUTO_FORMAL_DEAD_CODE AUTO_FORMAL_SIGNALS AUTO_FORMAL_ARITHMETIC_OVERFLOW }
config_rtlds -rule  -disable -tag { IDN_NR_SVKY ARY_MS_DRNG IDN_NR_AMKY IDN_NR_CKYW IDN_NR_SVKW ARY_NR_LBND VAR_NR_INDL INS_NR_PTEX INP_NO_USED OTP_NR_ASYA FLP_NR_MXCS OTP_UC_INST OTP_NR_UDRV REG_NR_TRRC INS_NR_INPR MOD_NS_GLGC } 
config_rtlds -rule  -disable -tag { REG_NR_RWRC }
# vsd2018_constrain //

# analyze -sv +incdir+../include+../mdl -f ../sim/designlist.f
# elaborate -bbox true -top cpu_wrap
analyze -sv +incdir+../include+../mdl ../script/axi_1to2_dec.sv
elaborate -bbox true -top axi_2to1_dec
include {../script/superlint.tcl}
include {../script/superlint.tcl}
include {../script/superlint.tcl}
