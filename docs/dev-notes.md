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

This project targets the **ZX Spectrum 48K**:
- RAM available for code + data: ~40 KB (ROM occupies 16 KB at `$0000`–`$3FFF`).
- No AY sound chip — sound is BEEP only.
- No memory paging — simpler model, broader hardware compatibility.

When using ZEsarUX, the `--machine 48k` flag (set in `tools/Makefile` via `EMU_ARGS`) forces 48K mode. Do not rely on the emulator's saved config file — always pass `--noconfigfile --machine 48k` to guarantee a clean 48K environment.

The compiler flag `--arch zx48k` (set in `tools/Makefile`) enforces the 48K target at compile time.

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
