' =============================================================================
' src/game/physics.bas
' Bird physics — gravity accumulator and flap impulse.
'
' Exports:
'   InitPhysics()          — reset bird to start position and zero velocity
'   UpdatePhysics(flap%)   — advance one game tick
'                            pass 1 to apply flap impulse, 0 for gravity only
'
' Global state (declared here; accessible everywhere via #include chain):
'   birdRow  — current row  (clamped 1–22)
'   birdVel  — velocity in rows/tick, positive = downward (clamped -3..+3)
'   birdCol  — fixed column (4); never changes
'
' Physics model:
'   Gravity adds +1 to birdVel each tick (positive = downward, ZX row order).
'   A flap sets birdVel = -3 (upward impulse), overriding current velocity.
'   birdRow is updated by birdVel then clamped to the play area (rows 1–22).
'   Row 0 is reserved for HUD; row 23 is the floor sentinel used by game.bas.
'
' Design decision — UpdatePhysics() takes a flap parameter instead of reading
' INKEY$ directly.  This keeps physics testable: tests call UpdatePhysics(0)
' or UpdatePhysics(1) without needing real keyboard input.
' =============================================================================

DIM birdRow AS INTEGER
DIM birdVel AS INTEGER
DIM birdCol AS INTEGER

SUB InitPhysics()
  birdRow = 11   ' vertical centre of the 24-row screen
  birdVel = 0    ' no initial velocity
  birdCol = 4    ' fixed — bird never moves horizontally
END SUB

SUB UpdatePhysics(flap AS INTEGER)
  ' Flap impulse — overrides current velocity (not additive)
  IF flap = 1 THEN birdVel = -3

  ' Gravity — one row per tick, positive = downward
  birdVel = birdVel + 1

  ' Clamp velocity to prevent runaway acceleration
  IF birdVel >  3 THEN birdVel =  3
  IF birdVel < -3 THEN birdVel = -3

  ' Update position
  birdRow = birdRow + birdVel

  ' Clamp to play area (row 1 = ceiling, row 22 = floor)
  IF birdRow <  1 THEN birdRow =  1
  IF birdRow > 22 THEN birdRow = 22
END SUB
