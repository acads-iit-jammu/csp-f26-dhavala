/* E5 — A character's code, and its successor.                [graded]
   GIVEN   : one printable character (letter, digit or symbol)
   ENSURES : final output line ENDS WITH exactly:  code=<N> next=<C>
             N = its ASCII code, C = the NEXT character in the table
   EXAMPLE : input "A"  ->  final line  "code=65 next=B"
   HINT    : a char is a small integer; %d and %c are two readers
             of the same bits. Adding 1 moves one seat over.
   CHECK   : ./check.sh e5                                              */
#include <stdio.h>

int main(void) {
    /* your program here */
    return 0;
}
