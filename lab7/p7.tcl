# Program 7

#     Simulation parameters setup
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    CMUPriQueue    		   ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     6                          ;# number of mobilenodes
set val(rp)     DSR                        ;# routing protocol
set val(x)      700                        ;# X dimension of topography
set val(y)      700                        ;# Y dimension of topography
set val(stop)   60.0                       ;# time of simulation end

#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open p7.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open p7.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#     Mobile node parameter setup
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#Create 6 nodes with initial positions
set n0 [$ns node]
$n0 set X_ 150
$n0 set Y_ 300
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20

set n1 [$ns node]
$n1 set X_ 300
$n1 set Y_ 500
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20

set n2 [$ns node]
$n2 set X_ 500
$n2 set Y_ 500
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20

set n3 [$ns node]
$n3 set X_ 300
$n3 set Y_ 100
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20

set n4 [$ns node]
$n4 set X_ 500
$n4 set Y_ 100
$n4 set Z_ 0.0
$ns initial_node_pos $n4 20

set n5 [$ns node]
$n5 set X_ 650
$n5 set Y_ 300
$n5 set Z_ 0.0
$ns initial_node_pos $n5 20

#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink5 [new Agent/TCPSink]
$ns attach-agent $n5 $sink5
$ns connect $tcp0 $sink5
$tcp0 set packetSize_ 1500

#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at  3.0  "$ftp0 start"
$ns at 60.0 "$ftp0 stop"

#Allow node n3 to move towards node n1 with speed 5 m/sec
$ns at 4.0 "$n3 setdest 300.0 500.0 5.0"

#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam p7.nam &
    exec cat p7.tr | awk -f p7.awk &
    exit 0
}

for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run



