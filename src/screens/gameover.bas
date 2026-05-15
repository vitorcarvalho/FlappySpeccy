' =============================================================================
' src/screens/gameover.bas
' Game-over screen — score display, medal award, retry prompt.
'
' Exports:
'   GetMedalRank(score AS INTEGER) AS INTEGER
'     Pure function — no screen side effects; testable.
'     Returns: 0 = no medal, 1 = bronze, 2 = silver, 3 = gold, 4 = platinum.
'
'   ShowGameOver(score AS INTEGER)
'     Draws the full game-over screen, blocks until SPACE is pressed.
'
' Medal thresholds (matching original Flappy Bird):
'   ≥ 40  Platinum  INK 5 BRIGHT 1  (cyan)
'   ≥ 30  Gold      INK 6 BRIGHT 1  (bright yellow)
'   ≥ 20  Silver    INK 7 BRIGHT 1  (bright white)
'   ≥ 10  Bronze    INK 3 BRIGHT 0  (magenta)
'   <  10  —        (no medal displayed)
'
' Screen layout:
'   Row  4  col 11  "GAME OVER"             INK 2 BRIGHT 1  (bright red)
'   Row  8  col 12  "SCORE:"                INK 5 BRIGHT 0
'   Row  9  col 14  score value             INK 6 BRIGHT 1
'   Row 12  col 12  "MEDAL:"                INK 5 BRIGHT 0  (only if earned)
'   Row 13  col 12  medal name              medal colour    (only if earned)
'   Row 18  col  6  "PRESS SPACE TO RETRY"  INK 7 BRIGHT 1 FLASH 1
'
' Centering rationale (screen is 32 cols wide):
'   "GAME OVER"             9 chars  →  (32-9)/2  = 11  → col 11
'   "SCORE:"                6 chars  →  fixed col 12 (label), score at col 19
'   "MEDAL:"                6 chars  →  fixed col 12 (label), name at col 19
'   "PRESS SPACE TO RETRY" 20 chars  →  (32-20)/2 =  6  → col  6
' =============================================================================

#ifndef GAMEOVER_BAS
#define GAMEOVER_BAS

' ── Medal rank — pure function, no screen I/O ─────────────────────────────────

FUNCTION GetMedalRank(score AS INTEGER) AS INTEGER
  IF score >= 40 THEN RETURN 4
  IF score >= 30 THEN RETURN 3
  IF score >= 20 THEN RETURN 2
  IF score >= 10 THEN RETURN 1
  RETURN 0
END FUNCTION

' ── Full game-over screen ─────────────────────────────────────────────────────

SUB ShowGameOver(score AS INTEGER)
  DIM rank AS INTEGER
  DIM k    AS STRING

  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS

  ' ── Header ──────────────────────────────────────────────────────────────────
  PRINT BRIGHT 1; INK 2; PAPER 0; AT 4, 11; "GAME OVER"

  ' ── Score ───────────────────────────────────────────────────────────────────
  PRINT BRIGHT 0; INK 5; PAPER 0; AT 8, 12; "SCORE:"
  PRINT BRIGHT 1; INK 6; PAPER 0; AT 8, 19; score

  ' ── Medal ───────────────────────────────────────────────────────────────────
  rank = GetMedalRank(score)
  IF rank > 0 THEN
    PRINT BRIGHT 0; INK 5; PAPER 0; AT 12, 12; "MEDAL:"
    IF rank = 1 THEN PRINT BRIGHT 0; INK 3; PAPER 0; AT 12, 19; "BRONZE"
    IF rank = 2 THEN PRINT BRIGHT 1; INK 7; PAPER 0; AT 12, 19; "SILVER"
    IF rank = 3 THEN PRINT BRIGHT 1; INK 6; PAPER 0; AT 12, 19; "GOLD"
    IF rank = 4 THEN PRINT BRIGHT 1; INK 5; PAPER 0; AT 12, 19; "PLATINUM"
  END IF

  ' ── Retry prompt ────────────────────────────────────────────────────────────
  PRINT BRIGHT 1; INK 7; PAPER 0; FLASH 1; AT 18, 6; "PRESS SPACE TO RETRY"
  FLASH 0

  ' ── Wait for SPACE ──────────────────────────────────────────────────────────
  DO
    PAUSE 1
    k = INKEY$
  LOOP UNTIL k = " "

  FLASH 0 : BRIGHT 0

END SUB

#endif
