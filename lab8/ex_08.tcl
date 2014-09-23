set ns [new Simulator]			;# "new" is used to allocate memory to "ns" instance.
$ns rtproto DV                               ;# Enabling distance routing protocol.

# Open a new file to store Network Animator (NAM) data which is used for *Visualization*
set namfile [open ex_08.nam w]		;# "namfile" is a file pointer for "ex_01.nam"
$ns namtrace-all $namfile		;# "namtrace-all" is an instance procedure (i.e., built-in function) for NAM

# Open a new file to store trace data which is used for *Analysis*
set tracefile [open ex_08.tr w]  	;# "tracefile" is a file pointer for "ex_01.tr"
$ns trace-all $tracefile      		;# "trace-all" is an instance procedure (i.e., built-in function) for trace 

for {set i 0} {$i < 7} {incr i} {
set n($i) [$ns node]
}

for {set i 0} {$i < 7} {incr i} {
$ns duplex-link $n($i) $n([expr ($i+1)%7]) 1Mb 10ms DropTail
}
$ns rtmodel-at 1.0 down $n(1) $n(2)
$ns rtmodel-at 2.0 up $n(1) $n(2)

$ns rtmodel-at 3.0 down $n(3) $n(2)
$ns rtmodel-at 3.5 up $n(3) $n(2)



# Setting up UDP Source
set udp [new Agent/UDP]			;# Create a new instance called "udp" of Agent/UDP class
$ns attach-agent $n(0) $udp		;# Configure n1 as the UDP Source

# Setting up a dummy UDP Destination (There are no ACKs in UDP!)
set null [new Agent/Null]		;# Create a new instance called "null" of Agent/Null class
$ns attach-agent $n(3) $null		;# Configure n2 as the UDP Destination

# Setup connection between UDP Source and Destination
$ns connect $udp $null

# Enable CBR application on UDP Source and set its parameters
set cbr [new Application/Traffic/CBR]	;# Create a new instance called "cbr" of Application/Traffic/CBR class
$cbr set packetSize_ 500		;# packet size is set to 500 bytes
$cbr set interval_ 0.005		;# packet will be sent at an interval of 0.005 seconds
$cbr attach-agent $udp			;# Configure the application to use UDP

# Schedule traffic in the network by starting and stopping the created applications
# Note that you can schedule them in any order. A sample order of starting and stopping is given below:
$ns at 0.5 "$cbr start"			;# CBR application started
$ns at 4.5 "$cbr stop"			;# CBR application stopped

# User defined procedure to terminate the simulation
proc finish {} {      			;# "finish" is a user defined name of the procedure.
global ns namfile tracefile  		;# these parameters are made global so that they can be used inside "finish" procedure
$ns flush-trace				;# "flush-trace" is a built-in procedure to de-allocate the memory.
close $namfile				;# Closes ex_01.nam
close $tracefile			;# Closes ex_01.tr
exec nam ex_08.nam &			;# Creates a new process in background to execute "nam ex_01.nam"
exit 0
}

$ns at 10.0 "finish"			;# Simulation stops at time 10
$ns run					;# "run" is an instance procedure to execute the events.
