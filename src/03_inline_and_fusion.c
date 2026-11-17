#include <stdio.h>
#include <string.h>

enum { ELEMENTS = 16000000 };

static int values[ELEMENTS];

static int add(int a, int b) {
    return a + b;
}

static int sum_separately(void) {
    for (int i = 0; i < ELEMENTS; ++i) {
        values[i] *= 2;
    }

    int total = 0;
    for (int i = 0; i < ELEMENTS; ++i) {
        total = add(total, values[i]);
    }
    return total;
}

static int sum_fused(void) {
    int total = 0;
    for (int i = 0; i < ELEMENTS; ++i) {
        values[i] *= 2;
        total = add(total, values[i]);
    }
    return total;
}

int main(int argc, char *argv[]) {
    int use_fused = argc == 2 && strcmp(argv[1], "fused") == 0;
    if (argc > 1 && !use_fused) {
        fprintf(stderr, "Usage: %s [fused]\n", argv[0]);
        return 1;
    }

    for (int i = 0; i < ELEMENTS; ++i) {
        values[i] = 1 + i % 16;
    }

    int total = use_fused ? sum_fused() : sum_separately();
    printf("Sum after doubling: %d\n", total);
    return 0;
}
