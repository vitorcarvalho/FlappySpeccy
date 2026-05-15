# Root-level Makefile — delegates all targets to tools/Makefile.
# Run any target from the repo root without specifying -f tools/Makefile.
#
# Usage:
#   make                          — compile 48K game
#   make run                      — compile + launch 48K game in emulator
#   make build-128k               — compile 128K game (AY sound, -D AY_SOUND)
#   make run-128k                 — compile + launch 128K game (--machine 128k)
#   make build-launcher-128k      — compile launcher with AY sound
#   make run-launcher-128k        — launch launcher on 128K emulator
#   make tests                    — compile all test TAPs
#   make build-launcher           — compile launcher TAP (game + test suite menu)
#   make run-launcher             — compile + launch launcher in emulator
#   make run-test-suite           — run all tests from a single menu-driven TAP
#   make run-test-bird-udg        — run LoadBirdUDG() unit test standalone
#   make run-test-title-render    — run ShowTitle() attribute test standalone
#   make run-test-physics         — run physics unit test standalone
#   make run-test-pipes           — run pipe spawn/state unit test standalone
#   make run-test-collision       — run collision detection unit test standalone
#   make run-test-gameover        — run medal rank unit test standalone
#   make run-test-sound           — run sound smoke test standalone (48K BEEP)
#   make run-test-sound-128k      — run AY sound smoke test (--machine 128k)
#   make run-test-difficulty-curve — run difficulty curve (speed/border) unit tests standalone
#   make dist                     — copy both 48K and 128K TAPs to dist/
#   make clean                    — remove build artefacts

.PHONY: all run tests dist clean build-launcher run-launcher \
        build-128k run-128k build-launcher-128k run-launcher-128k \
        run-test-suite run-test-bird-udg run-test-title-render run-test-physics run-test-pipes \
        run-test-collision run-test-gameover run-test-sound run-test-difficulty-curve \
        run-test-sound-128k

all run tests dist clean build-launcher run-launcher \
build-128k run-128k build-launcher-128k run-launcher-128k \
run-test-suite run-test-bird-udg run-test-title-render run-test-physics run-test-pipes \
run-test-collision run-test-gameover run-test-sound run-test-difficulty-curve \
run-test-sound-128k:
	@$(MAKE) -f tools/Makefile $@
