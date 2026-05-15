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
' The sprite represents a PEACOCK front-facing fan, inspired by NBC logo.
' Feathers radiate upward from a narrow body/neck at the bottom.
'
'   Row  Binary      Dec  Description
'   0    10101010    170  feather tips    (X_X_X_X_)
'   1    01010100     84  feather shafts  (_X_X_X__)
'   2    01111110    126  full fan spread (_XXXXXX_)
'   3    00111100     60  fan base        (__XXXX__)
'   4    00011000     24  neck            (___XX___)
'   5    00011100     28  body / chest    (___XXX__)
'   6    00001000      8  lower body      (____X___)
'   7    00000000      0  empty row (breathing room)

AssertByte("row 0  feather tips ",170,  PEEK(USR "A" + 0))
AssertByte("row 1  feather shaft", 84,  PEEK(USR "A" + 1))
AssertByte("row 2  fan spread   ",126,  PEEK(USR "A" + 2))
AssertByte("row 3  fan base     ", 60,  PEEK(USR "A" + 3))
AssertByte("row 4  neck         ", 24,  PEEK(USR "A" + 4))
AssertByte("row 5  body/chest   ", 28,  PEEK(USR "A" + 5))
AssertByte("row 6  lower body   ",  8,  PEEK(USR "A" + 6))
AssertByte("row 7  empty row    ",  0,  PEEK(USR "A" + 7))

' ── Summary ───────────────────────────────────────────────────────────────────
PRINT
IF failed = 0 THEN
  PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
ELSE
  PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
END IF

' ── UDG visual render ─────────────────────────────────────────────────────────
' 4×4 grid of CHR$(144) — confirm the peacock fan silhouette looks correct.
PRINT
PRINT INK 5; BRIGHT 0; "UDG RENDER (visual confirm):"
PRINT INK 6; BRIGHT 1; CHR$(144); CHR$(144); CHR$(144); CHR$(144)
PRINT INK 6; BRIGHT 1; CHR$(144); CHR$(144); CHR$(144); CHR$(144)
PRINT INK 6; BRIGHT 1; CHR$(144); CHR$(144); CHR$(144); CHR$(144)
PRINT INK 6; BRIGHT 1; CHR$(144); CHR$(144); CHR$(144); CHR$(144)

PAUSE 0
