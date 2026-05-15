# Flappy Speccy — Build Makefile
#
# Requires:
#   zxbc     — Boriel ZX BASIC compiler  (pip install zxbasic)
#   zesarux  — ZX Spectrum emulator      (~/Applications/ZEsarUX.app)
#
# Usage:
#   make                    — compile game
#   make run                — compile + launch game in emulator
#   make tests              — compile all test TAPs
#   make run-test-<name>    — run a specific test in the emulator
#                             e.g. make run-test-bird-udg
#   make clean              — remove build artefacts

# ── Tool configuration ────────────────────────────────────────────────────────
ZXBC     := /opt/homebrew/bin/zxbc
EMULATOR := $(HOME)/Applications/ZEsarUX.app/Contents/MacOS/zesarux
EMU_ARGS := --noconfigfile --machine 48k

# ── Paths ─────────────────────────────────────────────────────────────────────
SRC    := src/game/main.bas
TAP    := build/flappy_speccy.tap
DIST   := dist/flappy_speccy.tap

# ── Compiler flags ─────────────────────────────────────────────────────────────
# -f tap       : produce a .TAP tape image
#                (--tap is deprecated since zxbasic 1.16; -f tap is the current form)
# -B           : prepend a BASIC loader block so LOAD "" auto-starts the code
# -a           : set autorun flag on the BASIC loader (runs immediately after load)
# --optimize 2 : enable optimisation (safe; does not change semantics)
# --arch zx48k : target ZX Spectrum 48K (default, but stated explicitly)
#                Available: zx48k, zxnext
ZXFLAGS      := -f tap -B -a --optimize 2 --arch zx48k

# Test TAPs use the same flags minus -B/-a (tests handle their own screen init)
ZXFLAGS_TEST := -f tap -B -a --optimize 2 --arch zx48k

# ── Test sources ──────────────────────────────────────────────────────────────
TEST_SRCS := $(wildcard tests/test_*.bas)
TEST_TAPS := $(patsubst tests/%.bas,build/%.tap,$(TEST_SRCS))

# ── Targets ───────────────────────────────────────────────────────────────────
.PHONY: all run dist tests clean \
        run-test-suite \
        run-test-bird-udg run-test-title-render run-test-physics run-test-pipes

all: $(TAP)

$(TAP): $(SRC)
	@mkdir -p build
	$(ZXBC) $(SRC) $(ZXFLAGS) -o $(TAP)

run: $(TAP)
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $(TAP))

# ── Test compilation ──────────────────────────────────────────────────────────
tests: $(TEST_TAPS)

build/test_%.tap: tests/test_%.bas
	@mkdir -p build
	$(ZXBC) $< $(ZXFLAGS_TEST) -o $@

# ── Test runners ──────────────────────────────────────────────────────────────
run-test-bird-udg: build/test_bird_udg.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)

run-test-title-render: build/test_title_render.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)

run-test-physics: build/test_physics.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)

run-test-pipes: build/test_pipes.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)

run-test-suite: build/test_suite.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)


# ── Distribution ──────────────────────────────────────────────────────────────
dist: $(TAP)
	@mkdir -p dist
	cp $(TAP) $(DIST)

# ── Cleanup ───────────────────────────────────────────────────────────────────
clean:
	rm -f build/*.tap build/*.z80 build/*.asm
