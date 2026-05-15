' =============================================================================
' tests/test_physics.bas
' Unit test — InitPhysics() and UpdatePhysics() in src/game/physics.bas
'
' Fully automated — no user interaction required.
' Green = PASS, red = FAIL.  Press any key to exit.
'
' Test cases:
'   1. InitPhysics()   — birdRow=11, birdVel=0, birdCol=4
'   2. Gravity         — 5 no-flap ticks → bird falls (birdRow > 11)
'   3. Flap            — UpdatePhysics(1) sets vel to -3 then +1 gravity = -2
'                        → birdRow rises to 9 from row 11
'   4. Velocity clamp  — 10 gravity-only ticks → birdVel never exceeds 3
'   5. Floor clamp     — 20 gravity-only ticks → birdRow never exceeds 22
'   6. Ceiling clamp   — 10 flap-every-tick ticks → birdRow never goes below 2
'
' Compile:  make tests
' Run:      make run-test-physics
' =============================================================================

#include "assert_helpers.bas"
#include "../src/game/physics.bas"

SUB RunTestPhysics()
  DIM i AS INTEGER

  ' ── Screen setup ────────────────────────────────────────────────────────────
  BORDER 0 : PAPER 0 : INK 7 : BRIGHT 0 : FLASH 0 : CLS
  PRINT BRIGHT 1; INK 6; "TEST: Physics"
  PRINT INK 5;           "─────────────"
  PRINT

  passed = 0
  failed = 0

  ' ── Test 1: InitPhysics ─────────────────────────────────────────────────────
  InitPhysics()
  AssertEq("init: birdRow = 11", 11, birdRow)
  AssertEq("init: birdVel = 0 ",  0, birdVel)
  AssertEq("init: birdCol = 4 ",  4, birdCol)

  ' ── Test 2: Gravity — 5 no-flap ticks ────────────────────────────────────
  ' t1: vel=1 row=12  t2: vel=2 row=14  t3: vel=3 row=17
  ' t4: vel=3 row=20  t5: vel=3 row=22 (clamped)
  InitPhysics()
  FOR i = 1 TO 5
    UpdatePhysics(0)
  NEXT i
  AssertGT("gravity: birdRow > 11 after 5 ticks", 11, birdRow)

  ' ── Test 3: Flap ──────────────────────────────────────────────────────────
  ' From row 11, vel 0: flap → vel=-3, gravity +1 → vel=-2, row=9
  InitPhysics()
  UpdatePhysics(1)
  AssertEq("flap: birdVel = -2 after flap+gravity", -2, birdVel)
  AssertEq("flap: birdRow rises to 9",               9, birdRow)

  ' ── Test 4: Velocity clamp (max +3) ───────────────────────────────────────
  InitPhysics()
  FOR i = 1 TO 10
    UpdatePhysics(0)
  NEXT i
  AssertLTE("vel clamp: birdVel <= 3", 3, birdVel)

  ' ── Test 5: Floor clamp (max row 22) ──────────────────────────────────────
  InitPhysics()
  FOR i = 1 TO 20
    UpdatePhysics(0)
  NEXT i
  AssertLTE("floor clamp: birdRow <= 22", 22, birdRow)

  ' ── Test 6: Ceiling clamp (min row 2) ─────────────────────────────────────
  ' Flap every tick for 10 ticks — bird should be pushed hard toward the ceiling.
  ' birdRow must stay >= 2 (row 1 is the ceiling bar; bird must not enter it).
  InitPhysics()
  FOR i = 1 TO 10
    UpdatePhysics(1)
  NEXT i
  AssertGT("ceil clamp: birdRow >= 2  ", 1, birdRow)

  ' ── Summary ─────────────────────────────────────────────────────────────────
  PRINT
  IF failed = 0 THEN
    PRINT BRIGHT 1; INK 4; "ALL "; passed; " TESTS PASSED"
  ELSE
    PRINT BRIGHT 1; INK 2; failed; " FAILED  "; INK 4; passed; " PASSED"
  END IF

END SUB

#ifndef SUITE_MODE
RunTestPhysics()
PAUSE 0
#endif
