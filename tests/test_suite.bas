' =============================================================================
' tests/test_suite.bas
' Unified menu-driven test runner.
'
' All tests compile into a single .tap.  Press a number key to run a test;
' any key to return to the menu after results are shown.
'
' Tests:
'   1  Bird UDG       — automated PEEK assertions + UDG visual render
'   2  Title Render   — semi-automated (press SPACE to advance phase 1)
'   3  Physics        — automated gravity, flap, clamp assertions
'   4  Pipes          — automated init and spawn state assertions
'   5  Collision      — automated floor + attr-based pipe hit assertions
'   6  Game Over      — automated medal rank boundary assertions
'
' #define SUITE_MODE before including test files suppresses their standalone
' RunTestXxx() + PAUSE 0 calls, leaving only the SUB definitions.
'
' Compile:  make tests
' Run:      make run-test-suite
' =============================================================================

#define SUITE_MODE

#include "assert_helpers.bas"
#include "test_bird_udg.bas"
#include "test_title_render.bas"
#include "test_physics.bas"
#include "test_pipes.bas"
#include "test_collision.bas"
#include "test_gameover.bas"

' ── Menu ──────────────────────────────────────────────────────────────────────

SUB ShowMenu()
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; PAPER 0; AT 2, 4; "FLAPPY SPECCY TEST SUITE"
  PRINT           INK 5; PAPER 0; AT 3, 4; "────────────────────────"
  PRINT           INK 7; PAPER 0; AT 6, 6; "1  BIRD UDG      (auto)"
  PRINT           INK 7; PAPER 0; AT 8, 6; "2  TITLE RENDER  (semi)"
  PRINT           INK 7; PAPER 0; AT 10,6; "3  PHYSICS       (auto)"
  PRINT           INK 7; PAPER 0; AT 12,6; "4  PIPES         (auto)"
  PRINT           INK 7; PAPER 0; AT 14,6; "5  COLLISION     (auto)"
  PRINT           INK 7; PAPER 0; AT 16,6; "6  GAME OVER     (auto)"
  PRINT           INK 5; PAPER 0; AT 18,6; "0  BACK TO LAUNCHER"
  PRINT BRIGHT 1; INK 5; PAPER 0; AT 20,4; "PRESS 1-6 TO SELECT TEST"
END SUB

' ── "back to menu" prompt shown after every test ──────────────────────────────

SUB WaitForMenu()
  FLASH 0 : BRIGHT 0
  PRINT INK 5; PAPER 0; AT 22, 0; "──────────────────────────────"
  PRINT INK 7; BRIGHT 1; PAPER 0; AT 23, 4; "PRESS ANY KEY FOR MENU"
  DO
    PAUSE 1
  LOOP UNTIL INKEY$ <> ""
END SUB

' ── Main loop (callable from launcher or standalone) ─────────────────────────

SUB RunTestSuite()
  DIM menuKey AS STRING
  DO
    ShowMenu()
    DO
      PAUSE 1
      menuKey = INKEY$
    LOOP UNTIL menuKey = "0" OR menuKey = "1" OR menuKey = "2" OR menuKey = "3" OR menuKey = "4" OR menuKey = "5" OR menuKey = "6"

    IF menuKey = "1" THEN
      RunTestBirdUDG()
      WaitForMenu()
    END IF

    IF menuKey = "2" THEN
      RunTestTitleRender()
      WaitForMenu()
    END IF

    IF menuKey = "3" THEN
      RunTestPhysics()
      WaitForMenu()
    END IF

    IF menuKey = "4" THEN
      RunTestPipes()
      WaitForMenu()
    END IF

    IF menuKey = "5" THEN
      RunTestCollision()
      WaitForMenu()
    END IF

    IF menuKey = "6" THEN
      RunTestGameOver()
      WaitForMenu()
    END IF
  LOOP UNTIL menuKey = "0"
END SUB

' ── Standalone entry point ────────────────────────────────────────────────────
' Suppressed when compiled via launcher.bas (#define LAUNCHER_MODE).

#ifndef LAUNCHER_MODE
RunTestSuite()
#endif
