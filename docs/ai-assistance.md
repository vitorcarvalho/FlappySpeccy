# AI Assistance for ZX Spectrum Development

Community-sourced evidence on what works and what doesn't when using AI
tools (LLMs, RL agents, etc.) for ZX Spectrum game development.

---

## Community projects (real, inspectable artefacts)

### 1. AI algorithms *running on* the ZX Spectrum
**[AI-to-ZX](https://github.com/JGalego/AI-to-ZX)** — GitHub

- Implements AI and computational demos targeting the ZX Spectrum.
- Programs written in **ZX BASIC, compiled to Z80** — same toolchain as this project.
- Runs in a Spectrum emulator.
- Goal: exploring AI within 1980s hardware limits.

This is the clearest "serious" AI + ZX project currently available.

---

### 2. AI assisting humans to write ZX Spectrum BASIC
**[Old Machinery blog — "ZX Spectrum and ChatGPT"](https://oldmachinery.blogspot.com/2025/02/zx-spectrum-and-chatgpt.html)**

- ChatGPT generated a ZX Spectrum BASIC quiz game.
- Output was converted using `bas2tap` and run in an emulator.
- Author documents explicit constraints needed to stop the LLM producing
  dialect-incorrect output.

**Key finding:** LLMs do not natively understand Sinclair BASIC. They must be
constrained with hard rules and validated with a tokeniser/compiler. This is
a documented failure mode, not speculation.

**[Reddit — community threads](https://www.reddit.com/r/zxspectrum/comments/1cn8hep/importing_basic_in_a_text_file_to_an_emulator/)**

- Recurrent pattern: AI output is syntactically "almost right" but dialect-incorrect.
- Tools like `zmakebas` / `bas2tap` are used as post-hoc validators.

**Confirmed pattern:** LLMs are useful as syntax accelerators, not as
authoritative ZX BASIC compilers.

---

### 3. AI learning to *play* ZX Spectrum games
**[Teaching an AI to Play ZX Spectrum Games — Kevin Watkins](https://www.mrkwatkins.co.uk/)**

- Reinforcement-learning project.
- Built a Z80 emulator and a Spectrum emulator, then trained RL agents to play Spectrum games.
- Motivation: "Why should Atari get all the love?"

This is AI + ZX Spectrum at systems-research level.

---

### 4. AI-assisted assets (not core logic)
**[itch.io — ZX Spectrum + AI graphics](https://itch.io/games/newest/ai-graphics/tag-zx-spectrum)**

- Games tagged ZX Spectrum that use AI-generated graphics.
- AI used off-device for art generation, not gameplay logic.

Useful pattern for UDG / sprite design; orthogonal to the game loop.

---

## What does *not* exist (important negative finding)

- ❌ No established framework where an LLM reliably emits correct Sinclair BASIC
  or Z80 ASM without human-authored constraints and post-processing.
- ❌ No end-to-end "AI makes a Speccy game" pipeline accepted by the community.

---

## Reality summary

| Use case | Exists? | Maturity |
|---|---|---|
| AI algorithms running on ZX Spectrum | ✅ Yes | Solid niche |
| AI helping write ZX BASIC | ✅ Yes | Fragile, rule-bound |
| AI learning to play ZX games | ✅ Yes | Research-grade |
| Fully autonomous AI game creation | ❌ No | Not real |
| LLM understands Sinclair BASIC natively | ❌ No | Proven false |

---

## Strategic guidance for this project

Use AI (including Augment) for:
- **Structure** — module layout, variable naming, loop skeleton
- **Refactoring** — extracting SUBs, renaming, reorganising
- **Algorithm sketching** — physics pseudocode, collision logic outline

Enforce:
- **Dialect rules** — Boriel ZX BASIC syntax, not generic BASIC
- **Compiler validation** — `zxbc` must pass cleanly; treat warnings as errors
- **Emulator-based test loops** — no change is "done" until it runs in Fuse

**Treat AI as a junior assistant, not a compiler.** Every generated code
snippet must be compiled and tested in the emulator before being considered
correct.
