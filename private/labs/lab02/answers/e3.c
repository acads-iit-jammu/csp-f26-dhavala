#include <stdio.h>
int main(void){int a,b;scanf("%d %d",&a,&b);
/* q uses integer division (fraction discarded); qf promotes to double first */
printf("q=%d r=%d qf=%.2f\n",a/b,a%b,(double)a/b);return 0;}
