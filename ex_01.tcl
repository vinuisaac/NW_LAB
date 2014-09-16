# Create a new instance of a Simulator named "ns"
set ns [new Simulator]			;# "new" is used to allocate memory to "ns" instance.

# Open a new file to store Network Animator (NAM) data which is used for *Visualization*
set namfile [open ex_01.nam w]		;# "namfile" is a file pointer for "ex_01.nam"
$ns namtrace-all $namfile		;# "namtrace-all" is an instance procedure (i.e., built-in function) for NAM

# Open a new file to store trace data which is used for *Analysis*
set tracefile [open ex_01.tr w]  	;# "tracefile" is a file pointer for "ex_01.tr"
$ns trace-all $tracefile      		;# "trace-all" is an instance procedure (i.e., built-in function) for trace 

# Creating five instances of *node* inside the "ns" instance. Hence, the syntax is "$ns node" in brackets and not "new node"
set n0 [$ns node]		 
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Setting up links to design the given topology [Assumptions: Bandwidth: 1Mbps, Propagation delay: 10ms, Packet Discard Stragety: DropTail]
$ns duplex-link $n0 $n4 1Mb 10ms DropTail 
$ns duplex-link $n1 $n4 1Mb 10ms DropTail
$ns duplex-link $n4 $n3 1Mb 10ms DropTail
$ns duplex-link $n4 $n2 1Mb 10ms DropTail

# Setting up TCP Source
set tcp [new Agent/TCP]			;# Create a new instance called "tcp" of Agent/TCP class
$ns attach-agent $n0 $tcp   		;# Configure n0 as the TCP Source

# Setting up TCP Destination (also known as TCP Sink)
set sink [new Agent/TCPSink] 		;# Create a new instance called "sink" of Agent/TCPSink class
$ns attach-agent $n3 $sink    		;# Configure n3 as the TCP Destination

# Setup connection between TCP Source and Destination
$ns connect $tcp $sink

# Enable FTP application on TCP Source
set ftp [new Application/FTP]		;# Create a new instance called "ftp" of Application/FTP class
$ftp attach-agent $tcp			;# Configure the application to use TCP

# Setting up UDP Source
set udp [new Agent/UDP]			;# Create a new instance called "udp" of Agent/UDP class
$ns attach-agent $n1 $udp		;# Configure n1 as the UDP Source

# Setting up a dummy UDP Destination (There are no ACKs in UDP!)
set null [new Agent/Null]		;# Create a new instance called "null" of Agent/Null class
$ns attach-agent $n2 $null		;# Configure n2 as the UDP Destination

# Setup connection between UDP Source and Destination
$ns connect $udp $null

# Enable CBR application on UDP Source and set its parameters
set cbr [new Application/Traffic/CBR]	;# Create a new instance called "cbr" of Application/Traffic/CBR class
$cbr set packetSize_ 500		;# packet size is set to 500 bytes
$cbr set interval_ 0.005		;# packet will be sent at an interval of 0.005 seconds
$cbr attach-agent $udp			;# Configure the application to use UDP

# Schedule traffic in the network by starting and stopping the created applications
# Note that you can schedule them in any order. A sample order of starting and stopping is given below:
$ns at 0.0 "$cbr start"			;# CBR application started
$ns at 0.0 "$ftp start"			;# FTP application started
$ns at 9.0 "$cbr stop"			;# CBR application stopped
$ns at 9.0 "$ftp stop"			;# FTP application stopped

# User defined procedure to terminate the simulation
proc finish {} {      			;# "finish" is a user defined name of the procedure.
global ns namfile tracefile  		;# these parameters are made global so that they can be used inside "finish" procedure
$ns flush-trace				;# "flush-trace" is a built-in procedure to de-allocate the memory.
close $namfile				;# Closes ex_01.nam
close $tracefile			;# Closes ex_01.tr
exec nam ex_01.nam &			;# Creates a new process in background to execute "nam ex_01.nam"
exit 0
}

$ns at 10.0 "finish"			;# Simulation stops at time 10
$ns run					;# "run" is an instance procedure to execute the events.
