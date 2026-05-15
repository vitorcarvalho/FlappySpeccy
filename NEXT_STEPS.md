# Next Steps — Implementation Plan

Status: **Phase 8 complete. Dynamic speed scaling + border-tier indicator live. Unified test suite covers 8 modules.**

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
- [x] `tests/test_physics.bas` — fully automated; 6 assertions (init, gravity, flap, vel clamp, floor clamp, ceiling clamp); wrapped in `RunTestPhysics()` SUB
- [x] `tests/test_suite.bas` — menu-driven unified runner; `#define SUITE_MODE` suppresses standalone entry points; press 1/2/3 to run, any key to return to menu
- [x] `make tests` — compiles all 4 TAPs from repo root
- [x] `make run-test-suite` / `make run-test-bird-udg` / `make run-test-title-render` / `make run-test-physics`

---

## Phase 3 — Physics (Gravity + Flap) ✅ DONE

- [x] `src/game/physics.bas` — `InitPhysics()`, `UpdatePhysics(flap%)`; global `birdRow`, `birdVel`, `birdCol`
  - Each tick: `birdVel = birdVel + 1` (gravity); clamped to `[-3, +3]`
  - `birdRow = birdRow + birdVel`; clamped to `[2, 22]` (row 1 = white ceiling bar)
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
- [x] `tests/test_title_render.bas` — 2 new attribute assertions (rows 15+17); row 21 mute indicator added (9 total).

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

## Phase 7 — Sound ✅ DONE

**Goal:** flap sound, score reward, death jingle.

- [x] Created `assets/sounds/sounds.bas`:
  - `SoundFlap()` — single high chirp (A5 = 21 semitones, 20 ms); plays on each flap.
  - `SoundScore()` — two-note ascending fanfare (C5→G5, 50 ms each); plays when a pipe is cleared.
  - `SoundDie()` — descending chromatic sweep (A5 to C3 in steps of 3, ~0.48 s); replaces the old `PAUSE 25` death delay.
- [x] `src/game/game.bas` — `#include "../../assets/sounds/sounds.bas"`; three call sites integrated:
  - `SoundFlap()` inside the physTick block when `flapPending = 1` (fires on actual physics frame).
  - `SoundScore()` inside the scoring loop immediately after score increment.
  - `SoundDie()` replaces `PAUSE 25` in the death-flash section.
- [x] `tests/test_sound.bas` — 3 automated smoke assertions (set-flag → call → assert-flag=1 pattern).
- [x] `tests/test_suite.bas` — option **7 SOUND** added to menu.
- [x] `make run-test-sound` target added to both Makefiles.

> **BEEP note:** ZX Spectrum `BEEP duration, note` takes note in *semitones above middle C* (not Hz).
> Middle C = 0, A4 = 9, A5 = 21.  The plan's `BEEP 0.02, 880` used frequency notation and has been
> corrected to semitone values.  See `docs/dev-notes.md` §9 for the `AND`/`BAND` lesson — the same
> "check the ZX Spectrum ROM convention" discipline applies here.

---

## Phase 8 — Polish & Difficulty Curve ✅ DONE

- [x] **Dynamic speed** — `GetSpeedTier(score)` in `src/game/difficulty.bas` returns PAUSE delay 4→1.
  - Every 5 points scored, delay drops by 1 (floor = 1).
  - `RunGame()` initialises `pauseDelay = 4`; updates it in the scoring loop via `GetSpeedTier(score)`.
  - `PAUSE pauseDelay` replaces the fixed `PAUSE 1` in the game loop.
- [x] **Border tier indicator** — `GetBorderColor(score)` returns a ZX border colour index.
  - Tiers: black (0–9) → blue (10–19) → magenta (20–29) → yellow (30–39) → red (40+).
  - `BORDER borderColor` called immediately after each point is scored.
  - `BORDER 0` reset after game over so title/game-over screen is clean.
- [x] **High score persistence** — already in `main.bas`; `highScore` variable is updated after each
  `RunGame()` call and passed to `ShowTitle(highScore)` which renders it on the title screen.
  Persists for the full session (48K has no filesystem; in-RAM is the correct approach).
- [x] `src/game/difficulty.bas` **new** — pure module; both functions are pure (no I/O) so the
  test can include it in isolation without pulling in the full game-loop dependency chain.
- [x] `tests/test_difficulty_curve.bas` **new** — 19 boundary assertions:
  - 9 for `GetSpeedTier` (including clamp at 15 and 20)
  - 10 for `GetBorderColor` (boundary pairs for every tier transition)
- [x] `tests/test_suite.bas` — option **8 DIFFICULTY CURVE** added to menu.
- [x] `make run-test-difficulty-curve` target added to both Makefiles.

---

## Boundary Bars (Ceiling & Floor) ✅ DONE

**Goal:** Make the play-area limits visually obvious so the bird cannot appear to fly off-screen.

- [x] `src/game/game.bas` — draws 32 white solid-block chars (`CHR$(143)`, `INK 7 BRIGHT 1`) at row 1 (ceiling) and row 23 (floor) after `CLS`. Drawn once per session; never erased.
- [x] `src/game/physics.bas` — ceiling clamp tightened from row 1 → row 2 so the bird never enters the ceiling bar. Floor clamp unchanged (row 22 = last play row, one above the floor bar at 23).
- [x] `src/game/pipes.bas` — `ErasePipe` changed from `FOR r = 1 TO 22` → `FOR r = 2 TO 22`; `DrawPipe` top body changed from `FOR r = 1 TO gap-1` → `FOR r = 2 TO gap-1`. Ceiling bar is never overwritten by a scrolling pipe.
- [x] `tests/test_physics.bas` — Test 6 added: ceiling clamp — 10 consecutive flap ticks → `birdRow >= 2` (total 6 assertions).

**Screen zone map after this change:**

| Row | Zone |
|---|---|
| 0 | HUD (`SPC=FLAP` · score · `Q=QUIT`) |
| 1 | **Ceiling bar** — white solid blocks |
| 2–22 | Play area — bird, pipes, open air |
| 23 | **Floor bar** — white solid blocks |

---

## Mute / Unmute ✅ DONE

**Goal:** Let the player silence all sound effects without restarting; default to muted so first launch is quiet.

- [x] `assets/sounds/sounds.bas` — `DIM soundMuted AS INTEGER : soundMuted = 1` (global, muted by default).
  Each SUB checks the flag: `SoundFlap`/`SoundScore` skip `BEEP` when `soundMuted = 1`.
  `SoundDie` falls back to `PAUSE 25` (~0.5 s) when muted so the death-flash timing is preserved.
- [x] `src/screens/title.bas` — **M key** toggles mute on the title/start screen (row 21, col 12).
  Colour-coded: INK 3 (magenta) `M=MUTE  ` when muted, INK 4 (green) `M=UNMUTE` when on.
  Toggle: `soundMuted = 1 - soundMuted`; row redrawn in-place, no full CLS.
  `src/game/launcher.bas` reverted to 2-option menu — mute control belongs on the title screen.
- [x] `tests/test_sound.bas` — 4 new assertions (total: 7):
  - Test 4: `soundMuted` defaults to 1.
  - Test 5: toggle 1 → 0 (unmute).
  - Test 6: toggle 0 → 1 (re-mute).
  - Test 7: `SoundFlap()` callable and returns when unmuted (you hear one chirp).
- [x] `tests/test_suite.bas` — option 7 label updated to **7 SOUND+MUTE (auto)**.

---

## Phase 10 — ZX Spectrum 128K Support ✅ DONE

**Goal:** leverage the AY-3-8912 sound chip and distribute a dedicated 128K build alongside the 48K release. The 48K TAP must remain fully functional and unmodified.

- [x] **AY sound module** — `assets/sounds/sounds.bas` updated with dual path:
  - `#ifdef AY_SOUND` block: `OUT 65533`/`OUT 49149` writes to AY registers 0/1/7/8 (Channel A tone period, mixer, volume).
  - `#ifndef AY_SOUND` block: existing `BEEP`-based stubs (48K path — unchanged).
  - Same SUB signatures in both paths (`SoundFlap()`, `SoundDie()`, `SoundScore()`) — call sites in `game.bas` are build-flag agnostic.
  - `SoundDie` 128K: period starts at 126 (A5) and multiplies by 1189/1000 per step × 12 steps ≈ 0.48 s (matches 48K timing).

- [x] **Conditional compilation** — `-D AY_SOUND` flag added to 128K build only:
  ```sh
  zxbc src/game/main.bas -f tap -B -a --optimize 2 --arch zx48k -D AY_SOUND -o build/flappy_speccy_128.tap
  ```
  No runtime `IF` checks — the flag resolves at compile time via `#ifdef`/`#ifndef`.

- [x] **Makefile targets** — `tools/Makefile` extended:
  - `make build-128k` — compiles the 128K game TAP with `-D AY_SOUND`.
  - `make run-128k` — launches ZEsarUX with `--machine 128k` and the 128K TAP.
  - `make build-launcher-128k` / `make run-launcher-128k` — 128K launcher variants.
  - `make run-test-sound-128k` — compiles `tests/test_sound_128.bas` with `-D AY_SOUND`; runs on `--machine 128k`.
  - `make dist` — copies both `flappy_speccy.tap` (48K) and `flappy_speccy_128.tap` (128K) to `dist/`.

- [x] **AY timing** — all AY register writes are discrete PAUSE-separated steps outside the game loop; each sound SUB completes before returning to the caller (same contract as BEEP). The `SoundFlap`/`SoundScore` SUBs remain ≤ 6 PAUSE frames (~120 ms); only `SoundDie` is intentionally long (~0.48 s, after collision).

- [x] **Verify compatibility** — both builds compiled cleanly with zero errors:
  - 48K TAP: `make build` passes. 48K BEEP path unchanged.
  - 128K TAP: `make build-128k` passes. AY OUT writes are harmless no-ops on 48K hardware.

- [x] **Test** — `tests/test_sound_128.bas` (standalone, compiled with `-D AY_SOUND`): 7 assertions matching `test_sound.bas` — 3 callability smoke tests + 4 mute-flag assertions. Not in `test_suite` (requires separate compile flag).

- [ ] **`docs/references.md`** — TAP manifest deferred to Phase 11 (Packaging).

---

## Phase 11 — Packaging

- [ ] Build final `.tap` and `.tzx` tape images into `dist/`.
- [ ] Verify on real hardware (or ZXSpin for Windows) if possible.
- [ ] Write `docs/references.md` with final memory map, UDG layout, variable table.

---

## Optional Improvements

These are standalone, independently implementable polish items. None are required for a shippable game.
Each item is tagged: **[UI/UX]** for visual/interaction changes, **[CODE]** for refactors and structural changes.

---

### Visual — Tier 1 (High impact, small change)

- [ ] **[UI/UX] Coloured boundary bars** — change ceiling (row 1) to `INK 1 BRIGHT 1` (bright blue = sky) and floor (row 23) to `INK 4 BRIGHT 0` (green = ground). 2-line change in `game.bas`. Instantly communicates world context.

- [ ] **[UI/UX] Bird flap animation** — define a second UDG in slot `B` (`CHR$(145)`) with wings in the "up" position. Alternate `CHR$(144)` / `CHR$(145)` on each flap press in `game.bas`. Files: `assets/sprites/bird_udg.bas`, `game.bas`.

- [ ] **[UI/UX] Pipe caps** — draw the two rows adjacent to the gap (`gap-1` and `gap+pipeGapSize`) with `BRIGHT 1` while keeping the pipe body at `BRIGHT 0`. Same `CHR$(143)` character; the luminance jump reads as a wider cap — the signature Flappy Bird look. File: `pipes.bas`.

- [ ] **[UI/UX] HUD coloured background** — set `PAPER 1` (blue) on row 0 to separate the status bar from the play area. 3-line change in `game.bas`.

### Visual — Tier 2 (Polish)

- [ ] **[UI/UX] Score flash on increment** — apply `FLASH 1` to the score cell for one frame when a point is scored, then `FLASH 0`. Hardware-driven at zero CPU cost. File: `game.bas`.

- [ ] **[UI/UX] Redesign bird UDG as actual bird silhouette** — replace the current "SKY" text-art with a recognisable bird shape (body + beak + tail) in 8×8 pixels. File: `assets/sprites/bird_udg.bas`; update `test_bird_udg.bas` byte assertions.

- [ ] **[UI/UX] Title screen decorative frame** — print a border of solid block characters (`CHR$(143)`) or `=` in a contrasting colour around the content area (rows 0/23, cols 0/31). File: `title.bas`.

- [ ] **[UI/UX] Difficulty options colour-coded** — colour each option in the key guide independently: `1=EASY` in green (`INK 4`), `2=NORMAL` in yellow (`INK 6`), `3=HARD` in red (`INK 2`). Matches the border-tier colour language already in the game. File: `title.bas`.

- [ ] **[UI/UX] Bird sprite on Game Over screen** — print the bird UDG (`CHR$(144)`) in red (`INK 2 FLASH 1`) on the game-over screen before the score, then clear the flash. File: `gameover.bas`.

### Visual — Tier 3 (Bigger effort)

- [ ] **[UI/UX] Animated title screen birds** — cycle the three `CHR$(144)` birds on row 7 through `INK` colours or alternate with `CHR$(145)` (wings-up UDG) inside the `DO/LOOP UNTIL k=" "` wait loop. File: `title.bas`.

- [ ] **[UI/UX] Screen wipe transition on death** — column-by-column `PAPER 0 INK 0` sweep from left to right before `CLS` on game over. Cinematic pause before the game-over screen. Files: `game.bas`, `gameover.bas`.

- [ ] **[UI/UX] Scrolling star/cloud background** — sparse `·` characters in `INK 7 BRIGHT 0` scrolling slower than pipes using `OVER 1` (XOR) mode to avoid attribute clash. Requires a separate background position array and careful timing. File: new `background.bas` module.

---

### Code — Tier 1 (Shrinks code, no behaviour change)

- [ ] **[CODE] Boundary bars: `STRING$` instead of a 32-step loop** — replace the `FOR bc = 0 TO 31` loop in `game.bas` with two single-line PRINTs:
  ```bas
  PRINT INK 7; BRIGHT 1; PAPER 0; AT 1,  0; STRING$(32, CHR$(143));
  PRINT INK 7; BRIGHT 1; PAPER 0; AT 23, 0; STRING$(32, CHR$(143));
  ```
  Saves 6 lines, eliminates the `bc` variable declaration, and is faster at runtime (32 individual PRINT AT calls → 1 string operation per bar). File: `game.bas`.

- [ ] **[CODE] Difficulty mapping: replace IF chain with formula** — the 3-line IF chain in `main.bas`:
  ```bas
  IF selectedDifficulty = 1 THEN pipeGapSize = 10
  IF selectedDifficulty = 2 THEN pipeGapSize = 8
  IF selectedDifficulty = 3 THEN pipeGapSize = 6
  ```
  reduces to one line:
  ```bas
  pipeGapSize = 12 - (selectedDifficulty * 2)
  ```
  Verified: difficulty 1→10, 2→8, 3→6. File: `main.bas`.

- [ ] **[CODE] `CheckCollision()`: eliminate intermediate variables via early returns** — replace the `hit`/`attr`/`inkColor` variable chain with direct early returns:
  ```bas
  IF birdRow >= 22 THEN RETURN 1
  IF (PEEK(22528 + birdRow * 32 + birdCol) BAND 7) = 4 THEN RETURN 1
  RETURN 0
  ```
  Removes 3 local variable declarations; logic becomes linear and self-evident. File: `collision.bas`.

- [ ] **[CODE] Makefile: extract emulator launch into a `define` macro** — each of the 11 `run-*` targets in `tools/Makefile` repeats the same two lines (`pkill` + `open`). Extract into a `define`:
  ```makefile
  define run_emu
  -pkill -x zesarux 2>/dev/null; sleep 0.5
  open $(HOME)/Applications/ZEsarUX.app --args $(1) $(abspath $(2))
  endef
  ```
  Then each target body becomes `$(call run_emu,$(EMU_ARGS),$(TAP))`. Removes ~11 duplicate lines. File: `tools/Makefile`.

- [ ] **[CODE] Makefile: `EMU_ARGS_128` variable for 128K emulator args** — the 128K run targets hardcode `--noconfigfile --machine 128k` inline; the 48K targets use `$(EMU_ARGS)`. Add:
  ```makefile
  EMU_ARGS_128 := --noconfigfile --machine 128k
  ```
  and reference it in `run-128k`, `run-launcher-128k`, `run-test-sound-128k`. File: `tools/Makefile`.

### Code — Tier 2 (Readability / maintenance)

- [ ] **[CODE] AY register write helper in `sounds.bas`** — the `#ifdef AY_SOUND` blocks repeat `OUT 65533, reg : OUT 49149, val` pairs ~14 times with no abstraction. A single helper:
  ```bas
  SUB AYWrite(reg AS INTEGER, val AS INTEGER)
    OUT 65533, reg : OUT 49149, val
  END SUB
  ```
  eliminates the duplication and makes the sound routines readable as register-name → value mappings. Sound SUBs are not in the hot path, so the CALL overhead is irrelevant. File: `assets/sounds/sounds.bas`.

- [ ] **[CODE] Update stale `main.bas` header comment** — the top-of-file comment still reads "Version: v0.1 — proof of concept (splash screen only)" and lists game loop, sound, and high score as "NOT here yet". All of those are implemented. The comment is now actively misleading. File: `src/game/main.bas`.

- [ ] **[CODE] Add derivation comment to `SpawnPipe` formula** — `INT(RND * (21 - pipeGapSize)) + 2` is not immediately obvious. A one-line comment explaining the bounds (gap must satisfy `gap + pipeGapSize ≤ 22`, so gap ∈ [2, 22-pipeGapSize]) prevents future accidental breakage. File: `pipes.bas`.

- [ ] **[CODE] Cross-reference the pipe slot count (3) between `pipes.bas` and `game.bas`** — the array is `DIM pipeCol(3)` in `pipes.bas` and the scoring loop is `FOR i = 1 TO 3` in `game.bas`. A comment on each noting the dependency prevents silent divergence if the slot count ever changes. Files: `pipes.bas`, `game.bas`.

---

## Testing Approach

| Test | File | Status | How |
|---|---|---|---|
| Unified suite | `tests/test_suite.bas` | ✅ done | Menu-driven runner; all tests from one TAP |
| UDG memory integrity | `tests/test_bird_udg.bas` | ✅ done | Fully automated PEEK assertions |
| Title screen attributes | `tests/test_title_render.bas` | ✅ done | Semi-automated; 9 attribute assertions incl. mute indicator (row 21) |
| Physics unit test | `tests/test_physics.bas` | ✅ done | Fully automated; gravity, flap, floor clamp, ceiling clamp — 6 assertions |
| Pipe spawning | `tests/test_pipes.bas` | ✅ done | Fully automated; init state, gap bounds, spawn assertions |
| Collision accuracy | `tests/test_collision.bas` | ✅ done | Automated: safe/floor/POKE-green/POKE-clear — 4 assertions |
| Medal ranks | `tests/test_gameover.bas` | ✅ done | Automated: boundary values 0/9/10/20/30/40/50 — 7 assertions |
| Sound + mute (48K) | `tests/test_sound.bas` | ✅ done | Automated: 3 smoke + 4 mute-flag assertions — 7 total |
| AY sound (128K) | `tests/test_sound_128.bas` | ✅ done | Standalone only (-D AY_SOUND); 3 AY smoke + 4 mute-flag — 7 assertions; run with `make run-test-sound-128k` |
| Difficulty curve | `tests/test_difficulty_curve.bas` | ✅ done | Automated: `GetSpeedTier` + `GetBorderColor` boundary values — 19 assertions |
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
make run-test-sound            # run sound smoke test standalone (48K BEEP)
make run-test-difficulty-curve # run difficulty curve (speed/border) unit tests standalone
make build-128k                # compile 128K TAP with AY sound (-D AY_SOUND)
make run-128k                  # launch 128K build on --machine 128k
make run-test-sound-128k       # run AY sound smoke test (--machine 128k)
make dist                      # copy both 48K and 128K TAPs to dist/
make clean                     # remove build artefacts
zxbc src/game/main.bas -h      # compiler help
```
