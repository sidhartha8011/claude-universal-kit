---
description: Root-cause debugging — find the mechanism before fixing
argument-hint: <symptom — what's broken>
---

Something is broken. Find the root cause — the mechanism, not the symptom —
before changing any code, reproducing it first if at all possible. Then
apply the minimal fix, prove the repro now passes, and leave behind a
regression test that would have caught it.

SYMPTOM: $ARGUMENTS
