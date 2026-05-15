' =============================================================================
' tests/test_difficulty_curve.bas
' Unit test — GetSpeedTier() and GetBorderColor() in src/game/difficulty.bas
'
' Fully automated — no user interaction required.
' Green = PASS, red = FAIL.  Press any key to exit.
'
' Test cases — GetSpeedTier(s):
'   Speed tier drops by 1 every 5 points; floor = 1.
'   1.  score  0  → PAUSE 4   (below first threshold)
'   2.  score  4  → PAUSE 4   (boundary: just below 5)
'   3.  score  5  → PAUSE 3   (boundary: exactly at 5)
'   4.  score  9  → PAUSE 3   (below next threshold)
'   5.  score 10  → PAUSE 2
'   6.  score 14  → PAUSE 2
'   7.  score 15  → PAUSE 1
'   8.  score 20  → PAUSE 1   (would be 0 without clamp)
'   9.  score 50  → PAUSE 1   (deep over-range, still clamped)
'
' Test cases — GetBorderColor(s):
'   Border colour advances every 10 points.
'   10. score  0  → 0 (black)
'   11. score  9  → 0 (black)
'   12. score 10  → 1 (blue)
'   13. score 19  → 1 (blue)
'   14. score 20  → 3 (magenta)
'   15. score 29  → 3 (magenta)
'   16. score 30  → 6 (yellow)
'   17. score 39  → 6 (yellow)
'   18. score 40  → 2 (red)
'   19. score 50  → 2 (red)
'
' Compile:  make tests
' Run:      make run-test-difficulty-curve
' =============================================================================

#include "assert_helpers.bas"
#include "../src/game/difficulty.bas"

SUB RunTestDifficultyCurve()
  ' ── Screen setup ────────────────────────────────────────────────────────────
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; "TEST: Difficulty Curve"
  PRINT INK 5;           "──────────────────────"
  PRINT

  passed = 0
  failed = 0

  ' ── GetSpeedTier — PAUSE delay decreases every 5 points ─────────────────────
  AssertEq("speed: score  0 -> PAUSE 4", 4, GetSpeedTier(0))
  AssertEq("speed: score  4 -> PAUSE 4", 4, GetSpeedTier(4))
  AssertEq("speed: score  5 -> PAUSE 3", 3, GetSpeedTier(5))
  AssertEq("speed: score  9 -> PAUSE 3", 3, GetSpeedTier(9))
  AssertEq("speed: score 10 -> PAUSE 2", 2, GetSpeedTier(10))
  AssertEq("speed: score 14 -> PAUSE 2", 2, GetSpeedTier(14))
  AssertEq("speed: score 15 -> PAUSE 1", 1, GetSpeedTier(15))
  AssertEq("speed: score 20 -> PAUSE 1", 1, GetSpeedTier(20))
  AssertEq("speed: score 50 -> PAUSE 1", 1, GetSpeedTier(50))

  ' ── GetBorderColor — border colour advances every 10 points ─────────────────
  AssertEq("border: score  0 -> 0 blk", 0, GetBorderColor(0))
  AssertEq("border: score  9 -> 0 blk", 0, GetBorderColor(9))
  AssertEq("border: score 10 -> 1 blu", 1, GetBorderColor(10))
  AssertEq("border: score 19 -> 1 blu", 1, GetBorderColor(19))
  AssertEq("border: score 20 -> 3 mag", 3, GetBorderColor(20))
  AssertEq("border: score 29 -> 3 mag", 3, GetBorderColor(29))
  AssertEq("border: score 30 -> 6 yel", 6, GetBorderColor(30))
  AssertEq("border: score 39 -> 6 yel", 6, GetBorderColor(39))
  AssertEq("border: score 40 -> 2 red", 2, GetBorderColor(40))
  AssertEq("border: score 50 -> 2 red", 2, GetBorderColor(50))

  ' ── Summary ─────────────────────────────────────────────────────────────────
  PRINT
  IF failed = 0 THEN
    PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
  ELSE
    PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
  END IF

END SUB

#ifndef SUITE_MODE
RunTestDifficultyCurve()
PAUSE 0
#endif
