# Prompts

Seven prompts covering one migration, in order. Each file has a short header explaining when to use it, then a single fenced block to copy into your agent.

They are starting points. The searches in [01-scout.md](01-scout.md) and the checks in [04-structural-finish.md](04-structural-finish.md) are the two you will most often want to edit for your own codebase: add your own base classes, your own connection helper, your own naming conventions. Everything else tends to survive contact with a real project unchanged.

## Order

| # | File | Purpose | Roughly |
|---|------|---------|---------|
| 0 | [00-setup.md](00-setup.md) | Find reFind.exe and the official templates, check version control | 2 min |
| 1 | [01-scout.md](01-scout.md) | Migration Brief: stack, surface area, connection, risks | 10-20 min |
| 2 | [02-tailor-rules.md](02-tailor-rules.md) | Official template plus a small additive section | 10 min |
| 3 | [03-run-refind.md](03-run-refind.md) | Copy the sources, run reFind, verify the pass | 5 min |
| 4 | [04-structural-finish.md](04-structural-finish.md) | Connection definition, driver link, wait cursor | 20-40 min |
| 5 | [05-compile-fix.md](05-compile-fix.md) | Build until green, then a smoke checklist | the rest of the day |
| 6 | [06-leftover-audit.md](06-leftover-audit.md) | Optional: what the template says it does not cover | 10 min |

Steps 0 to 3 are cheap and reversible. Step 5 is where the time goes, and how much time depends almost entirely on how honest step 1 was.

## Placeholders

Fill these in before pasting. Prompt 0 produces most of them.

| Placeholder | Meaning | Example |
|-------------|---------|---------|
| `<PROJECT>` | What you call the application | `Ops` |
| `<STACK>` | Detected source library | `BDE`, `ADO`, `DBX`, `IBX` |
| `<SRC>` | Folder holding the original sources | `C:\src\Ops` |
| `<OUT>` | Folder for the migrated copy | `C:\src\Ops_FireDAC` |
| `<RULES>` | Your tailored rule file | `C:\src\FireDAC_Migrate_BDE_Ops.txt` |
| `<REFIND>` | Path to reFind.exe | `C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\reFind.exe` |

## How to use them

1. Copy only the fenced block. The text around it is for you, not the agent.
2. Attach or `@`-mention the files a prompt names: the official rule file, the Migration Brief, the compiler output.
3. Save the Migration Brief to disk. Later prompts and later sessions read it instead of re-scouting, which is the single biggest saving in the whole workflow.
4. Do not paste the next prompt until you have read the output of the last one.

If you installed the skills, you can skip most of this and just say what you want: the agent will follow the same workflow. The prompts are the manual, reviewable version of the same thing, and are useful when you want to run one step in isolation or with an agent that has no skill support.

## Reading the answers

Things that mean the answer is not trustworthy, roughly in order of how often they happen:

- **Claims to have read the whole project.** The scout prompt exists to prevent this. An agent that swallowed a thousand units has a shallow view of all of them and will confidently misreport the connection mechanism.
- **Names a stack the hit counts do not support**, or quietly picks one when the counts show two. Mixed stacks are common in old applications and change the plan.
- **Rewrites the official template** instead of appending to it. Diff the file. The stock rules should be byte-identical.
- **Invents a `#migrate` for an API the template lists as unsupported.** Those are marked unsupported because the semantics differ; a rename produces code that compiles and behaves differently.
- **Reports the connection as "typical for BDE" rather than quoting values from your source.** If it did not find the alias name, it did not open the right file.
- **Hand-edits the same error in twenty files.** That is a rule that should have been in the file, and a sign the loop is grinding rather than converging.
- **Fixes a compile error by changing SQL or business logic.** Building is not the goal; building and behaving the same is.
