' =============================================================================
' tests/test_bird_udg.bas
' Unit test — LoadBirdUDG() in assets/sprites/bird_udg.bas
'
' Strategy: call LoadBirdUDG(), then PEEK each of the 8 UDG bytes and compare
' against the expected pixel-map values documented in bird_udg.bas.
'
' Fully automated — no user interaction required.
' Green = PASS, red = FAIL.  Press any key to exit.
'
' Compile:  make test-bird-udg
' Run:      make run-test-bird-udg
' =============================================================================

#include "assert_helpers.bas"
#include "../assets/sprites/bird_udg.bas"

SUB RunTestBirdUDG()
  ' ── Screen setup ────────────────────────────────────────────────────────────
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; "TEST: LoadBirdUDG()"
  PRINT INK 5;           "────────────────────"
  PRINT

  ' ── Run SUB under test ──────────────────────────────────────────────────────
  passed = 0
  failed = 0
  LoadBirdUDG()

  ' ── Assertions ──────────────────────────────────────────────────────────────
  AssertEq("row 0  top padding  ",   0, PEEK(USR "A" + 0))
  AssertEq("row 1  S top K out  ", 247, PEEK(USR "A" + 1))
  AssertEq("row 2  S left K mid ", 155, PEEK(USR "A" + 2))
  AssertEq("row 3  S mid K left ", 241, PEEK(USR "A" + 3))
  AssertEq("row 4  S right K mid",  57, PEEK(USR "A" + 4))
  AssertEq("row 5  S bot K outer", 245, PEEK(USR "A" + 5))
  AssertEq("row 6  bot padding  ",   0, PEEK(USR "A" + 6))
  AssertEq("row 7  empty row    ",   0, PEEK(USR "A" + 7))

  ' ── Summary ─────────────────────────────────────────────────────────────────
  PRINT
  IF failed = 0 THEN
    PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
  ELSE
    PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
  END IF

  ' ── UDG visual render ───────────────────────────────────────────────────────
  PRINT
  PRINT INK 5; BRIGHT 0; "UDG RENDER (visual confirm):"
  PRINT INK 6; BRIGHT 1; CHR$(144); CHR$(144); CHR$(144); CHR$(144)
  PRINT INK 6; BRIGHT 1; CHR$(144); CHR$(144); CHR$(144); CHR$(144)
  PRINT INK 6; BRIGHT 1; CHR$(144); CHR$(144); CHR$(144); CHR$(144)
  PRINT INK 6; BRIGHT 1; CHR$(144); CHR$(144); CHR$(144); CHR$(144)

END SUB

#ifndef SUITE_MODE
RunTestBirdUDG()
PAUSE 0
#endif
