' =============================================================================
' tests/assert_helpers.bas
' Shared assertion helpers for all test files.
'
' Include-guarded — safe to #include from multiple test files without
' causing duplicate SUB or variable definitions.
'
' Provides:
'   passed, failed               — integer counters; reset at start of each
'                                  RunTestXxx() call
'   AssertEq(label, exp, got)    — integers must be equal
'   AssertGT(label, thresh, got) — got must be > thresh
'   AssertLTE(label, thresh,got) — got must be <= thresh
'   AssertAttr(label, addr, exp) — PEEKs addr, compares with expected
' =============================================================================

#ifndef ASSERT_HELPERS_BAS
#define ASSERT_HELPERS_BAS

DIM passed AS INTEGER
DIM failed AS INTEGER

SUB AssertEq(label AS STRING, expected AS INTEGER, got AS INTEGER)
  IF expected = got THEN
    PRINT INK 4; "PASS "; INK 7; label
    passed = passed + 1
  ELSE
    PRINT INK 2; "FAIL "; INK 7; label
    PRINT INK 2; "     exp="; expected; "  got="; got
    failed = failed + 1
  END IF
END SUB

SUB AssertGT(label AS STRING, threshold AS INTEGER, got AS INTEGER)
  IF got > threshold THEN
    PRINT INK 4; "PASS "; INK 7; label
    passed = passed + 1
  ELSE
    PRINT INK 2; "FAIL "; INK 7; label
    PRINT INK 2; "     want >"; threshold; "  got="; got
    failed = failed + 1
  END IF
END SUB

SUB AssertLTE(label AS STRING, threshold AS INTEGER, got AS INTEGER)
  IF got <= threshold THEN
    PRINT INK 4; "PASS "; INK 7; label
    passed = passed + 1
  ELSE
    PRINT INK 2; "FAIL "; INK 7; label
    PRINT INK 2; "     want <="; threshold; "  got="; got
    failed = failed + 1
  END IF
END SUB

SUB AssertAttr(label AS STRING, addr AS INTEGER, expected AS INTEGER)
  DIM got AS INTEGER
  got = PEEK(addr)
  IF expected = got THEN
    PRINT INK 4; "PASS "; INK 7; label
    passed = passed + 1
  ELSE
    PRINT INK 2; "FAIL "; INK 7; label
    PRINT INK 2; "     exp="; expected; "  got="; got
    failed = failed + 1
  END IF
END SUB

#endif
