# 06 — Leftover audit (optional)

**When:** after a green build, or earlier if you want the risk list before committing to the migration.
**Attach:** the official `FireDAC_Migrate_*.txt` for your stack.
**Fill in:** `<PROJECT>`, `<SRC>`, `<OUT>`.

The comment lines in the official templates are a list of things Embarcadero decided the rules should not attempt: helpers with different semantics, APIs with no FireDAC equivalent. That list is more useful as a checklist than as documentation.

Copy everything inside the fence:

```text
Audit <PROJECT> against the gaps the official rule file documents.

INPUTS:
- The official rule file, attached. Its `;` comment lines list helpers and APIs marked as not supported.
- Before: <SRC>
- After:  <OUT>

HARD RULES:
- Work from the symbols named in those comments, plus the risks recorded in the Migration Brief. Do not invent a list of your own and do not re-read the whole tree.
- Every row cites a file and a line.
- Rank by the risk of silently wrong behaviour at runtime, not by how often the symbol appears.
- If something is listed as unsupported but this project never used it, leave it out rather than padding the table.

OUTPUT:

# Leftover audit — <PROJECT>

## Documented gaps present in the original
| Pattern | File and line | Risk | FireDAC approach |
|---------|---------------|------|------------------|

## Still present after migration
| Pattern | File and line | Status: fixed / stubbed / open |
|---------|---------------|--------------------------------|

## Deal with these first
Three at most, in order, with one sentence each on what goes wrong if you do not.
1.
2.
3.
```

## Why this is worth ten minutes

Every item here comes from Embarcadero's own template comments, so the list is not a model's opinion about your code. It is also the part of a migration that is easiest to skip and most expensive to discover later, because none of it breaks the build.
