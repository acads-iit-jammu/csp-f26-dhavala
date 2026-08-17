/* P2 (playground) — scanf and the & (address-of).
   RUN IT FIRST, type a number when it waits.
   THEN TINKER — predict before each run:
     1. Remove the & before rollNumber. Compile (a warning!) and run.
        What garbage happens? scanf needed the CELL, you gave the VALUE.
     2. Type letters instead of a number when it asks. What does it read?
     3. Change %d to %f but keep int. Why is the printed value nonsense?
        (Meaning lives in the reader — wrong reader, wrong meaning.)   */
#include <stdio.h>

int main(void) {
    int rollNumber;
    printf("Enter your roll number: ");
    scanf("%d", &rollNumber);
    printf("Your roll number is %d\n", rollNumber);
    return 0;
}
