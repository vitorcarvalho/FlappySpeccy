# Flappy Speccy — Build Makefile
#
# Requires:
#   zxbc     — Boriel ZX BASIC compiler  (pip install zxbasic)
#   zesarux  — ZX Spectrum emulator      (~/Applications/ZEsarUX.app)
#
# Usage:
#   make                    — compile 48K game
#   make run                — compile + launch 48K game in emulator
#   make build-128k         — compile 128K game (AY sound, -D AY_SOUND)
#   make run-128k           — compile + launch 128K game (--machine 128k)
#   make tests              — compile all test TAPs
#   make run-test-<name>    — run a specific test in the emulator
#                             e.g. make run-test-bird-udg
#   make run-test-sound-128k — run AY sound smoke test (--machine 128k)
#   make dist               — copy both 48K and 128K TAPs to dist/
#   make clean              — remove build artefacts

# ── Tool configuration ────────────────────────────────────────────────────────
ZXBC     := /opt/homebrew/bin/zxbc
EMULATOR := $(HOME)/Applications/ZEsarUX.app/Contents/MacOS/zesarux
EMU_ARGS := --noconfigfile --machine 48k

# ── Paths ─────────────────────────────────────────────────────────────────────
SRC              := src/game/main.bas
TAP              := build/flappy_speccy.tap
TAP_128          := build/flappy_speccy_128.tap
DIST_48          := dist/flappy_speccy.tap
DIST_128         := dist/flappy_speccy_128.tap
LAUNCHER_SRC     := src/game/launcher.bas
LAUNCHER_TAP     := build/launcher.tap
LAUNCHER_128_TAP := build/launcher_128.tap

# All ZX BASIC source files — used as a blanket dependency so any .bas change
# triggers a rebuild of every TAP that transitively includes it.
# Without this, Make only sees the direct source file and misses include changes.
ALL_BAS := $(shell find src tests assets -name '*.bas' 2>/dev/null)

# ── Compiler flags ─────────────────────────────────────────────────────────────
# -f tap       : produce a .TAP tape image
#                (--tap is deprecated since zxbasic 1.16; -f tap is the current form)
# -B           : prepend a BASIC loader block so LOAD "" auto-starts the code
# -a           : set autorun flag on the BASIC loader (runs immediately after load)
# --optimize 2 : enable optimisation (safe; does not change semantics)
# --arch zx48k : target ZX Spectrum 48K (default, but stated explicitly)
#                Available: zx48k, zxnext
# -D AY_SOUND  : enables AY-3-8912 sound path in sounds.bas (128K build only)
#                The arch remains zx48k — 128K is backward-compatible with 48K code.
ZXFLAGS      := -f tap -B -a --optimize 2 --arch zx48k
ZXFLAGS_128  := -f tap -B -a --optimize 2 --arch zx48k -D AY_SOUND

# Test TAPs: same 48K flags.  AY test uses ZXFLAGS_128 (see run-test-sound-128k).
ZXFLAGS_TEST     := -f tap -B -a --optimize 2 --arch zx48k
ZXFLAGS_TEST_128 := -f tap -B -a --optimize 2 --arch zx48k -D AY_SOUND

# ── Test sources ──────────────────────────────────────────────────────────────
TEST_SRCS := $(wildcard tests/test_*.bas)
TEST_TAPS := $(patsubst tests/%.bas,build/%.tap,$(TEST_SRCS))

# ── Targets ───────────────────────────────────────────────────────────────────
.PHONY: all run dist tests clean \
        build-launcher run-launcher \
        build-128k run-128k build-launcher-128k run-launcher-128k \
        run-test-suite \
        run-test-bird-udg run-test-title-render run-test-physics run-test-pipes \
        run-test-collision run-test-gameover run-test-sound run-test-difficulty-curve \
        run-test-sound-128k

all: $(TAP)

$(TAP): $(ALL_BAS)
	@mkdir -p build
	$(ZXBC) $(SRC) $(ZXFLAGS) -o $(TAP)

run: $(TAP)
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $(TAP))

# ── 128K build (AY-3-8912 sound, -D AY_SOUND) ─────────────────────────────────
build-128k: $(TAP_128)

$(TAP_128): $(ALL_BAS)
	@mkdir -p build
	$(ZXBC) $(SRC) $(ZXFLAGS_128) -o $(TAP_128)

run-128k: $(TAP_128)
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args --noconfigfile --machine 128k $(abspath $(TAP_128))

build-launcher-128k: $(LAUNCHER_128_TAP)

$(LAUNCHER_128_TAP): $(ALL_BAS)
	@mkdir -p build
	$(ZXBC) $(LAUNCHER_SRC) $(ZXFLAGS_128) -o $(LAUNCHER_128_TAP)

run-launcher-128k: $(LAUNCHER_128_TAP)
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args --noconfigfile --machine 128k $(abspath $(LAUNCHER_128_TAP))

# ── Launcher ──────────────────────────────────────────────────────────────────
build-launcher: $(LAUNCHER_TAP)

$(LAUNCHER_TAP): $(ALL_BAS)
	@mkdir -p build
	$(ZXBC) $(LAUNCHER_SRC) $(ZXFLAGS) -o $(LAUNCHER_TAP)

run-launcher: $(LAUNCHER_TAP)
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $(LAUNCHER_TAP))

# ── Test compilation ──────────────────────────────────────────────────────────
tests: $(TEST_TAPS)

build/test_%.tap: tests/test_%.bas $(ALL_BAS)
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

run-test-collision: build/test_collision.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)

run-test-gameover: build/test_gameover.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)

run-test-sound: build/test_sound.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)

run-test-difficulty-curve: build/test_difficulty_curve.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)

run-test-suite: build/test_suite.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args $(EMU_ARGS) $(abspath $<)

# ── 128K AY sound smoke test ──────────────────────────────────────────────────
# Compiled with -D AY_SOUND; run on --machine 128k to hear the AY effects.
# On 48K the OUT writes are harmless no-ops; logic assertions still pass.
build/test_sound_128.tap: tests/test_sound_128.bas $(ALL_BAS)
	@mkdir -p build
	$(ZXBC) $< $(ZXFLAGS_TEST_128) -o $@

run-test-sound-128k: build/test_sound_128.tap
	-pkill -x zesarux 2>/dev/null; sleep 0.5
	open $(HOME)/Applications/ZEsarUX.app --args --noconfigfile --machine 128k $(abspath $<)

# ── Distribution ──────────────────────────────────────────────────────────────
# Copies both 48K and 128K TAPs to dist/.
#   dist/flappy_speccy.tap     — ZX Spectrum 48K (BEEP sound)
#   dist/flappy_speccy_128.tap — ZX Spectrum 128K (AY-3-8912 sound)
dist: $(TAP) $(TAP_128)
	@mkdir -p dist
	cp $(TAP)     $(DIST_48)
	cp $(TAP_128) $(DIST_128)

# ── Cleanup ───────────────────────────────────────────────────────────────────
clean:
	rm -f build/*.tap build/*.z80 build/*.asm
