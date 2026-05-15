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
'   "FLAPPY SPECCY"          row  2 col  9  INK 6 BRIGHT 1  → 64+6     =  70
'   "A ZX SPECTRUM GAME"     row  4 col  7  INK 5            →    5     =   5
'   CHR$(144) bird UDG       row  7 col 14  INK 6 BRIGHT 1  → 64+6     =  70
'   separator dashes         row 11 col  7  INK 5            →    5     =   5
'   "PRESS SPACE TO FLY"     row 13 col  7  INK 7 BRIGHT 1
'                                            FLASH 1         → 128+64+7 = 199
'   "1=EASY 2=NORMAL 3=HARD" row 15 col  5  INK 5            →    5     =   5
'   "> NORMAL <" (default)   row 17 col 11  INK 6 BRIGHT 1  → 64+6     =  70
'   "HIGH SCORE: 0"          row 19 col  9  INK 4            →    4     =   4
'   "M=MUTE  " (default)     row 21 col 12  INK 3            →    3     =   3
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
  DIM atDiffKey  AS INTEGER
  DIM atDiffSel  AS INTEGER
  DIM atHiScore  AS INTEGER
  DIM atMute     AS INTEGER

  atTitle    = PEEK(22528 +  2*32 +  9)
  atSubtitle = PEEK(22528 +  4*32 +  7)
  atBird     = PEEK(22528 +  7*32 + 14)
  atSep      = PEEK(22528 + 11*32 +  7)
  atCta      = PEEK(22528 + 13*32 +  7)
  atDiffKey  = PEEK(22528 + 15*32 +  5)   ' "1=EASY 2=NORMAL 3=HARD" key guide
  atDiffSel  = PEEK(22528 + 17*32 + 11)   ' "> NORMAL <" default selection
  atHiScore  = PEEK(22528 + 19*32 +  9)
  atMute     = PEEK(22528 + 21*32 + 12)   ' "M=MUTE  " default (soundMuted=1)

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
  AssertEq("diff key   r15 c5  attr=5  ",   5, atDiffKey)
  AssertEq("diff sel   r17 c11 attr=70 ",  70, atDiffSel)
  AssertEq("hi-score   r19 c9  attr=4  ",   4, atHiScore)
  AssertEq("mute ind   r21 c12 attr=3  ",   3, atMute)

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
