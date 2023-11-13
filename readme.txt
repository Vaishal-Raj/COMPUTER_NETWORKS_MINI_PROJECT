Here are the instructions to run this program.

1. Install NS2 on your system.

2. Install XGraph on your system.

3. Run the tcl file using NS2.

ns project.tcl

4. Take the generated .xg file and paste it in XGraph's bin folder.

5. Run the file using XGraph.

./xgraph vegas.xg -color blue -thickness 2 newreno.xg -color red -thickness 3 -title_x RTT_in_Seconds -title_y CWND_in_MSS