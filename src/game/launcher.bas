' =============================================================================
' src/game/launcher.bas
' Top-level launcher — choose between the game and the test suite.
'
' Presents a two-option menu:
'   1  PLAY GAME    → RunFlappySpeccy() (defined in main.bas)
'   2  TEST SUITE   → RunTestSuite()    (defined in tests/test_suite.bas)
'
' Compilation:
'   make build-launcher    — produces build/launcher.tap
'   make run-launcher      — compile + launch in emulator
'
' Design notes:
'   LAUNCHER_MODE  suppresses standalone entry points in main.bas and
'                  test_suite.bas so their SUBs are defined but not called.
'   SUITE_MODE     suppresses standalone RunTestXxx() calls inside each
'                  individual test file (same guard used by test_suite.bas).
'   Include paths are relative to this file (src/game/).
' =============================================================================

#define LAUNCHER_MODE
' SUITE_MODE is defined by tests/test_suite.bas on include — no need to repeat it here.

#include "main.bas"
#include "../../tests/test_suite.bas"

' ── Launcher menu ─────────────────────────────────────────────────────────────

DIM lKey AS STRING

DO
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS

  PRINT BRIGHT 1; INK 6; PAPER 0; AT 3,  9; "FLAPPY SPECCY"
  PRINT           INK 5; PAPER 0; AT 4,  6; "─────────────────────"
  PRINT           INK 7; PAPER 0; AT 9,  8; "1  PLAY GAME"
  PRINT           INK 7; PAPER 0; AT 11, 8; "2  TEST SUITE"
  PRINT BRIGHT 1; INK 5; PAPER 0; AT 17, 7; "PRESS 1 OR 2"

  DO
    PAUSE 1
    lKey = INKEY$
  LOOP UNTIL lKey = "1" OR lKey = "2"

  IF lKey = "1" THEN RunFlappySpeccy()
  IF lKey = "2" THEN RunTestSuite()

LOOP
