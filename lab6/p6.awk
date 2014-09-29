BEGIN {
            udp_sink=0;
	    tcp_sink=0;
            src = $9;
            dst = $10;	
            type=$5;
            pktsize=$6;
	
}
{
	if($1 == "r" && dst == 6)
              tcp_sink += $6;

        if($1 == "r" &&  dst == 7)
			udp_sink += $pktsize;
}
END {
         
		printf("\n total udp bytes received %d",udp_sink);
		printf("\n total tcp bytes received %d",tcp_sink);
} 
