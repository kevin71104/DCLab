wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/home/team05/Lab1/src/Top.vcd.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb_Top"
wvGetSignalSetScope -win $_nWave1 "/tb_Top/top"
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb_Top/top/curr_cnt\[6:0\]} \
{/tb_Top/top/curr_num\[3:0\]} \
{/tb_Top/top/curr_state} \
{/tb_Top/top/i_clk} \
{/tb_Top/top/i_rst} \
{/tb_Top/top/i_start} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 )} 
wvSetPosition -win $_nWave1 {("G1" 6)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 85960.111489 -snap {("G1" 5)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 6)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 )} 
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSelectGroup -win $_nWave1 {G1}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 6)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb_Top"
wvGetSignalSetScope -win $_nWave1 "/tb_Top/top"
wvSetPosition -win $_nWave1 {("G1" 7)}
wvSetPosition -win $_nWave1 {("G1" 7)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb_Top/top/i_clk} \
{/tb_Top/top/i_rst} \
{/tb_Top/top/i_start} \
{/tb_Top/top/curr_cnt\[6:0\]} \
{/tb_Top/top/curr_num\[3:0\]} \
{/tb_Top/top/curr_state} \
{/tb_Top/top/curr_stage\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 7 )} 
wvSetPosition -win $_nWave1 {("G1" 7)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 58929.685806 -snap {("G2" 0)}
wvResizeWindow -win $_nWave1 0 23 1366 705
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb_Top"
wvGetSignalSetScope -win $_nWave1 "/tb_Top/top"
wvGetSignalSetScope -win $_nWave1 "/tb_Top/top"
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb_Top/top/i_clk} \
{/tb_Top/top/i_rst} \
{/tb_Top/top/i_start} \
{/tb_Top/top/curr_cnt\[6:0\]} \
{/tb_Top/top/curr_num\[3:0\]} \
{/tb_Top/top/curr_state} \
{/tb_Top/top/curr_stage\[3:0\]} \
{/tb_Top/top/curr_random\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSetPosition -win $_nWave1 {("G1" 8)}
wvGetSignalClose -win $_nWave1
wvSetRadix -win $_nWave1 -format UDec {("G1" 8)}
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb_Top"
wvGetSignalSetScope -win $_nWave1 "/tb_Top/top"
wvGetSignalSetScope -win $_nWave1 "/tb_Top/top"
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb_Top/top/i_clk} \
{/tb_Top/top/i_rst} \
{/tb_Top/top/i_start} \
{/tb_Top/top/curr_cnt\[6:0\]} \
{/tb_Top/top/curr_num\[3:0\]} \
{/tb_Top/top/curr_state} \
{/tb_Top/top/curr_stage\[3:0\]} \
{/tb_Top/top/curr_random\[3:0\]} \
{/tb_Top/top/en} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 52726.882572 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 25355.921237 -snap {("G1" 7)}
wvSetCursor -win $_nWave1 26783.241306 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 29218.081425 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 31149.161519 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 18891.000921 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 20738.121011 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 22669.201106 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 28966.201413 -snap {("G1" 6)}
wvSetCursor -win $_nWave1 50459.962461 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 45926.122240 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 53146.682592 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 48612.842371 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 44079.002150 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 15196.760741 -snap {("G1" 5)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 41056.442002 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 23256.921134 -snap {("G2" 0)}
wvSetCursor -win $_nWave1 31736.881548 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 38285.761867 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 45086.522199 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 46345.922260 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 41476.242023 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 32996.281609 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 46513.842269 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 39041.401904 -snap {("G2" 0)}
wvSetCursor -win $_nWave1 38285.761867 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 42819.602088 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvUnknownSaveResult -win $_nWave1 -clear
wvSetCursor -win $_nWave1 50124.122445 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb_Top/top/i_clk} \
{/tb_Top/top/i_rst} \
{/tb_Top/top/i_start} \
{/tb_Top/top/curr_num\[3:0\]} \
{/tb_Top/top/curr_state} \
{/tb_Top/top/curr_stage\[3:0\]} \
{/tb_Top/top/curr_random\[3:0\]} \
{/tb_Top/top/en} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/tb_Top/top/curr_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetPosition -win $_nWave1 {("G2" 1)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 52475.002559 -snap {("G3" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 41308.322015 -snap {("G3" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 37026.361806 -snap {("G3" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team05/Lab1/src/Top.vcd.fsdb" \
           "/home/team05/Lab1/src/Top.vcd"
wvReloadFile -win $_nWave1
wvZoomOut -win $_nWave1
wvExit
