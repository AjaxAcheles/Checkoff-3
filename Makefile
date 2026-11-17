CC = gcc
TIME ?= /usr/bin/time

EXPERIMENTS := 01_loop_collapse 02_loop_unroll 03_inline_and_fusion
LEVELS := 0 1 2 3
BINARIES := $(foreach experiment,$(EXPERIMENTS),$(foreach level,$(LEVELS),build/$(experiment)_O$(level)))
ASSEMBLY := $(foreach experiment,$(EXPERIMENTS),asm/$(experiment)_O0.s asm/$(experiment)_O3.s)
BASE_CFLAGS := -std=c11 -Wall -Wextra -Wpedantic

.PHONY: all bench asm clean

all: $(BINARIES)

build:
	@mkdir -p $@

# Use the same source and compiler flags at each optimization level.
define optimization_rules
build/%_O$(1): src/%.c | build
	$$(CC) $$(CPPFLAGS) $$(BASE_CFLAGS) $$(CFLAGS) -O$(1) $$< $$(LDFLAGS) $$(LDLIBS) -o $$@

asm/%_O$(1).s: src/%.c
	@mkdir -p $$(@D)
	$$(CC) $$(CPPFLAGS) $$(BASE_CFLAGS) $$(CFLAGS) -O$(1) -S -fverbose-asm $$< -o $$@
endef

$(foreach level,$(LEVELS),$(eval $(call optimization_rules,$(level))))

bench: all
	@set -eu; \
	export LC_ALL=C; \
	timing=$$(mktemp); \
	trap 'rm -f "$$timing"' 0; \
	printf '%-23s %5s %4s %9s %9s %9s\n' 'Experiment' 'Opt' 'Run' 'real (s)' 'user (s)' 'sys (s)'; \
	for binary in $(BINARIES); do \
	    name=$${binary##*/}; \
	    for run in 1 2 3; do \
	        $(TIME) -f '%e %U %S' -o "$$timing" "./$$binary" > /dev/null; \
	        read -r real user sys < "$$timing"; \
	        printf '%-23s %5s %4s %9s %9s %9s\n' "$${name%_O?}" "-$${name##*_}" "$$run" "$$real" "$$user" "$$sys"; \
	    done; \
	done; \
	for level in $(LEVELS); do \
	    for run in 1 2 3; do \
	        $(TIME) -f '%e %U %S' -o "$$timing" "./build/03_inline_and_fusion_O$$level" fused > /dev/null; \
	        read -r real user sys < "$$timing"; \
	        printf '%-23s %5s %4s %9s %9s %9s\n' '03_inline_and_fusion' 'fused' "$$run" "$$real" "$$user" "$$sys"; \
	    done; \
	done

asm: $(ASSEMBLY)

clean:
	rm -rf build asm
