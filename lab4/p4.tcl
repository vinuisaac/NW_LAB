#Program 4

set ns [new Simulator]

set tracefile [open p4.tr w]
$ns trace-all $tracefile

set namfile [open p4.nam w]
$ns namtrace-all $namfile

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail

set em [new ErrorModel]
$em unit pkt 
$em set rate_ 0.2  
$em ranvar [new RandomVariable/Uniform] 
$em drop-target [new Agent/Null] 

$ns make-lan -trace on " $n3 $n4 $n5 $n6 "  0.5Mb 40ms LL Queue/DropTail Mac/802_3 

$ns link-lossmodel $em $n2 $n3

set tcp [new Agent/TCP]
$ns attach-agent $n1 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n5 $sink
$ns connect $tcp $sink
$tcp0 set packetSize_ 1000

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.01 "$ftp start"
$ns at 48.0 "$ftp stop"

proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam p4.nam &
    exec cat p4.tr | awk -f p4.awk &
    exit 0
}

$ns at 50.0 "finish" 
$ns run
