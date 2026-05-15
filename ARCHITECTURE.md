# Architecture — Flappy Speccy

## 1. Hardware Constraints (ZX Spectrum 48K)

| Resource | Limit | Impact on design |
|---|---|---|
| CPU | Z80 @ 3.5 MHz | Every loop iteration is expensive; avoid floating-point |
| RAM | ~40 KB usable | All game state must fit in variables + a small UDG table |
| Screen | 32 × 24 character cells | Bird and pipes are character-cell objects, not pixel objects |
| Attribute grid | 32 × 24, 1 byte/cell | Colour changes per character cell only (not per pixel) |
| UDGs | 21 slots (A–U, address $FF58) | Bird sprite = 1 UDG (8×8 px); pipe tile = block graphic |
| Sound | 48K: `BEEP f, d` only | Monophonic; flap + death sounds only |
| Sound | 128K: AY-3-8912 PSG | 3-channel; music + effects via `OUT` writes (Phase 10) |
| Frame rate | ~50 Hz (PAL) interrupt | Game loop tied to TV frame interrupt for timing |

---

## 2. Coordinate System

```
(0,0) ─────────────────────── (31,0)   ← top
  │                                │
  │   32 cols × 24 rows            │
  │   PRINT AT row, col            │
  │                                │
(0,23) ──────────────────── (31,23)  ← bottom (floor)
```

- **Bird** is tracked as `(birdRow, birdCol)` — fixed column (col 4).
- **Pipes** are tracked as column positions; each pair has a `(topRows, gapStart)`.
- Scroll = pipes move left by 1 column per game tick.

---

## 3. Component Map

```
┌─────────────────────────────────────────────────┐
│                   main.bas                       │
│  Entry point: init → title screen → game loop   │
└────────┬────────────────────────────────────────┘
         │ calls
   ┌─────▼──────┐   ┌────────────┐   ┌───────────────┐
   │  game.bas  │   │ screens.bas│   │  sprites.bas  │
   │  Game loop │   │ Title/over │   │  UDG defs     │
   │  Physics   │   │ Pause      │   │  Pipe tiles   │
   │  Collision │   └────────────┘   └───────────────┘
   │  Score     │
   └────────────┘
```

### Module responsibilities

| File | Status | Responsibility |
|---|---|---|
| `src/game/main.bas` | ✅ done | Bootstrap: load UDGs → CLS → title → map difficulty → `RunGame` loop |
| `src/screens/title.bas` | ✅ done | `ShowTitle(score)` — splash screen, difficulty 1/2/3 selection, sets `selectedDifficulty` |
| `assets/sprites/bird_udg.bas` | ✅ done | `LoadBirdUDG()` — POKEs 8 bytes into UDG slot "A" ("SKY" pixel-art glyph) |
| `src/game/physics.bas` | ✅ done | `InitPhysics()` / `UpdatePhysics(flap%)` — gravity accumulator, velocity clamp, floor/ceiling clamp |
| `src/game/difficulty.bas` | ✅ done | `GetSpeedTier(s)` / `GetBorderColor(s)` — pure difficulty-curve helpers (no I/O) |
| `src/game/game.bas` | ✅ done | `RunGame()` — 50 Hz render loop, 25 Hz physics tick, collision, scoring, HUD, dynamic PAUSE speed, border-tier BORDER, sound, death jingle |
| `src/game/pipes.bas` | ✅ done | `InitPipes()` / `UpdatePipes()` — 3-slot array, 2-col-wide pipes, difficulty-driven gap (`pipeGapSize` 10/8/6); `pipeScored(3)` tracks awarded points |
| `src/game/collision.bas` | ✅ done | `CheckCollision()` — floor sentinel (row ≥ 22) + ATTR-based pipe hit (INK 4 = green) |
| `src/screens/gameover.bas` | ✅ done | `GetMedalRank(score)` (pure, testable) + `ShowGameOver(score)` — medal display, SPACE to retry |
| `assets/sounds/sounds.bas` | ✅ done | `SoundFlap()` / `SoundScore()` / `SoundDie()` — BEEP-based 48K sound effects |
| `assets/sprites/pipe_tiles.bas` | 🔜 planned | Block graphic character selection |

---

## 4. Game State

```basic
DIM birdRow  AS INTEGER   ' current row  (0-22)
DIM birdVel  AS INTEGER   ' vertical velocity (-3 to +3)
DIM score    AS INTEGER   ' pipes cleared
DIM gameOver AS INTEGER   ' 0=playing, 1=dead

' Pipe array — 3 slots max on screen simultaneously
DIM pipeCol(3)         AS INTEGER  ' left-edge column of each pipe
DIM pipeGap(3)         AS INTEGER  ' row where gap starts (2..(22-pipeGapSize))
DIM pipeActive(3)      AS INTEGER  ' 1=active, 0=free slot
DIM pipeGapSize        AS INTEGER  ' gap height: 10=easy / 8=normal / 6=hard

' Difficulty (set on title screen, applied before each RunGame call)
DIM selectedDifficulty AS INTEGER  ' 1=Easy / 2=Normal / 3=Hard
```

---

## 5. Game Loop (pseudocode)

```
LOOP
  WAIT FOR INTERRUPT          ' sync to 50 Hz frame
  READ INPUT (SPACE key)
  UPDATE PHYSICS (gravity + flap)
  SCROLL PIPES LEFT BY 1
  SPAWN NEW PIPE IF NEEDED
  ERASE OLD POSITIONS
  DRAW BIRD + PIPES
  CHECK COLLISION → if hit → game over
  UPDATE SCORE DISPLAY
  INCREASE SPEED EVERY 5 PTS
END LOOP
```

---

## 6. Bird Visual Identity — "SKY" glyph

The game character is called the **bird** throughout the code. Its visual representation is the word **"SKY"** rendered as a pixel-art glyph at 8×8 resolution.

The 8 columns are split across three letters with no inter-letter gaps: **S** (3px) | **K** (3px) | **Y** (2px). One row of padding sits above and below the 5-row letterform.

```
  Row 0:  ........   top padding
  Row 1:  ###.#.##   S top,   K outer, Y both arms
  Row 2:  #..##.##   S left,  K l+mid, Y both arms
  Row 3:  ###.....#  S mid,   K left,  Y stem
  Row 4:  ..###..#   S right, K l+mid, Y stem
  Row 5:  ###.#..#   S bot,   K outer, Y stem
  Row 6:  ........   bottom padding
  Row 7:  ........   empty (breathing room)
```

**Future improvement:** a second UDG slot (B) could extend the glyph to 16px wide for a larger logo treatment, or revert to a traditional bird silhouette. The yellow ink (`INK 6 BRIGHT 1`) already provides strong contrast against the black background.

---

## 7. Rendering Strategy

- **PRINT AT** used for all character-cell drawing (fast, no ROM pixel routines needed).
- **INK/PAPER** attributes colour bird (yellow) and pipes (green) independently.
- **CLS** not called per frame — only erase the exact cells that moved.
- **Border** (`BORDER n`) used for score colour feedback on death.
- **FLASH** attribute applied to bird on collision.

---

## 7. Folder Structure (annotated)

Files marked ✅ exist; 🔜 are planned.

```
spectrum/
├── Makefile                    ✅ Root delegator — delegates to tools/Makefile
├── README.md                   ✅ Project overview, quick start, contributing guide
├── ARCHITECTURE.md             ✅ This file
├── NEXT_STEPS.md               ✅ Implementation plan and phase status
│
├── src/
│   ├── game/
│   │   ├── main.bas            ✅ Entry point: init → title → game loop
│   │   ├── game.bas            ✅ RunGame() — 50 Hz loop, 25 Hz physics, collision check
│   │   ├── physics.bas         ✅ InitPhysics() / UpdatePhysics() — gravity + flap
│   │   ├── pipes.bas           ✅ InitPipes() / UpdatePipes() — scroll, spawn, gap
│   │   ├── difficulty.bas      ✅ GetSpeedTier() / GetBorderColor() — pure difficulty helpers
│   │   └── collision.bas       ✅ CheckCollision() — floor + ATTR pipe hit detection
│   └── screens/
│       ├── title.bas           ✅ Title / start screen with UDG bird, difficulty select
│       └── gameover.bas        ✅ GetMedalRank() + ShowGameOver() — medal, SPACE to retry
│
├── assets/
│   ├── sprites/
│   │   ├── bird_udg.bas        ✅ LoadBirdUDG() — 8 POKE calls into UDG slot "A"
│   │   └── pipe_tiles.bas      🔜 Block graphic selection for pipes
│   └── sounds/
│       └── sounds.bas          ✅ SoundFlap() / SoundScore() / SoundDie() — BEEP effects
│
├── build/                      ✅ Compiler output (.tap) — gitignored
├── dist/                       ✅ Release tape images
├── tools/
│   └── Makefile                ✅ Compiler flags, build and test rules
├── docs/
│   ├── dev-notes.md            ✅ Toolchain decisions, macOS setup, emulator tips
│   └── ai-assistance.md        ✅ Notes on AI-assisted development workflow
└── tests/
    ├── assert_helpers.bas      ✅ Shared AssertEq/GT/LTE/Attr helpers + passed/failed counters
    ├── test_suite.bas          ✅ Menu-driven unified runner (SUITE_MODE compile target)
    ├── test_bird_udg.bas       ✅ UDG memory integrity test (fully automated)
    ├── test_title_render.bas   ✅ Screen attribute test (semi-automated, snapshots before CLS)
    └── test_physics.bas        ✅ Physics unit test (fully automated)
```

---

## 8. Build Pipeline

```
src/**/*.bas
     │
     ▼  zxbc (Boriel ZX BASIC compiler)
build/flappy_speccy.tap        ← two-block TAP: BASIC loader + machine code
     │
     ▼  ZEsarUX emulator (or real hardware via tape)
[running game]
```

Compiler flags (see `tools/Makefile`):

```sh
zxbc src/game/main.bas \
     -f tap          \   # .TAP output (--tap deprecated since zxbasic 1.16)
     -B              \   # prepend BASIC loader block
     -a              \   # autorun loader immediately after load
     --optimize 2    \   # safe optimisation
     --arch zx48k    \   # explicit 48K target
     -o build/flappy_speccy.tap
```

The `-B -a` flags produce a two-block TAP:
- Block 1 — `Program: loader` (type `$00`): BASIC stub that autorun calls `RANDOMIZE USR 32768`
- Block 2 — `Bytes: flappy_spe` (type `$03`): compiled Z80 machine code at address `$8000`

---

## 9. Key ZX Spectrum Memory Addresses

| Address | Hex | Purpose |
|---|---|---|
| 16384 | $4000 | Display file start (pixel data) |
| 22528 | $5800 | Colour attribute file start |
| 65368 | $FF58 | UDG table start (21 × 8 bytes) |
| 23692 | $5C4C | ATTR-P (current attribute for PRINT) |
| 23606 | $5BF6 | UDG base pointer |

---

## 10. ZX BASIC Syntax Notes

```basic
' Variable declaration (typed — avoids slow FP default)
DIM x AS INTEGER

' Print at row, column
PRINT AT 10, 4; CHR$(144)   ' CHR$(144) = UDG "A" (bird sprite)

' Define UDG "A" (bird) — 8 rows of 8 pixels as bytes
FOR i = 0 TO 7: READ b: POKE USR "A" + i, b: NEXT i
DATA 24, 60, 126, 255, 126, 60, 24, 0

' Read keyboard
IF INKEY$ = " " THEN birdVel = -3

' BEEP (frequency Hz, duration seconds)
BEEP 0.05, 880   ' short flap sound
```
