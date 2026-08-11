/* The runaway program for Act 4.  It never stops on its own.
   Your job is NOT to fix it — it is to learn the fire extinguisher. */
#include <stdio.h>
#include <unistd.h>

int main(void) {
    long n = 0;
    while (1) {
        printf("still running... %ld\n", n);
        n = n + 1;
        sleep(1);
    }
    return 0;
}
