---
name: firedac-migrate
description: >-
  Migrate a Delphi or C++Builder application from BDE, ADO, dbExpress or IBX to
  FireDAC using Embarcadero's official reFind rule templates, a small additive
  rule section for project-specific identifiers, bulk reFind execution on a copy
  of the sources, and a compile-fix loop in the IDE. Use when the user asks to
  migrate to FireDAC, run a reFind migration, or replace TQuery, TDatabase,
  TADOQuery, TADOConnection, TSQLQuery, TSQLConnection, TIBQuery or TIBDatabase
  usage with FireDAC components.
license: MIT
metadata:
  version: "1.0"
  pack: firedac-refind-pack
---

# FireDAC migration with reFind

Take a legacy data-access application to a **building FireDAC baseline** using, in order:

1. The official Embarcadero `FireDAC_Migrate_*.txt` template as the foundation
2. A small additive rule section for identifiers the template cannot know about
3. `reFind.exe` for the bulk PAS/DFM transform
4. Structural FireDAC wiring and a compile-fix loop for everything reFind cannot express

`references/stack-map.md` has the per-stack detection symbols, template paths, driver links and the leftovers each stack typically produces. Read it once the stack is known.

## What this skill will not do

- It will not rewrite APIs the official template marks `Not supported`. Those need a decision, and the decision is the user's.
- It will not author a rule file from scratch. Rules come from the installed Samples; you only append.
- It will not read the whole tree. Search and sample instead.

## Hard rules

- Work on a branch and migrate a **copy** of the sources. Edit in place only if the user explicitly asks for it.
- Template-first, additive-only: never delete, reorder or reword stock rules.
- Treat every rule line you write as a draft. Show it to the user, with a reason, before it runs.
- Confirm the reFind command line (masks, rule file, target folder) before executing it.
- After reFind, assume connection setup and unsupported APIs are still open work.
- DFM edits: if you have IDE-aware file tools, use them and keep the paired PAS focused. Otherwise make sure the form is closed in the designer before editing the DFM as text.
- Do not rewrite credentials found in connection strings or `Params` unless asked to.

## Step 0 — Environment

Report these before anything else:

- **reFind.exe** — `<Studio>\bin\reFind.exe`, for example `C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\reFind.exe`. Run it with no arguments to confirm the version and the rule grammar it supports.
- **Official templates** — `C:\Users\Public\Documents\Embarcadero\Studio\<ver>\Samples\Object Pascal\Database\FireDAC\Tool\reFind`. `<ver>` changes with each major release.
- **Version control** — current branch, and whether the working tree is clean.
- **Paths** — source folder and the output folder the migrated copy will go to.

If the Samples tree does not exist, Samples were not selected when RAD Studio was installed. Say so and stop: without the official template there is nothing to build on.

## Step 1 — Scout

Do not open every unit. Search first, then read a handful of files.

- Count hits for the legacy type families in `references/stack-map.md` and let the counts decide the stack. Mixed stacks are common; call that out instead of picking one.
- Open a small representative set: the unit that opens the connection, the data modules, two or three of the busiest forms, and any custom dataset or connection descendants.
- Record how the connection is configured: BDE alias, `dbxconnections.ini`, ADO connection string, IBX database path and `Params`, or values hard-coded in the DFM.
- List custom descendants (`TMyQuery = class(TQuery)` and similar). They decide the wrapper strategy in step 3.

Produce a **Migration Brief**: stack and evidence, surface area, connection mechanism, custom wrappers, risks, and which official template to start from. Keep it in a file so later steps and later sessions can reuse it instead of re-scouting.

## Step 2 — Choose the template

Map the detected stack to the installed template (see `references/stack-map.md`). Copy it to a working file named after the project, for example `FireDAC_Migrate_BDE_MyApp.txt`. Never edit the file inside the Samples tree.

Read the comments in the template before continuing. They document what the rules deliberately do not cover, which is the risk list for step 5 and 6.

## Step 3 — Customise (additive)

Only if the brief found something the stock rules do not cover: house wrappers, project-specific property names, obsolete units of your own.

- Append one clearly marked section at the end of the copied file. Leave the stock rules untouched.
- One `;` comment line per added rule, saying why it exists.
- Prefer class-qualified `#migrate` over bare renames, and prefer boring rules over clever regex.
- **Wrappers**: if `TMyQuery` descends from `TQuery`, the stock rules already migrate the ancestor, so the wrapper keeps working and its name stays valid in every DFM. Flattening the wrapper to `TFDQuery` is a bigger change; do it only if the user asks.
- Summarise the added lines for the user before running anything.

The `refind-rulesmith` skill covers rule drafting in detail, including how to turn recurring compiler errors into a rule.

## Step 4 — Run reFind

Create the output folder, copy the sources into it, then run reFind against the copy:

```bat
reFind.exe <Out>\*.pas <Out>\*.dfm /S /X:<rules.txt>
```

- Add `*.fmx` for FireMonkey projects, and extra masks for `*.inc` or `*.dpr` if the legacy types appear there.
- `/S` recurses. Without it, subfolders are skipped.
- reFind writes a `.bak` beside each changed file and **by default refuses to touch a file that already has one**. Re-running on the same folder therefore does nothing. Start from a fresh copy, or pass `/B:1`.
- Report the exact command, the file count and any failures.

Then spot-check the copy: the connection unit, one data module and one wrapper unit. Confirm the type renames landed, the legacy unit left the `uses` clause, and the DFM still parses.

## Step 5 — Structural FireDAC setup

reFind renames identifiers; it cannot build a connection. Expect to do this by hand, guided by the brief:

- Turn the old connection settings into FireDAC ones: `ConnectionDefName` plus an `FDConnectionDefs.ini` entry, or explicit `DriverID` and `Params` on the connection component.
- Add `TFDGUIxWaitCursor` (VCL, FMX or console flavour) and the `TFDPhysXxxDriverLink` for the target RDBMS.
- Neutralise obsolete bootstrap code: alias creation, ini loading, driver registration.
- Keep the edits minimal. The goal of this step is a project that can attempt a build, not a redesign.

## Step 6 — Compile-fix

Build, then work in batches:

1. Build and collect the errors.
2. Triage: missing unit, renamed member, leftover legacy API, DFM type mismatch, semantic change.
3. Fix a batch, rebuild, repeat.

If the same legacy symbol fails across many units, stop hand-editing. Add a rule, throw the copy away and re-run reFind from the original sources. Fifty identical hand edits is a sign the rule file is incomplete.

Keep a **Leftover Log** of anything that is not a one-to-one migration, with the file, the pattern and the FireDAC approach chosen.

## Step 7 — Done

- The project builds.
- The application connects.
- The user has: the Migration Brief, the rule file used and its added lines, the exact reFind command, the Leftover Log, and a smoke-test checklist derived from the application's own main screens.
