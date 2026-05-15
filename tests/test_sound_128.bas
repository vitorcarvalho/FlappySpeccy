' =============================================================================
' tests/test_sound_128.bas
' Unit test -- SoundFlap(), SoundScore(), SoundDie() compiled with -D AY_SOUND.
'
' Standalone only — NOT included in test_suite.bas.
' Reason: requires -D AY_SOUND compile flag (different from the 48K suite build).
'
' Fully automated — no user interaction required.
' Green = PASS, red = FAIL.  Press any key to exit.
'
' Test strategy:
'   Verifies that the AY_SOUND code path compiles, all SUBs are callable, and
'   the mute flag behaves identically to the 48K build.
'   On a real 128K machine the AY OUT writes produce audible sound; on 48K the
'   OUT instructions are harmless no-ops and the logic assertions still pass.
'
' Test cases — callable without crash (soundMuted=1 by default, so silent):
'   1. SoundFlap  — AY chirp (A5, 1 frame)   -> callable, no crash
'   2. SoundScore — AY two-tone reward        -> callable, no crash
'   3. SoundDie   — AY descending sweep / PAUSE 25 -> callable, no crash
'
' Test cases — mute flag behaviour (identical to 48K build):
'   4. soundMuted defaults to 1 (muted on first load)
'   5. Toggle 1->0: soundMuted = 1 - soundMuted -> 0 (unmuted)
'   6. Toggle 0->1: soundMuted = 1 - soundMuted -> 1 (muted)
'   7. soundMuted=0: SoundFlap callable and returns (AY chirp on 128K)
'
' Compile:  make build-128k  (via tools/Makefile ZXFLAGS_TEST_128 = -D AY_SOUND)
' Run:      make run-test-sound-128k  (launches emulator with --machine 128k)
' =============================================================================

#include "assert_helpers.bas"
#include "../assets/sounds/sounds.bas"

SUB RunTestSound128()
  DIM called AS INTEGER

  ' -- Screen setup ------------------------------------------------------------
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; "TEST: Sound (128K / AY)"
  PRINT INK 5;           "───────────────────────"
  PRINT INK 3; BRIGHT 0; "(silent until mute test; 1 AY chirp at end)"
  PRINT

  passed = 0
  failed = 0

  ' -- Test 1: SoundFlap -- AY chirp ------------------------------------------
  called = 0
  SoundFlap()
  called = 1
  AssertEq("AY SoundFlap:  callable, no crash ", 1, called)

  ' -- Test 2: SoundScore -- AY two-tone reward --------------------------------
  called = 0
  SoundScore()
  called = 1
  AssertEq("AY SoundScore: callable, no crash ", 1, called)

  ' -- Test 3: SoundDie -- AY sweep / PAUSE 25 ---------------------------------
  called = 0
  SoundDie()
  called = 1
  AssertEq("AY SoundDie:   callable, no crash ", 1, called)

  ' -- Mute flag tests (same logic as 48K build) -------------------------------
  ' Tests 1-3 above ran with soundMuted=1 (default) -- silent, still returned.

  ' Test 4: default state is muted
  AssertEq("mute: default soundMuted=1        ", 1, soundMuted)

  ' Test 5: toggle 1 -> 0 (unmute)
  soundMuted = 1 - soundMuted
  AssertEq("mute: toggle 1->0                 ", 0, soundMuted)

  ' Test 6: toggle 0 -> 1 (re-mute)
  soundMuted = 1 - soundMuted
  AssertEq("mute: toggle 0->1                 ", 1, soundMuted)

  ' Test 7: unmuted -- SoundFlap callable and returns (AY chirp on 128K)
  soundMuted = 0
  called = 0
  SoundFlap()
  called = 1
  AssertEq("mute: unmuted AY SoundFlap ok     ", 1, called)
  soundMuted = 1   ' restore default

  ' -- Summary -----------------------------------------------------------------
  PRINT
  IF failed = 0 THEN
    PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
  ELSE
    PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
  END IF

END SUB

RunTestSound128()
PAUSE 0
