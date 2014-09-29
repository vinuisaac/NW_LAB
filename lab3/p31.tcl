# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

#===================================
#     Simulation parameters setup
#===================================
set val(stop)   20.0                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile

#===================================
#        Nodes Definition        
#===================================
#Create 10 nodes
set n0 [$ns node]
        $n0 shape square
        $n0 color blue	
set n1 [$ns node]
	$n1 shape square
        $n1 color blue
set n2 [$ns node]
	$n2 shape square
        $n2 color blue
set n3 [$ns node]
	$n3 shape square
        $n3 color blue
set n4 [$ns node]
	$n4 shape square
        $n4 color blue
set n5 [$ns node]
	$n5 shape square
        $n5 color blue
set n6 [$ns node]
	$n6 shape square
        $n6 color blue
set n7 [$ns node]
	$n7 shape hexagon
        $n7 color black
set n8 [$ns node]
	$n8 shape hexagon
        $n8 color black
set n9 [$ns node]
	$n9 shape hexagon
        $n9 color black

 #===================================
#        Links Definition        
#===================================


set lan [$ns newLan "$n0 $n1 $n2 $n3 $n4 $n5 $n6" 0.5Mb 40ms LL Queue/DropTail MAC/802_3 Channel]


#Createlinks between nodes
#$ns duplex-link $n6 $n7 100.0Mb 10ms DropTail
#$ns queue-limit $n6 $n7 50
$ns duplex-link $n8 $n7 100.0Mb 10ms DropTail
$ns queue-limit $n8 $n7 50
$ns duplex-link $n7 $n9 100.0Mb 10ms DropTail
$ns queue-limit $n7 $n9 50

#Give node position (for NAM)
#$ns duplex-link-op $n6 $n7 orient right-up
$ns duplex-link-op $n8 $n7 orient left-down
$ns duplex-link-op $n7 $n9 orient right-down

#===================================
#        Agents Definition        
#===================================
#Setup a TCP connection

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

$n0 label "Sender"

set sink1 [new Agent/TCPSink]
$ns attach-agent $n6 $sink1

$n7 label "Receiver"

$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500


#===================================
#        Applications Definition        
#===================================
#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 0.01 "$ftp0 start"
$ns at 20.0 "$ftp0 stop"


#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exit 0
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run  
