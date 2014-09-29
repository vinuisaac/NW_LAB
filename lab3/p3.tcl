set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red


set ntrace [open prg3.tr w]
$ns trace-all $ntrace

set namfile [open prg3.nam w]
$ns namtrace-all $namfile


proc finish { } {
		global ns ntrace namfile
	
			$ns flush-trace
			close $ntrace
			close $namfile

		exec nam prg3.nam &
		
		exit 0
	}


    for { set i 0 } {$i < 7 } { incr i } {
		set n($i) [$ns node]
	}


      $n(0) label "Udp Source "
      $n(6) label "Udp Sink"

      			



	set lan [$ns newLan "$n(0) $n(1) $n(2) $n(3) $n(4) $n(5) $n(6)" 0.5Mb 40ms LL Queue/DropTail MAC/802_3 Channel]


    #   $ns make-lan -trace on "$n(0) $n(1) $n(2) $n(3) $n(4) $n(5)"  0.5Mb 40ms LL Queue/DropTail Mac/802_3 




 set udp [new Agent/UDP]
$ns attach-agent $n(0) $udp

set sink0 [new Agent/Null]
$ns attach-agent $n(6) $sink0

$ns connect $udp $sink0

set cbr0 [new Application/Traffic/CBR]
	$cbr0 set packetSize_  1000
	$cbr0 set interval_ 0.1
	$cbr0 attach-agent $udp



$udp set fid_ 1




$ns at 0.01 "$cbr0 start"
$ns at 20.0 "$cbr0 stop"
$ns at 25.0 "finish"


$ns run 
 
		
