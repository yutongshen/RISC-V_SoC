debImport "-sverilog" "-f" "/home/fred2/RISCV/./sim/designlist.f"
wvCreateWindow
verdiWindowBeWindow -win $_nWave2
wvResizeWindow -win $_nWave2 0 27 900 216
wvResizeWindow -win $_nWave2 8 31 900 216
wvResizeWindow -win $_nWave2 8 31 938 655
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/fred2/RISCV/build/top.fsdb}
srcDeselectAll -win $_nTrace1
srcHBSelect "test.u_cpu_wrap" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap" -delim "."
srcHBSelect "test.u_cpu_wrap" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "if2id_pc" -line 62 -pos 1 -win $_nTrace1
srcSelect -signal "if2id_inst_valid" -line 61 -pos 1 -win $_nTrace1
srcSelect -signal "if2id_inst" -line 60 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSelectGroup -win $_nWave2 {G2}
wvSetPosition -win $_nWave2 {("G2" 0)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id2exe_pc" -line 118 -pos 1 -win $_nTrace1
srcSelect -signal "id2exe_inst_valid" -line 120 -pos 1 -win $_nTrace1
srcSelect -signal "id2exe_inst" -line 119 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSelectGroup -win $_nWave2 {G3}
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSetPosition -win $_nWave2 {("G3" 0)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe2mem_mem_req" -line 181 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe2mem_inst_valid" -line 180 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe2mem_inst_valid" -line 180 -pos 1 -win $_nTrace1
srcSelect -signal "exe2mem_pc" -line 178 -pos 1 -win $_nTrace1
srcSelect -signal "exe2mem_inst" -line 179 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectGroup -win $_nWave2 {G4}
wvSetPosition -win $_nWave2 {("G4" 0)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mem2wb_inst_valid" -line 215 -pos 1 -win $_nTrace1
srcSelect -signal "mem2wb_inst" -line 214 -pos 1 -win $_nTrace1
srcSelect -toggle -signal "mem2wb_inst" -line 214 -pos 1 -win $_nTrace1
srcSelect -signal "mem2wb_pc" -line 213 -pos 1 -win $_nTrace1
srcSelect -signal "mem2wb_inst" -line 214 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSelectSignal -win $_nWave2 {( "G4" 1 2 3 )} 
wvZoom -win $_nWave2 271460.125448 1818782.840502
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
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
wvZoom -win $_nWave2 115099093.189964 144688246.863799
wvZoom -win $_nWave2 121886569.301461 126871122.070888
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSelectGroup -win $_nWave2 {G5}
srcDeselectAll -win $_nTrace1
srcSelect -signal "mem2wb_rd_data" -line 221 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "stall_wfi" -line 252 -pos 1 -win $_nTrace1
srcSelect -signal "wakeup_event" -line 252 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/stall_wfi" \
           "/test/u_cpu_wrap/u_cpu_top/wakeup_event"
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoom -win $_nWave2 124005897.517398 124151056.984250
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 123612302.045379 125560248.439258
wvZoom -win $_nWave2 124031215.248285 124509474.488359
wvZoom -win $_nWave2 124086926.450001 124228347.193034
wvSetCursor -win $_nWave2 124094276.273563 -snap {("G4" 3)}
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 124048149.794569 124117592.955126
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 124092329.583005 124131904.717516
wvZoomOut -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 124105308.524884 124280063.240717
wvSelectGroup -win $_nWave2 {G1}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectGroup -win $_nWave2 {G6}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 )} 
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSelectGroup -win $_nWave2 {G1}
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_ifu" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_ifu" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top.u_ifu" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_ifu" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "imem_req" -line 8 -pos 1 -win $_nTrace1
srcSelect -signal "imem_addr" -line 9 -pos 1 -win $_nTrace1
srcSelect -signal "imem_rdata" -line 10 -pos 1 -win $_nTrace1
srcSelect -signal "imem_busy" -line 11 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_ifu/imem_req" \
           "/test/u_cpu_wrap/u_cpu_top/u_ifu/imem_addr\[31:0\]" \
           "/test/u_cpu_wrap/u_cpu_top/u_ifu/imem_rdata\[31:0\]" \
           "/test/u_cpu_wrap/u_cpu_top/u_ifu/imem_busy"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvZoom -win $_nWave2 124133181.588795 124178279.579978
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 124146355.374746 124171733.097383
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 124165411.406528 -snap {("G4" 3)}
srcDeselectAll -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_alu" -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 124140306.562629 124167412.517274
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 124143949.836041 -snap {("G1" 3)}
wvZoom -win $_nWave2 124127627.970878 124171930.176319
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 124155177.908653 -snap {("G1" 3)}
wvSetCursor -win $_nWave2 124194875.225356 -snap {("G6" 3)}
srcActiveTrace "test.u_cpu_wrap.u_cpu_top.if2id_inst\[31:0\]" -win $_nTrace1 \
           -TraceByDConWave -TraceTime 124155000 -TraceValue \
           11111111111100000000001010010011
wvSetCursor -win $_nWave2 124194557.646822 -snap {("G6" 3)}
srcActiveTrace "test.u_cpu_wrap.u_cpu_top.if2id_inst\[31:0\]" -win $_nTrace1 \
           -TraceByDConWave -TraceTime 124155000 -TraceValue \
           11111111111100000000001010010011
srcDeselectAll -win $_nTrace1
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcDeselectAll -win $_nTrace1
srcSelect -signal "if_inst" -line 323 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "if_inst" -line 323 -pos 1 -win $_nTrace1
srcAction -pos 322 5 2 -win $_nTrace1 -name "if_inst" -ctrlKey off
wvSelectGroup -win $_nWave2 {G6}
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G1" 4)}
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvZoom -win $_nWave2 124143745.081442 124187253.340549
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 69 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_ifu/clk"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetCursor -win $_nWave2 124173452.333539 -snap {("G1" 6)}
srcActiveTrace "test.u_cpu_wrap.u_cpu_top.u_ifu.inst\[31:0\]" -win $_nTrace1 \
           -TraceByDConWave -TraceTime 124155000 -TraceValue \
           11111111111100000000001100010011
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_valid" -line 94 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 5)}
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_ifu/inst_valid"
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvSetCursor -win $_nWave2 124175635.543673 -snap {("G1" 7)}
srcActiveTrace "test.u_cpu_wrap.u_cpu_top.u_ifu.inst\[31:0\]" -win $_nTrace1 \
           -TraceByDConWave -TraceTime 124175000 -TraceValue \
           00000000011000101000001010110011
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_latch" -line 95 -pos 1 -win $_nTrace1
srcAction -pos 94 10 5 -win $_nTrace1 -name "inst_latch" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "imem_busy" -line 73 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_latch" -line 74 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "imem_req_latch" -line 83 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
srcDeselectAll -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSetCursor -win $_nWave2 124165811.098069 -snap {("G1" 4)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_valid" -line 85 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "imem_req" -line 82 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "imem_req_latch" -line 83 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_ifu/imem_req_latch"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 2)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_valid" -line 85 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_latch_valid" -line 62 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_ifu/inst_latch_valid"
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_latch" -line 74 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_ifu/inst_latch\[31:0\]"
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvZoom -win $_nWave2 124161600.621381 124180625.738266
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 123795793.311139 124011820.444803
wvZoom -win $_nWave2 123851929.394221 123939424.254809
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
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
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 5
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 3
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 2
srcDeselectAll -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_idu.u_rfu" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top.u_idu.u_rfu" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_idu.u_rfu" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "gpr" -line 14 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 0)}
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_idu/u_rfu/gpr\[0:31\]"
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvExpandBus -win $_nWave2 {("G7" 1)}
wvZoom -win $_nWave2 122720104.301075 131519801.702509
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 130620907.881857 -snap {("G7" 9)}
wvSetCursor -win $_nWave2 130605137.814829 -snap {("G7" 7)}
wvZoom -win $_nWave2 130431667.077525 131220170.428908
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 125790468.981368 129227100.075568
wvZoom -win $_nWave2 127724343.826423 128340227.535061
wvSelectSignal -win $_nWave2 {( "G7" 16 )} 
wvSelectSignal -win $_nWave2 {( "G7" 20 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 127251710.035842 146181716.487455
wvZoom -win $_nWave2 139702090.623151 145706770.088985
wvZoom -win $_nWave2 143640643.821120 145523831.825638
wvZoom -win $_nWave2 144511365.156522 145186342.935919
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 121293126.344086 132233290.681004
wvZoom -win $_nWave2 128900265.703720 132194078.622362
wvZoom -win $_nWave2 130724258.879077 131515246.210794
wvZoom -win $_nWave2 131091401.744438 131332383.548008
wvScrollUp -win $_nWave2 26
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvSetPosition -win $_nWave2 {("G7" 1)}
wvCollapseBus -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 128507747.517611 132598392.039854
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_hzu" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top.u_hzu" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_hzu" -win $_nTrace1
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_valid" -line 29 -pos 1 -win $_nTrace1
srcSelect -signal "stall_all" -line 29 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_csr" -win $_nTrace1
wvZoom -win $_nWave2 125026162.438506 126550990.504145
wvSelectSignal -win $_nWave2 {( "G7" 3 )} 
wvSelectSignal -win $_nWave2 {( "G7" 2 3 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_valid" -line 29 -pos 1 -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_valid" -line 2 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "stall_all" -line 29 -pos 1 -win $_nTrace1
srcSelect -signal "inst_valid" -line 29 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_hzu/stall_all\[4:0\]" \
           "/test/u_cpu_wrap/u_cpu_top/u_hzu/inst_valid\[4:0\]"
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
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
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "id_stall" -line 29 -pos 1 -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_dpu" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_dpu" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_csr" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "if2id_inst_valid" -line 62 -pos 1 -win $_nTrace1
srcSelect -signal "if2id_pc" -line 63 -pos 1 -win $_nTrace1
srcSelect -signal "if2id_inst" -line 61 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 4)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G6" 3)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id2exe_pc" -line 119 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "id2exe_inst_valid" -line 121 -pos 1 -win $_nTrace1
srcSelect -signal "id2exe_pc" -line 119 -pos 1 -win $_nTrace1
srcSelect -signal "id2exe_inst" -line 120 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 3)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSelectGroup -win $_nWave2 {G3}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe2mem_inst_valid" -line 181 -pos 1 -win $_nTrace1
srcSelect -signal "exe2mem_pc" -line 179 -pos 1 -win $_nTrace1
srcSelect -signal "exe2mem_inst" -line 180 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSelectGroup -win $_nWave2 {G5}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSelectGroup -win $_nWave2 {G4}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mem2wb_inst_valid" -line 216 -pos 1 -win $_nTrace1
srcSelect -signal "mem2wb_pc" -line 214 -pos 1 -win $_nTrace1
srcSelect -signal "mem2wb_inst" -line 215 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 3 )} 
wvZoom -win $_nWave2 104992577.060932 182831901.433692
wvZoom -win $_nWave2 111688432.920922 148794634.145213
wvZoom -win $_nWave2 120532742.531708 135627917.581733
wvZoom -win $_nWave2 124211853.296581 127349918.360744
wvZoom -win $_nWave2 125077914.264029 126287025.355059
wvZoom -win $_nWave2 125576293.387543 126141845.349477
wvZoom -win $_nWave2 125779000.183892 125997923.523995
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
wvSetPosition -win $_nWave2 {("G8" 1)}
wvExpandBus -win $_nWave2 {("G8" 1)}
wvScrollDown -win $_nWave2 2
wvSelectSignal -win $_nWave2 {( "G8" 7 )} 
wvSetPosition -win $_nWave2 {("G8" 7)}
wvExpandBus -win $_nWave2 {("G8" 7)}
wvSetCursor -win $_nWave2 125874730.103128 -snap {("G8" 5)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mem2wb_rd_addr" -line 217 -pos 1 -win $_nTrace1
wvSetCursor -win $_nWave2 125875710.942540 -snap {("G8" 4)}
srcActiveTrace "test.u_cpu_wrap.u_cpu_top.u_hzu.stall_all\[2\]" -win $_nTrace1 \
           -TraceByDConWave -TraceTime 125875000 -TraceValue 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe_flush" -line 30 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {30 30 10 13 9 1}
wvSetCursor -win $_nWave2 125881595.978564 -snap {("G8" 10)}
debReload
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSetCursor -win $_nWave2 125881203.642829 -snap {("G8" 5)}
wvSetCursor -win $_nWave2 125874533.935335 -snap {("G8" 6)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoom -win $_nWave2 125836673.536889 125913571.340939
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 4
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 127480329.646038 129226653.970274
wvZoom -win $_nWave2 128403565.623867 128666453.156548
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 130223519.994355 132635678.000315
wvZoom -win $_nWave2 131014604.071523 131533347.728719
wvZoom -win $_nWave2 131220985.956621 131378096.490789
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 131630655.897836 131923478.398795
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 131766571.718117 131934498.600388
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 132069622.561200 132183981.369915
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 132654737.971341 133008881.378973
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 142483215.732607 146382601.210197
wvZoom -win $_nWave2 144195311.506811 145956324.303142
wvZoom -win $_nWave2 144491969.576433 145381943.785331
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
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
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 3
wvScrollUp -win $_nWave2 2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoom -win $_nWave2 329065357.795699 533105883.602150
wvZoom -win $_nWave2 473868311.593727 506046745.771088
wvZoom -win $_nWave2 486093809.883307 499703326.847209
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 5
wvZoom -win $_nWave2 491630297.967181 494459516.547491
wvZoom -win $_nWave2 491660719.672265 492350278.322663
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
srcHBSelect "test.u_cpu_wrap.u_cpu_top" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {10 10 3 3 30 31} -backward
srcDeselectAll -win $_nTrace1
srcSelect -signal "stall_wfi" -line 31 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/stall_wfi"
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
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
srcDeselectAll -win $_nTrace1
srcSelect -signal "stall_wfi" -line 31 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "stall_wfi" -line 31 -pos 1 -win $_nTrace1
srcAction -pos 30 2 1 -win $_nTrace1 -name "stall_wfi" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "wakeup_event" -line 253 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/wakeup_event"
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe2mem_wfi" -line 253 -pos 1 -win $_nTrace1
srcAction -pos 252 7 5 -win $_nTrace1 -name "exe2mem_wfi" -ctrlKey off
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 428085024.731183 497098731.989247
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 487961694.120707 516655565.238755
wvZoom -win $_nWave2 502462897.804015 504828342.376470
wvSetCursor -win $_nWave2 503081813.408979 -snap {("G5" 2)}
srcActiveTrace "test.u_cpu_wrap.u_cpu_top.wakeup_event" -win $_nTrace1 \
           -TraceByDConWave -TraceTime 475035000 -TraceValue 0
debReload
verdiWindowResize -win $_Verdi_1 "662" "353" "1070" "700"
srcDeselectAll -win $_nTrace1
srcSelect -signal "mip" -line 158 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_sru/mip\[31:0\]"
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSetPosition -win $_nWave2 {("G5" 3)}
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 465058651.675404 475910870.502438
wvZoom -win $_nWave2 473849337.893714 475871973.660760
wvZoom -win $_nWave2 474643168.060336 475139765.013894
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
wvSetPosition -win $_nWave2 {("G8" 1)}
wvCollapseBus -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSelectSignal -win $_nWave2 {( "G8" 2 )} 
wvSetPosition -win $_nWave2 {("G8" 2)}
wvCollapseBus -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
wvSelectSignal -win $_nWave2 {( "G8" 1 2 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 0)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mepc" -line 566 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_cpu_top/u_sru/mepc\[31:0\]"
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "mcause" -line 567 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mtvec" -line 563 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mie" -line 562 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mstatus" -line 558 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
srcDeselectAll -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_sru" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top.u_sru" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_sru" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "trap_vec" -line 56 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "ret_epc" -line 57 -pos 1 -win $_nTrace1
srcSelect -signal "trap_vec" -line 56 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 2 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 474992921.828645 475162013.981290
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSetCursor -win $_nWave2 475056255.627709 -snap {("G8" 6)}
wvSetCursor -win $_nWave2 475051710.139735 -snap {("G8" 7)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "irq_trigger" -line 53 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvScrollUp -win $_nWave2 3
wvScrollUp -win $_nWave2 2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 475147771.452281 475173832.250001
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 474984447.779089 475247484.361089
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 5
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 2
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
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
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 97751709.677419 164729732.974910
wvZoom -win $_nWave2 113595973.253161 130280462.927625
wvZoom -win $_nWave2 121071103.035566 124808667.926799
wvZoom -win $_nWave2 123402057.483796 124714893.897204
wvZoom -win $_nWave2 123980834.827245 124505498.841923
wvZoom -win $_nWave2 124131276.121731 124314626.449441
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 3
wvScrollUp -win $_nWave2 2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 2
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_ifu" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_cpu_top.u_ifu" -delim "."
srcHBSelect "test.u_cpu_wrap.u_cpu_top.u_ifu" -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 124220651.191838 124267310.235807
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 124308868.559870 124371080.618496
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 124241416.417422 124270850.079567
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 124227438.065315 124265838.972200
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 124312704.595102 124366658.557464
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 5
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcSelect -signal "jump" -line 30 -pos 1 -win $_nTrace1
srcSelect -signal "jump_addr" -line 31 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 9)}
wvSetCursor -win $_nWave2 124293269.565556 -snap {("G8" 9)}
wvZoom -win $_nWave2 124104527.388978 124379905.318739
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
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
wvZoom -win $_nWave2 455084514.874552 510215898.835125
wvZoom -win $_nWave2 468422752.929477 480871775.114123
wvZoom -win $_nWave2 474178752.434129 476989821.959694
wvZoom -win $_nWave2 474753056.960828 475619551.509927
wvZoom -win $_nWave2 474965798.454038 475274817.119397
wvZoom -win $_nWave2 475147997.631246 475193408.976335
