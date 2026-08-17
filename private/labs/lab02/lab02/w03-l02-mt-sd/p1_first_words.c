/* P1 (playground) — printf and the backslash characters.
   RUN IT FIRST:   gcc p1_first_words.c -o p1 && ./p1
   THEN TINKER — one change at a time, predict before each run:
     1. Change the \n after "columns:" to \t.  What happens, and why?
     2. Delete the \n on the last line. Where does your prompt land?
     3. Make it beep: add \a inside any string.
     4. Print an actual backslash and a double quote.                  */
#include <stdio.h>

int main(void) {
    printf("first words\n");
    printf("columns:\n");
    printf("%d\t%d\t%d\n", 1, 22, 333);
    printf("done\n");
    return 0;
}
