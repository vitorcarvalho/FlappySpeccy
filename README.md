# Flappy Speccy 🐦

A Flappy Bird clone for the **ZX Spectrum 48K**, written in **ZX BASIC (Boriel BASIC)**.

The bird drops under gravity. Tap a key to flap. Navigate through gaps in the pipes. Die gloriously.

---

## Platform

| Property | Value |
|---|---|
| Target hardware | ZX Spectrum 48K |
| CPU | Zilog Z80 @ 3.5 MHz |
| RAM | 48 KB usable (16 KB ROM + 48 KB) |
| Screen | 256 × 192 pixels / 32 × 24 character cells |
| Colours | 8 foreground + 8 background, 2 brightness levels |
| Sound | Single-bit BEEP |
| Language | ZX BASIC (Boriel BASIC / `zxbc`) |
| Output format | `.tap` tape image (also `.tzx`, `.z80`) |

---

## Game Concept

Faithful ZX Spectrum adaptation of the Flappy Bird mechanic:

- **Bird** — character-cell sprite using a UDG (user-defined graphic), subject to gravity.
- **Pipes** — pairs of block-graphic columns scrolling right-to-left at a fixed speed.
- **Gap** — random vertical gap, same height every pair, constant width.
- **Score** — increments each time a pipe pair is cleared; displayed in the border area.
- **Collision** — detected when the bird occupies the same cell as a pipe or the floor/ceiling.
- **Difficulty** — pipe scroll speed increases every 5 points.

### Controls

| Key | Action |
|---|---|
| `SPACE` | Flap (bird rises) |
| `P` | Pause |
| `Q` | Quit to title |

---

## Toolchain

| Tool | Purpose |
|---|---|
| [Boriel ZX BASIC SDK](https://zxbasic.readthedocs.io/) | Compiler — `zxbc` converts `.bas` → `.tap` |
| [ZEsarUX](https://github.com/chernandezba/zesarux) | ZX Spectrum emulator for macOS/Linux/Windows |
| `make` | Build automation (root `Makefile` delegates to `tools/Makefile`) |

> **macOS note:** ZEsarUX must be installed in `~/Applications/ZEsarUX.app`. If Gatekeeper blocks it, run `xattr -dr com.apple.quarantine ~/Applications/ZEsarUX.app`.

---

## Quick Start

### 1. Prerequisites

```sh
# Compiler — requires Python 3.11+
pip install zxbasic
zxbc --version          # verify

# Emulator — download from https://github.com/chernandezba/zesarux/releases
# macOS: copy ZEsarUX.app to ~/Applications/
```

### 2. Compile

```sh
make          # produces build/flappy_speccy.tap
```

### 3. Run

```sh
make run      # compiles (if needed) then launches ZEsarUX with the tape
```

The emulator opens in 48K mode with the tape pre-loaded. Type `LOAD ""` and press **Enter** if it doesn't start automatically. The splash screen appears; press **SPACE** to advance.

---

## Unit Tests

Tests live in `tests/` and are standalone `.bas` programs that compile to their own `.tap` files. Each test runs inside the emulator and prints colour-coded `PASS`/`FAIL` lines directly on screen.

### Compile all tests

```sh
make tests
```

### Run a specific test

```sh
make run-test-bird-udg        # automated — verifies UDG byte values via PEEK
make run-test-title-render    # semi-automated — renders title, then checks screen attributes
```

### Test catalogue

| Target | File | Automation | What it checks |
|---|---|---|---|
| `run-test-bird-udg` | `tests/test_bird_udg.bas` | Fully automated | Calls `LoadBirdUDG()`, PEEKs all 8 UDG bytes, compares against expected pixel map |
| `run-test-title-render` | `tests/test_title_render.bas` | Semi-automated (press SPACE once) | Renders the title screen, then PEEKs 6 attribute cells to verify ink/paper/bright/flash |

### Writing a new test

1. Create `tests/test_<name>.bas`.
2. `#include` the module under test using a relative path (e.g. `#include "../src/game/mything.bas"`).
3. Write assertions using `PEEK` for memory checks or attribute-sniffing (`PEEK(22528 + row*32 + col)`) for screen checks.
4. Print `PASS` in green (`INK 4`) or `FAIL` in red (`INK 2`).
5. Add a `run-test-<name>` target in `tools/Makefile` and declare it in `.PHONY`.

---

## Project Structure

```
spectrum/
├── Makefile                    ← Root delegator — run all make targets from here
├── README.md                   ← This file
├── ARCHITECTURE.md             ← Hardware constraints, component map, memory addresses
├── NEXT_STEPS.md               ← Implementation plan and phase status
│
├── src/
│   ├── game/
│   │   └── main.bas            ← Entry point: init → title → game loop (placeholder)
│   └── screens/
│       └── title.bas           ← Title/splash screen with UDG bird and "PRESS SPACE"
│
├── assets/
│   └── sprites/
│       └── bird_udg.bas        ← LoadBirdUDG() SUB: POKEs 8 bytes into UDG slot "A"
│
├── build/                      ← Compiler output (.tap) — gitignored
├── dist/                       ← Release tape images
│
├── tools/
│   └── Makefile                ← Actual build rules and compiler flags
│
├── docs/
│   ├── dev-notes.md            ← Toolchain decisions, macOS setup, emulator tips
│   └── ai-assistance.md        ← Notes on AI-assisted development workflow
│
└── tests/
    ├── test_bird_udg.bas        ← UDG memory integrity test (fully automated)
    └── test_title_render.bas   ← Screen attribute test (semi-automated)
```

Full architecture details → [ARCHITECTURE.md](ARCHITECTURE.md)

---

## Contributing

### Coding standards

- **Declare all variables explicitly** — `DIM x AS INTEGER`, never bare `DIM x`. Untyped variables default to floating-point and are 30–100× slower on the Z80.
- **Encapsulate in SUBs** — each module exposes a named `SUB`. Main orchestrates; modules do not call each other directly.
- **Use `USR "A"` not hardcoded addresses** — `USR "A"` reads the live UDG pointer from the system variable, which is portable across Spectrum variants.
- **No floating-point in the game loop** — all physics, collision, and scroll variables must be `INTEGER`.
- **Comment pixel maps** — when defining UDG or tile bytes, include the binary representation and a description of each row.
- **Test your module** — add a `tests/test_<module>.bas` before submitting.

### Build flags (reference)

```
-f tap         produce a .TAP tape image
-B             prepend a BASIC loader block (LOAD "" works)
-a             autorun the BASIC loader immediately after load
--optimize 2   safe optimisation — does not change semantics
--arch zx48k   target ZX Spectrum 48K
```

---

## References

- [Boriel ZX BASIC docs](https://zxbasic.readthedocs.io/en/docs/)
- [ZX Spectrum BASIC Programming (Vickers)](https://worldofspectrum.org/ZXBasicManual/)
- [ZEsarUX emulator](https://github.com/chernandezba/zesarux)
- [SkoolKit disassembly toolkit](https://skoolkit.ca/)
- [ZX Spectrum memory map](https://sinclair.wiki.zxnet.co.uk/wiki/ZX_Spectrum_memory_map)
- [Flappy Bird — Wikipedia](https://en.wikipedia.org/wiki/Flappy_Bird)
