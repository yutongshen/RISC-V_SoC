debImport "-sverilog" "-f" "/home/fred2/RISCV/./sim/designlist.f"
srcDeselectAll -win $_nTrace1
wvCreateWindow
verdiWindowBeWindow -win $_nWave2
wvResizeWindow -win $_nWave2 0 27 900 209
wvResizeWindow -win $_nWave2 0 27 900 209
wvResizeWindow -win $_nWave2 8 31 1173 519
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/fred2/RISCV/build/top.fsdb}
srcDeselectAll -win $_nTrace1
srcHBSelect "test.u_cpu_wrap" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap" -delim "."
srcHBSelect "test.u_cpu_wrap" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_marb" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_mmu" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top.u_mmu" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_mmu" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "satp_asid" -line 15 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "satp" -line 13 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcShowCalling -win $_nTrace1
srcSelect -win $_nTrace1 -range {631 631 3 4 1 1}
srcHBSelect "test.u_cpu_wrap.u_cpu_top" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe_mmu_csr_wr" -line 586 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {632 641 1 1 1 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk_wfi" -line 632 -pos 1 -win $_nTrace1
srcSelect -signal "rstn_sync" -line 633 -pos 1 -win $_nTrace1
srcSelect -signal "exe_mmu_csr_wr" -line 636 -pos 1 -win $_nTrace1
srcSelect -signal "id2exe_csr_waddr" -line 637 -pos 1 -win $_nTrace1
srcSelect -signal "id_csr_addr" -line 638 -pos 1 -win $_nTrace1
srcSelect -signal "exe_csr_wdata" -line 639 -pos 1 -win $_nTrace1
srcSelect -signal "id_mmu_csr_rdata" -line 640 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 2 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 7)}
wvGoToTime -win $_nWave2 16683500
wvGoToTime -win $_nWave2 166835000
wvSetWindowTimeUnit -win $_nWave2 10.000000 ns
wvGoToTime -win $_nWave2 1668350
wvSetWindowTimeUnit -win $_nWave2 1.000000 ns
wvZoom -win $_nWave2 1642718.639344 1722296.704918
wvZoom -win $_nWave2 1666501.743431 1672623.133091
wvZoom -win $_nWave2 1667837.179005 1669265.245950
wvSelectGroup -win $_nWave2 {G2}
wvSetPosition -win $_nWave2 {("G2" 0)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id_mmu_csr_wr" -line 434 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id_mmu_csr_wr" -line 434 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id_mmu_csr_wr" -line 434 -pos 1 -win $_nTrace1
srcAction -pos 433 6 6 -win $_nTrace1 -name "id_mmu_csr_wr" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr" -line 43 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mpu_csr_sel" -line 43 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pmu_csr_sel" -line 40 -pos 1 -win $_nTrace1
srcSelect -signal "fpu_csr_sel" -line 41 -pos 1 -win $_nTrace1
srcSelect -signal "mpu_csr_sel" -line 43 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pmu_csr_sel" -line 40 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pmu_csr_sel" -line 40 -pos 1 -win $_nTrace1
srcSelect -signal "fpu_csr_sel" -line 41 -pos 1 -win $_nTrace1
srcSelect -signal "dbg_csr_sel" -line 42 -pos 1 -win $_nTrace1
srcSelect -signal "mpu_csr_sel" -line 43 -pos 1 -win $_nTrace1
srcSelect -signal "mpu_csr_sel" -line 44 -pos 1 -win $_nTrace1
srcSelect -signal "sru_csr_sel" -line 45 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvZoom -win $_nWave2 1667821.871856 1668553.013318
srcDeselectAll -win $_nTrace1
srcSelect -signal "raddr" -line 34 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mmu_csr_sel" -line 34 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mpu_csr_sel" -line 43 -pos 1 -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_mmu" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top.u_mmu" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_mmu" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "satp" -line 18 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 9 )} 
wvSetCursor -win $_nWave2 1668191.130564 -snap {("G2" 10)}
wvScrollDown -win $_nWave2 1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_hzu" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_sru" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top.u_sru" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_sru" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tvm" -line 48 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
wvSetPosition -win $_nWave2 {("G2" 9)}
wvSelectSignal -win $_nWave2 {( "G2" 9 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tvm" -line 48 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1666626.014176 1671714.390188
wvZoom -win $_nWave2 1667697.588947 1668550.998795
wvSetCursor -win $_nWave2 1668045.194723 -snap {("G2" 9)}
wvSelectSignal -win $_nWave2 {( "G2" 9 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_mmu" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top.u_mmu" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_mmu" -win $_nTrace1
wvSelectGroup -win $_nWave2 {G3}
wvSetPosition -win $_nWave2 {("G3" 0)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {6 11 3 1 25 1}
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 1667906.905738 -snap {("G3" 3)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "csr_wr" -line 6 -pos 1 -win $_nTrace1
srcAction -pos 5 3 4 -win $_nTrace1 -name "csr_wr" -ctrlKey off
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvScrollDown -win $_nWave2 1
wvZoomOut -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 1667465.672399 1669196.168031
wvSelectSignal -win $_nWave2 {( "G2" 9 )} 
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id2exe_inst_valid" -line 646 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe_stall" -line 646 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "stall_wfi" -line 646 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 5 )} 
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 5
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id2exe_inst_valid" -line 500 -pos 1 -win $_nTrace1
srcSelect -signal "id2exe_pc" -line 498 -pos 1 -win $_nTrace1
srcSelect -signal "id2exe_inst" -line 499 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 4)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 3)}
wvZoom -win $_nWave2 1667939.212818 1668825.191666
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
