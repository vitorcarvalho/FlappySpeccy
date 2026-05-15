' =============================================================================
' assets/sprites/bird_udg.bas
' Defines and loads the bird User Defined Graphic into UDG slot A.
'
' The ZX Spectrum 48K provides 21 UDG slots (A–U).  Each slot is 8 bytes,
' one byte per pixel row, MSB = leftmost pixel.  Printing CHR$(144) outputs
' UDG "A" at the current cursor position.
'
' ── Visual identity ──────────────────────────────────────────────────────────
' The game character is called the "bird" in code, but its visual
' representation is a PEACOCK — front-facing, tail fan fully spread, inspired
' by the NBC peacock logo.
'
' The fan radiates upward from a narrow body/neck at the bottom, with
' alternating feather tips at the top row to suggest the pinwheel of coloured
' feathers.  The two key elements at 8×8 pixels:
'   1. Fan   — rows 0–3: alternating tips converging into a solid spread.
'   2. Body  — rows 4–6: neck narrowing to a small chest and lower body.
'
' Pixel map — 1 = ink, 0 = paper (binary → decimal):
'
'   Row 0:  1 0 1 0 1 0 1 0  = 170   feather tips (X_X_X_X_)
'   Row 1:  0 1 0 1 0 1 0 0  =  84   feather shafts (_X_X_X__)
'   Row 2:  0 1 1 1 1 1 1 0  = 126   full fan spread (_XXXXXX_)
'   Row 3:  0 0 1 1 1 1 0 0  =  60   fan base narrowing (__XXXX__)
'   Row 4:  0 0 0 1 1 0 0 0  =  24   neck (___XX___)
'   Row 5:  0 0 0 1 1 1 0 0  =  28   body / chest (___XXX__)
'   Row 6:  0 0 0 0 1 0 0 0  =   8   lower body (____X___)
'   Row 7:  0 0 0 0 0 0 0 0  =   0   empty row (visual gap between cells)
'
' Design decision: individual POKE calls are used instead of FOR/READ/DATA.
' DATA statements inside a SUB can cause data-pointer ordering issues if
' other DATA statements exist elsewhere in the program.  Explicit POKEs
' are unambiguous and easier to read.
'
' USR "A":
'   Boriel BASIC supports the Sinclair-compatible USR "char" form, which
'   returns the RAM address of the 8-byte block for UDG slot "A".
'   On a 48K Spectrum this is typically $FF58 (65368), but USR "A" is
'   portable — it reads the live UDG base pointer from the system variables.
' =============================================================================

#ifndef BIRD_UDG_BAS
#define BIRD_UDG_BAS

SUB LoadBirdUDG()

  POKE USR "A" + 0, 170   ' 10101010 — feather tips (X_X_X_X_)
  POKE USR "A" + 1,  84   ' 01010100 — feather shafts (_X_X_X__)
  POKE USR "A" + 2, 126   ' 01111110 — full fan spread (_XXXXXX_)
  POKE USR "A" + 3,  60   ' 00111100 — fan base narrowing (__XXXX__)
  POKE USR "A" + 4,  24   ' 00011000 — neck (___XX___)
  POKE USR "A" + 5,  28   ' 00011100 — body / chest (___XXX__)
  POKE USR "A" + 6,   8   ' 00001000 — lower body (____X___)
  POKE USR "A" + 7,   0   ' 00000000 — empty (breathing room)

END SUB

#endif
