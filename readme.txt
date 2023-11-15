Here are the instructions to run this program.

1. Install NS2 on your system.

2. Install XGraph on your system.

3. Run both the tcl files using NS2.

ns vegas.tcl
ns newreno.tcl

4. Take the generated .xg files and paste it in XGraph's bin folder.

5. Run the file using XGraph.

./xgraph vegas.xg -color blue -thickness 2 newreno.xg -color red -thickness 3 -title_x RTT_in_Seconds -title_y CWND_in_MSS
