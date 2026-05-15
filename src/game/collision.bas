' =============================================================================
' src/game/collision.bas
' Collision detection — attribute-based pipe hit + floor sentinel.
'
' Exports:
'   CheckCollision()  — returns 1 if the bird has collided, 0 otherwise
'
' Depends on (must be included before this file via the #include chain):
'   physics.bas  — birdRow, birdCol globals
'
' Collision rules:
'   Floor : birdRow >= 22  (physics clamps the bird here on floor impact)
'   Pipe  : (PEEK(22528 + birdRow * 32 + birdCol) AND 7) = 4
'           Pipes are drawn with INK 4 (green); the lower 3 bits of the
'           attribute byte identify the ink colour.
'           This check must run BEFORE the bird is drawn so the bird's own
'           INK 6 (yellow) attribute does not produce a false positive.
'
' Attribute memory map (ZX Spectrum 48K):
'   $5800 = 22528 — first attribute cell (row 0, col 0)
'   Each row is 32 bytes wide.
'   Formula: 22528 + row * 32 + col
' =============================================================================

#ifndef COLLISION_BAS
#define COLLISION_BAS

FUNCTION CheckCollision() AS INTEGER
  DIM hit      AS INTEGER
  DIM attr     AS INTEGER
  DIM inkColor AS INTEGER

  hit = 0

  ' Floor sentinel — physics clamps birdRow to 22 on floor impact
  IF birdRow >= 22 THEN
    hit = 1
  ELSE
    ' Attribute-based pipe detection.
    ' Extract ink colour (lower 3 bits) into a temp variable to avoid
    ' compound-expression issues with some Boriel BASIC parser versions.
    attr     = PEEK(22528 + birdRow * 32 + birdCol)
    inkColor = attr AND 7
    IF inkColor = 4 THEN hit = 1
  END IF

  RETURN hit
END FUNCTION

#endif
