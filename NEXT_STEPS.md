# Next Steps — Implementation Plan

Status: **Phase 6 complete. Scoring, HUD, game-over screen with medals live. Unified test suite covers 6 modules.**

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

- [x] `tests/assert_helpers.bas` — shared `AssertEq`, `AssertGT`, `AssertLTE`, `AssertAttr` + `passed`/`failed` counters; include-guarded
- [x] `tests/test_bird_udg.bas` — fully automated; PEEKs all 8 UDG bytes; wrapped in `RunTestBirdUDG()` SUB
- [x] `tests/test_title_render.bas` — semi-automated; snapshots attributes **before** `CLS` to avoid overwrite; wrapped in `RunTestTitleRender()` SUB
- [x] `tests/test_physics.bas` — fully automated; 5 assertions (init, gravity, flap, vel clamp, floor clamp); wrapped in `RunTestPhysics()` SUB
- [x] `tests/test_suite.bas` — menu-driven unified runner; `#define SUITE_MODE` suppresses standalone entry points; press 1/2/3 to run, any key to return to menu
- [x] `make tests` — compiles all 4 TAPs from repo root
- [x] `make run-test-suite` / `make run-test-bird-udg` / `make run-test-title-render` / `make run-test-physics`

---

## Phase 3 — Physics (Gravity + Flap) ✅ DONE

- [x] `src/game/physics.bas` — `InitPhysics()`, `UpdatePhysics(flap%)`; global `birdRow`, `birdVel`, `birdCol`
  - Each tick: `birdVel = birdVel + 1` (gravity); clamped to `[-3, +3]`
  - `birdRow = birdRow + birdVel`; clamped to `[1, 22]`
  - On flap: `birdVel = -3`
- [x] `src/game/game.bas` — `RunGame()` with 50 Hz `PAUSE 1` loop; SPACE = flap, Q = quit; floor hit = red flash then return to title
- [x] `src/game/main.bas` — updated to `DO / ShowTitle / RunGame / LOOP`
- [x] Physics verified in emulator — bird falls, flap works, floor clamped

---

## Phase 4 — Pipes ✅ DONE

**Goal:** green pipe columns scroll from right to left.

- [x] Create `src/game/pipes.bas`:
  - 3-slot arrays: `pipeCol(3)`, `pipeGap(3)`, `pipeActive(3)`.
  - `InitPipes()` — reset all slots; spawn slot 1 (state only, no draw).
  - `SpawnPipe(slot)` — set col=30, gap row driven by `pipeGapSize`.
  - `ErasePipe(slot)` / `DrawPipe(slot)` — blank or render CHR$(143) in INK 4.
  - `UpdatePipes()` — erase → decrement → deactivate if col<0, else draw → spawn trigger.
- [x] Pipes 2 columns wide; spawn when rightmost pipe reaches col 14.
- [x] `src/game/game.bas` — 50 Hz pipe scroll, 25 Hz physics tick (bird speed).
- [x] `tests/test_pipes.bas` — automated assertions: init state, gap bounds, spawn state.
- [x] Pipes verified in emulator — green columns scroll left, gaps random each spawn.

---

## Phase 4b — Difficulty Selection ✅ DONE

**Goal:** player chooses gap size from the title screen before each round.

- [x] `src/game/pipes.bas` — `pipeGapSize` global (default 8); `DrawPipe`/`SpawnPipe` use it.
  - Gap formula: `INT(RND * (21 - pipeGapSize)) + 2` → range `2 .. (22 - pipeGapSize)`.
  - Easy=10 rows (2–12), Normal=8 rows (2–14), Hard=6 rows (2–16).
- [x] `src/screens/title.bas` — `selectedDifficulty` global; rows 15+17 show key guide and
  live selection indicator; 1/2/3 keys cycle; SPACE confirms.
- [x] `src/game/main.bas` — CLS before each round; maps `selectedDifficulty` → `pipeGapSize`.
- [x] `tests/test_pipes.bas` — 3 new difficulty bound groups (Easy/Normal/Hard), 11 total assertions.
- [x] `tests/test_title_render.bas` — 2 new attribute assertions (rows 15+17).

---

## Phase 5 — Collision Detection ✅ DONE

**Goal:** game ends when bird hits a pipe or floor/ceiling.

- [x] Created `src/game/collision.bas` — `CheckCollision() AS INTEGER`:
  - Floor sentinel: `IF birdRow >= 22 THEN hit = 1`
  - ATTR-based pipe hit (checked BEFORE drawing the bird to avoid false positives):
    ```basic
    attr     = PEEK(22528 + birdRow * 32 + birdCol)
    inkColor = attr BAND 7   ' BAND = bitwise AND; plain AND is logical in Boriel BASIC
    IF inkColor = 4 THEN hit = 1   ' INK 4 = green = pipe
    ```
- [x] Integrated `CheckCollision()` into `game.bas` — replaces the old floor-only guard.
- [x] Created `tests/test_collision.bas` — 4 automated assertions (safe/floor/pipe/clear).
- [x] Added option 5 to the test suite menu (`test_suite.bas`).
- [x] Added `run-test-collision` Makefile target.
- [x] Fixed transitive Makefile dependency: `ALL_BAS` wildcard covers all `.bas` files.

---

## Phase 6 — Screens & Score ✅ DONE

**Goal:** in-game score, HUD, game-over screen with medal.

- [x] `src/game/pipes.bas` — added `pipeScored(3)` array; reset on `InitPipes` and `SpawnPipe`.
- [x] `src/screens/gameover.bas` — `GetMedalRank(score AS INTEGER) AS INTEGER` (pure, testable):
  - Thresholds: ≥40 = Platinum (4), ≥30 = Gold (3), ≥20 = Silver (2), ≥10 = Bronze (1), else 0.
  - `ShowGameOver(score)` — renders "GAME OVER", score, medal name with colour, flashing retry prompt.
- [x] `src/game/game.bas` — `score` declared as global INTEGER; scoring loop after each `UpdatePipes()`:
  - Pipe cleared when `pipeCol(i) <= 2` (bird at col 4); `pipeScored` prevents double-award.
  - HUD row 0: `SPC=FLAP` (col 0) | score (col 14, bright yellow) | `Q=QUIT` (col 25).
- [x] `src/game/main.bas` — `highScore` updated after each `RunGame()`; `ShowGameOver(score)` called before next title.
- [x] `tests/test_gameover.bas` — 7 automated boundary assertions for `GetMedalRank`.
- [x] `tests/test_suite.bas` — option **6 GAME OVER** added to menu.
- [x] `make run-test-gameover` target added to both Makefiles.

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

## Phase 10 — ZX Spectrum 128K Support

**Goal:** leverage the AY-3-8912 sound chip and distribute a dedicated 128K build alongside the 48K release. The 48K TAP must remain fully functional and unmodified.

- [ ] **AY sound module** — create `assets/sounds/sounds.bas`:
  - Gate all implementations behind `#ifdef AY_SOUND`.
  - 48K path: `BEEP`-based stubs (already planned in Phase 7).
  - 128K path: AY register writes via `OUT` to ports `0xFFFD` (register select) and `0xBFFD` (register data).
  - Expose the same SUB signatures in both paths — `SoundFlap()`, `SoundDie()`, `SoundScore()` — so call sites in `game.bas` are build-flag agnostic.

- [ ] **Conditional compilation** — add `-D AY_SOUND` flag to the 128K build only:
  ```sh
  zxbc src/game/main.bas -f tap -B -a --optimize 2 --arch zx48k -D AY_SOUND -o build/flappy_speccy_128.tap
  ```
  No runtime `IF` checks — the flag resolves at compile time via `#ifdef`.

- [ ] **Makefile targets** — extend `tools/Makefile`:
  - `make build-128k` — compiles the 128K TAP with `-D AY_SOUND`.
  - `make run-128k` — launches ZEsarUX with `--machine 128k` and the 128K TAP.
  - `make dist` — copies both `flappy_speccy.tap` (48K) and `flappy_speccy_128.tap` (128K) to `dist/`.

- [ ] **AY timing** — AY register writes must complete outside the tight game loop to avoid frame-rate impact. Use a dedicated sound-update SUB called once per physics tick (25 Hz), not per render frame.

- [ ] **Verify compatibility**:
  - 48K TAP: loads and runs on 48K hardware and in 128K → 48 BASIC mode.
  - 128K TAP: loads and runs in 128K mode with AY audio active.
  - Both verified in ZEsarUX (`--machine 48k` and `--machine 128k`).

- [ ] **Update `dist/` manifest** — document which TAP targets which hardware in `docs/references.md`.

---

## Testing Approach

| Test | File | Status | How |
|---|---|---|---|
| Unified suite | `tests/test_suite.bas` | ✅ done | Menu-driven runner; all tests from one TAP |
| UDG memory integrity | `tests/test_bird_udg.bas` | ✅ done | Fully automated PEEK assertions |
| Title screen attributes | `tests/test_title_render.bas` | ✅ done | Semi-automated; attributes snapshot before `CLS` |
| Physics unit test | `tests/test_physics.bas` | ✅ done | Fully automated; gravity, flap, clamp assertions |
| Pipe spawning | `tests/test_pipes.bas` | ✅ done | Fully automated; init state, gap bounds, spawn assertions |
| Collision accuracy | `tests/test_collision.bas` | ✅ done | Automated: safe/floor/POKE-green/POKE-clear — 4 assertions |
| Medal ranks | `tests/test_gameover.bas` | ✅ done | Automated: boundary values 0/9/10/20/30/40/50 — 7 assertions |
| Full play-through | Manual | 🔜 planned | Load release `.tap`, play to score ≥ 10 |

---

## Useful Commands

```sh
make                           # compile game
make run                       # compile + launch emulator
make tests                     # compile all test TAPs
make run-test-suite            # run all tests via the menu-driven TAP
make run-test-bird-udg         # run UDG byte test standalone
make run-test-title-render     # run title attribute test standalone
make run-test-physics          # run physics test standalone
make run-test-pipes            # run pipe spawn/state test standalone
make run-test-collision        # run collision detection test standalone
make run-test-gameover         # run medal rank test standalone
make clean                     # remove build artefacts
zxbc src/game/main.bas -h      # compiler help
```
