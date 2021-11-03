debImport "-sverilog" "-f" "/home/fred2/RISCV/./sim/designlist.f"
srcDeselectAll -win $_nTrace1
wvCreateWindow
verdiWindowBeWindow -win $_nWave2
wvResizeWindow -win $_nWave2 0 27 900 209
wvResizeWindow -win $_nWave2 8 31 900 209
wvResizeWindow -win $_nWave2 8 31 1020 666
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/fred2/RISCV/build/top.fsdb}
srcHBSelect "test.u_cpu_wrap" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap" -delim "."
srcHBSelect "test.u_cpu_wrap" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_marb" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_marb" -delim "."
srcHBSelect "test.u_cpu_wrap.u_marb" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_marb.u_l1dc" -win $_nTrace1
srcHBSelect "test.u_cpu_wrap.u_marb.u_l1ic" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap.u_marb.u_l1ic" -delim "."
srcHBSelect "test.u_cpu_wrap.u_marb.u_l1ic" -win $_nTrace1
srcHBDrag -win $_nTrace1
wvRenameGroup -win $_nWave2 {G1} {u_l1ic}
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_marb/u_l1ic/clk" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/rstn" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/core_req" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/core_bypass" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/core_wr" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/core_addr\[31:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/core_wdata\[31:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/core_byte\[3:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/core_rdata\[31:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/core_err" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/core_busy" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_awburst\[1:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_awid\[9:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_awaddr\[31:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_awsize\[2:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_awlen\[7:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_awvalid" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_awready" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_wstrb\[3:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_wid\[9:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_wdata\[31:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_wlast" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_wvalid" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_wready" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_bid\[9:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_bresp\[1:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_bvalid" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_bready" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_araddr\[31:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_arburst\[1:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_arsize\[2:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_arid\[9:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_arlen\[7:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_arvalid" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_arready" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_rdata\[31:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_rresp\[1:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_rid\[9:0\]" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_rlast" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_rvalid" \
           "/test/u_cpu_wrap/u_marb/u_l1ic/m_rready"
wvSetPosition -win $_nWave2 {("u_l1ic" 0)}
wvSetPosition -win $_nWave2 {("u_l1ic" 41)}
wvSetPosition -win $_nWave2 {("u_l1ic" 41)}
wvSetPosition -win $_nWave2 {("u_l1ic" 17)}
wvSelectSignal -win $_nWave2 {( "u_l1ic" 17 )} 
wvResizeWindow -win $_nWave2 522 31 1328 1008
wvResizeWindow -win $_nWave2 381 50 1020 666
wvResizeWindow -win $_nWave2 381 50 1339 799
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoom -win $_nWave2 0.000000 9236320.230836
wvZoom -win $_nWave2 0.000000 712708.756081
wvSelectSignal -win $_nWave2 {( "u_l1ic" 12 )} 
wvScrollDown -win $_nWave2 10
wvSelectSignal -win $_nWave2 {( "u_l1ic" 12 13 14 15 16 17 18 19 20 21 22 23 24 \
           25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 )} 
wvSetPosition -win $_nWave2 {("u_l1ic" 40)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 30)}
wvSetPosition -win $_nWave2 {("G2" 30)}
wvScrollDown -win $_nWave2 1
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSelectGroup -win $_nWave2 {G3}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cur_state" -line 94 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_marb/u_l1ic/cur_state\[2:0\]"
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvScrollUp -win $_nWave2 12
wvSelectGroup -win $_nWave2 {G2}
wvScrollDown -win $_nWave2 0
wvSetPosition -win $_nWave2 {("u_l1ic" 11)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("u_l1ic" 11)}
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "u_l1ic" 12 )} 
schCreateWindow -delim "." -win $_nSchema1 -scope "test.u_cpu_wrap.u_marb.u_l1ic"
schCloseWindow -win $_nSchema3
wvSelectSignal -win $_nWave2 {( "u_l1ic" 11 )} 
wvZoom -win $_nWave2 83979.238204 211062.864158
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 65728.340431 161140.447508
wvScrollDown -win $_nWave2 8
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G2" 23 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 22 )} 
wvSelectSignal -win $_nWave2 {( "G2" 23 )} 
wvSelectSignal -win $_nWave2 {( "G2" 24 )} 
wvSelectSignal -win $_nWave2 {( "G2" 17 )} 
wvSelectSignal -win $_nWave2 {( "G2" 18 )} 
wvSelectSignal -win $_nWave2 {( "G2" 19 )} 
wvSelectSignal -win $_nWave2 {( "G2" 20 )} 
wvSelectSignal -win $_nWave2 {( "G2" 21 )} 
wvSelectSignal -win $_nWave2 {( "G2" 22 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvScrollDown -win $_nWave2 4
wvSelectSignal -win $_nWave2 {( "G2" 14 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "m_rvalid" -line 293 -pos 1 -win $_nTrace1
srcSelect -signal "tag_cs" -line 304 -pos 1 -win $_nTrace1
srcSelect -signal "tag_we" -line 305 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSelectGroup -win $_nWave2 {G4}
wvSetPosition -win $_nWave2 {("G3" 0)}
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "data_cs" -line 313 -pos 1 -win $_nTrace1
srcSelect -signal "data_we" -line 314 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
wvSelectSignal -win $_nWave2 {( "G3" 2 4 )} 
wvZoom -win $_nWave2 63674.398884 273799.915199
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1903618.858967 2040342.865412
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1897559.661601 1946603.517927
wvResizeWindow -win $_nWave2 271 171 1339 799
wvScrollUp -win $_nWave2 18
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSetPosition -win $_nWave2 {("G2" 1)}
wvExpandBus -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G3" 5)}
wvSelectGroup -win $_nWave2 {G2}
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSetPosition -win $_nWave2 {("G2" 1)}
wvCollapseBus -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G3" 5)}
wvSelectGroup -win $_nWave2 {G2}
wvSetCursor -win $_nWave2 1906304.409267 -snap {("G3" 4)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 1916097.503876 -snap {("u_l1ic" 12)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
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
wvZoom -win $_nWave2 0.000000 40992652.445369
wvZoom -win $_nWave2 0.000000 2431406.024335
wvZoom -win $_nWave2 0.000000 511075.980141
wvZoom -win $_nWave2 72327.089801 226553.972466
wvZoom -win $_nWave2 89017.616125 194777.778119
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
wvZoom -win $_nWave2 0.000000 1112847.823188
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G2" 7 )} 
wvSelectSignal -win $_nWave2 {( "G2" 6 )} 
wvSelectSignal -win $_nWave2 {( "G2" 7 )} 
wvSelectSignal -win $_nWave2 {( "G2" 6 )} 
wvSelectSignal -win $_nWave2 {( "G2" 7 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 7
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G3" 4)}
srcDeselectAll -win $_nTrace1
verdiWindowResize -win $_Verdi_1 "384" "128" "1118" "804"
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "valid_wr" -line 256 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G3" 0)}
wvAddSignal -win $_nWave2 "/test/u_cpu_wrap/u_marb/u_l1ic/valid_wr"
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvScrollUp -win $_nWave2 13
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 4
wvZoom -win $_nWave2 81060.715529 171385.512832
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 3
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 3
wvScrollUp -win $_nWave2 4
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 3
wvScrollDown -win $_nWave2 4
wvScrollDown -win $_nWave2 3
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 5
wvScrollUp -win $_nWave2 3
wvScrollUp -win $_nWave2 3
wvScrollUp -win $_nWave2 4
wvScrollUp -win $_nWave2 2
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 4
wvScrollDown -win $_nWave2 3
wvScrollDown -win $_nWave2 4
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 3
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 28 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 6015.387125 487246.357148
wvZoom -win $_nWave2 96653.062020 182783.891202
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
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
wvScrollUp -win $_nWave2 17
wvZoom -win $_nWave2 0.000000 29073669.771072
wvZoom -win $_nWave2 0.000000 3358144.999572
wvZoom -win $_nWave2 0.000000 782751.800108
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1661616.724475 2573876.886932
wvZoom -win $_nWave2 1804009.049519 2098286.521280
wvZoom -win $_nWave2 1858209.999052 1972430.079142
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 1414855.185632 3620812.195488
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
wvZoom -win $_nWave2 162124348.699272 192213909.261186
wvZoom -win $_nWave2 174773862.192450 180190609.307134
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
wvScrollDown -win $_nWave2 18
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 120875770.031217 290101848.074922
wvZoom -win $_nWave2 168244984.384745 192545919.629314
wvZoom -win $_nWave2 175780550.152527 178840293.299866
wvZoom -win $_nWave2 178155751.388624 178585580.030550
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoom -win $_nWave2 89342960.457856 254364663.891779
wvZoom -win $_nWave2 148585923.709362 192889357.097450
wvScrollUp -win $_nWave2 2
wvScrollUp -win $_nWave2 16
wvZoom -win $_nWave2 175370829.847155 177814203.384688
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 175189038.787849 178850285.295702
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "u_l1ic" 2 )} 
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
wvSelectGroup -win $_nWave2 {u_l1ic}
wvSelectGroup -win $_nWave2 {G2}
wvSelectGroup -win $_nWave2 {G3}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSelectGroup -win $_nWave2 {u_l1ic}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 0.000000 17546895.005203
wvZoom -win $_nWave2 0.000000 1314647.700702
wvZoom -win $_nWave2 0.000000 478799.890994
wvSelectSignal -win $_nWave2 {( "u_l1ic" 3 )} 
wvSelectSignal -win $_nWave2 {( "u_l1ic" 5 )} 
wvSelectSignal -win $_nWave2 {( "u_l1ic" 4 )} 
wvSelectSignal -win $_nWave2 {( "u_l1ic" 5 )} 
wvSelectSignal -win $_nWave2 {( "u_l1ic" 6 )} 
wvSetSearchMode -win $_nWave2 -value 
wvSetSearchMode -win $_nWave2 -value 7e0
wvSearchNext -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 178170574.774626 178353923.744330
wvSetCursor -win $_nWave2 178334653.977457 -snap {("u_l1ic" 11)}
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 178314716.446365 178397137.627335
wvSelectSignal -win $_nWave2 {( "u_l1ic" 9 )} 
wvSetCursor -win $_nWave2 178345506.460835 -snap {("u_l1ic" 3)}
srcActiveTrace "test.u_cpu_wrap.u_marb.u_l1ic.core_req" -win $_nTrace1 \
           -TraceByDConWave -TraceTime 178345000 -TraceValue x
srcDeselectAll -win $_nTrace1
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst_valid" -line 98 -pos 1 -win $_nTrace1
srcAction -pos 97 17 7 -win $_nTrace1 -name "inst_valid" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "stall" -line 100 -pos 1 -win $_nTrace1
srcAction -pos 99 24 3 -win $_nTrace1 -name "stall" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "if_stall" -line 341 -pos 1 -win $_nTrace1
srcAction -pos 340 6 3 -win $_nTrace1 -name "if_stall" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe_hazard" -line 37 -pos 1 -win $_nTrace1
srcAction -pos 36 1 7 -win $_nTrace1 -name "exe_hazard" -ctrlKey off
wvSelectSignal -win $_nWave2 {( "u_l1ic" 12 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "id2exe_rs1_addr" -line 565 -pos 1 -win $_nTrace1
srcAction -pos 564 7 11 -win $_nTrace1 -name "id2exe_rs1_addr" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "id_rs1_addr" -line 502 -pos 1 -win $_nTrace1
wvSelectGroup -win $_nWave2 {G4}
wvSetPosition -win $_nWave2 {("G4" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "id_rs1_addr" -line 502 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 178313558.604583 -snap {("G4" 1)}
wvSetCursor -win $_nWave2 178340317.614430 -snap {("G4" 1)}
wvSetCursor -win $_nWave2 178305668.127320 -snap {("G4" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "id2exe_rs1_addr" -line 502 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
srcDeselectAll -win $_nTrace1
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "exe_stall" -line 497 -pos 1 -win $_nTrace1
srcSelect -signal "stall_wfi" -line 497 -pos 1 -win $_nTrace1
srcSelect -signal "id_flush_force" -line 497 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
wvSelectSignal -win $_nWave2 {( "G4" 2 )} 
wvSelectSignal -win $_nWave2 {( "G4" 2 3 4 )} 
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSelectSignal -win $_nWave2 {( "G4" 5 )} 
wvSelectSignal -win $_nWave2 {( "G4" 4 )} 
wvSetCursor -win $_nWave2 178306011.191549 -snap {("G4" 4)}
srcActiveTrace "test.u_cpu_wrap.u_cpu_top.id_rs1_addr\[4:0\]" -win $_nTrace1 \
           -TraceByDConWave -TraceTime 178305000 -TraceValue zzzzz
srcDeselectAll -win $_nTrace1
srcSelect -signal "inst\[19:15\]" -line 55 -pos 1 -win $_nTrace1
srcAction -pos 54 6 2 -win $_nTrace1 -name "inst\[19:15\]" -ctrlKey off
wvSelectGroup -win $_nWave2 {G5}
debReload
srcHBSelect "test.u_cpu_wrap" -win $_nTrace1
srcSetScope -win $_nTrace1 "test.u_cpu_wrap" -delim "."
srcHBSelect "test.u_cpu_wrap" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSignalView -on
srcSignalViewSetFilter "dmmu*"
srcSignalViewSelect "test.u_cpu_wrap.dmmu_pa\[55:0\]"
srcSignalViewSelect "test.u_cpu_wrap.dmmu_awvalid"
srcSignalViewSelect "test.u_cpu_wrap.dmmu_bvalid"
srcSignalViewSelect "test.u_cpu_wrap.dmmu_awlen\[7:0\]"
srcSignalViewSelect "test.u_cpu_wrap.dmmu_arsize\[2:0\]"
srcSignalViewSelect "test.u_cpu_wrap.dmmu_araddr\[31:0\]"
srcSignalViewSelect "test.u_cpu_wrap.dmmu_pa\[55:0\]"
srcSignalViewSelect "test.u_cpu_wrap.dmmu_araddr\[31:0\]"
srcSignalViewSelect "test.u_cpu_wrap.dmmu_arready"
