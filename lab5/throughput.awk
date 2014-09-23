BEGIN {
recvbytes = 0
startT = $2
 }
{
if ($1=="r" && $4 == 3 && $6 > 100)   {
    recvbytes += $6
    endT = $2
  }
}
END { 
printf ("Throughput = %f Mbits/sec\n", (recvbytes / (endT - startT)) * (8 / (1024 * 1024)))
}
