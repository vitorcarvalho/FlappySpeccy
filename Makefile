# Root-level Makefile — delegates all targets to tools/Makefile.
# Run any target from the repo root without specifying -f tools/Makefile.
#
# Usage:
#   make                          — compile game
#   make run                      — compile + launch in emulator
#   make tests                    — compile all test TAPs
#   make build-launcher           — compile launcher TAP (game + test suite menu)
#   make run-launcher             — compile + launch launcher in emulator
#   make run-test-suite           — run all tests from a single menu-driven TAP
#   make run-test-bird-udg        — run LoadBirdUDG() unit test standalone
#   make run-test-title-render    — run ShowTitle() attribute test standalone
#   make run-test-physics         — run physics unit test standalone
#   make run-test-pipes           — run pipe spawn/state unit test standalone
#   make dist                     — copy TAP to dist/
#   make clean                    — remove build artefacts

.PHONY: all run tests dist clean build-launcher run-launcher \
        run-test-suite run-test-bird-udg run-test-title-render run-test-physics run-test-pipes

all run tests dist clean build-launcher run-launcher \
run-test-suite run-test-bird-udg run-test-title-render run-test-physics run-test-pipes:
	@$(MAKE) -f tools/Makefile $@
