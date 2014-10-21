BEGIN {
	count=0;
	time=0;
        total_bytes_sent =0;
        total_bytes_received=0;
        
}
{
	if ( $1 == "r" &&  $4 == 1 && $5 == "tcp")
				total_bytes_received += $6;

        if($1 == "+" &&  $3 == 0 && $5 == "tcp")
				total_bytes_sent +=  $6;
} 
END {
       system("clear");
       printf("\n Transmission time required to transfer the file is %lf",$2);
       printf("\n Actual data sent from the server is %lf Mbps",(total_bytes_sent)/1000000);
       printf("\n Data Received by the client is %lf Mbps\n",(total_bytes_received)/1000000);            	 
} 
