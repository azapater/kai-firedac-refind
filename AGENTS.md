# FireDAC migration with reFind

Fallback instructions for agents that read `AGENTS.md` but do not support skill folders. Copy this file into your project root, next to the `.dproj`, and the workflow below applies to every session there.

If your agent does support skills, install the pack's `skills` folder instead. The skills carry the same workflow with more detail, and load only when it is relevant rather than sitting in context all the time.

## Context

This project is being migrated from a legacy data-access library (BDE, ADO, dbExpress or IBX) to FireDAC, using `reFind.exe` from the RAD Studio `bin` folder and the official rule templates under:

```
C:\Users\Public\Documents\Embarcadero\Studio\<ver>\Samples\Object Pascal\Database\FireDAC\Tool\reFind
```

If that folder does not exist, Samples were not installed. Say so and stop, rather than writing a rule file from memory.

## Rules

- Work on a branch, and run reFind over a **copy** of the sources. Never in place unless explicitly asked.
- Start from the official template for the detected stack. Append one clearly marked section for project-specific rules; never edit or reorder the stock rules.
- Do not read the whole tree. Search for the legacy types, then open the connection unit, the data modules and a few busy forms.
- Show any rule you write, with a reason, before it runs. Confirm the reFind command line before executing it.
- If the official template lists an API as not supported, it needs a code change and a decision, not an invented rule.
- Never rewrite credentials found in connection strings or params.
- Do not change SQL, business logic or UI to make an error go away.

## Workflow

1. **Environment.** Locate `reFind.exe` and the Samples template tree. Report the branch and whether the tree is clean.
2. **Scout.** Count hits for the legacy types, open a small named set of files, and write a Migration Brief: stack, surface area, connection mechanism, custom descendants, risks, and which template to start from. Save it to disk.
3. **Rules.** Copy the official template, append project-specific rules if the brief found any, and summarise them. Having nothing to add is a valid outcome.
4. **Run reFind.** Copy the tree, run `reFind.exe <Out>\*.pas <Out>\*.dfm /S /X:<rules>`, then spot-check and report what legacy symbols remain and why. Note that reFind skips files that already have a `.bak`, so the copy must be fresh.
5. **Wire up FireDAC.** Connection definition from the old settings, `TFDPhysXxxDriverLink`, `TFDGUIxWaitCursor`, and neutralise obsolete alias or ini bootstrap code. Minimum edits.
6. **Compile-fix.** Build, triage, fix in batches, rebuild. If the same symbol fails across many units, propose a rule and re-run reFind from a fresh copy instead of hand-editing.

Deliver the Migration Brief, the rule file and its additions, the exact reFind command, a log of everything that was not a one-to-one migration, and a smoke-test checklist based on this application's own screens.
