' =============================================================================
' src/game/game.bas
' Core game loop — Phase 4: physics + scrolling pipes.
' Scoring and full collision detection are added in later phases.
'
' Exports:
'   RunGame()  — runs one game session; returns when Q is pressed or the
'                bird hits the floor (row 22).
'
' Depends on (via the #include chain in main.bas):
'   physics.bas  — InitPhysics(), UpdatePhysics(), birdRow, birdVel, birdCol
'   pipes.bas    — InitPipes(), UpdatePipes()
'   bird_udg.bas — CHR$(144) must be loaded by LoadBirdUDG() before RunGame()
'
' Rendering strategy (from ARCHITECTURE.md):
'   CLS not called per frame.  Pipes are erased then redrawn via UpdatePipes().
'   The bird is drawn last so it always appears on top of pipe columns.
' =============================================================================

#include "physics.bas"
#include "pipes.bas"

SUB RunGame()
  DIM prevRow  AS INTEGER
  DIM gameOver AS INTEGER
  DIM quitGame AS INTEGER
  DIM key      AS STRING

  ' ── Initialise ──────────────────────────────────────────────────────────────
  CLS
  gameOver = 0
  quitGame = 0
  InitPhysics()
  InitPipes()
  prevRow = birdRow

  ' ── HUD ─────────────────────────────────────────────────────────────────────
  ' Row 0 is reserved for controls hint; bird is clamped to rows 1–22.
  PRINT INK 5; BRIGHT 0; PAPER 0; AT 0, 0; "SPC=FLAP  Q=QUIT"

  ' ── Initial draw ────────────────────────────────────────────────────────────
  PRINT INK 6; BRIGHT 1; PAPER 0; AT birdRow, birdCol; CHR$(144)

  ' ── Game loop (~50 Hz) ──────────────────────────────────────────────────────
  DO
    PAUSE 1          ' yield to 50 Hz interrupt — keeps timing hardware-accurate
    key = INKEY$

    ' Quit to title screen
    IF key = "q" OR key = "Q" THEN
      gameOver = 1
      quitGame = 1
    END IF

    ' Erase bird at previous position before moving
    PRINT INK 0; PAPER 0; AT prevRow, birdCol; " "

    ' Advance physics — flap on SPACE, gravity only otherwise
    prevRow = birdRow
    IF key = " " THEN
      UpdatePhysics(1)
    ELSE
      UpdatePhysics(0)
    END IF

    ' Scroll pipes (erase at old col, move, draw at new col)
    UpdatePipes()

    ' Draw bird last — always on top of any pipe column
    PRINT INK 6; BRIGHT 1; PAPER 0; AT birdRow, birdCol; CHR$(144)

    ' Floor collision → game over (ceiling is clamped silently for now)
    IF birdRow >= 22 THEN gameOver = 1

  LOOP UNTIL gameOver = 1

  ' ── Death flash (skipped on clean Q-quit) ───────────────────────────────────
  IF quitGame = 0 THEN
    PRINT INK 2; BRIGHT 1; FLASH 1; PAPER 0; AT birdRow, birdCol; CHR$(144)
    PAUSE 25   ' ~0.5 s flash
    FLASH 0
    BRIGHT 0
  END IF

END SUB
