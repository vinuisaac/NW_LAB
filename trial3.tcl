# Create a new instance of a Simulator named "ns"
set ns [new Simulator]			;# "new" is used to allocate memory to "ns" instance.

# Open a new file to store Network Animator (NAM) data which is used for *Visualization*
set namfile [open trial3.nam w]		;# "namfile" is a file pointer for "ex_01.nam"
$ns namtrace-all $namfile		;# "namtrace-all" is an instance procedure (i.e., built-in function) for NAM

# Open a new file to store trace data which is used for *Analysis*
set tracefile [open trial3.tr w]  	;# "tracefile" is a file pointer for ".tr"
$ns trace-all $tracefile      		;# "trace-all" is an instance procedure (i.e., built-in function) for trace 

# Creating five instances of *node* inside the "ns" instance. Hence, the syntax is "$ns node" in brackets and not "new node"
set n0 [$ns node]		 
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

# Setting up links to design the given LAN topology  
#$ns make-lan "$n0 $n1 $n2 $n3 $n4 $n5 $n6" 100Mb 1ms LL Queue/DropTail Mac/802_3 Channel Phy/WiredPhy
set lan [$ns newLan "$n0 $n1 $n2 $n3 $n4 $n5 $n6" 100Mb 1ms LL Queue/DropTail Mac/802_3 Channel] 

# Setting up UDP Source
set udp [new Agent/UDP]			;# Create a new instance called "udp" of Agent/UDP class
$ns attach-agent $n0 $udp		;# Configure n1 as the UDP Source

# Setting up a dummy UDP Destination (There are no ACKs in UDP!)
set null [new Agent/Null]		;# Create a new instance called "null" of Agent/Null class
$ns attach-agent $n6 $null		;# Configure n6 as the UDP Destination

# Setup connection between UDP Source and Destination
$ns connect $udp $null

# Enable CBR application on UDP Source and set its parameters
set cbr [new Application/Traffic/CBR]	;# Create a new instance called "cbr" of Application/Traffic/CBR class
$cbr set packetSize_ 1000		;# packet size is set to 1500 bytes
$cbr set interval_ 0.005		;# packet will be sent at an interval of 0.005 seconds
$cbr attach-agent $udp			;# Configure the application to use UDP

# Schedule traffic in the network by starting and stopping the created applications
# Note that you can schedule them in any order. A sample order of starting and stopping is given below:
$ns at 1.0 "$cbr start"			;# CBR application started
$ns at 24.0 "$cbr stop"			;# CBR application stopped


# User defined procedure to terminate the simulation
proc finish {} {      			;# "finish" is a user defined name of the procedure.
global ns namfile tracefile  		;# these parameters are made global so that they can be used inside "finish" procedure
$ns flush-trace				;# "flush-trace" is a built-in procedure to de-allocate the memory.
close $namfile				;# Closes ex_01.nam
close $tracefile			;# Closes ex_01.tr
exec nam trial3.nam &			;# Creates a new process in background to execute "nam ex_01.nam"
exit 0
}

$ns at 25.0 "finish"			;# Simulation stops at time 10
$ns run					;# "run" is an instance procedure to execute the events.
