# Root-level Makefile — delegates all targets to tools/Makefile.
# Run any target from the repo root without specifying -f tools/Makefile.
#
# Usage:
#   make                      — compile game
#   make run                  — compile + launch in emulator
#   make tests                — compile all test TAPs
#   make run-test-bird-udg    — run LoadBirdUDG() unit test
#   make run-test-title-render — run ShowTitle() attribute test
#   make dist                 — copy TAP to dist/
#   make clean                — remove build artefacts

.PHONY: all run tests dist clean run-test-bird-udg run-test-title-render

all run tests dist clean run-test-bird-udg run-test-title-render:
	@$(MAKE) -f tools/Makefile $@
