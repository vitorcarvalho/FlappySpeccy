# Developer Notes — Flappy Speccy

Distilled toolchain notes for macOS development. Keep these as the canonical
reference for anyone setting up the environment.

---

## Toolchain choice

Two viable paths exist for ZX Spectrum BASIC development. **This project uses Path B.**

| | Path A — Sinclair BASIC | Path B — Boriel ZX BASIC ✅ |
|---|---|---|
| Source format | Tokenised line-numbered BASIC | Structured BASIC (no mandatory line numbers) |
| Converter | `zmakebas` or `bas2tap` | `zxbc` (Boriel ZX BASIC compiler) |
| Output | Tokenised `.TAP` (interpreted at runtime) | Native Z80 machine code wrapped in `.TAP` |
| Performance | Slow (interpreter) | Fast (compiled) — suitable for a game loop |
| Language extras | None beyond original Sinclair BASIC | Types, SUBs, inline ASM, `#include` |

**Do not use zmakebas or bas2tap for this project.** They produce interpreted
Sinclair BASIC, which is too slow for a real-time game loop on a 3.5 MHz Z80.

---

## "Compile" vs tokenise — why it matters

Sinclair BASIC stores programs in a *tokenised internal format*, not as plain
text. Tools like `zmakebas` / `bas2tap` convert ASCII listings into that
tokenised format — the program still runs under the Spectrum ROM interpreter.

Boriel ZX BASIC (`zxbc`) is different: it compiles `.bas` source into actual
Z80 machine code. The `.TAP` it emits contains a short BASIC loader that
`RANDOMIZE USR` jumps into compiled binary code. Runtime behaviour is
indistinguishable from an assembly game.

---

## Toolchain installation (macOS)

```sh
# Compiler (requires Python 3.11+)
pip install zxbasic
zxbc --version        # should print version string

# Emulator — ZEsarUX (recommended for this project)
# 1. Download the macOS DMG from https://github.com/chernandezba/zesarux/releases
# 2. Open the DMG and copy ZEsarUX.app to ~/Applications/
# 3. If Gatekeeper blocks launch, remove the quarantine attribute:
xattr -dr com.apple.quarantine ~/Applications/ZEsarUX.app

# Verify: compile and run a hello-world
echo 'PRINT "Hello, Speccy!"' > /tmp/hello.bas
zxbc /tmp/hello.bas -f tap -B -a -o /tmp/hello.tap
~/Applications/ZEsarUX.app/Contents/MacOS/zesarux --noconfigfile --machine 48k /tmp/hello.tap
```

---

## 48K vs 128K targeting

The **primary target is ZX Spectrum 48K**:
- RAM available for code + data: ~40 KB (ROM occupies 16 KB at `$0000`–`$3FFF`).
- No AY sound chip — sound is BEEP only.
- No memory paging — simpler model, broader hardware compatibility.

**128K support is planned for Phase 10** — the 48K TAP already runs in 128K compatibility mode with zero changes. The 128K build adds AY-3-8912 sound via `-D AY_SOUND` at compile time and a dedicated `make build-128k` / `make run-128k` Makefile target.

When using ZEsarUX, the `--machine 48k` flag (set in `tools/Makefile` via `EMU_ARGS`) forces 48K mode. Do not rely on the emulator's saved config file — always pass `--noconfigfile --machine 48k` to guarantee a clean 48K environment.

The compiler flag `--arch zx48k` (set in `tools/Makefile`) enforces the 48K target at compile time. For the future 128K build, the same `--arch zx48k` flag is used — the 128K features are gated by the `-D AY_SOUND` preprocessor define, not a different arch.

---

## VS Code integration

Build and Run tasks are configured in `.vscode/tasks.json`.

| Shortcut | Task |
|---|---|
| `⇧⌘B` | Build (default build task) |
| `⌘P` → `Tasks: Run Task` → Run | Build + launch in Fuse |
| `⌘P` → `Tasks: Run Task` → Clean | Remove `build/` artefacts |

The terminal alternative is `make` / `make run` / `make clean` from the repo
root (delegating to `tools/Makefile`).

---

## Tape formats

| Format | Use |
|---|---|
| `.TAP` | Standard virtual tape — Fuse and most emulators |
| `.TZX` | Extended tape with timing metadata — needed for some copy-protected originals; not needed here |
| `.Z80` | Snapshot format — useful for saving emulator state mid-game for debugging |

`zxbc` with `--tap` produces `.TAP` directly. That is the only format needed
for this project.

---

## Emulator tips (ZEsarUX)

- **SmartLoad:** pass the `.TAP` path as the last argument — ZEsarUX injects `LOAD ""` automatically in 48K mode.
- **Manual load:** if SmartLoad doesn't fire, type `LOAD ""` at the BASIC prompt and press **Enter**.
- **Clean config:** always pass `--noconfigfile` to avoid stale settings from a previous session.
- **Snapshot:** `File → Save Snapshot` → `.z80` — save emulator state mid-game for debugging.
- **Debug / ZRCP:** ZEsarUX exposes a remote command protocol (ZRCP) on TCP port 10000; useful for future automated test integration.
- **Kill before launch:** the Makefile runs `pkill -x zesarux` before every `open` call to guarantee a fresh 48K state; never rely on a running instance.

---

## Boriel ZX BASIC — Lessons Learned

Hard-won gotchas discovered during development. Treat these as project law.

### 1. `DO : statement : LOOP UNTIL` inline form is not supported

```basic
' ❌ Compiler error: unexpected token 'LOOP'
DO : PAUSE 1 : LOOP UNTIL INKEY$ <> ""

' ✅ Correct — multi-line only
DO
  PAUSE 1
LOOP UNTIL INKEY$ <> ""
```

### 2. Include guards prevent double-definition errors

When a module is `#include`d from both a standalone test and `test_suite.bas`, its SUBs and globals would be defined twice without guards — the compiler errors out. Pattern:

```basic
#ifndef MY_MODULE_BAS
#define MY_MODULE_BAS

DIM myGlobal AS INTEGER

SUB MyFunction()
  ' ...
END SUB

#endif
```

All source modules (`physics.bas`, `title.bas`, `bird_udg.bas`) and the shared helper (`assert_helpers.bas`) use this pattern.

### 3. `SUITE_MODE` define — suppress standalone entry points

To allow a test file to be both run standalone and included into `test_suite.bas` without double-executing its body:

```basic
' At the bottom of tests/test_foo.bas:
#ifndef SUITE_MODE
RunTestFoo()
PAUSE 0
#endif
```

`test_suite.bas` starts with `#define SUITE_MODE` before any `#include`, so all standalone calls are compiled out.

### 4. Attribute assertions must snapshot before `CLS`

`CLS` with any `PAPER`/`INK` state rewrites **every byte** in the attribute file (`$5800`–`$5AFF`) to the current attribute. If you `CLS` before PEEKing attributes, every assertion reads the post-CLS value instead of what was drawn.

```basic
' ❌ Wrong — CLS overwrites the attributes we want to test
ShowTitle(0)
BORDER 0 : PAPER 0 : INK 7 : CLS   ' attribute file is now all 7s
AssertAttr("title", 22528 + 2*32 + 9, 70)   ' reads 7, not 70 — FAIL

' ✅ Correct — snapshot first, then clear and report
ShowTitle(0)
DIM atTitle AS INTEGER
atTitle = PEEK(22528 + 2*32 + 9)   ' captured before CLS
BORDER 0 : PAPER 0 : INK 7 : CLS
AssertEq("title attr=70", 70, atTitle)   ' compares saved value — PASS
```

### 5. `W170` unused-function warnings in standalone test builds

The shared `assert_helpers.bas` defines `AssertEq`, `AssertGT`, `AssertLTE`, and `AssertAttr`. A standalone test that only calls two of them will get W170 warnings for the unused helpers. These are harmless — the compiler strips unused SUBs. The unified suite uses all helpers and compiles cleanly.

### 6. INTEGER everywhere — no exceptions in the game loop

Untyped `DIM x` defaults to floating-point, which routes through the ZX ROM FP calculator — 30–100× slower than integer arithmetic on a 3.5 MHz Z80. Every game-loop variable — `birdRow`, `birdVel`, `pipeCol`, `score` — must be `DIM x AS INTEGER`.

### 7. Physics tick divider — decoupling logic Hz from render Hz

The game loop runs at 50 Hz (one `PAUSE 1` per iteration). Running physics every frame makes the bird fall and flap too fast for a comfortable game feel. The solution is a divider flag:

```basic
DIM physTick    AS INTEGER   ' toggles 0→1→0; physics runs only when 1
DIM flapPending AS INTEGER   ' latches SPACE across skipped frames

physTick = 1 - physTick
IF physTick = 1 THEN
  prevRow = birdRow
  UpdatePhysics(flapPending)
  flapPending = 0
END IF
```

- **Pipes scroll every frame** (50 Hz) for smooth visual movement.
- **Physics ticks every 2nd frame** (25 Hz) — halves effective fall and flap speed without changing the impulse constants in `UpdatePhysics`.
- **Input latch:** `IF key = " " THEN flapPending = 1` fires every frame; the flag is consumed by `UpdatePhysics` and reset only on the physics frame. No SPACE press is lost on a skipped frame.
- To change speed ratio: set divider to `3` for ≈17 Hz physics (slower/floatier), or remove divider entirely for 50 Hz (original fast feel).

### 8. Difficulty-driven parameter via global variable

The difficulty selection pattern avoids passing parameters through deep call chains. Instead, a shared global in the module that owns the parameter (`pipeGapSize` in `pipes.bas`) is set by the coordinator (`RunFlappySpeccy` in `main.bas`) after the player confirms their choice on the title screen.

```basic
' --- pipes.bas: declare the parameter with a safe default ---
DIM pipeGapSize AS INTEGER : pipeGapSize = 8

' --- title.bas: record the player's choice in a global ---
DIM selectedDifficulty AS INTEGER   ' 1=Easy / 2=Normal / 3=Hard
' ... input loop sets selectedDifficulty = diff before returning ...

' --- main.bas: map choice → parameter before RunGame ---
IF selectedDifficulty = 1 THEN pipeGapSize = 10
IF selectedDifficulty = 2 THEN pipeGapSize = 8
IF selectedDifficulty = 3 THEN pipeGapSize = 6
RunGame()
```

**Gap formula:** `INT(RND * (21 - pipeGapSize)) + 2` produces values in `2 .. (22 - pipeGapSize)`.

| Difficulty | `pipeGapSize` | Gap row range |
|---|---|---|
| Easy   | 10 | 2–12 |
| Normal |  8 | 2–14 |
| Hard   |  6 | 2–16 |

The `DrawPipe` and `SpawnPipe` SUBs in `pipes.bas` simply reference `pipeGapSize` — no parameter changes to those functions were needed.

### 9. `AND` is logical, not bitwise — use `BAND` for bit masking

In Boriel ZX BASIC, `AND` / `OR` / `NOT` are **logical** operators. Applied to integers, `AND` returns `0` or `1` (truthy/falsy), not the bitwise result.

```basic
' ❌ Wrong — AND is logical; (4 AND 7) → 1, not 4
inkColor = attr AND 7
IF inkColor = 4 THEN hit = 1   ' never fires when attr = 4 (pipe green)

' ✅ Correct — BAND is bitwise AND
inkColor = attr BAND 7
IF inkColor = 4 THEN hit = 1   ' fires correctly
```

**Bitwise operator names in Boriel BASIC:**

| Operator | Meaning |
|---|---|
| `BAND` | Bitwise AND |
| `BOR` | Bitwise OR |
| `BXOR` | Bitwise XOR |
| `BNOT` | Bitwise NOT |

This matters for any attribute byte extraction. The ZX Spectrum attribute byte layout is:

```
bit 7   6   5   4   3   2   1   0
      FLASH  BRIGHT  PAPER(2:0)  INK(2:0)
```

To extract INK (lower 3 bits): `inkColor = attr BAND 7`
To extract PAPER (bits 3–5):   `paper = (attr BAND 56) / 8`  (or `BSHIFT` if available)
To test BRIGHT (bit 6):         `bright = (attr BAND 64) BAND 64`

**Symptom of the bug:** collision detection always returned 0 even when a pipe was present at the bird's cell. The test `pipe hit: green attr → collision` failed with `exp=1 got=0`. The POKE'd attribute was 4 but `4 AND 7 = 1` (logical), so `inkColor = 1 ≠ 4`.

---

## Prior Art — Flappy Bird on ZX Spectrum

Reference implementations to study before designing each new phase.

| Project | Target | Language | Year | Notable features |
|---|---|---|---|---|
| [Flappy Bird ZX](https://spectrumcomputing.co.uk/index.php?cat=96&id=30100) | 48K + 128K | Machine code (Z80) | 2014 | Horizontal scroll, border effects, in-game music (*Kalambur*), TAP + TZX + SCL, RZX gameplay recording available |
| [Flappy Bird Simulator](https://spectrumcomputing.co.uk/index.php?cat=96&id=30074) | 48K only | Unknown | 2014 | Minimal one-author implementation; no music; useful as a complexity baseline |
| [Flappy Bird — ZX Next](https://retrobeachman.itch.io/flappybirdzxnext) | ZX Spectrum **Next** | NextBASIC | ~2021 | AYFX sound engine, SD card high-score persist, attract/demo mode after 20 s idle, Kempston + keyboard simultaneously, 50/60 Hz, UDGs converted with **UDGeed** |

**Design implications for FlappySpeccy:**

- **Sound:** BEEP-only on 48K. AY/AYFX requires 128K. Plan `SoundFlap()` / `SoundDie()` with `BEEP` sequences — see Phase 7.
- **High score:** no SD card or guaranteed storage on 48K. In-session `hiScore AS INTEGER` is the correct scope; tape-save is a Phase 9 stretch goal.
- **Attract mode:** the Next port shows a demo after 20 s of title-screen inactivity. Worth adding in Phase 8 — it significantly improves perceived polish.
- **Border effects:** used in the polished 48K port for visual feedback. Zero-cost: `BORDER n` during death flash or score milestones.
- **Joystick:** Kempston reads port `$1F`; could be added in Phase 8 alongside SPACE.
- **UDGeed:** tool by David Saphier (emook) for converting graphics to UDG bytes. Useful if we expand beyond the current 1-UDG "SKY" glyph — e.g. a proper bird silhouette or animated sprite.
