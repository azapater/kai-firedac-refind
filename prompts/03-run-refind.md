# 03 — Run reFind on a copy

**When:** the tailored rule file exists and you have read its added section.
**Fill in:** `<PROJECT>`, `<SRC>`, `<OUT>`, `<RULES>`, `<REFIND>`.

This is the destructive step. It is also the cheap one to redo: the originals are untouched, so if the result is wrong, delete the copy and run it again with better rules.

Copy everything inside the fence:

```text
Run the reFind pass for <PROJECT>. Work on a copy. Do not modify anything under <SRC>.

CONTEXT:
- Source tree: <SRC>
- Output tree: <OUT>
- Rule file:   <RULES>
- reFind.exe:  <REFIND>

STEPS:

1) If <OUT> already exists, list what is in it and ask me before deleting anything.

2) Create <OUT> and copy the whole source tree into it, subfolders included.

3) Show me the command before you run it. It should look like:

   <REFIND> <OUT>\*.pas <OUT>\*.dfm /S /X:<RULES>

   - add *.fmx for FireMonkey projects
   - add *.dpr, *.inc or *.dpk if the brief found legacy types in them
   - /S is required, or subfolders are skipped
   - reFind refuses to touch a file that already has a .bak beside it, so this has to run on a fresh copy

4) Run it and capture the output.

5) Spot-check the copy by role rather than by file name: the connection unit, one data module, one form, and one custom descendant if the brief found any. For each, report what changed and what did not.

6) Search <OUT> for the legacy types listed in the brief and report the counts that remain. Explain every non-zero count.

OUTPUT:

# reFind pass — <PROJECT>
- Command run:
- Files changed:
- Errors or warnings:
- Spot checks: file, before, after
- Legacy symbols remaining: symbol, count, why
- Next step: structural FireDAC wiring

Stop after the report. Do not start fixing compile errors yet.
```

## Reading the result

Some legacy hits will remain, and that is expected: comments, string literals, unit names in `uses` clauses that the rules deliberately leave alone, and APIs the template marks unsupported. What you are looking for in step 6 is a hit the agent cannot explain. That usually means a mask was missing, `/S` was left off, or the copy was not fresh.
