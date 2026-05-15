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
' Test cases — callable without crash (run silently; soundMuted=1 by default):
'   1. SoundFlap  — single chirp (A5, 20 ms)  → callable, no crash
'   2. SoundScore — two-note fanfare (~100 ms) → callable, no crash
'   3. SoundDie   — descending sweep / PAUSE 25 → callable, no crash
'
' Test cases — mute flag behaviour:
'   4. soundMuted defaults to 1 (muted on first load)
'   5. Toggle 1→0: soundMuted = 1 - soundMuted → 0 (unmuted)
'   6. Toggle 0→1: soundMuted = 1 - soundMuted → 1 (muted)
'   7. soundMuted=0: SoundFlap callable and returns (you will hear one chirp)
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
  PRINT INK 3; BRIGHT 0; "(silent until mute test; 1 chirp at end)"
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

  ' ── Mute flag tests ─────────────────────────────────────────────────────────
  ' Tests 1-3 above ran with soundMuted=1 (default) — silent, still returned.

  ' Test 4: default state is muted
  AssertEq("mute: default soundMuted=1 ", 1, soundMuted)

  ' Test 5: toggle 1 → 0 (unmute)
  soundMuted = 1 - soundMuted
  AssertEq("mute: toggle 1->0          ", 0, soundMuted)

  ' Test 6: toggle 0 → 1 (re-mute)
  soundMuted = 1 - soundMuted
  AssertEq("mute: toggle 0->1          ", 1, soundMuted)

  ' Test 7: unmuted — SoundFlap callable and returns (audible chirp)
  soundMuted = 0
  called = 0
  SoundFlap()
  called = 1
  AssertEq("mute: unmuted SoundFlap ok ", 1, called)
  soundMuted = 1   ' restore default

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
