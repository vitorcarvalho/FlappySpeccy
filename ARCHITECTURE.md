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
| `src/game/main.bas` | ✅ done | Bootstrap: load UDGs → title → `DO/RunGame/LOOP` |
| `src/screens/title.bas` | ✅ done | `ShowTitle(score)` — splash screen, high score display, "PRESS SPACE" |
| `assets/sprites/bird_udg.bas` | ✅ done | `LoadBirdUDG()` — POKEs 8 bytes into UDG slot "A" (peacock silhouette) |
| `src/game/physics.bas` | ✅ done | `InitPhysics()` / `UpdatePhysics(flap%)` — gravity accumulator, velocity clamp, floor/ceiling clamp |
| `src/game/game.bas` | ✅ done | `RunGame()` — 50 Hz render loop, 25 Hz physics tick, input latch, death flash |
| `src/game/pipes.bas` | ✅ done | `InitPipes()` / `UpdatePipes()` — 3-slot array, 2-col-wide pipes, 6-row gaps, scroll + spawn |
| `src/game/collision.bas` | 🔜 planned | ATTR-based hit detection (read display attributes) |
| `src/screens/gameover.bas` | 🔜 planned | Game-over splash, medal display |
| `assets/sprites/pipe_tiles.bas` | 🔜 planned | Block graphic character selection |
| `assets/sounds/sounds.bas` | 🔜 planned | Named `BEEP` sequences for events |

---

## 4. Game State

```basic
DIM birdRow  AS INTEGER   ' current row  (0-22)
DIM birdVel  AS INTEGER   ' vertical velocity (-3 to +3)
DIM score    AS INTEGER   ' pipes cleared
DIM gameOver AS INTEGER   ' 0=playing, 1=dead

' Pipe array — up to 4 pipe pairs on screen simultaneously
DIM pipeCol(4)      AS INTEGER  ' column of each pipe pair
DIM pipeGap(4)      AS INTEGER  ' row where gap begins (1-16)
DIM pipeActive(4)   AS INTEGER  ' 1=active, 0=free slot
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

## 6. Bird Visual Identity — Peacock

The game character is called the **bird** throughout the code, but its visual representation is a **Peacock** — front-facing, tail fan fully spread, inspired by the NBC peacock logo.

The fan radiates upward from a narrow body/neck at the bottom. The alternating feather tips in row 0 (X_X_X_X_) capture the iconic NBC pinwheel silhouette at 8×8 pixel resolution.

```
  Row 0:  X_X_X_X_   feather tips (4 tips, alternating)
  Row 1:  _X_X_X__   feather shafts (converging)
  Row 2:  _XXXXXX_   full fan spread
  Row 3:  __XXXX__   fan base narrowing
  Row 4:  ___XX___   neck
  Row 5:  ___XXX__   body / chest
  Row 6:  ____X___   lower body
  Row 7:  ________   empty
```

**Future improvement:** if a second UDG slot (B) is available, print it immediately to the right to extend the fan width. The colour scheme (cyan/green ink) reinforces the peacock identity — consider `INK 5` (cyan) or `INK 4` (green) when the game palette is finalised.

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
│   │   ├── game.bas            ✅ RunGame() — 50 Hz loop, 25 Hz physics, input latch
│   │   ├── physics.bas         ✅ InitPhysics() / UpdatePhysics() — gravity + flap
│   │   ├── pipes.bas           ✅ InitPipes() / UpdatePipes() — scroll, spawn, gap
│   │   └── collision.bas       🔜 Hit detection
│   └── screens/
│       ├── title.bas           ✅ Title / start screen with UDG bird
│       └── gameover.bas        🔜 Game-over screen
│
├── assets/
│   ├── sprites/
│   │   ├── bird_udg.bas        ✅ LoadBirdUDG() — 8 POKE calls into UDG slot "A"
│   │   └── pipe_tiles.bas      🔜 Block graphic selection for pipes
│   └── sounds/
│       └── sounds.bas          🔜 BEEP sequences
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
