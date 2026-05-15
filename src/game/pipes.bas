' =============================================================================
' src/game/pipes.bas
' Pipe column management — spawn, scroll, erase, draw.
'
' Exports:
'   InitPipes()      — reset all slots; spawn first pipe (state only, no draw)
'   SpawnPipe(slot)  — activate a slot: col=31, random gap row 2–15
'   ErasePipe(slot)  — blank all rows 1–22 at the pipe's column
'   DrawPipe(slot)   — render green blocks (INK 4) above and below the gap
'   UpdatePipes()    — one tick: erase → scroll → deactivate or redraw → spawn
'
' Global state (arrays are 1-based in Boriel/Sinclair BASIC):
'   pipeCol(4)    — current screen column (0–31); -1 = off-screen
'   pipeGap(4)    — row where the 4-row gap starts (2–15)
'   pipeActive(4) — 1 = active, 0 = inactive
'
' Pipe visual:
'   CHR$(143) = solid block graphic (ZX Spectrum mosaic char, all quadrants set)
'   INK 4 = green.  Top body: rows 1..(gap-1).  Bottom body: rows (gap+4)..22.
'   Gap rows are left blank.  Row 0 = HUD; row 23 = status bar.
'
' Spawn trigger:
'   A new pipe is spawned in the first free slot when the rightmost active
'   pipe reaches column 24 (gives ~7 ticks / ~0.14 s between pipes).
'   Speed tuning is deferred to Phase 8.
'
' Compile:  make  (included via src/game/game.bas → src/game/main.bas)
' =============================================================================

#ifndef PIPES_BAS
#define PIPES_BAS

DIM pipeCol(4)    AS INTEGER
DIM pipeGap(4)    AS INTEGER
DIM pipeActive(4) AS INTEGER

' ── Erase one pipe column — blank all rows 1–22 at its current column ─────────

SUB ErasePipe(slot AS INTEGER)
  DIM r AS INTEGER
  DIM c AS INTEGER
  c = pipeCol(slot)
  IF c >= 0 AND c <= 31 THEN
    FOR r = 1 TO 22
      PRINT PAPER 0; INK 0; AT r, c; " "
    NEXT r
  END IF
END SUB

' ── Draw one pipe column at its current column ────────────────────────────────

SUB DrawPipe(slot AS INTEGER)
  DIM r   AS INTEGER
  DIM c   AS INTEGER
  DIM gap AS INTEGER
  c   = pipeCol(slot)
  gap = pipeGap(slot)
  IF c >= 0 AND c <= 31 THEN
    FOR r = 1 TO gap - 1
      PRINT PAPER 0; INK 4; AT r, c; CHR$(143)
    NEXT r
    FOR r = gap + 4 TO 22
      PRINT PAPER 0; INK 4; AT r, c; CHR$(143)
    NEXT r
  END IF
END SUB

' ── Activate a slot at column 31 with a random gap row ────────────────────────

SUB SpawnPipe(slot AS INTEGER)
  pipeCol(slot)    = 31
  pipeGap(slot)    = INT(RND * 14) + 2   ' random row 2–15
  pipeActive(slot) = 1
END SUB

' ── Initialise all slots and spawn the first pipe (state only, no draw) ───────

SUB InitPipes()
  DIM i AS INTEGER
  FOR i = 1 TO 4
    pipeActive(i) = 0
    pipeCol(i)    = -1
    pipeGap(i)    = 0
  NEXT i
  SpawnPipe(1)
END SUB

' ── Scroll all active pipes one column left; spawn when slot free ──────────────

SUB UpdatePipes()
  DIM i        AS INTEGER
  DIM maxCol   AS INTEGER
  DIM freeSlot AS INTEGER
  maxCol   = -1
  freeSlot = 0

  FOR i = 1 TO 4
    IF pipeActive(i) = 1 THEN
      ErasePipe(i)
      pipeCol(i) = pipeCol(i) - 1
      IF pipeCol(i) < 0 THEN
        pipeActive(i) = 0
        IF freeSlot = 0 THEN freeSlot = i   ' slot just freed
      ELSE
        DrawPipe(i)
        IF pipeCol(i) > maxCol THEN maxCol = pipeCol(i)
      END IF
    ELSE
      IF freeSlot = 0 THEN freeSlot = i
    END IF
  NEXT i

  ' Spawn when rightmost active pipe is at or inside col 24
  IF maxCol >= 0 AND maxCol <= 24 AND freeSlot > 0 THEN
    SpawnPipe(freeSlot)
    DrawPipe(freeSlot)
  END IF
END SUB

#endif
