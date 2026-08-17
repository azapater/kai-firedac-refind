# 02 — Tailor the rule file

**When:** the Migration Brief is written.
**Attach:** the official `FireDAC_Migrate_*.txt` for your stack, from the installed Samples, and the brief.
**Fill in:** `<PROJECT>`, `<STACK>`, `<RULES>` (where the tailored file should be written, for example `FireDAC_Migrate_BDE_MyApp.txt` next to the project).

Copy the official template out of the Samples tree first. Never edit the file in place.

Copy everything inside the fence:

```text
You are customising Embarcadero reFind rules for the <STACK> to FireDAC migration of <PROJECT>.

INPUTS:
- The official rule file, attached. It is the source of truth for the bulk renames.
- The Migration Brief from the scout step, attached.

HARD RULES:
- Template first: start from a complete, unmodified copy of the official file.
- Append exactly one clearly marked section at the end. Do not delete, reorder or reword stock rules.
- Prefer the directives over raw regular expressions: #migrate, #unuse, #remove, #replaceunit. Use a regex only when no directive fits, and explain in one sentence what it matches.
- Qualify by class when the identifier is ambiguous. Write
    #migrate TQuery, TTable: DatabaseName -> ConnectionName
  rather than a bare rename that will also hit unrelated code.
- Every added rule gets a `;` comment line above it saying why it exists.
- Wrappers: a class that descends from a legacy dataset or connection type usually needs no rule at all. The stock rules migrate its ancestor, so the wrapper keeps working and its type name stays valid in every DFM. Flatten a wrapper to a FireDAC type only if the brief asks for it. State which you chose and why.
- Do not put connection wiring in the rule file. That is the next step.
- If the official template lists an API under "Not supported", do not invent a rule for it. Put it in the manual list instead.
- If the brief turned up nothing the stock rules miss, say so and use the official file unchanged. That is a valid outcome, and better than inventing rules.

OUTPUT — two parts.

PART A, in chat:

### Added rules
| Rule | Why | Risk |
|------|-----|------|
| ... | ... | low / medium / high |

### Wrapper strategy
- Keep wrappers | Flatten to FireDAC types, and one sentence of justification.

### Left for manual work
- Bullets. Connection definition, driver links, wait cursor, unsupported APIs, data that has to move.

PART B, written to disk as <RULES>:
1. The complete official rule file, unchanged.
2. This banner:

; =============================================================================
; <PROJECT> additions, generated from the Migration Brief
; Review before running reFind
; =============================================================================

3. The added rules, each under its comment line.

Stop after writing the file. Do not run reFind yet.
```

## Before you accept the file

Diff it against the official template. The only difference should be your new section at the end. If stock rules moved, changed or vanished, reject the file and ask again.
