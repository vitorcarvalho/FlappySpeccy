# Next Steps — Implementation Plan

Status: **POC complete. Splash screen runs. Unit test framework in place.**

---

## Phase 0 — Environment Setup ✅ DONE

- [x] **Install Boriel ZX BASIC SDK**
  ```sh
  pip install zxbasic          # Python package
  zxbc --version               # verify
  ```

- [x] **Install ZEsarUX emulator** — download from https://github.com/chernandezba/zesarux/releases
  - macOS: copy `ZEsarUX.app` to `~/Applications/`
  - If Gatekeeper blocks it: `xattr -dr com.apple.quarantine ~/Applications/ZEsarUX.app`

- [x] **Verify toolchain** — `make && make run` → splash screen loads

---

## Phase 1 — Skeleton + Build System ✅ DONE

- [x] `src/game/main.bas` — entry point with screen init and module calls
- [x] `tools/Makefile` — compiler flags, `make`, `make run`, `make tests`, `make run-test-*`
- [x] Root `Makefile` — delegates all targets to `tools/Makefile`

---

## Phase 2 — UDG Bird Sprite + Title Screen ✅ DONE

- [x] `assets/sprites/bird_udg.bas` — `LoadBirdUDG()` SUB with 8 explicit POKE calls
- [x] `src/screens/title.bas` — `ShowTitle()` SUB: splash screen with UDG bird, colours, "PRESS SPACE"
- [x] Title renders correctly in ZEsarUX — SPACE advances to "COMING SOON" placeholder

---

## Phase 2b — Unit Tests ✅ DONE

- [x] `tests/test_bird_udg.bas` — fully automated; PEEKs all 8 UDG bytes, green PASS on screen
- [x] `tests/test_title_render.bas` — semi-automated; renders title then checks 6 attribute cells
- [x] `make tests` — compiles both test TAPs from repo root
- [x] `make run-test-bird-udg` / `make run-test-title-render` — launches each test in emulator

---

## Phase 3 — Physics (Gravity + Flap)

**Goal:** bird falls, SPACE makes it rise.

- [ ] Create `src/game/physics.bas`:
  - `birdRow`, `birdVel` as INTEGER variables.
  - Each tick: `birdVel = birdVel + 1` (gravity = +1 row/tick).
  - `birdRow = birdRow + birdVel` (clamped to 1–22).
  - On SPACE: `birdVel = -3`.

- [ ] Tie loop to a `PAUSE 1` per iteration (~50 ms).
- [ ] Test: bird should fall naturally, flap on key press.

---

## Phase 4 — Pipes

**Goal:** green pipe columns scroll from right to left.

- [ ] Create `src/game/pipes.bas`:
  - Maintain array of 4 pipe pairs: `pipeCol()`, `pipeGap()`.
  - Each tick: decrement `pipeCol(i)` by 1.
  - Spawn new pipe at col 31 when rightmost pipe reaches col 24.
  - Gap position: `pipeGap(i) = INT(RND * 14) + 2` (rows 2–16).
  - Draw with block graphics `\::` (solid block) for pipe body.

- [ ] Erase pipe characters at old column before drawing at new column.
- [ ] Gap height = 4 rows (constant).

---

## Phase 5 — Collision Detection

**Goal:** game ends when bird hits a pipe or floor/ceiling.

- [ ] Create `src/game/collision.bas`:
  - After drawing, read attribute at bird's cell:
    ```basic
    DIM attr AS UBYTE
    attr = PEEK (22528 + birdRow * 32 + birdCol)
    IF (attr AND 7) = 4 THEN gameOver = 1  ' INK=GREEN = pipe
    ```
  - Floor: `IF birdRow >= 23 THEN gameOver = 1`
  - Ceiling: `IF birdRow <= 0 THEN gameOver = 1`

- [ ] On death: `FLASH 1`, `BEEP 0.5, 200`, transition to game-over screen.

---

## Phase 6 — Screens & Score

**Goal:** title screen, in-game score, game-over screen with medal.

- [ ] Create `src/screens/title.bas`:
  - ASCII art title, "PRESS SPACE TO START", high score.

- [ ] Create `src/screens/gameover.bas`:
  - "GAME OVER", final score, bronze/silver/gold/platinum medal
    (≥10 / ≥20 / ≥30 / ≥40 points — matching original Flappy Bird).
  - Prompt: "PRESS SPACE TO RETRY".

- [ ] Score display: `PRINT AT 0, 13; score` (top-centre, bright white).

---

## Phase 7 — Sound

**Goal:** flap sound, death jingle.

- [ ] Create `assets/sounds/sounds.bas`:
  ```basic
  SUB SoundFlap()
    BEEP 0.02, 880
  END SUB

  SUB SoundDie()
    FOR f = 800 TO 100 STEP -50: BEEP 0.02, f: NEXT f
  END SUB
  ```

---

## Phase 8 — Polish & Difficulty Curve

- [ ] Increase pipe scroll speed every 5 points (reduce `PAUSE` delay).
- [ ] Add border colour change as speed tier indicator.
- [ ] Persist high score across game sessions (POKE to a known RAM address).
- [ ] Optimise render loop — profile with FUSE's built-in profiler.

---

## Phase 9 — Packaging

- [ ] Build final `.tap` and `.tzx` tape images into `dist/`.
- [ ] Verify on real hardware (or ZXSpin for Windows) if possible.
- [ ] Write `docs/references.md` with final memory map, UDG layout, variable table.

---

## Testing Approach

| Test | File | Status | How |
|---|---|---|---|
| UDG memory integrity | `tests/test_bird_udg.bas` | ✅ done | Fully automated PEEK assertions |
| Title screen attributes | `tests/test_title_render.bas` | ✅ done | Semi-automated attribute-sniffing |
| Physics unit test | `tests/test_physics.bas` | 🔜 planned | Standalone `.bas` that prints position each tick |
| Pipe spawning | `tests/test_pipes.bas` | 🔜 planned | Print pipe state each frame to verify spacing |
| Collision accuracy | `tests/test_collision.bas` | 🔜 planned | Place bird adjacent to known pipe, assert death triggers |
| Full play-through | Manual | 🔜 planned | Load release `.tap`, play to score ≥ 10 |

---

## Useful Commands

```sh
make                           # compile game
make run                       # compile + launch emulator
make tests                     # compile all test TAPs
make run-test-bird-udg         # run UDG byte test in emulator
make run-test-title-render     # run title attribute test in emulator
make clean                     # remove build artefacts
zxbc src/game/main.bas -h      # compiler help
```
