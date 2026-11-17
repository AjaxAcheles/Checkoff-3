# Compiler Optimization Experiments

COMP 211 Systems Fundamentals, Checkoff 3

Three C programs for comparing loops, function calls, and unused work at different GCC optimization levels.

## Build and run

You'll need GCC, GNU Make, and GNU `time` (the Makefile uses `/usr/bin/time`). From this directory, run

```sh
make clean && make all && make asm && make bench
```

`make all` builds each program at `-O0` through `-O3` in `build/`. `make asm` writes `-O0` and `-O3` listings to `asm/`. `make bench` runs each binary three times and reports elapsed time (`real`), CPU time in the program (`user`), and CPU time in the kernel (`sys`). To see a program's output, run the binary directly, for example `./build/02_loop_unroll_O3`.

## What the assembly shows

These observations are from GCC 13.3.0 on x86-64. Open the two `.s` files for each program side by side. The listings include C source comments, and a jump back to an earlier label is a good place to look for a loop.

### 01. Loop collapse and dead code elimination

At `-O0`, two `jle` instructions jump back into the loops, one after checking against `499` and the other after checking against `149999999`.

At `-O3`, `movl $500, %edx` loads Part A's answer for the print call. There are no loops left in `main`. Part B only changed an unused local variable, so GCC dropped the whole loop.

### 02. Array sum, vectorization, and unrolling

The program sums one million integers over 128 passes. At `-O0`, each inner-loop iteration adds one element. The three elapsed times were 0.12, 0.17, and 0.13 seconds.

At `-O3`, GCC changes the loop order so it can load four integers together and reuse them across passes. In `.L4`, each `paddd` adds four integers in parallel (vectorization). Two `paddd` instructions run before `subl $2, %eax` and the jump back to `.L4` (partial unrolling of the pass loop). After the loops, the four partial sums are combined and passed to the print call. Both builds print `1088000000` as the sum.

### 03. Function inlining and loop fusion

At `-O0`, the sum loops contain `call add`. At `-O3`, the calls and the standalone `add` function are gone. Look for the `return a + b` source comment near the vector additions in the optimized listing.

The default version still has separate loops for doubling and summing. The manually fused version does both in one pass. Both print `272000000` as the sum. `make bench` times the default version. To compare both versions at the same optimization level, run

```sh
/usr/bin/time -p ./build/03_inline_and_fusion_O3
/usr/bin/time -p ./build/03_inline_and_fusion_O3 fused
```

## Recorded timings and takeaways

Median elapsed time (`real`) from three runs per build, in seconds. Times cover the full program, including array setup. `0.00` is the timer's displayed value for a run below its reporting precision.

| Experiment | `-O0` | `-O1` | `-O2` | `-O3` |
| --- | ---: | ---: | ---: | ---: |
| 01 Loop collapse | 0.08 | 0.05 | 0.00 | 0.00 |
| 02 Array sum | 0.07 | 0.03 | 0.02 | 0.01 |
| 03 Inlining and fusion (default) | 0.05 | 0.03 | 0.02 | 0.02 |
| 03 Inlining and fusion (fused) | 0.05 | 0.02 | 0.02 | 0.01 |

The fused version matches the default at `-O0` and `-O2` and edges ahead at `-O1` and `-O3` (0.01s versus 0.02s at `-O3`), since GCC inlines `add()` from `-O1` up and manual fusion mainly removes a pass.

-O3 deleted the loops in Experiment 01 (both `-O2` and `-O3` read `0.00s`). Experiment 02 lands at `0.02s` (`-O2`) and `0.01s` (`-O3`), and its `-O3` listing vectorizes with `paddd` and partially unrolls the pass loop. Experiment 03 inlines `add()` at `-O3`, and the fused version edges ahead at `0.01s` versus `0.02s` for default by doing the doubling and summing in one pass.

## Slides

`slides/` is reserved for the Checkoff 3 presentation.

## Resources

- [GCC optimization options](https://gcc.gnu.org/onlinedocs/gcc-13.3.0/gcc/Optimize-Options.html)
- [GCC output options, including `-S`](https://gcc.gnu.org/onlinedocs/gcc-13.3.0/gcc/Overall-Options.html)
