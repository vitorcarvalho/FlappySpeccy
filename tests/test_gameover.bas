' =============================================================================
' tests/test_gameover.bas
' Unit test — GetMedalRank() in src/screens/gameover.bas
'
' Fully automated — no user interaction required.
' Green = PASS, red = FAIL.  Press any key to exit.
'
' Test cases (boundary values for each medal tier):
'   1. Score   0 → rank 0 (no medal)
'   2. Score   9 → rank 0 (just below bronze)
'   3. Score  10 → rank 1 (bronze threshold)
'   4. Score  20 → rank 2 (silver threshold)
'   5. Score  30 → rank 3 (gold threshold)
'   6. Score  40 → rank 4 (platinum threshold)
'   7. Score  50 → rank 4 (above platinum — stays at 4)
'
' Medal thresholds: >=40=Platinum(4) >=30=Gold(3) >=20=Silver(2) >=10=Bronze(1) else 0
'
' Compile:  make tests
' Run:      make run-test-gameover
' =============================================================================

#include "assert_helpers.bas"
#include "../src/screens/gameover.bas"

SUB RunTestGameOver()

  ' ── Screen setup ────────────────────────────────────────────────────────────
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; "TEST: Medal Ranks"
  PRINT INK 5;           "─────────────────"
  PRINT

  passed = 0
  failed = 0

  ' ── Test 1: no medal below threshold ────────────────────────────────────────
  AssertEq("score  0 → no medal (rank 0)   ", 0, GetMedalRank(0))

  ' ── Test 2: just below bronze ───────────────────────────────────────────────
  AssertEq("score  9 → no medal (rank 0)   ", 0, GetMedalRank(9))

  ' ── Test 3: bronze threshold ────────────────────────────────────────────────
  AssertEq("score 10 → bronze   (rank 1)   ", 1, GetMedalRank(10))

  ' ── Test 4: silver threshold ────────────────────────────────────────────────
  AssertEq("score 20 → silver   (rank 2)   ", 2, GetMedalRank(20))

  ' ── Test 5: gold threshold ──────────────────────────────────────────────────
  AssertEq("score 30 → gold     (rank 3)   ", 3, GetMedalRank(30))

  ' ── Test 6: platinum threshold ──────────────────────────────────────────────
  AssertEq("score 40 → platinum (rank 4)   ", 4, GetMedalRank(40))

  ' ── Test 7: above platinum — stays 4 ────────────────────────────────────────
  AssertEq("score 50 → platinum (rank 4)   ", 4, GetMedalRank(50))

  ' ── Summary ─────────────────────────────────────────────────────────────────
  PRINT
  IF failed = 0 THEN
    PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
  ELSE
    PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
  END IF

END SUB

#ifndef SUITE_MODE
RunTestGameOver()
PAUSE 0
#endif
