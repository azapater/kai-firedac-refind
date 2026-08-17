# 04 — Structural FireDAC wiring

**When:** the reFind pass is done and its report looked sane.
**Fill in:** `<PROJECT>`, `<OUT>`, and the target connection details.
**Open in the IDE:** the project file inside `<OUT>`.

reFind renames identifiers. It cannot build a connection, and it cannot know which driver you are targeting. This is the step that turns renamed code into something that can open a database.

Copy everything inside the fence:

```text
The reFind pass on <OUT> is done. Wire up FireDAC so the project can connect, with the minimum edits needed to attempt a build.

TARGET CONNECTION:
- DriverID:
- Server or host:
- Database:
- Connection definition name to use consistently:
- Credentials: prompt at runtime | read from existing configuration | ask me
If any of these are blank, take them from the Migration Brief and tell me exactly what you assumed.

REQUIRED WORK:

1) The connection component
- Make it a TFDConnection using the connection definition name above, either through ConnectionDefName plus an FDConnectionDefs.ini entry, or through DriverID plus Params set on the component. Say which you chose and why.
- Set LoginPrompt to match the credentials decision above.
- Keep the PAS and the DFM consistent with each other.

2) Plumbing reFind cannot add
- TFDGUIxWaitCursor, from FireDAC.VCLUI.Wait, FireDAC.FMXUI.Wait or FireDAC.ConsoleUI.Wait, whichever suits this project.
- The TFDPhysXxxDriverLink for the target driver.
Both are runtime requirements. Without them the project compiles and then fails the first time it opens a connection, which is a confusing way to find out.

3) Obsolete bootstrap code
- Alias creation, ini loading, driver registration, session setup: neutralise the body but keep the routine, so its callers still link. Leave a comment saying what it used to do and why FireDAC does not need it.

4) Datasets left pointing at nothing
- Anything that referenced the old connection by name should now reference the FireDAC connection.

RULES:
- Minimum edits. The goal is a project that can attempt a build, not a redesign.
- Do not mass-edit forms unless the build forces it.
- Do not change SQL text, business logic or UI.
- Do not write credentials into source that is under version control. Ask me instead.

OUTPUT:

# Structural finish — <PROJECT>
- Files changed, one line of reasoning each
- Connection configuration: the exact DriverID and Params, credentials masked
- Components added, and where they live
- Bootstrap code neutralised, and what it did before
- Still manual: the first entries in the Leftover Log

Stop here. Do not start the compile-fix loop yet.
```

## Check before moving on

Ask for the connection settings in full and read them. This is the one step where a plausible-looking answer with the wrong `DriverID` or a guessed server name will cost you an hour in the next step, wearing the costume of a compile error.
