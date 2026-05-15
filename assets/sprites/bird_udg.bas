' =============================================================================
' assets/sprites/bird_udg.bas
' Defines and loads the bird User Defined Graphic into UDG slot A.
'
' The ZX Spectrum 48K provides 21 UDG slots (A–U).  Each slot is 8 bytes,
' one byte per pixel row, MSB = leftmost pixel.  Printing CHR$(144) outputs
' UDG "A" at the current cursor position.
'
' ── Visual identity ──────────────────────────────────────────────────────────
' The game character is called the "bird" in code.  Its visual representation
' is the word "SKY" rendered as a pixel-art glyph at 8×8 resolution.
'
' Layout: 8 columns split as S (3px) | K (3px) | Y (2px), no gaps.
' 1 row of top padding, 5 active rows, 2 rows of bottom padding.
'
' Pixel map — 1 = ink, 0 = paper (binary → decimal):
'
'   Row 0:  0 0 0 0 0 0 0 0  =   0   top padding
'   Row 1:  1 1 1 1 0 1 1 1  = 247   S top    K outer  Y both
'   Row 2:  1 0 0 1 1 0 1 1  = 155   S left   K l+mid  Y both
'   Row 3:  1 1 1 1 0 0 0 1  = 241   S mid    K left   Y stem
'   Row 4:  0 0 1 1 1 0 0 1  =  57   S right  K l+mid  Y stem
'   Row 5:  1 1 1 1 0 1 0 1  = 245   S bot    K outer  Y stem
'   Row 6:  0 0 0 0 0 0 0 0  =   0   bottom padding
'   Row 7:  0 0 0 0 0 0 0 0  =   0   empty (breathing room)
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

  POKE USR "A" + 0,   0   ' 00000000 — top padding
  POKE USR "A" + 1, 247   ' 11110111 — S top,   K outer, Y both
  POKE USR "A" + 2, 155   ' 10011011 — S left,  K l+mid, Y both
  POKE USR "A" + 3, 241   ' 11110001 — S mid,   K left,  Y stem
  POKE USR "A" + 4,  57   ' 00111001 — S right, K l+mid, Y stem
  POKE USR "A" + 5, 245   ' 11110101 — S bot,   K outer, Y stem
  POKE USR "A" + 6,   0   ' 00000000 — bottom padding
  POKE USR "A" + 7,   0   ' 00000000 — empty (breathing room)

END SUB

#endif
