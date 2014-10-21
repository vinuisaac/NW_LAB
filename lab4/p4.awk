BEGIN {
	count=0;
	time=0;
        dcount=0;
}
{
	if( $1=="r" && ( $4==2 || $4==3))
	{
			count += $6;
			time=$2;
        }
        if( $1=="d" && ($4==2 || $4==3) )
        {
		         dcount ++;
        }
}
END {
        system("clear");      
	printf("\n Total bytes transferred from n2 to n3 is: %d",count);
	printf("\n Total simulation time: %lf",$2); 
	printf("\n Throughput : %lf  \n\n", (count/$2) * (8/1000000) );
	printf("\n Total packets dropped is: %d", dcount);
    } 
