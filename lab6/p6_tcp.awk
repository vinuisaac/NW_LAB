BEGIN {
         
	tcp_sink=0;
    
	
}
{
	if($1=="r" && $4 == 6){
		tcp_sink += $6;
		printf("\n %lf", tcp_sink/1000000);
	
	}
}
END {
} 
