' =============================================================================
' src/game/launcher.bas
' Top-level launcher — choose between the game and the test suite.
'
' Presents a three-option menu:
'   1  PLAY GAME    → RunFlappySpeccy() (defined in main.bas)
'   2  TEST SUITE   → RunTestSuite()    (defined in tests/test_suite.bas)
'   3  SOUND        → toggle soundMuted (0 = on, 1 = muted; default = muted)
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
'   soundMuted is declared in assets/sounds/sounds.bas (included via main.bas).
'   Toggle: soundMuted = 1 - soundMuted  (flips between 1 and 0).
'   Key "3" re-renders only the SOUND row and loops back — no full CLS needed.
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

  ' SOUND row — colour-coded: magenta = muted, green = on
  IF soundMuted = 1 THEN
    PRINT INK 3; PAPER 0; AT 13, 8; "3  SOUND: MUTED"
  ELSE
    PRINT INK 4; PAPER 0; AT 13, 8; "3  SOUND: ON   "
  END IF

  PRINT BRIGHT 1; INK 5; PAPER 0; AT 17, 5; "PRESS 1, 2 OR 3"

  DO
    PAUSE 1
    lKey = INKEY$
  LOOP UNTIL lKey = "1" OR lKey = "2" OR lKey = "3"

  IF lKey = "1" THEN RunFlappySpeccy()
  IF lKey = "2" THEN RunTestSuite()
  IF lKey = "3" THEN
    soundMuted = 1 - soundMuted   ' toggle: 1 → 0 (on) or 0 → 1 (muted)
    ' Redraw SOUND row in place — no full CLS so other rows stay visible
    IF soundMuted = 1 THEN
      PRINT INK 3; PAPER 0; AT 13, 8; "3  SOUND: MUTED"
    ELSE
      PRINT INK 4; PAPER 0; AT 13, 8; "3  SOUND: ON   "
    END IF
  END IF

LOOP
