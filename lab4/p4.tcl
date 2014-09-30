#Program 4
set val(stop)   20.0 ;#time of simulation end

#Create a ns simulator
set ns [new Simulator]

#Open the NS trace file
set tracefile [open p4.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open p4.nam w]
$ns namtrace-all $namfile

#Create 7 nodes
set n0 [$ns node]

set n1 [$ns node]
$n1 shape square
$n1 label "ftp_server"

set n2 [$ns node]
$n2 color green	
$n2 label "error_node"

set n3 [$ns node]
$n3 color green
$n3 label "error_node"

set n4 [$ns node]

set n5 [$ns node]
$n5 label "ftp_client"

set n6 [$ns node]

#Createlinks between nodes
$ns duplex-link $n0 $n2 100.0Mb 10ms DropTail
$ns queue-limit $n0 $n2 50
$ns duplex-link $n0 $n1 100.0Mb 10ms DropTail
$ns queue-limit $n0 $n1 50
$ns duplex-link $n1 $n2 100.0Mb 10ms DropTail
$ns queue-limit $n1 $n2 50
$ns duplex-link $n2 $n3 100.0Mb 10ms DropTail
$ns queue-limit $n2 $n3 50

#Give node position (for NAM)
$ns duplex-link-op $n0 $n2 orient right
$ns duplex-link-op $n0 $n1 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

set em [new ErrorModel]
$em unit pkt ; # error unit (default: packets) (Other units: time, bits)
$em set rate_ 0.2 ; # error rate probability 
$em ranvar [new RandomVariable/Uniform] ; # specify the rv for generating errors
$em drop-target [new Agent/Null] ; # collect corrupted packets and handle

#Create a LAN of four nodes and record the trace (ex: collision-c, hop-h)
$ns make-lan -trace on " $n3 $n4 $n5 $n6 "  0.5Mb 40ms LL Queue/DropTail Mac/802_3 

#Associate a link loss model between nodes n2 and n3
$ns link-lossmodel $em $n2 $n3

#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n1 $tcp0
set sink2 [new Agent/TCPSink]
$ns attach-agent $n5 $sink2
$ns connect $tcp0 $sink2
$tcp0 set packetSize_ 1000

#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 0.01 "$ftp0 start"
$ns at 48.0 "$ftp0 stop"

#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam p4.nam &
    exec cat p4.tr | awk -f p4.awk &
    exit 0
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
