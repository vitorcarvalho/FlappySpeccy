' =============================================================================
' src/screens/title.bas
' Title / splash screen renderer.
'
' Exports one SUB:
'   ShowTitle(score AS INTEGER)
'     Draws the full splash screen and blocks until SPACE is pressed.
'     Returns to caller with no side-effects on global state.
'
' Screen layout (32 cols × 24 rows, PAPER 0 background set by main.bas):
'
'   Row  2  col  9  "FLAPPY SPECCY"        INK 6 BRIGHT 1  (bright yellow)
'   Row  4  col  7  "A ZX SPECTRUM GAME"   INK 5 BRIGHT 0  (cyan)
'   Row  7  col 14  CHR$(144) × 3          INK 6 BRIGHT 1  (bird UDG × 3)
'   Row 11  col  7  separator dashes        INK 5 BRIGHT 0  (cyan)
'   Row 13  col  7  "PRESS SPACE TO FLY"   INK 7 BRIGHT 1 FLASH 1
'   Row 19  col  9  "HIGH SCORE: n"        INK 4 BRIGHT 0  (green)
'
' Centering rationale (screen is 32 columns wide):
'   "FLAPPY SPECCY"      13 chars  → (32-13) / 2 = 9   → col 9
'   "A ZX SPECTRUM GAME" 18 chars  → (32-18) / 2 = 7   → col 7
'   CHR$(144) × 3         3 chars  → (32-3)  / 2 = 14  → col 14
'   "PRESS SPACE TO FLY" 18 chars  → col 7  (same as subtitle)
'   "HIGH SCORE: 0"      13 chars  → (32-13) / 2 = 9   → col 9
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

SUB ShowTitle(score AS INTEGER)

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

  ' ── High score ────────────────────────────────────────────────────────────
  ' Green ink (INK 4).  The score value is printed directly after the label.
  ' For v0.1 this is always 0; future versions will persist across rounds.
  PRINT INK 4; BRIGHT 0; PAPER 0; AT 19, 9; "HIGH SCORE: "; score

  ' ── Wait for SPACE ────────────────────────────────────────────────────────
  ' INKEY$ returns the currently pressed key, or "" when nothing is pressed.
  ' PAUSE 1 yields to the 50 Hz interrupt before re-checking the key —
  ' avoids busy-spinning the Z80 and suppresses compiler warning W130
  ' (empty loop body).  The keyboard is still scanned during PAUSE, so
  ' a held SPACE is detected on the very next frame (~20 ms latency max).
  DO
    PAUSE 1
  LOOP UNTIL INKEY$ = " "

  ' Reset flash/bright before returning so the caller's context is clean.
  FLASH 0
  BRIGHT 0

END SUB

#endif
