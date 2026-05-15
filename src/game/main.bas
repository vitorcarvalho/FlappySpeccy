' =============================================================================
' src/game/main.bas
' Flappy Speccy — program entry point.
'
' Version: v0.1 — proof of concept (splash screen only).
'
' What this version does:
'   1. Resets the screen to a known black state.
'   2. Loads the bird User Defined Graphic into UDG slot A.
'   3. Displays the title / splash screen.
'   4. Waits for SPACE, then shows a placeholder "coming soon" message.
'
' What is NOT here yet (see NEXT_STEPS.md):
'   - Game loop (physics, pipes, collision, scoring)
'   - Game-over screen
'   - Sound effects
'   - High score persistence
'
' Compilation (from repo root):
'   make
'   — or —
'   zxbc src/game/main.bas --tap --optimize 2 --machine 48 \
'        -o build/flappy_speccy.tap
'
' #include paths are relative to this file (src/game/).
' Boriel resolves SUB names in two passes, so include order does not affect
' call resolution — but keeping assets before screens aids readability.
' =============================================================================

#include "../../assets/sprites/bird_udg.bas"
#include "../screens/title.bas"

' =============================================================================
' Global state
' =============================================================================
' All variables are explicitly typed.  The default Boriel type is a 40-bit
' floating-point value backed by the Spectrum ROM FP calculator — extremely
' slow on a 3.5 MHz Z80.  INTEGER (signed 16-bit) uses native CPU arithmetic
' and is the right choice for all game counters and positions.

DIM highScore AS INTEGER   ' best score seen this session; 0 until game loop added

' =============================================================================
' Screen initialisation
' =============================================================================
' The ROM startup sequence leaves white paper, black ink, and a white border.
' We override everything explicitly so the program looks the same whether it
' launches cold (from power-on) or warm (from a RUN in the BASIC editor).

BORDER 0    ' black border — eliminates the white frame around the picture area
PAPER  0    ' black paper  — background colour for CLS and all future PRINTs
INK    7    ' white ink    — default foreground; individual PRINTs override this
BRIGHT 0    ' no bright    — prevents stray bright attributes from prior state
FLASH  0    ' no flash     — same reason

CLS         ' fill the entire screen with the current PAPER colour (black)

' =============================================================================
' Load UDG
' =============================================================================
' Must happen before ShowTitle because the title screen prints CHR$(144).
' CHR$(144) = UDG "A" = bird sprite (defined in assets/sprites/bird_udg.bas).
' Until LoadBirdUDG() is called, CHR$(144) shows a random or default glyph.

LoadBirdUDG()

' =============================================================================
' Title screen
' =============================================================================
' ShowTitle blocks until SPACE is pressed, then returns cleanly.
' We pass highScore so the title can display the all-time best run.
' (For v0.1 this is always 0; persistence is a later phase.)

ShowTitle(highScore)

' =============================================================================
' Placeholder — game loop goes here (Phase 3 in NEXT_STEPS.md)
' =============================================================================
' SPACE was pressed on the title screen.  In a future version this is where
' the game loop starts: reset bird position, reset pipes, enter the 50 Hz
' interrupt-synchronised loop.

CLS

PRINT INK 6; BRIGHT 1; PAPER 0; AT 10, 8; "COMING SOON!"
PRINT INK 7; BRIGHT 0; PAPER 0; AT 12, 5; "GAME LOOP NOT YET BUILT"
PRINT INK 5; BRIGHT 0; PAPER 0; AT 14, 5; "SEE NEXT_STEPS.MD  PH.3"

' PAUSE 0 suspends the program until any key is pressed.
' When the key is pressed, the program exits back to the BASIC prompt.
PAUSE 0
