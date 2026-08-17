/* P3 (playground) — the space before %c, and integer division.
   RUN IT FIRST: enter a number, then a grade letter.
   THEN TINKER — predict before each run:
     1. Delete the space before %c in the scanf. Run again. Why does it
        no longer wait for your letter? (Hint: where did the Enter key go?)
     2. Change  7 / 2  to  7.0 / 2  — and then to  7 / 2.0.
     3. Print marks with %c instead of %d. Which character appears — and
        find it on the ASCII table. Same bits, different reader.        */
#include <stdio.h>

int main(void) {
    int marks;
    char grade;
    printf("Enter marks (integer): ");
    scanf("%d", &marks);
    printf("Enter grade letter: ");
    scanf(" %c", &grade);          /* note the space before %c */
    printf("marks=%d grade=%c half=%d\n", marks, grade, 7 / 2);
    return 0;
}
