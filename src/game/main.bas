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
#include "game.bas"

' =============================================================================
' Global state
' =============================================================================
' All variables are explicitly typed.  The default Boriel type is a 40-bit
' floating-point value backed by the Spectrum ROM FP calculator — extremely
' slow on a 3.5 MHz Z80.  INTEGER (signed 16-bit) uses native CPU arithmetic
' and is the right choice for all game counters and positions.

DIM highScore AS INTEGER   ' best score seen this session; 0 until game loop added

' =============================================================================
' RunFlappySpeccy — full game session (callable from launcher or standalone)
' =============================================================================
' Initialises screen and UDG, then loops: title screen → RunGame → repeat.
' When invoked from launcher.bas, LAUNCHER_MODE suppresses the standalone call
' below so only this SUB definition is compiled into the launcher binary.

SUB RunFlappySpeccy()
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0
  CLS
  LoadBirdUDG()
  highScore = 0
  DO
    ShowTitle(highScore)
    RunGame()
  LOOP
END SUB

' =============================================================================
' Standalone entry point
' =============================================================================
' Suppressed when compiled via launcher.bas (#define LAUNCHER_MODE).

#ifndef LAUNCHER_MODE
RunFlappySpeccy()
#endif
