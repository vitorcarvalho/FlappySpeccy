' =============================================================================
' src/game/difficulty.bas
' Phase 8: difficulty-curve helpers — pure functions, no I/O.
'
' Exports:
'   GetSpeedTier(s AS INTEGER) AS INTEGER
'     Returns the PAUSE delay for the current score.
'     Speed increases every 5 points; minimum delay = 1 (fastest).
'       score  0– 4 → PAUSE 4   (slowest)
'       score  5– 9 → PAUSE 3
'       score 10–14 → PAUSE 2
'       score 15+   → PAUSE 1   (fastest — clamped)
'
'   GetBorderColor(s AS INTEGER) AS INTEGER
'     Returns the ZX Spectrum border colour index for the score tier.
'       score  0– 9 → 0  (black)
'       score 10–19 → 1  (blue)
'       score 20–29 → 3  (magenta)
'       score 30–39 → 6  (yellow)
'       score 40+   → 2  (red)
'
' Design notes:
'   Both functions are pure (no side effects, no PRINT/BORDER/BEEP) so they
'   can be included and called directly from test_difficulty_curve.bas without
'   dragging in the full game-loop dependencies.
'
'   INT() is used for integer division because Boriel's "/" operator returns
'   a floating-point value.  INT() floors towards negative infinity, which is
'   correct for non-negative scores.
'
' Compile:  included transitively via src/game/game.bas
' Test:     make run-test-difficulty-curve
' =============================================================================

#ifndef DIFFICULTY_BAS
#define DIFFICULTY_BAS

' Returns the PAUSE delay (1–4) for a given score.
' Delay drops by 1 for every 5 points scored, floored at 1.
FUNCTION GetSpeedTier(s AS INTEGER) AS INTEGER
  DIM d AS INTEGER
  d = 4 - INT(s / 5)
  IF d < 1 THEN d = 1
  RETURN d
END FUNCTION

' Returns the ZX border colour index (0–6) for a given score.
' Colour tier advances every 10 points, giving 5 distinct visual bands.
FUNCTION GetBorderColor(s AS INTEGER) AS INTEGER
  IF s >= 40 THEN RETURN 2   ' red    — max speed tier
  IF s >= 30 THEN RETURN 6   ' yellow
  IF s >= 20 THEN RETURN 3   ' magenta
  IF s >= 10 THEN RETURN 1   ' blue
  RETURN 0                    ' black  — starting tier
END FUNCTION

#endif
