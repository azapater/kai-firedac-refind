---
name: refind-rulesmith
description: >-
  Draft small, reviewable additions to an Embarcadero reFind rule file, using
  #migrate, #unuse, #remove, #replaceunit or PCRE patterns, starting from the
  official FireDAC_Migrate_*.txt templates. Use when customising reFind rules for
  a specific project, covering house-built dataset or connection wrappers, or
  turning a compiler error that repeats across many units into one bulk rule.
license: MIT
metadata:
  version: "1.0"
  pack: firedac-refind-pack
---

# reFind rule smith

Propose **small, reviewable** additions to an official reFind template so the bulk pass also covers identifiers that only exist in this project.

`references/refind-syntax.md` has the directive grammar, the command-line switches and the behaviour that catches people out. Read it before writing a rule you are not sure about.

## Inputs

- The official template being extended (`FireDAC_Migrate_BDE.txt`, or the ADO, DBX or IBX equivalent) from the installed Samples tree.
- Evidence: a migration brief, a symbol list, or the compiler errors from a build after a reFind pass.
- Ideally, a PAS or DFM snippet showing the pattern in context.

Without evidence, do not guess. Ask for the snippet.

## Rules of the craft

1. **Additive only.** Keep the official file intact and append one clearly marked section, for example `; --- MyApp additions (reviewed) ---`.
2. Prefer `#migrate` over a raw PCRE pattern when renaming a Delphi identifier. `#migrate` understands `uses` clauses and can add the units the new type needs; a regex cannot.
3. Qualify by class when the identifier is ambiguous. `DatabaseName` on its own is a rename that will also hit unrelated code; `#migrate TQuery, TTable: DatabaseName -> ConnectionName` will not.
4. `#unuse` for units that disappear, `#replaceunit` for units that are replaced one-for-one, `#remove` for properties that must vanish from PAS and DFM.
5. If you do reach for PCRE, explain what it matches in one sentence and keep it narrow. Long patterns with nested lookarounds are a sign the rule wants to be several simpler ones.
6. Never bulk-rewrite passwords or connection secrets. If a pattern would touch credentials, say so and stop.
7. If the official template lists the API under `Not supported`, do not invent a `#migrate` for it. Recommend the code change instead, and say which file it belongs in.

## Wrappers

A house wrapper such as `TMyQuery = class(TQuery)` usually needs **no rule at all**. The stock rules migrate the ancestor, so the wrapper becomes a `TFDQuery` descendant and its type name stays valid everywhere it appears, including in every DFM.

Adding `#migrate TMyQuery -> TFDQuery` flattens the hierarchy instead: it deletes the wrapper from the design surface and any behaviour it carried with it. Propose that only when the user has asked for the wrapper to go.

## Output format

One block per proposed line, then the finished section:

```text
LINE:     #migrate ...
WHY:      one sentence
RISK:     low | medium | high, and why
VALIDATE: how to check it, for example a search that should return zero hits afterwards
```

Follow that with the complete additive section, ready to paste at the end of the copied template.

## Example section

```text
; --- MyApp additions (reviewed) ---
; Internal BDE helper unit, removed as part of the migration
#unuse MyCompany.BdeUtils
; Wrapper flattening requested by the team; ancestors would otherwise carry the migration
#migrate TAppQuery -> TFDQuery, FireDAC.Comp.Client
#migrate TAppDatabase -> TFDConnection, FireDAC.Comp.Client
; Wrapper property that shadowed the BDE name
#migrate TAppQuery: Database -> Connection
```

## When to refuse

Say what should be changed in code instead, and where, when:

- The change is semantic, not a rename. The old and new APIs behave differently.
- The symbol collides with unrelated types and cannot be qualified by class.
- There is one example and no way to tell whether the pattern generalises.

A rule that is wrong is worse than no rule: it runs across the whole tree in one pass, and the damage looks like a successful migration.
