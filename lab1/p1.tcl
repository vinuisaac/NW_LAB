#Program 1

et ns [new Simulator]

et tracefile [open p1.tr w]
$ns trace-all $tracefile

set namfile [open p1.nam w]
$ns namtrace-all $namfile

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

$ns duplex-link $n0 $n4 100.0Mb 40ms DropTail
$ns duplex-link $n4 $n3 100.0Mb 40ms DropTail
$ns duplex-link $n1 $n4 100.0Mb 40ms DropTail
$ns duplex-link $n4 $n2 100.0Mb 40ms DropTail

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
$ns connect $tcp $sink
$tcp0 set packetSize_ 1000

set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n2 $null
$ns connect $udp1 $null
$udp1 set packetSize_ 1000

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $tcp
$cbr0 set packetSize_ 1000
$cbr0 set rate_  3.0Mb
$cbr0 set random_ null
$ns at 0.01 "$cbr0 start"
$ns at 9.9  "$cbr0 stop"

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp
$cbr1 set packetSize_ 1000
$cbr1 set rate_ 2.0Mb
$cbr1 set random_ null
$ns at 0.1 "$cbr1 start"
$ns at 9.0 "$cbr1 stop"

#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam p1.nam &
    exit 0
}

$ns at 15.0 "finish" 
$ns run

