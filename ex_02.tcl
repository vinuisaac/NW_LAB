# Create a new instance of a Simulator named "ns"
set ns [new Simulator]			;# "new" is used to allocate memory to "ns" instance.

# Open a new file to store Network Animator (NAM) data which is used for *Visualization*
set namfile [open ex_02.nam w]		;# "namfile" is a file pointer for "ex_02.nam"
$ns namtrace-all $namfile		;# "namtrace-all" is an instance procedure (i.e., built-in function) for NAM

# Open a new file to store trace data which is used for *Analysis*
set tracefile [open ex_02.tr w]  	;# "tracefile" is a file pointer for "ex_02.tr"
$ns trace-all $tracefile      		;# "trace-all" is an instance procedure (i.e., built-in function) for trace

# Before we proceed, set the TCP packet size to 1500 bytes 
Agent/TCP set packetSize_ 1500

# Creating two instances of *node* inside the "ns" instance. Hence, the syntax is "$ns node" in brackets and not "new node"
set n0 [$ns node]			;# Server node	 
set n1 [$ns node]			;# Client node

# Setting up link between client and server [Assumptions: Bandwidth: 1Mbps, Propagation delay: 10ms, Packet Discard Stragety: DropTail]
$ns duplex-link $n0 $n1 1Mb 10ms DropTail 

# Setting up TCP Source
set tcp [new Agent/TCP]			;# Create a new instance called "tcp" of Agent/TCP
$ns attach-agent $n0 $tcp   		;# Configure n0 as the TCP Server (source)

# Setting up TCP Destination (also known as TCP Sink)
set sink [new Agent/TCPSink] 		;# Create a new instance called "sink" of Agent/TCPSink
$ns attach-agent $n1 $sink    		;# Configure n1 as the TCP client (destination)

# Setup connection between TCP Source and Destination
$ns connect $tcp $sink

# Enable FTP application on TCP Source
set ftp [new Application/FTP]		;# Create a new instance called "ftp" of Application/FTP
$ftp attach-agent $tcp			;# Configure the application to use TCP

# Start sending the 10MB file from server node to the client node
set filesize [expr 10*1024*1024]	;# We convert filesize from MB to bytes
$ns at 0.0 "$ftp send $filesize"	;# "send" works with *bytes*. For working with *number of packets*, use "produce" instead of "send"

# User defined procedure to terminate the simulation
proc finish {} {      			;# "finish" is a user defined name of the procedure.
global ns namfile tracefile  		;# these parameters are made global so that they can be used inside "finish" procedure
$ns flush-trace				;# "flush-trace" is a built-in procedure to de-allocate the memory.
close $namfile				;# Closes ex_02.nam
close $tracefile			;# Closes ex_02.tr
set awkCode {
	     BEGIN{}				;# This is to verify whether client has downloaded the whole file or not!
	{
		if ($1 == "r" && $4 == 1 && $6 > 1500) {	;# Checking whether "n1" has "received" a file of "size > 1500"			
			count = count + $6 - ($6 % 1500);	;# Removing the headers from calculation
			print $2, count >> "ex_02.data";	;# Storing the results in a file called "ex_02.data"
		}
	}
 END{}
}
exec awk $awkCode ex_02.tr					;# Execute the awkCode on "ex_02.tr" file to extract the desired values
exec nam ex_02.nam &						;# Creates a new process in background to execute "nam ex_02.nam"
exec xgraph ex_02.data -bg white &
#exec xgraph -bb -tk -x Time -y Bytes ex_02.data -bg white &	;# Creates a new process in background to plot a graph
exit 0
}

$ns at 100.0 "finish"			;# Set this value based on bandwidth and frequent observations.
$ns run					;# "run" is an instance procedure to execute the events.
