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

#include "assert_helpers.bas"
#include "../assets/sprites/bird_udg.bas"
#include "../src/screens/title.bas"

SUB RunTestTitleRender()
  ' ── Phase 1: render the title screen ──────────────────────────────────────
  ' Identical setup to main.bas so the test exercises what the player sees.
  ' ShowTitle blocks until SPACE is pressed.
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  LoadBirdUDG()
  ShowTitle(0)

  ' ── Phase 2: attribute assertions ─────────────────────────────────────────
  ' Read attribute bytes BEFORE CLS — CLS would overwrite them with PAPER 0
  ' INK 7 (= 7) and make every assertion fail.
  DIM atTitle    AS INTEGER
  DIM atSubtitle AS INTEGER
  DIM atBird     AS INTEGER
  DIM atSep      AS INTEGER
  DIM atCta      AS INTEGER
  DIM atHiScore  AS INTEGER

  atTitle    = PEEK(22528 +  2*32 +  9)
  atSubtitle = PEEK(22528 +  4*32 +  7)
  atBird     = PEEK(22528 +  7*32 + 14)
  atSep      = PEEK(22528 + 11*32 +  7)
  atCta      = PEEK(22528 + 13*32 +  7)
  atHiScore  = PEEK(22528 + 19*32 +  9)

  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; "TEST: ShowTitle() attrs"
  PRINT INK 5;           "───────────────────────"
  PRINT

  passed = 0
  failed = 0

  AssertEq("title      r2  c9  attr=70 ",  70, atTitle)
  AssertEq("subtitle   r4  c7  attr=5  ",   5, atSubtitle)
  AssertEq("bird UDG   r7  c14 attr=70 ",  70, atBird)
  AssertEq("separator  r11 c7  attr=5  ",   5, atSep)
  AssertEq("CTA        r13 c7  attr=199", 199, atCta)
  AssertEq("hi-score   r19 c9  attr=4  ",   4, atHiScore)

  ' ── Summary ─────────────────────────────────────────────────────────────────
  PRINT
  IF failed = 0 THEN
    PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
  ELSE
    PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
  END IF

END SUB

#ifndef SUITE_MODE
RunTestTitleRender()
PAUSE 0
#endif
