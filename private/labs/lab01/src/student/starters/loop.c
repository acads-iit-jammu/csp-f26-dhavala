/* The runaway program for Act 4.  It never stops on its own.
   Your job is NOT to fix it — it is to learn the fire extinguisher. */
#include <stdio.h>
#include <unistd.h>

int main(void) {
    printf("runaway started - I will now run FOREVER, silently.\n");
    printf("find me:   pgrep loop        stop me:   kill <that number>\n");
    while (1) {
        sleep(1);
    }
    return 0;
}
