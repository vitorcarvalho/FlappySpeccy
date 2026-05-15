' =============================================================================
' src/game/game.bas
' Core game loop — Phase 8: physics + pipes + collision + scoring + sound +
'                           dynamic speed + border tier indicator.
'
' Exports:
'   RunGame()  — runs one game session; returns when Q is pressed or the
'                bird collides with a pipe or the floor (row 22).
'   score      — INTEGER global; final score readable by main.bas after return.
'
' Depends on (via the #include chain in main.bas):
'   difficulty.bas — GetSpeedTier(s), GetBorderColor(s) — pure speed/border helpers
'   physics.bas    — InitPhysics(), UpdatePhysics(), birdRow, birdVel, birdCol
'   pipes.bas      — InitPipes(), UpdatePipes(), pipeCol/Active/Scored arrays
'   collision.bas  — CheckCollision() — returns 1 on pipe or floor hit
'   sounds.bas     — SoundFlap(), SoundScore(), SoundDie()
'   bird_udg.bas   — CHR$(144) must be loaded by LoadBirdUDG() before RunGame()
'
' Rendering strategy (from ARCHITECTURE.md):
'   CLS not called per frame.  Pipes are erased then redrawn via UpdatePipes().
'   The bird is drawn last so it always appears on top of pipe columns.
'
' Physics tick divider:
'   The game loop runs at 50 Hz but physics only advances every 2 frames (25 Hz).
'   Pipes still scroll every frame for smooth visual movement.
'   Flap input is latched so no SPACE press is lost on a skipped physics frame.
'
' Scoring:
'   Bird is always at birdCol (=4).  A pipe at pipeCol <= 2 has fully cleared
'   the bird.  pipeScored(i) prevents awarding the point more than once.
'   HUD row 0 layout:  "SPC=FLAP" col 0 | score col 14 | "Q=QUIT" col 25
'
' Dynamic speed (Phase 8):
'   pauseDelay starts at 4 (slowest) and drops by 1 every 5 points.
'   Minimum pauseDelay = 1 (fastest).  Computed by GetSpeedTier(score).
'
' Border tier indicator (Phase 8):
'   BORDER colour advances every 10 points: black→blue→magenta→yellow→red.
'   Reset to BORDER 0 after game over so the title screen is clean.
' =============================================================================

#include "difficulty.bas"
#include "physics.bas"
#include "pipes.bas"
#include "collision.bas"
#include "../screens/gameover.bas"
#include "../../assets/sounds/sounds.bas"

DIM score AS INTEGER   ' global — main.bas reads this after RunGame() returns

SUB RunGame()
  DIM prevRow     AS INTEGER
  DIM gameOver    AS INTEGER
  DIM quitGame    AS INTEGER
  DIM key         AS STRING
  DIM physTick    AS INTEGER   ' toggles 0/1; physics runs only when 1
  DIM flapPending AS INTEGER   ' latches SPACE across skipped physics frames
  DIM i           AS INTEGER   ' scoring loop index
  DIM pauseDelay  AS INTEGER   ' PAUSE ticks per frame (4=slow … 1=fast)
  DIM borderColor AS INTEGER   ' current border colour index

  ' ── Initialise ──────────────────────────────────────────────────────────────
  CLS
  gameOver    = 0
  quitGame    = 0
  physTick    = 0
  flapPending = 0
  score       = 0
  pauseDelay  = 4              ' start at slowest speed (score 0)
  borderColor = 0
  BORDER 0
  InitPhysics()
  InitPipes()
  prevRow = birdRow

  ' ── HUD ─────────────────────────────────────────────────────────────────────
  ' Row 0 layout: "SPC=FLAP" col 0 | score (right-justified) col 14 | "Q=QUIT" col 25
  PRINT INK 5; BRIGHT 0; PAPER 0; AT 0, 0;  "SPC=FLAP"
  PRINT INK 6; BRIGHT 1; PAPER 0; AT 0, 14; "0"
  PRINT INK 5; BRIGHT 0; PAPER 0; AT 0, 25; "Q=QUIT"

  ' ── Initial draw ────────────────────────────────────────────────────────────
  PRINT INK 6; BRIGHT 1; PAPER 0; AT birdRow, birdCol; CHR$(144)

  ' ── Game loop (~50 Hz) ──────────────────────────────────────────────────────
  DO
    PAUSE pauseDelay   ' dynamic: 4 frames at score 0, down to 1 at score 15+
    key = INKEY$

    ' Quit to title screen
    IF key = "q" OR key = "Q" THEN
      gameOver = 1
      quitGame = 1
    END IF

    ' Latch flap — remember SPACE even on frames where physics is skipped
    IF key = " " THEN flapPending = 1

    ' Erase bird at previous position before moving
    PRINT INK 0; PAPER 0; AT prevRow, birdCol; " "

    ' Physics runs every 2 frames (25 Hz) — halves fall/flap speed
    physTick = 1 - physTick
    IF physTick = 1 THEN
      prevRow = birdRow
      IF flapPending = 1 THEN SoundFlap()   ' chirp before physics so sound leads the jump
      UpdatePhysics(flapPending)
      flapPending = 0
    END IF

    ' Scroll pipes every frame — smooth visual movement at full 50 Hz
    UpdatePipes()

    ' ── Scoring ─────────────────────────────────────────────────────────────
    ' Bird is at birdCol (4).  A pipe left-edge at col <= 2 means its trailing
    ' edge has cleared col 4, so the bird has passed it.  Award point once.
    FOR i = 1 TO 3
      IF pipeActive(i) = 1 AND pipeScored(i) = 0 AND pipeCol(i) <= 2 THEN
        pipeScored(i) = 1
        score = score + 1
        PRINT INK 6; BRIGHT 1; PAPER 0; AT 0, 14; score; "  "
        SoundScore()
        ' Phase 8: update speed tier and border colour on every point scored
        pauseDelay  = GetSpeedTier(score)
        borderColor = GetBorderColor(score)
        BORDER borderColor
      END IF
    NEXT i

    ' Collision check BEFORE drawing the bird — at this point the attribute at
    ' birdRow/birdCol reflects only the pipe (or empty air), not the bird's own
    ' INK 6, so we get a clean attribute read with no false positives.
    IF CheckCollision() = 1 THEN gameOver = 1

    ' Draw bird last — always on top of any pipe column
    PRINT INK 6; BRIGHT 1; PAPER 0; AT birdRow, birdCol; CHR$(144)

  LOOP UNTIL gameOver = 1

  ' ── Death flash + jingle (skipped on clean Q-quit) ─────────────────────────
  IF quitGame = 0 THEN
    PRINT INK 2; BRIGHT 1; FLASH 1; PAPER 0; AT birdRow, birdCol; CHR$(144)
    SoundDie()   ' descending sweep ~0.5 s — doubles as the death pause
    FLASH 0
    BRIGHT 0
  END IF

  ' Phase 8: reset border to black so the title/game-over screen is clean
  BORDER 0

END SUB
