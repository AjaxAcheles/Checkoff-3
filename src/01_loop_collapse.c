#include <stdint.h>
#include <stdio.h>

int main(void) {
    int total = 0;
    for (int i = 0; i < 500; ++i) {
        total += 1;
    }
    printf("Part A total: %d\n", total);
    uint64_t unused_total = 0;
    for (int i = 0; i < 150000000; ++i) {
        unused_total += (uint64_t)i;
    }
    // And then we do nothing with the unused variable
}
