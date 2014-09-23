BEGIN {
  tdelay=0
  count=0
  pktid=-1
}

{
   if($1 == "+" && $3 == 0 && $12 > pktid) {
       pktid=$12
      sTime[pkitd] = $2
    }
   if($1 == "r" && $4 == 6) {
      eTime[$12] = $2
       count++
    }
    if($1 == "d")
        eTime[$12] = -1
}

END {
       for(i=0;i<=pktid;i++) {
          delay = eTime[i] - sTime[i]
          if(delay > 0)
             tdelay += delay
  }
 printf("Average Delay = %.4f ms \n", (tdelay/count) * 1000)       
}
