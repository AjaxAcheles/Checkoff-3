#include <stdint.h>
#include <stdio.h>

int main(void)
{
    /* Part A: Print the result. */
    int total = 0;
    for (int i = 0; i < 500; ++i) {
        total += 1;
    }
    printf("Part A total: %d\n", total);

    /* Part B: Discard the result. */
    uint64_t unused_total = 0;
    for (int i = 0; i < 150000000; ++i) {
        unused_total += (uint64_t)i;
    }
    (void)unused_total; /* Suppress the unused-variable warning. */

    return 0;
}
