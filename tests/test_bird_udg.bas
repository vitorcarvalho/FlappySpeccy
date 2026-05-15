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

#include "../assets/sprites/bird_udg.bas"

' ── Test counters ─────────────────────────────────────────────────────────────
DIM passed AS INTEGER
DIM failed AS INTEGER

' ── AssertByte ────────────────────────────────────────────────────────────────
' Compares expected vs actual byte value and prints a PASS/FAIL line.
' Updates the shared passed/failed counters.
SUB AssertByte(label AS STRING, expected AS INTEGER, got AS INTEGER)
  IF expected = got THEN
    PRINT INK 4; "PASS "; INK 7; label
    passed = passed + 1
  ELSE
    PRINT INK 2; "FAIL "; INK 7; label
    PRINT INK 2; "     exp="; expected; "  got="; got
    failed = failed + 1
  END IF
END SUB

' ── Screen setup ──────────────────────────────────────────────────────────────
BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
PRINT BRIGHT 1; INK 6; "TEST: LoadBirdUDG()"
PRINT INK 5;           "────────────────────"
PRINT

' ── Run SUB under test ────────────────────────────────────────────────────────
' USR "A" is read live from the system variable — portable across Spectrum
' variants.  Before calling LoadBirdUDG() the slot contains ROM defaults.
passed = 0
failed = 0
LoadBirdUDG()

' ── Assertions ────────────────────────────────────────────────────────────────
' Expected values mirror the documented pixel map in bird_udg.bas.
' The sprite represents a PEACOCK in side-profile flying pose.
' The crest (rows 0-1) is the key distinguishing feature.
'
'   Row  Binary      Dec  Description
'   0    01010000     80  crest tips — two spikes (_X_X____)
'   1    01110000    112  crest base / head top  (_XXX____)
'   2    01111000    120  head                   (_XXXX___)
'   3    11111110    254  wings spread            (XXXXXXX_)
'   4    01111000    120  body                   (_XXXX___)
'   5    00111100     60  lower body             (__XXXX__)
'   6    00011100     28  tail feather hint      (___XXX__)
'   7    00000000      0  empty row (breathing room)

AssertByte("row 0  crest tips  ", 80,  PEEK(USR "A" + 0))
AssertByte("row 1  crest base  ",112,  PEEK(USR "A" + 1))
AssertByte("row 2  head        ",120,  PEEK(USR "A" + 2))
AssertByte("row 3  wings spread",254,  PEEK(USR "A" + 3))
AssertByte("row 4  body        ",120,  PEEK(USR "A" + 4))
AssertByte("row 5  lower body  ", 60,  PEEK(USR "A" + 5))
AssertByte("row 6  tail hint   ", 28,  PEEK(USR "A" + 6))
AssertByte("row 7  empty row   ",  0,  PEEK(USR "A" + 7))

' ── Summary ───────────────────────────────────────────────────────────────────
PRINT
IF failed = 0 THEN
  PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
ELSE
  PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
END IF

PAUSE 0
