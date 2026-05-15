' =============================================================================
' src/screens/title.bas
' Title / splash screen renderer.
'
' Exports:
'   ShowTitle(score AS INTEGER)
'     Draws the full splash screen, handles difficulty selection, and blocks
'     until SPACE is pressed.  Sets the global selectedDifficulty (1/2/3).
'     Returns to caller with no side-effects beyond selectedDifficulty.
'
' Screen layout (32 cols × 24 rows, CLS called by RunFlappySpeccy before entry):
'
'   Row  2  col  9  "FLAPPY SPECCY"        INK 6 BRIGHT 1  (bright yellow)
'   Row  4  col  7  "A ZX SPECTRUM GAME"   INK 5 BRIGHT 0  (cyan)
'   Row  7  col 14  CHR$(144) × 3          INK 6 BRIGHT 1  (bird UDG × 3)
'   Row 11  col  7  separator dashes        INK 5 BRIGHT 0  (cyan)
'   Row 13  col  7  "PRESS SPACE TO FLY"   INK 7 BRIGHT 1 FLASH 1
'   Row 15  col  5  "1=EASY 2=NORMAL 3=HARD"  INK 5 BRIGHT 0  (key guide)
'   Row 17  col 11  "> NORMAL <"           INK 6 BRIGHT 1  (current selection)
'   Row 19  col  9  "HIGH SCORE: n"        INK 4 BRIGHT 0  (green)
'
' Centering rationale (screen is 32 columns wide):
'   "FLAPPY SPECCY"         13 chars  → (32-13)/2  = 9   → col 9
'   "A ZX SPECTRUM GAME"    18 chars  → (32-18)/2  = 7   → col 7
'   CHR$(144) × 3            3 chars  → (32-3)/2   = 14  → col 14
'   "PRESS SPACE TO FLY"    18 chars  → col 7  (same as subtitle)
'   "1=EASY 2=NORMAL 3=HARD" 22 chars → (32-22)/2  = 5   → col 5
'   "> NORMAL <"            10 chars  → (32-10)/2  = 11  → col 11
'   "HIGH SCORE: 0"         13 chars  → (32-13)/2  = 9   → col 9
'
' Difficulty keys:
'   1 = Easy   (pipeGapSize 10)  gap row 2-12
'   2 = Normal (pipeGapSize  8)  gap row 2-14  ← default
'   3 = Hard   (pipeGapSize  6)  gap row 2-16
'
' Colour constants (ZX Spectrum ink values):
'   0 = black  1 = blue   2 = red    3 = magenta
'   4 = green  5 = cyan   6 = yellow 7 = white
'
' Design decision — this SUB owns only drawing, not screen state.
' PAPER 0 / BORDER 0 / CLS are called once in main.bas before ShowTitle.
' This keeps the SUB reusable (e.g. returning to title after game over).
' =============================================================================

#ifndef TITLE_BAS
#define TITLE_BAS

' selectedDifficulty is set by ShowTitle and read by RunFlappySpeccy in main.bas.
'   1 = Easy (gap 10 rows)  2 = Normal (gap 8 rows)  3 = Hard (gap 6 rows)
DIM selectedDifficulty AS INTEGER

SUB ShowTitle(score AS INTEGER)
  DIM diff AS INTEGER
  DIM k    AS STRING
  diff = 2   ' default: Normal

  ' ── Title ─────────────────────────────────────────────────────────────────
  ' BRIGHT 1 makes yellow more vivid; on a real CRT the difference is
  ' significant.  On emulators it may look similar to BRIGHT 0.
  PRINT INK 6; BRIGHT 1; PAPER 0; AT 2, 9; "FLAPPY SPECCY"

  ' ── Subtitle ──────────────────────────────────────────────────────────────
  ' Cyan (INK 5) at normal brightness — visually subordinate to the title.
  PRINT INK 5; BRIGHT 0; PAPER 0; AT 4, 7; "A ZX SPECTRUM GAME"

  ' ── Bird sprite ───────────────────────────────────────────────────────────
  ' CHR$(144) = UDG "A" (loaded by LoadBirdUDG before ShowTitle is called).
  ' Three copies side-by-side form a small flock impression.
  ' The semicolons between items suppress newlines — they print on the same row.
  PRINT INK 6; BRIGHT 1; PAPER 0; AT 7, 14; CHR$(144); CHR$(144); CHR$(144)

  ' ── Separator ─────────────────────────────────────────────────────────────
  ' 18 dashes match the width of the subtitle and prompt lines.
  PRINT INK 5; BRIGHT 0; PAPER 0; AT 11, 7; "------------------"

  ' ── Call-to-action ────────────────────────────────────────────────────────
  ' FLASH 1 alternates ink and paper at ~1.5 Hz on real hardware — the
  ' classic Spectrum "look at me" effect.  Reset immediately after with the
  ' standalone FLASH 0 statement so later PRINTs are not affected.
  PRINT INK 7; BRIGHT 1; PAPER 0; FLASH 1; AT 13, 7; "PRESS SPACE TO FLY"
  FLASH 0

  ' ── Difficulty key guide ──────────────────────────────────────────────────
  ' Cyan label on row 15; dynamic selection indicator on row 17 (bright yellow).
  ' "1=EASY 2=NORMAL 3=HARD" = 22 chars → centered at col 5.
  PRINT INK 5; BRIGHT 0; PAPER 0; AT 15, 5; "1=EASY 2=NORMAL 3=HARD"

  ' ── Initial selection indicator (Normal by default) ───────────────────────
  ' 10-char field: "> EASY <  " / "> NORMAL <" / "> HARD <  " — all same width
  ' so no explicit erase is needed when switching; overprint is sufficient.
  PRINT INK 6; BRIGHT 1; PAPER 0; AT 17, 11; "> NORMAL <"

  ' ── High score ────────────────────────────────────────────────────────────
  PRINT INK 4; BRIGHT 0; PAPER 0; AT 19, 9; "HIGH SCORE: "; score

  ' ── Wait for SPACE; allow 1/2/3 to change difficulty ──────────────────────
  ' PAUSE 1 yields to the 50 Hz interrupt to avoid busy-spinning the Z80.
  ' k is sampled once per frame; held keys are handled correctly.
  DO
    PAUSE 1
    k = INKEY$

    IF k = "1" OR k = "2" OR k = "3" THEN
      IF k = "1" THEN diff = 1
      IF k = "2" THEN diff = 2
      IF k = "3" THEN diff = 3
      ' Redraw selection indicator — all variants are 10 chars, no erase needed.
      IF diff = 1 THEN PRINT INK 6; BRIGHT 1; PAPER 0; AT 17, 11; "> EASY <  "
      IF diff = 2 THEN PRINT INK 6; BRIGHT 1; PAPER 0; AT 17, 11; "> NORMAL <"
      IF diff = 3 THEN PRINT INK 6; BRIGHT 1; PAPER 0; AT 17, 11; "> HARD <  "
    END IF

  LOOP UNTIL k = " "

  ' Commit selection to global; reset flash/bright before returning.
  selectedDifficulty = diff
  FLASH 0
  BRIGHT 0

END SUB

#endif
