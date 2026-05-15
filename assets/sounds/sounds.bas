' =============================================================================
' assets/sounds/sounds.bas
' Sound effects — ZX Spectrum 48K BEEP-based.
'
' Exports:
'   SoundFlap()   — short high chirp played when the bird flaps.
'   SoundScore()  — quick two-note ascending reward when a pipe is cleared.
'   SoundDie()    — descending sweep played on collision / death.
'
' BEEP syntax (ZX Spectrum ROM / Boriel ZX BASIC):
'   BEEP duration, note
'   duration — seconds (floating-point literal; e.g. 0.02 = 20 ms)
'   note     — semitones above middle C (C4 = 0, A4 = 9, A5 = 21)
'
' Semitone reference used here:
'   -12 = C3  (~130 Hz)    0 = C4 (middle C, ~262 Hz)
'    12 = C5  (~523 Hz)   21 = A5  (~880 Hz)
'    24 = C6  (~1047 Hz)
'
' Note: BEEP is synchronous and blocks the game loop while playing.
'   SoundFlap / SoundScore are kept ≤ 20 ms so they don't affect feel.
'   SoundDie is intentionally longer (~0.5 s) — it plays after game-over.
'
' Phase 10 note: gate all AY-based sounds behind #ifdef AY_SOUND here;
'   BEEP stubs remain the 48K path.
'
' Compile:  make  (included via src/game/game.bas → assets/sounds/sounds.bas)
' =============================================================================

#ifndef SOUNDS_BAS
#define SOUNDS_BAS

' ── Flap chirp — single short high note ──────────────────────────────────────
' A5 = 21 semitones above middle C ≈ 880 Hz.  Duration 0.02 s (1 frame @ 50 Hz).

SUB SoundFlap()
  BEEP 0.02, 21
END SUB

' ── Score reward — two ascending notes ───────────────────────────────────────
' C5 (12) → G5 (19): a rising perfect-fifth fanfare lasting ~0.1 s total.
' Kept short so it doesn't delay the frame after a pipe is cleared.

SUB SoundScore()
  BEEP 0.05, 12   ' C5
  BEEP 0.05, 19   ' G5
END SUB

' ── Death jingle — descending chromatic sweep ─────────────────────────────────
' Sweeps from A5 (21 semitones) down to C3 (-12 semitones) in steps of 3.
' 12 steps × 0.04 s ≈ 0.48 s — plays after collision, before game-over screen.

SUB SoundDie()
  DIM n AS INTEGER
  FOR n = 21 TO -12 STEP -3
    BEEP 0.04, n
  NEXT n
END SUB

#endif
