' =============================================================================
' tests/test_pipes.bas
' Unit test — InitPipes() and SpawnPipe() in src/game/pipes.bas
'
' Fully automated — no user interaction required.
' Green = PASS, red = FAIL.  Press any key to exit.
'
' Test cases:
'   1. InitPipes()      — pipeActive(1) = 1  (first pipe active)
'   2. InitPipes()      — pipeCol(1) = 30    (left edge; pipe is 2 cols wide)
'   3. InitPipes()      — pipeGap(1) >= 2    (lower bound of 6-row gap start)
'   4. InitPipes()      — pipeGap(1) <= 15   (upper bound of 6-row gap start)
'   5. InitPipes()      — pipeActive(2) = 0  (remaining slots inactive)
'   6. SpawnPipe(2)     — pipeActive(2) = 1  (slot becomes active)
'   7. SpawnPipe(2)     — pipeCol(2) = 30    (left edge of 2-wide pipe)
'   8. SpawnPipe(2)     — pipeGap(2) >= 2    (random gap lower bound)
'   9. SpawnPipe(2)     — pipeGap(2) <= 15   (random gap upper bound)
'
' Note: UpdatePipes() is not tested here because it calls ErasePipe/DrawPipe
' which print to screen and would corrupt the assertion output. The scroll
' and deactivation logic is exercised visually during 'make run'.
'
' Compile:  make tests
' Run:      make run-test-pipes
' =============================================================================

#include "assert_helpers.bas"
#include "../src/game/pipes.bas"

SUB RunTestPipes()
  ' ── Screen setup ────────────────────────────────────────────────────────────
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; "TEST: Pipes"
  PRINT INK 5;           "───────────"
  PRINT

  passed = 0
  failed = 0

  ' ── Test group 1: InitPipes ───────────────────────────────────────────────
  InitPipes()
  AssertEq("init: pipeActive(1) = 1",  1,  pipeActive(1))
  AssertEq("init: pipeCol(1) = 30",    30, pipeCol(1))
  AssertGT("init: pipeGap(1) >= 2",    1,  pipeGap(1))
  AssertLTE("init: pipeGap(1) <= 15", 15,  pipeGap(1))
  AssertEq("init: pipeActive(2) = 0",  0,  pipeActive(2))

  ' ── Test group 2: SpawnPipe ───────────────────────────────────────────────
  SpawnPipe(2)
  AssertEq("spawn: pipeActive(2) = 1",  1,  pipeActive(2))
  AssertEq("spawn: pipeCol(2) = 30",   30,  pipeCol(2))
  AssertGT("spawn: pipeGap(2) >= 2",    1,  pipeGap(2))
  AssertLTE("spawn: pipeGap(2) <= 15", 15,  pipeGap(2))

  ' ── Summary ──────────────────────────────────────────────────────────────
  PRINT
  IF failed = 0 THEN
    PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
  ELSE
    PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
  END IF

END SUB

#ifndef SUITE_MODE
RunTestPipes()
PAUSE 0
#endif
