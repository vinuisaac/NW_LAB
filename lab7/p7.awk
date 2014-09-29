BEGIN {
        count1=0;
	count2=0;
        count3=0;
	count4=0;
        count5=0;
	}
{
        if( $1=="r"  && $3=="_1_" && $4=="RTR")
			count1++;
        if( $1=="r" && $4=="RTR" && $3=="_2_")
			count2++;
        if( $1=="r" && $4=="RTR" && $3=="_3_")
			count3++;
	if( $1=="r" && $4=="RTR" && $3=="_4_")
			count4++;
	if( $1=="r" && $4=="RTR" && $3=="_5_")
			count5++;
	if( $1 == "SFESTs")
             printf("\n%lf\t%d\t%s\t%d\t%s\t%s\t%d\t%s\t%s",$2,$5,$6,$7,$11,$12,$13,$14,$15);
}
END {   
        printf("\n packet received by node 1 %d",count1);
	printf("\n packet received by node 2 %d",count2);
	printf("\n packet received by node 3 %d",count3);
	printf("\n packet received by node 4 %d",count4);
	printf("\n packet received by node 5 %d\n",count5);
} 
