##################################################################
# Script designed by:					 	 #
# Mohit P. Tahiliani					 	 #
# Assistant Professor				 		 #
# Department of Computer Science and Engineering		 #
# NITK, Surathkal				 		 #
# Email: tahiliani.nitk@gmail.com				 #
# Blog: http://mohittahiliani.blogspot.com 			 #
# 								 #
# Also Refer: Wireless Information Networking Group (WiNG)	 #
# NITK, Surathkal				 		 #
# Email: wing@nitk.ac.in					 #
# Website: http://wing.nitk.ac.in 				 #
##################################################################

##################################################################
# Parameters given in the exercise question:			 #
# - Number of nodes					 	 #
# - Links between nodes to create topology	 		 #
# - Number of nodes acting as routers	 			 #
# - Link which is to be configured as a bottleneck link	 	 #
# - Source and destination nodes for TCP traffic		 #
# - Source and destination nodes for UDP traffic 		 #
# - Type of Application that uses TCP				 #
# - Type of Application that uses UDP				 #
# - Bandwidth between the links, including bottleneck link	 #
# - Propagation delay for links, including bottleneck link 	 #
# - Packet Discard Strategy on links				 #
# - Range of bottleneck bandwidth for repeating this experiment  #
# 								 #
# Parameters to be assumed by the user / student:		 #
# - Packet Discard Strategy on bottleneck link			 #
# - Start and Stop time of applications, packet size, etc	 #
# - Total simulation time					 #
##################################################################

# Create a new instance of a Simulator named "ns"
set ns [new Simulator]			;# "new" is used to allocate memory to "ns" instance.

# Open a new file to store Network Animator (NAM) data which is used for *Visualization*
set namfile [open ex_05_e.nam w]		;# "namfile" is a file pointer for "ex_05.nam"
$ns namtrace-all $namfile		;# "namtrace-all" is an instance procedure (i.e., built-in function) for NAM

# Open a new file to store trace data which is used for *Analysis*
set tracefile [open ex_05_e.tr w]  	;# "tracefile" is a file pointer for "ex_05.tr"
$ns trace-all $tracefile      		;# "trace-all" is an instance procedure (i.e., built-in function) for trace 

# Creating five instances of *node* inside the "ns" instance. Hence, the syntax is "$ns node" in brackets and not "new node"
set n0 [$ns node]		 
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

# Setting up links to design the given topology
$ns duplex-link $n0 $n2 1Mb 10ms DropTail 
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.75Mb 10ms DropTail	;# Bottleneck link has less bandwidth. [Assumption: DropTail is used] 
$ns duplex-link $n3 $n4 1Mb 10ms DropTail
$ns duplex-link $n3 $n5 1Mb 10ms DropTail
$ns duplex-link $n4 $n6 1Mb 10ms DropTail
$ns duplex-link $n5 $n7 1Mb 10ms DropTail

# Setting up TCP Source
set tcp [new Agent/TCP]			;# Create a new instance called "tcp" of Agent/TCP class
$ns attach-agent $n0 $tcp   		;# Configure n0 as the TCP Source

# Setting up TCP Destination (also known as TCP Sink)
set sink [new Agent/TCPSink] 		;# Create a new instance called "sink" of Agent/TCPSink class
$ns attach-agent $n6 $sink    		;# Configure n6 as the TCP Destination

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
$ns attach-agent $n7 $null		;# Configure n7 as the UDP Destination

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
close $namfile				;# Closes ex_05.nam
close $tracefile			;# Closes ex_05.tr
exec nam ex_05_e.nam &			;# Creates a new process in background to execute "nam ex_05.nam"
exit 0
}

$ns at 10.0 "finish"			;# Simulation stops at time 10
$ns run					;# "run" is an instance procedure to execute the events.
