# Root-level Makefile — delegates all targets to tools/Makefile.
# Run any target from the repo root without specifying -f tools/Makefile.
#
# Usage:
#   make                          — compile game
#   make run                      — compile + launch in emulator
#   make tests                    — compile all test TAPs
#   make run-test-suite           — run all tests from a single menu-driven TAP
#   make run-test-bird-udg        — run LoadBirdUDG() unit test standalone
#   make run-test-title-render    — run ShowTitle() attribute test standalone
#   make run-test-physics         — run physics unit test standalone
#   make dist                     — copy TAP to dist/
#   make clean                    — remove build artefacts

.PHONY: all run tests dist clean run-test-suite run-test-bird-udg run-test-title-render run-test-physics

all run tests dist clean run-test-suite run-test-bird-udg run-test-title-render run-test-physics:
	@$(MAKE) -f tools/Makefile $@
