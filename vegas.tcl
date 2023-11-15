# Create a simulator object
set ns [new Simulator]

# Open the nam file vegas.nam and the variable-trace file vegas.tr
set namfile [open vegas.nam w]
$ns namtrace-all $namfile
set tracefile [open vegas.tr w]
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

# Create a TCP sending agent (TCP Vegas) and attach it to A
set tcpVegas [new Agent/TCP/Vegas]
$tcpVegas set class_ 0
$tcpVegas set window_ 100
$tcpVegas set packetSize_ 960
$ns attach-agent $A $tcpVegas

# Let's trace some variables
$tcpVegas attach $tracefile
$tcpVegas tracevar cwnd_
$tcpVegas tracevar ssthresh_
$tcpVegas tracevar ack_
$tcpVegas tracevar maxseq_

# Create a TCP receive agent (a traffic sink) and attach it to B
set end0 [new Agent/TCPSink]
$ns attach-agent $B $end0

# Connect the traffic source with the traffic sink
$ns connect $tcpVegas $end0

# Schedule the connection data flow; start sending data at T=0, stop at T=10.0
set myftp [new Application/FTP]
$myftp attach-agent $tcpVegas
$ns at 0.0 "$myftp start"
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

set outfileVegas [open "vegas.xg" w]
$ns at 0.0 "plotWindow $tcpVegas $outfileVegas"
$ns at 10.1 "exec xgraph -lw 2 -geometry 800x400 -x1 'RTT (seconds)' -y1 'Congestion Window Size(MSS)' vegas.xg"

after 1000 {
    exec nam vegas.nam
}

# Run the simulation
$ns run

