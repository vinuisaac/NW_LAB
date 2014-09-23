##################################################################
# Mohit P. Tahiliani				 		 #
# Ph.D Candidate				 		 #
# Department of Computer Engineering			 	 #
# N.I.T.K., Surathkal				 		 #
# tahiliani.nitk@gmail.com					 #
# www.mohittahiliani.blogspot.com				 #
##################################################################

##################################################################
#	    Setting the Default Parameters			 #
##################################################################

set val(chan)		Channel/WirelessChannel
set val(prop)		Propagation/TwoRayGround
set val(netif)		Phy/WirelessPhy
set val(mac)          Mac/802_11
set val(ifq)		CMUPriQueue
set val(ll)		LL
set val(ant)           Antenna/OmniAntenna
set val(x)		700	
set val(y)		700	
set val(ifqlen)	50		
set val(nn)		6		
set val(stop)		60.0		
set val(rp)            DSR       

##################################################################
#	    Creating New Instance of a Scheduler		 #
##################################################################

set ns_		[new Simulator]

##################################################################
#		Creating Trace files				 #
##################################################################

set tracefd	[open ex_07.tr w]
$ns_ trace-all $tracefd

##################################################################
#	        Creating NAM Trace files			 #
##################################################################

set namtrace [open ex_07.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set prop	[new $val(prop)]

set topo	[new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

##################################################################
#		Node Configuration				 #
##################################################################

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON

##################################################################
#		Creating Nodes					 #
##################################################################

for {set i 0} {$i < $val(nn)} {incr i} {
     set node_($i) [$ns_ node]	
     $node_($i) random-motion 0	
}

$node_(0) set X_ 150.0
$node_(0) set Y_ 300.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 300.0
$node_(1) set Y_ 500.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 500.0
$node_(2) set Y_ 500.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 300.0
$node_(3) set Y_ 100.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 500.0
$node_(4) set Y_ 100.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 650.0
$node_(5) set Y_ 300.0
$node_(5) set Z_ 0.0


##################################################################
#		Initial Positions of Nodes			 #
##################################################################
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 60  ;# initial node position and size of the node
}

##################################################################
#		Topology Design				 	 #
##################################################################

$ns_ at 4.0 "$node_(3) setdest 300.0 500.0 5.0"

##################################################################
#		Generating Traffic				 #
##################################################################

set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp0
$ns_ attach-agent $node_(5) $sink0
$ns_ connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns_ at 3.0 "$ftp0 start" 
$ns_ at 59.0 "$ftp0 stop"


##################################################################
#		Simulation Termination				 #
##################################################################

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}
$ns_ at $val(stop) "puts \"NS EXITING...\" ; $ns_ halt"

puts "Starting Simulation..."
$ns_ run
exit(0)
