' =============================================================================
' tests/test_pipes.bas
' Unit test — InitPipes() and SpawnPipe() in src/game/pipes.bas
'
' Fully automated — no user interaction required.
' Green = PASS, red = FAIL.  Press any key to exit.
'
' Gap formula: INT(RND * (21 - pipeGapSize)) + 2  →  row 2 .. (22 - pipeGapSize)
'
' Test cases — InitPipes() / SpawnPipe() invariants:
'   1.  InitPipes()      — pipeActive(1) = 1  (first pipe active)
'   2.  InitPipes()      — pipeCol(1) = 30    (left edge; pipe is 2 cols wide)
'   3.  InitPipes()      — pipeActive(2) = 0  (remaining slots inactive)
'   4.  SpawnPipe(2)     — pipeActive(2) = 1  (slot becomes active)
'   5.  SpawnPipe(2)     — pipeCol(2) = 30    (left edge of 2-wide pipe)
'
' Test cases — difficulty gap bounds (pipeGapSize controls the range):
'   Easy   (pipeGapSize=10)  gap: InitPipes → pipeGap(1) in 2..12
'   6.  pipeGap(1) >= 2
'   7.  pipeGap(1) <= 12
'   Normal (pipeGapSize=8)   gap: InitPipes → pipeGap(1) in 2..14
'   8.  pipeGap(1) >= 2
'   9.  pipeGap(1) <= 14
'   Hard   (pipeGapSize=6)   gap: InitPipes → pipeGap(1) in 2..16
'   10. pipeGap(1) >= 2
'   11. pipeGap(1) <= 16
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

  ' ── Group 1: InitPipes / SpawnPipe invariants (difficulty-independent) ────
  pipeGapSize = 8   ' Normal — default; any value works for these checks
  InitPipes()
  AssertEq("init: pipeActive(1) = 1",  1,  pipeActive(1))
  AssertEq("init: pipeCol(1) = 30",    30, pipeCol(1))
  AssertEq("init: pipeActive(2) = 0",  0,  pipeActive(2))
  SpawnPipe(2)
  AssertEq("spawn: pipeActive(2) = 1",  1,  pipeActive(2))
  AssertEq("spawn: pipeCol(2) = 30",   30,  pipeCol(2))

  ' ── Group 2: gap bounds — Easy (pipeGapSize=10)  range 2..12 ─────────────
  pipeGapSize = 10
  InitPipes()
  AssertGT ("easy: pipeGap(1) >= 2",    1,  pipeGap(1))
  AssertLTE("easy: pipeGap(1) <= 12",  12,  pipeGap(1))

  ' ── Group 3: gap bounds — Normal (pipeGapSize=8)  range 2..14 ────────────
  pipeGapSize = 8
  InitPipes()
  AssertGT ("norm: pipeGap(1) >= 2",    1,  pipeGap(1))
  AssertLTE("norm: pipeGap(1) <= 14",  14,  pipeGap(1))

  ' ── Group 4: gap bounds — Hard (pipeGapSize=6)  range 2..16 ─────────────
  pipeGapSize = 6
  InitPipes()
  AssertGT ("hard: pipeGap(1) >= 2",    1,  pipeGap(1))
  AssertLTE("hard: pipeGap(1) <= 16",  16,  pipeGap(1))

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
