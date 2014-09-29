BEGIN {
               
	udp_sink=0;
       
}
{
	if($1=="r" && $4 == 7 ){
		
		udp_sink += $6;
			printf("\n %lf" ,udp_sink/1000000);
		
	}

	
}
END {
	
} 
