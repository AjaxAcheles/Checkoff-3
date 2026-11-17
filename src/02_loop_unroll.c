#include <stdio.h>

enum { ELEMENTS = 1000000, PASSES = 128 };

static int values[ELEMENTS];

int main(void) {
    for (int i = 0; i < ELEMENTS; ++i) {
        values[i] = 1 + i % 16;
    }

    int total = 0;
    for (int pass = 0; pass < PASSES; ++pass) {
        for (int i = 0; i < ELEMENTS; ++i) {
            total += values[i];
        }
    }

    printf("Array sum across %d passes: %d\n", PASSES, total);
    return 0;
}
