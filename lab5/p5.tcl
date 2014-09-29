#Program 5
set val(stop) 50.0 ;#time of simulation end

#Create a ns simulator
set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

#Open the NS trace file
set tracefile [open p5.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open p5.nam w]
$ns namtrace-all $namfile

#Create 8 nodes
set n0 [$ns node]
$n0 label "ftp source"
set n1 [$ns node]
$n1 label "cbr source"
$n1 shape square
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
$n6 label "ftp receiver"
set n7 [$ns node]
$n7 label "cbr receiver"

#Create links between nodes
$ns duplex-link $n2 $n0 1.0Mb 10ms DropTail
$ns queue-limit $n2 $n0 50
$ns duplex-link $n1 $n2 1.0Mb 10ms DropTail
$ns queue-limit $n1 $n2 50
$ns duplex-link $n2 $n3 1.50Mb 10ms DropTail
$ns queue-limit $n2 $n3 50
$ns duplex-link $n3 $n4 1.0Mb 10ms DropTail
$ns queue-limit $n3 $n4 50
$ns duplex-link $n3 $n5 1.0Mb 10ms DropTail
$ns queue-limit $n3 $n5 50
$ns duplex-link $n5 $n7 1.0Mb 10ms DropTail
$ns queue-limit $n5 $n7 50
$ns duplex-link $n4 $n6 1.0Mb 10ms DropTail
$ns queue-limit $n4 $n6 50

#Give node position (for NAM)
$ns duplex-link-op $n2 $n0 orient left-up
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down
$ns duplex-link-op $n5 $n7 orient right
$ns duplex-link-op $n4 $n6 orient right

#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink6 [new Agent/TCPSink]
$ns attach-agent $n6 $sink6
$ns connect $tcp0 $sink6
$tcp0 set packetSize_ 1500

#Setup a UDP connection
set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
set null7 [new Agent/Null]
$ns attach-agent $n7 $null7
$ns connect $udp1 $null7
$udp1 set packetSize_ 1500

$tcp0 set fid_ 1
$udp1 set fid_ 2

#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
#$cbr0 set packetSize_ 1460
#$cbr0 set rate_ 0.5Mb
#$cbr0 set random_ null
$ns at 0.01 "$ftp0 start"
$ns at 40.0 "$ftp0 stop"

#Setup a CBR Application over UDP connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 1500
$cbr1 set rate_ 0.5Mb
$cbr1 set random_ null
$ns at 0.01 "$cbr1 start"
$ns at 40.0 "$cbr1 stop"

#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam p5.nam &
    exec awk -f p5.awk & 
    exec grep "d " p5.tr >> p52.tr
    exec cat p52.tr
    exit 0
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run


