# Create a new instance of a Simulator named "ns"
set ns [new Simulator]			;# "new" is used to allocate memory to "ns" instance.

# Open a new file to store Network Animator (NAM) data which is used for *Visualization*
set namfile [open ex_04.nam w]		;# "namfile" is a file pointer for "ex_04.nam"
$ns namtrace-all $namfile		;# "namtrace-all" is an instance procedure (i.e., built-in function) for NAM

# Open a new file to store trace data which is used for *Analysis*
set tracefile [open ex_04.tr w]  	;# "tracefile" is a file pointer for "ex_04.tr"
$ns trace-all $tracefile      		;# "trace-all" is an instance procedure (i.e., built-in function) for trace

# Before we proceed, set the TCP packet size to 1500 bytes 
Agent/TCP set packetSize_ 1460

# Creating five instances of *node* inside the "ns" instance. Hence, the syntax is "$ns node" in brackets and not "new node"
set n0 [$ns node]		 
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

# Setting up links to design the given topology [Assumptions: Bandwidth: 1Mbps, Propagation delay: 10ms, Packet Discard Stragety: DropTail]

$ns duplex-link $n0 $n1 1Mb 10ms DropTail 
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail
$ns make-lan "$n3 $n4 $n5 $n6" 100Mb 1ms LL Queue/DropTail Mac/802_3 Channel Phy/WiredPhy

# Configure the link between node 2 and node 3 to behave as a faulty link
set errmodel [new ErrorModel]		
$errmodel set rate_ 0.2			;# error rate in the link is fixed to 0.2
$errmodel ranvar [new RandomVariable/Uniform] 
$errmodel drop-target [new Agent/Null] 
$ns lossmodel $errmodel $n2 $n3 	

# Setting up TCP Source
set tcp [new Agent/TCP]			;# Create a new instance called "tcp" of Agent/TCP class
$ns attach-agent $n1 $tcp   		;# Configure n1 as the TCP Server (source)

# Setting up TCP Destination (also known as TCP Sink)
set sink [new Agent/TCPSink] 		;# Create a new instance called "sink" of Agent/TCPSink class
$ns attach-agent $n5 $sink    		;# Configure n5 as the TCP Client (destination)

# Setup connection between TCP Source and Destination
$ns connect $tcp $sink

# Enable FTP application on TCP Source
set ftp [new Application/FTP]		;# Create a new instance called "ftp" of Application/FTP class
$ftp attach-agent $tcp			;# Configure the application to use TCP

# Start sending the 4MB file from server node to the client node
set filesize [expr 4*1024*1024]		;# We convert filesize from MB to bytes
$ns at 0.0 "$ftp send $filesize"	;# "send" works with *bytes*. For working with *number of packets*, use "produce" instead of "send"

# User defined procedure to terminate the simulation
proc finish {} {      			;# "finish" is a user defined name of the procedure.
global ns namfile tracefile  		;# these parameters are made global so that they can be used inside "finish" procedure
$ns flush-trace				;# "flush-trace" is a built-in procedure to de-allocate the memory.
close $namfile				;# Closes ex_04.nam
close $tracefile			;# Closes ex_04.tr
set awkCode {
	     BEGIN{}				;# This is to verify whether client has downloaded the whole file or not!
	{
		if ($1 == "r" && $4 == 5 && $6 > 1460) {	;# Checking whether "n5" has "received" a file of "size > 1460"			
			count_bytes = count_bytes + $6 - ($6 % 1460)	;# Removing the headers from calculation
			print $2, count_bytes >> "ex_04_bytes.data";	;# Storing the results in a file called "ex_02.data"
		}
		else if ($1 == "d" && $5 == "tcp" && $6 > 1460) {	;# Checking for dropped packets (they would be equal to the number of retransmitted packets
			count_packets++;
			print $2, count_packets >> "ex_04_packets.data"	;# Storing the results in a file called "ex_04_packets.data"
		}
	}
 END{}
}
exec awk $awkCode ex_04.tr					;# Execute the awkCode on "ex_04.tr" file to extract the desired values
exec nam ex_04.nam &						;# Creates a new process in background to execute "nam ex_04.nam"
exec xgraph -bb -tk -x Time -y Bytes ex_04_bytes.data -bg white &	;# Creates a new process in background to plot a graph
exec xgraph -bb -tk -x Time -y Packets ex_04_packets.data -bg white &	;# Creates a new process in background to plot a graph
exit 0
}

$ns at 100.0 "finish"			;# Simulation stops at time 100
$ns run					;# "run" is an instance procedure to execute the events.
