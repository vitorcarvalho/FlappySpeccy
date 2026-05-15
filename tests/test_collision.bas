' =============================================================================
' tests/test_collision.bas
' Unit test — CheckCollision() in src/game/collision.bas
'
' Fully automated — no user interaction required.
' Green = PASS, red = FAIL.  Press any key to exit.
'
' Test cases:
'   1. Safe position   — clear screen, birdRow=10, birdCol=4 → expect 0
'   2. Floor hit       — set birdRow=22                       → expect 1
'   3. Pipe hit        — POKE green attr at bird cell         → expect 1
'   4. Pipe cleared    — POKE white attr back                 → expect 0
'
' Technique: The test POKEs the attribute byte at (22528 + row*32 + col)
' directly to simulate a pipe (INK 4 = green, attr value 4) without needing
' to draw actual pipes on screen.
'
' Compile:  make tests
' Run:      make run-test-collision
' =============================================================================

#include "assert_helpers.bas"
#include "../src/game/physics.bas"
#include "../src/game/collision.bas"

SUB RunTestCollision()
  DIM attrAddr AS INTEGER

  ' ── Screen setup ────────────────────────────────────────────────────────────
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; "TEST: Collision"
  PRINT INK 5;           "───────────────"
  PRINT

  passed = 0
  failed = 0

  ' Place bird at a safe interior position (row 10, col 4)
  InitPhysics()
  birdRow = 10
  birdCol = 4
  attrAddr = 22528 + birdRow * 32 + birdCol

  ' ── Test 1: Safe position — clear screen, no green attr → no collision ──────
  ' CLS above set all attrs to INK 7 (white); (7 AND 7)=7 ≠ 4 → safe
  AssertEq("safe pos: no collision expected", 0, CheckCollision())

  ' ── Test 2: Floor hit — birdRow = 22 → collision ────────────────────────────
  birdRow = 22
  AssertEq("floor hit: row 22 → collision  ", 1, CheckCollision())
  birdRow = 10   ' restore

  ' ── Test 3: Pipe hit — POKE green attr at bird cell → collision ──────────────
  ' INK 4 (green), PAPER 0, no BRIGHT/FLASH → raw attr byte = 4
  POKE attrAddr, 4
  AssertEq("pipe hit: green attr → collision", 1, CheckCollision())

  ' ── Test 4: Pipe cleared — restore white attr → no collision ────────────────
  ' INK 7 (white), PAPER 0 → raw attr byte = 7
  POKE attrAddr, 7
  AssertEq("pipe gone: attr 7 → no collision", 0, CheckCollision())

  ' ── Summary ─────────────────────────────────────────────────────────────────
  PRINT
  IF failed = 0 THEN
    PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
  ELSE
    PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
  END IF

END SUB

#ifndef SUITE_MODE
RunTestCollision()
PAUSE 0
#endif
