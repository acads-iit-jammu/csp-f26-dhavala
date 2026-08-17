/* E1 — Sum and average of three integers.                    [graded]
   GIVEN   : three integers on one line, each 1..100 (read with ONE scanf)
   ENSURES : final output line ENDS WITH exactly:  sum=<S> avg=<A>
             where <A> has exactly 2 decimal places (%.2f)
   EXAMPLE : input "12 7 9"  ->  final line  "sum=28 avg=9.33"
   CHECK   : ./check.sh e1
   Prompts and any lines ABOVE the final line are yours to design.     */
#include <stdio.h>

int main(void)
{
int a,b,c;printf("Enter three integers: ");
scanf("%d %d %d",&a,&b,&c);
printf("sum=%d avg=%.2f\n",a+b+c,(a+b+c)/3.0);
return 0;
}
    