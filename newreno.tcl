# Create a simulator object
set ns [new Simulator]

# Open the nam file newreno.nam and the variable-trace file newreno.tr
set namfile [open newreno.nam w]
$ns namtrace-all $namfile
set tracefile [open newreno.tr w]
$ns trace-all $tracefile

# Define a 'finish' procedure
proc finish {} {
    global ns namfile tracefile
    $ns flush-trace
    close $namfile
    close $tracefile
    exit 0
}

# Create the network nodes
set A [$ns node]
set R [$ns node]
set B [$ns node]

# Create a duplex link between the nodes
$ns duplex-link $A $R 10Mb 10ms DropTail
$ns duplex-link $R $B 800Kb 50ms DropTail

# The queue size at $R is to be 7, including the packet being sent
$ns queue-limit $R $B 7

# some hints for nam
# color packets of flow 0 red
$ns color 0 Red
$ns duplex-link-op $A $R orient right
$ns duplex-link-op $R $B orient right
$ns duplex-link-op $R $B queuePos 0.5

# Create a TCP sending agent (TCP New Reno) and attach it to A
set tcpNewReno [new Agent/TCP/Newreno]
$tcpNewReno set class_ 1
$tcpNewReno set window_ 100
$tcpNewReno set packetSize_ 960
$ns attach-agent $A $tcpNewReno

# Let's trace some variables
$tcpNewReno attach $tracefile
$tcpNewReno tracevar cwnd_
$tcpNewReno tracevar ssthresh_
$tcpNewReno tracevar ack_
$tcpNewReno tracevar maxseq_

# Create a TCP receive agent (a traffic sink) and attach it to B
set end1 [new Agent/TCPSink]
$ns attach-agent $B $end1

# Connect the traffic source with the traffic sink
$ns connect $tcpNewReno $end1

# Schedule the connection data flow; start sending data at T=0, stop at T=10.0
set myftp1 [new Application/FTP]
$myftp1 attach-agent $tcpNewReno
$ns at 0.0 "$myftp1 start"
$ns at 10.0 "finish"

proc plotWindow {tcpSource outfile} {
    global ns
    set now [$ns now]
    set cwnd [$tcpSource set cwnd_]

    # the data is recorded in a file called congestion.xg (this can be plotted 
    # using xgraph or gnuplot. this example uses xgraph to plot the cwnd_
    puts $outfile "$now $cwnd"
    $ns at [expr $now+0.1] "plotWindow $tcpSource $outfile"
}

set outfileNewReno [open "newreno.xg" w]
$ns at 0.0 "plotWindow $tcpNewReno $outfileNewReno"
$ns at 10.1 "exec xgraph -lw 2 -geometry 800x400 -x1 'RTT (seconds)' -y1 'Congestion Window Size(MSS)' newreno.xg"

after 1000 {
    exec nam newreno.nam
}

# Run the simulation
$ns run

