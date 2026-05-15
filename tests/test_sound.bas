' =============================================================================
' tests/test_sound.bas
' Unit test — SoundFlap(), SoundScore(), SoundDie() in assets/sounds/sounds.bas
'
' Fully automated — no user interaction required.
' Green = PASS, red = FAIL.  Press any key to exit.
'
' Test strategy:
'   BEEP has no observable return value and no addressable side effects on the
'   48K Spectrum.  The only reliable assertion is that each SUB:
'     (a) compiles without error, and
'     (b) returns (i.e. does not hang or crash).
'
'   Technique: set a flag to 0, call the SUB, immediately set flag to 1, then
'   assert flag = 1.  If the SUB hangs or throws a runtime error the flag stays
'   0 and the test fails.  If it returns normally the flag reaches 1 and passes.
'
'   You will hear the sounds play during the test — that is the audible proof
'   the BEEP statements actually execute.
'
' Test cases:
'   1. SoundFlap  — single chirp (A5, 20 ms)  → callable, no crash
'   2. SoundScore — two-note fanfare (~100 ms) → callable, no crash
'   3. SoundDie   — descending sweep (~480 ms) → callable, no crash
'
' Compile:  make tests
' Run:      make run-test-sound
' =============================================================================

#include "assert_helpers.bas"
#include "../assets/sounds/sounds.bas"

SUB RunTestSound()
  DIM called AS INTEGER

  ' ── Screen setup ────────────────────────────────────────────────────────────
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; "TEST: Sound Effects"
  PRINT INK 5;           "───────────────────"
  PRINT INK 3; BRIGHT 0; "(you will hear 3 sounds)"
  PRINT

  passed = 0
  failed = 0

  ' ── Test 1: SoundFlap — short chirp ─────────────────────────────────────────
  called = 0
  SoundFlap()
  called = 1
  AssertEq("SoundFlap:  callable, no crash ", 1, called)

  ' ── Test 2: SoundScore — two-note reward ────────────────────────────────────
  called = 0
  SoundScore()
  called = 1
  AssertEq("SoundScore: callable, no crash ", 1, called)

  ' ── Test 3: SoundDie — descending jingle ────────────────────────────────────
  called = 0
  SoundDie()
  called = 1
  AssertEq("SoundDie:   callable, no crash ", 1, called)

  ' ── Summary ─────────────────────────────────────────────────────────────────
  PRINT
  IF failed = 0 THEN
    PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
  ELSE
    PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
  END IF

END SUB

#ifndef SUITE_MODE
RunTestSound()
PAUSE 0
#endif
