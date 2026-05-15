' =============================================================================
' src/game/pipes.bas
' Pipe column management — spawn, scroll, erase, draw.
'
' Exports:
'   InitPipes()      — reset all slots; spawn first pipe (state only, no draw)
'   SpawnPipe(slot)  — activate a slot: left edge col=30, random gap row 2–15
'   ErasePipe(slot)  — blank all rows 1–22 across 2 columns at current position
'   DrawPipe(slot)   — render green blocks (INK 4) above and below the gap
'   UpdatePipes()    — one tick: erase → scroll → deactivate or redraw → spawn
'
' Global state (arrays are 1-based in Boriel/Sinclair BASIC):
'   pipeCol(3)    — left-edge column (0–30); -1 = off-screen; pipe is 2 cols wide
'   pipeGap(3)    — row where the 6-row gap starts (2–15)
'   pipeActive(3) — 1 = active, 0 = inactive
'
' Pipe visual:
'   CHR$(143) = solid block graphic (ZX Spectrum mosaic char, all quadrants set)
'   INK 4 = green.  Pipe is 2 columns wide.
'   Top body: rows 1..(gap-1).  Bottom body: rows (gap+6)..22.  Gap = 6 rows.
'   Gap rows are left blank.  Row 0 = HUD; row 23 = status bar.
'
' Spawn trigger:
'   A new pipe is spawned in the first free slot when the rightmost active
'   pipe left-edge reaches column 14 (~16-col centre-to-centre spacing).
'   Max 3 concurrent pipes.  Speed tuning is deferred to Phase 8.
'
' Compile:  make  (included via src/game/game.bas → src/game/main.bas)
' =============================================================================

#ifndef PIPES_BAS
#define PIPES_BAS

DIM pipeCol(3)    AS INTEGER
DIM pipeGap(3)    AS INTEGER
DIM pipeActive(3) AS INTEGER

' ── Erase 2-wide pipe — blank rows 1–22 across both columns ───────────────────

SUB ErasePipe(slot AS INTEGER)
  DIM r AS INTEGER
  DIM c AS INTEGER
  c = pipeCol(slot)
  IF c >= 0 AND c <= 30 THEN
    FOR r = 1 TO 22
      PRINT PAPER 0; INK 0; AT r, c; "  "   ' two spaces = 2 columns
    NEXT r
  END IF
END SUB

' ── Draw 2-wide pipe at its current left-edge column ─────────────────────────

SUB DrawPipe(slot AS INTEGER)
  DIM r   AS INTEGER
  DIM c   AS INTEGER
  DIM gap AS INTEGER
  c   = pipeCol(slot)
  gap = pipeGap(slot)
  IF c >= 0 AND c <= 30 THEN
    FOR r = 1 TO gap - 1
      PRINT PAPER 0; INK 4; AT r, c; CHR$(143); CHR$(143)
    NEXT r
    FOR r = gap + 6 TO 22                   ' gap is 6 rows tall
      PRINT PAPER 0; INK 4; AT r, c; CHR$(143); CHR$(143)
    NEXT r
  END IF
END SUB

' ── Activate a slot: left edge at col 30, 2 wide → occupies cols 30–31 ────────

SUB SpawnPipe(slot AS INTEGER)
  pipeCol(slot)    = 30
  pipeGap(slot)    = INT(RND * 14) + 2   ' random row 2–15
  pipeActive(slot) = 1
END SUB

' ── Initialise all 3 slots and spawn the first pipe (state only, no draw) ─────

SUB InitPipes()
  DIM i AS INTEGER
  FOR i = 1 TO 3
    pipeActive(i) = 0
    pipeCol(i)    = -1
    pipeGap(i)    = 0
  NEXT i
  SpawnPipe(1)
END SUB

' ── Scroll all active pipes one column left; spawn when spacing allows ─────────

SUB UpdatePipes()
  DIM i        AS INTEGER
  DIM maxCol   AS INTEGER
  DIM freeSlot AS INTEGER
  maxCol   = -1
  freeSlot = 0

  FOR i = 1 TO 3
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

  ' Spawn when rightmost pipe left-edge reaches col 14 (~16-col spacing)
  IF maxCol >= 0 AND maxCol <= 14 AND freeSlot > 0 THEN
    SpawnPipe(freeSlot)
    DrawPipe(freeSlot)
  END IF
END SUB

#endif
