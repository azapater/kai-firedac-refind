# 00 — Environment check

**When:** before anything else, with your project open in the IDE.
**Produces:** the paths the later prompts need, and an early answer to "are the Samples even installed?".

Copy everything inside the fence:

```text
Before we start a FireDAC migration with reFind, confirm the environment. Report only what you actually verify. Do not guess paths.

STEP 1 — reFind.exe
- Look for it in the RAD Studio bin folder, typically:
  C:\Program Files (x86)\Embarcadero\Studio\<ver>\bin\reFind.exe
- Run it with no arguments and report the version line and the rule directives it lists.

STEP 2 — Official rule templates
- Look for:
  C:\Users\Public\Documents\Embarcadero\Studio\<ver>\Samples\Object Pascal\Database\FireDAC\Tool\reFind
- List the migration subfolders you find there.
- If the folder does not exist, say so plainly: the Samples were not selected when RAD Studio was installed, and the official templates are the foundation of this workflow. Stop and tell me to install them.

STEP 3 — Version control
- Report the repository type, the current branch, and whether the working tree is clean.
- If the project is not under version control, say so and recommend a committed baseline before we touch anything.

STEP 4 — Paths
- The source folder holding the project file and units.
- A proposed output folder for the migrated copy, as a sibling of the source.

OUTPUT — exactly this structure:

# Environment check
- reFind.exe: <path> (version <n>)
- Samples reFind tree: <path> | MISSING
- Templates available: <list of subfolders>
- Repository: <type>, branch <name>, working tree clean | dirty
- Source folder: <path>
- Output folder (proposed): <path>
- Ready to scout: yes | no, and why

Stop after the report. Do not read project source yet.
```

Keep the four paths from the report. The rest of the prompts refer to them as `<REFIND>`, `<RULES>`, `<SRC>` and `<OUT>`.
