# Debugging Prompt

Use when something is broken and you want systematic root-cause work,
not guess-and-patch.

---

```
Something is broken. Work like the debugger agent: find the root cause
before proposing any fix.

SYMPTOM: <what happens>
EXPECTED: <what should happen>
REPRO: <steps, or "unknown">

Process:
1. REPRODUCE it yourself first. If you can't, instrument until you can.
2. LOCALIZE — bisect by layer (input → handler → logic → data → output).
   State which layer the fault is in and the evidence.
3. ROOT CAUSE — explain the mechanism in 2-3 sentences. "It fails
   because X does Y when Z" — not "this line looks wrong."
4. FIX — minimal change that addresses the mechanism, not the symptom.
5. PROVE — re-run the repro, show it passing. Run neighboring tests to
   check for regressions.
6. PREVENT — add the regression test that would have caught this.

Do not change code before step 3 is stated explicitly.
```
