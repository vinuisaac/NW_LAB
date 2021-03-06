set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red


set tracefile [open p3.tr w]
$ns trace-all $tracefile

set namfile [open p3.nam w]
$ns namtrace-all $namfile


proc finish {} {
		global ns ntrace namfile
	
		$ns flush-trace
		close $tracefile
		close $namfile
		exec nam p3.nam &
		exit 0
	}

	set n0 [$ns node]
	set n1 [$ns node]
	set n2 [$ns node]
	set n3 [$ns node]
	set n4 [$ns node]
	set n5 [$ns node]
	set n6 [$ns node]
	
set lan [$ns newLan "$n0 $n1 $n2 $n3 $n4 $n5 $n6" 0.5Mb 40ms LL Queue/DropTail MAC/802_3 Channel]


set udp [new Agent/UDP]
$ns attach-agent $n0 $udp

set null [new Agent/Null]
$ns attach-agent $n6 $null

$ns connect $udp $null

set cbr0 [new Application/Traffic/CBR]
	$cbr0 set packetSize_  1000
	$cbr0 set interval_ 0.1
	$cbr0 attach-agent $udp

$ns at 0.01 "$cbr0 start"
$ns at 20.0 "$cbr0 stop"
$ns at 25.0 "finish"

$ns run 
 
		
