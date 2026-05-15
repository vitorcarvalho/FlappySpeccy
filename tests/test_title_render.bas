' =============================================================================
' tests/test_title_render.bas
' Unit test — ShowTitle() in src/screens/title.bas
'
' Two-phase test:
'
'   Phase 1 — Visual render (manual)
'     The title screen is drawn exactly as it would be in the game.
'     Verify visually that layout, colours and bird UDG look correct.
'     Press SPACE to advance (ShowTitle blocks here, as it does in the game).
'
'   Phase 2 — Attribute assertions (automated)
'     After ShowTitle returns the ZX Spectrum attribute file (0x5800) retains
'     every ink/paper/bright/flash byte that was written during rendering.
'     We PEEK each relevant cell and compare against the expected value.
'
' Attribute byte formula:  FLASH*128 + BRIGHT*64 + PAPER*8 + INK
' Attribute base address:  22528  (= 0x5800)
' Cell address:            22528 + row*32 + col
'
' Expected attribute values:
'   "FLAPPY SPECCY"      row  2 col  9  INK 6 BRIGHT 1  → 64+6   =  70
'   "A ZX SPECTRUM GAME" row  4 col  7  INK 5            →    5   =   5
'   CHR$(144) bird UDG   row  7 col 14  INK 6 BRIGHT 1  → 64+6   =  70
'   separator dashes     row 11 col  7  INK 5            →    5   =   5
'   "PRESS SPACE TO FLY" row 13 col  7  INK 7 BRIGHT 1
'                                        FLASH 1         → 128+64+7 = 199
'   "HIGH SCORE: 0"      row 19 col  9  INK 4            →    4   =   4
'
' Note: FLASH 0 / BRIGHT 0 at the end of ShowTitle reset the system variable
' only — they do NOT modify attribute bytes already written to 0x5800+.
' Attribute values set during PRINT are therefore stable for PEEK checks.
'
' Compile:  make test-title-render
' Run:      make run-test-title-render
' =============================================================================

#include "../assets/sprites/bird_udg.bas"
#include "../src/screens/title.bas"

' ── Test counters ─────────────────────────────────────────────────────────────
DIM passed AS INTEGER
DIM failed AS INTEGER

' ── AssertAttr ────────────────────────────────────────────────────────────────
' PEEKs the attribute byte at addr and compares with expected.
SUB AssertAttr(label AS STRING, addr AS INTEGER, expected AS INTEGER)
  DIM got AS INTEGER
  got = PEEK(addr)
  IF expected = got THEN
    PRINT INK 4; "PASS "; INK 7; label
    passed = passed + 1
  ELSE
    PRINT INK 2; "FAIL "; INK 7; label
    PRINT INK 2; "     exp="; expected; "  got="; got
    failed = failed + 1
  END IF
END SUB

' ── Phase 1: render the title screen ─────────────────────────────────────────
' Identical setup to main.bas so the test exercises exactly what the player sees.
BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
LoadBirdUDG()
ShowTitle(0)   ' ← blocks until SPACE is pressed

' ── Phase 2: attribute assertions ────────────────────────────────────────────
' ShowTitle has returned — screen attribute bytes are still in place.
' Overwrite the display with test output.
BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
PRINT BRIGHT 1; INK 6; "TEST: ShowTitle() attrs"
PRINT INK 5;           "───────────────────────"
PRINT

passed = 0
failed = 0

' ── Title: "FLAPPY SPECCY"  AT 2,9  INK 6 BRIGHT 1 PAPER 0  → 70
AssertAttr("title      r2  c9  attr=70 ", 22528 + 2*32 +  9,  70)

' ── Subtitle: "A ZX SPECTRUM GAME"  AT 4,7  INK 5 PAPER 0  → 5
AssertAttr("subtitle   r4  c7  attr=5  ", 22528 + 4*32 +  7,   5)

' ── Bird UDG CHR$(144)×3  AT 7,14  INK 6 BRIGHT 1 PAPER 0  → 70
AssertAttr("bird UDG   r7  c14 attr=70 ", 22528 + 7*32 + 14,  70)

' ── Separator  AT 11,7  INK 5 PAPER 0  → 5
AssertAttr("separator  r11 c7  attr=5  ", 22528 +11*32 +  7,   5)

' ── CTA "PRESS SPACE TO FLY"  AT 13,7  INK 7 BRIGHT 1 FLASH 1 PAPER 0  → 199
AssertAttr("CTA        r13 c7  attr=199", 22528 +13*32 +  7, 199)

' ── High score  AT 19,9  INK 4 PAPER 0  → 4
AssertAttr("hi-score   r19 c9  attr=4  ", 22528 +19*32 +  9,   4)

' ── Summary ───────────────────────────────────────────────────────────────────
PRINT
IF failed = 0 THEN
  PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
ELSE
  PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
END IF

PAUSE 0
