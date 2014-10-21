#Program 2

set ns [new Simulator]

set tracefile [open p2.tr w]
$ns trace-all $tracefile

set namfile [open p2.nam w]
$ns namtrace-all $namfile

set s [$ns node]
set c [$ns node]

$ns duplex-link $s $c 10Mb 22ms DropTail

set tcp [new Agent/TCP]
$ns attach-agent $s $tcp
$tcp0 set packetSize_ 1500

set sink [new Agent/TCPSink]
$ns attach-agent $c $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

proc finish { } {
	global ns tracefile namfile 
	$ns flush-trace
	close $tracefile
    	close $namfile
    	exec nam p2.nam &
	exec awk -f p2.awk p2.tr &
	exec awk -f p21.awk  p2.tr > p21.tr &
	exec xgraph p21.tr -geometry 800*400 -t "bytes_received_at_client" -x "time_in_secs" -y "bytes_in_bps"  &
		}

$ns at 0.01 "$ftp start"
$ns at 15.0 "$ftp stop"
$ns at 18.0 "finish"
$ns run

	
