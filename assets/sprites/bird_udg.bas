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
' representation is a PEACOCK — specifically a Peacock in side-profile
' flying pose.  At 8×8 pixels the two distinguishing features that can be
' communicated are:
'   1. Crest  — two short spikes on top of the head (rows 0–1).  This is
'               the single most recognisable peacock silhouette feature.
'   2. Tail   — rows 5–6 fan slightly wider than the body to hint at the
'               peacock train spreading behind the bird in flight.
'
' Future work: if a second UDG slot is available, a separate tail tile
' (UDG "B") could be printed immediately to the right of the bird to show
' the full peacock fan.  Colour choice on the title screen (cyan/green) also
' reinforces the peacock identity.
'
' Pixel map — 1 = ink, 0 = paper (binary → decimal):
'
'   Row 0:  0 1 0 1 0 0 0 0  =  80   crest: two tips  (_X_X____)
'   Row 1:  0 1 1 1 0 0 0 0  = 112   crest base + head top  (_XXX____)
'   Row 2:  0 1 1 1 1 0 0 0  = 120   head  (_XXXX___)
'   Row 3:  1 1 1 1 1 1 1 0  = 254   wings spread — flying pose  (XXXXXXX_)
'   Row 4:  0 1 1 1 1 0 0 0  = 120   body  (_XXXX___)
'   Row 5:  0 0 1 1 1 1 0 0  =  60   lower body  (__XXXX__)
'   Row 6:  0 0 0 1 1 1 0 0  =  28   tail feather hint  (___XXX__)
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

SUB LoadBirdUDG()

  POKE USR "A" + 0,  80   ' 01010000 — crest tips (two spikes)
  POKE USR "A" + 1, 112   ' 01110000 — crest base / head top
  POKE USR "A" + 2, 120   ' 01111000 — head
  POKE USR "A" + 3, 254   ' 11111110 — wings spread
  POKE USR "A" + 4, 120   ' 01111000 — body
  POKE USR "A" + 5,  60   ' 00111100 — lower body
  POKE USR "A" + 6,  28   ' 00011100 — tail feather hint
  POKE USR "A" + 7,   0   ' 00000000 — empty (breathing room)

END SUB
