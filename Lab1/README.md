# Simulation guideline

This is the step for running simulation of lab1
1. Login to DCLab server.
2. Keep the directory structure we have provided
3. Type "tool 2" to enable ncsim (for simulation) and
   nWave (for viewing waveform).
4. Change to directory sim/
5. Type "make TEST=LAB1 TOPLEVEL=DE2_115 SV=1" to
   run the GUI simulation.
6. The red/black/blue parts in the GUI mean LEDs
   are lighted/dark/error, respectively.
6. If the output is different from what you
   are expecting, then you can use nWave to view
   the waveform.

# Notes

By default the simulation runs 1000 cycles Verilog
simulation and sleep 100ms.
