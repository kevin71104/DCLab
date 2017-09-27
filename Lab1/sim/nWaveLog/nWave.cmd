wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/home/team05/Lab1/sim/LAB1.fsdb}
wvResizeWindow -win $_nWave1 0 23 1366 705
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/DE2_115"
wvGetSignalSetScope -win $_nWave1 "/DE2_115/deb0"
wvSetPosition -win $_nWave1 {("G1" 3)}
wvSetPosition -win $_nWave1 {("G1" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/DE2_115/deb0/i_clk} \
{/DE2_115/deb0/i_rst} \
{/DE2_115/deb0/neg_r} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 )} 
wvSetPosition -win $_nWave1 {("G1" 3)}
wvGetSignalSetScope -win $_nWave1 "/DE2_115/seven_dec0"
wvGetSignalSetScope -win $_nWave1 "/DE2_115/top0"
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/DE2_115/deb0/i_clk} \
{/DE2_115/deb0/i_rst} \
{/DE2_115/deb0/neg_r} \
{/DE2_115/top0/o_random_out\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/DE2_115/deb0/i_clk} \
{/DE2_115/deb0/i_rst} \
{/DE2_115/deb0/neg_r} \
{/DE2_115/top0/o_random_out\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSetPosition -win $_nWave1 {("G1" 4)}
wvGetSignalClose -win $_nWave1
wvResizeWindow -win $_nWave1 0 23 1366 705
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 20499.306908
wvSetCursor -win $_nWave1 20484.820619
wvSetCursor -win $_nWave1 20465.505566
wvZoom -win $_nWave1 20465.505566 20492.063764
wvSetCursor -win $_nWave1 20466.542443 -snap {("G1" 1)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 30.163703 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 33.557119 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 27.524379
