' =============================================================================
' assets/sounds/sounds.bas
' Sound effects — ZX Spectrum 48K BEEP-based.
'
' Exports:
'   soundMuted    — INTEGER global; 1 = muted (default), 0 = unmuted.
'                   Set by the launcher menu option 3 (toggle).
'                   All SUBs check this flag and short-circuit when muted.
'   SoundFlap()   — short high chirp played when the bird flaps.
'   SoundScore()  — quick two-note ascending reward when a pipe is cleared.
'   SoundDie()    — descending sweep on death; falls back to PAUSE 25 when muted
'                   so the death-flash timing is preserved regardless of mute state.
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

' ── Mute flag ─────────────────────────────────────────────────────────────────
' 1 = muted (default — avoids surprise noise on first launch).
' Toggled by the M key on the title screen: soundMuted = 1 - soundMuted.

DIM soundMuted AS INTEGER : soundMuted = 1

' ── Flap chirp — single short high note ──────────────────────────────────────
' A5 ~ 880 Hz.
' 48K:  BEEP 0.02 s.
' 128K: AY Ch A period 126 (fine=126, coarse=0), 1 frame PAUSE, then silence.

SUB SoundFlap()
  IF soundMuted = 0 THEN
    #ifdef AY_SOUND
    OUT 65533, 0 : OUT 49149, 126  ' Ch A fine period  (A5 ~ 880 Hz, period=126)
    OUT 65533, 1 : OUT 49149, 0    ' Ch A coarse period
    OUT 65533, 7 : OUT 49149, 62   ' mixer: tone A only ($3E = 0b00111110)
    OUT 65533, 8 : OUT 49149, 15   ' Ch A volume: max (15)
    PAUSE 1                         ' ~20 ms (1 frame @ 50 Hz)
    OUT 65533, 8 : OUT 49149, 0    ' silence: Ch A volume = 0
    #endif
    #ifndef AY_SOUND
    BEEP 0.02, 21                   ' A5, 20 ms
    #endif
  END IF
END SUB

' ── Score reward — two ascending notes ───────────────────────────────────────
' C5 (12) -> G5 (19): rising perfect-fifth fanfare, ~0.1 s total.
' 48K:  two BEEPs.  128K: AY two-tone sequence on Ch A.

SUB SoundScore()
  IF soundMuted = 0 THEN
    #ifdef AY_SOUND
    OUT 65533, 7 : OUT 49149, 62   ' mixer: tone A only
    OUT 65533, 0 : OUT 49149, 212  ' C5 ~ 523 Hz, period=212 (fine)
    OUT 65533, 1 : OUT 49149, 0    ' coarse=0
    OUT 65533, 8 : OUT 49149, 15   ' volume max
    PAUSE 3                         ' ~60 ms
    OUT 65533, 8 : OUT 49149, 0
    OUT 65533, 0 : OUT 49149, 141  ' G5 ~ 784 Hz, period=141 (fine)
    OUT 65533, 1 : OUT 49149, 0    ' coarse=0
    OUT 65533, 8 : OUT 49149, 15   ' volume max
    PAUSE 3                         ' ~60 ms
    OUT 65533, 8 : OUT 49149, 0    ' silence
    #endif
    #ifndef AY_SOUND
    BEEP 0.05, 12   ' C5
    BEEP 0.05, 19   ' G5
    #endif
  END IF
END SUB

' ── Death jingle — descending chromatic sweep ─────────────────────────────────
' 48K:  12 BEEP steps from A5 (+21) down to C3 (-12), step -3. ~0.48 s.
' 128K: AY Ch A, 12 steps. Period starts at 126 (A5) and multiplies by
'       1189/1000 per step (one minor third = 2^(3/12) ~ 1.189), descending.
'       12 x PAUSE 2 ~ 0.48 s — matches 48K timing.
' When muted: PAUSE 25 preserves the death-flash gap regardless of build.

SUB SoundDie()
  DIM n      AS INTEGER   ' 48K semitone loop counter
  DIM ayStep AS INTEGER   ' 128K step counter
  DIM ayP    AS INTEGER   ' 128K period accumulator
  IF soundMuted = 1 THEN
    PAUSE 25   ' ~0.5 s death pause even when silent
  ELSE
    #ifdef AY_SOUND
    OUT 65533, 7 : OUT 49149, 62   ' mixer: tone A only
    ayP = 126                       ' start at A5 (~880 Hz)
    FOR ayStep = 1 TO 12
      OUT 65533, 0 : OUT 49149, ayP AND 255   ' fine period byte
      OUT 65533, 1 : OUT 49149, ayP / 256     ' coarse period byte
      OUT 65533, 8 : OUT 49149, 15            ' volume max
      PAUSE 2                                  ' ~40 ms per step
      OUT 65533, 8 : OUT 49149, 0             ' silence
      ayP = (ayP * 1189) / 1000               ' descend one minor third
    NEXT ayStep
    #endif
    #ifndef AY_SOUND
    FOR n = 21 TO -12 STEP -3
      BEEP 0.04, n
    NEXT n
    #endif
  END IF
END SUB

#endif
