#Program 2

#Create a ns simulator
set ns [new Simulator]

#Open the NS trace file
set tracefile [open p2.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open p2.nam w]
$ns namtrace-all $namfile

#Create 2 nodes
set s [$ns node]
set c [$ns node]

$ns color 1 Blue

#Create labels for nodes
$s label "Server"
$c label "Client"

#Create links between nodes
$ns duplex-link $s $c 10Mb 22ms DropTail

#Give node position (for NAM)
$ns duplex-link-op $s $c orient right

		
#Setup a TCP connection for node s(server)
set tcp0 [new Agent/TCP]
$ns attach-agent $s $tcp0
$tcp0 set packetSize_ 1500

#Setup a TCPSink connection for node c(client)
set sink0 [new Agent/TCPSink]
$ns attach-agent $c $sink0

$ns connect $tcp0 $sink0

#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP
$tcp0 set fid_ 1

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

$ns at 0.01 "$ftp0 start"
$ns at 15.0 "$ftp0 stop"
$ns at 15.1 "finish"
$ns run

	
