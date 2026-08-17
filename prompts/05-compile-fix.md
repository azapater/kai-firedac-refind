# 05 — Compile-fix loop

**When:** the structural wiring is in place.
**Fill in:** `<PROJECT>`, `<OUT>`.
**Where:** in the IDE, with the migrated project open, so the agent can read real compiler output.

This is the step that used to be measured in weeks. It works because the agent can see the error list, not because it is clever.

Copy everything inside the fence:

```text
Build <PROJECT> in <OUT> and drive a compile-fix loop until it builds.

HARD RULES:
- Fix in batches and rebuild after each batch. Report the error count every round so we can both see it falling.
- Prefer edits in PAS over redesigning DFMs.
- If the same legacy symbol fails across many units, stop. Propose an additive reFind rule for it and tell me whether re-running reFind from a fresh copy is cheaper than the hand edits. Do not quietly hand-edit fifty files.
- Never change SQL, business logic or UI behaviour to make an error go away. If a fix would change behaviour, stop and ask.
- If an API is one the official template marks unsupported, it belongs in the Leftover Log with a proposed approach. Do not guess a replacement.
- If the error count stops falling for two rounds, stop and tell me what is blocking, rather than trying variations.

LOOP:
1) Build.
2) Triage the errors: missing unit, renamed member, leftover legacy API, DFM type mismatch, or a semantic change that needs a decision.
3) Fix one batch.
4) Repeat until the build is clean.

WHEN THE BUILD IS GREEN:

# Compile-fix — <PROJECT>
## Build
- Result: SUCCESS | FAILED
- Rounds, with the error count at each one

## Fixes applied
- file: what changed, grouped by triage category

## Leftover Log
- Everything that was not a one-to-one migration, with the FireDAC approach taken, or still open

## Smoke test
Derive this from this application's own main screens, not from a generic list. For each item, say what to open and what result proves it worked.
- [ ] ...
```

## After it goes green

A clean build is not a finished migration. The wait cursor, the driver link and the connection definition all fail at runtime rather than at compile time, so run the smoke test before you believe the result. Then keep the Leftover Log: it is the backlog for the hardening pass, and it is the honest answer when someone asks what the migration did not cover.
