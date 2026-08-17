# 01 — Scout (Migration Brief)

**When:** the environment check passed and the project is open.
**Fill in:** `<PROJECT>`.
**Produces:** a Migration Brief. Save it as `MigrationBrief.md` in the project folder; every later prompt refers back to it.

The searches below cover all four legacy stacks on purpose. Let the hit counts decide which one you are on rather than assuming. Trim the lists if you already know, but leaving them in costs one extra search and catches mixed stacks.

Copy everything inside the fence:

```text
You are helping migrate <PROJECT> (the open project) to FireDAC using Embarcadero reFind. This step is analysis only.

HARD RULES:
- Do not read the whole codebase. Search first, then open a small, named set of files.
- Do not propose rewriting anything yet. Do not run reFind.
- The legacy libraries may not be installed on this machine. Source-level analysis is enough.
- Report counts you actually measured. If a search returns nothing, say zero.

STEP 1 — Hit counts across the project tree, as integers.

BDE:        TDatabase, TSession, TTable, TQuery, TStoredProc, TBatchMove, TUpdateSQL,
            Bde.DBTables, DBTables, AliasName, SessionName, PrivateDir
ADO:        TADOConnection, TADOQuery, TADOTable, TADOStoredProc, TADOCommand, TADODataSet,
            Data.Win.ADODB, ADODB, ConnectionString, Provider=
dbExpress:  TSQLConnection, TSQLQuery, TSQLDataSet, TSQLTable, TSQLStoredProc, TSQLMonitor,
            TSimpleDataSet, Data.SqlExpr, SqlExpr, dbxconnections.ini, GetDriverFunc
IBX:        TIBDatabase, TIBTransaction, TIBQuery, TIBTable, TIBDataSet, TIBStoredProc, TIBSQL,
            TIBEvents, IBX.IBDatabase, IBDatabase, SQLDialect
Shared:     DatabaseName, TClientDataSet, TDataSetProvider

STEP 2 — Find and open only these, by role, not by guessing file names:
- the unit that opens or configures the database connection
- every data module
- the two or three forms with the most dataset components
- any unit declaring a descendant of a legacy dataset or connection class
Name the files you opened. If a role has no match, say so.

STEP 3 — Write the brief using exactly this structure. Fill every section.

# Migration Brief — <PROJECT>

## Stack
- Primary: BDE | ADO | dbExpress | IBX | mixed
- Evidence: units and types, with counts
- Secondary stack, if any:

## Surface area
- Units / forms / data modules (order of magnitude is fine)
- Data modules:
- Custom dataset or connection descendants:

## Connection
- Mechanism: BDE alias | ini file | connection string | hard-coded params | other
- Values found (alias name, driver, server, database; mask credentials):
- Unit(s) that open the connection:
- Target FireDAC driver:

## Risks and leftovers
Things reFind cannot fix, one line each, worst first.
1.
2.
3.

## Official template to start from
- File:
- Why:

## Suggested additive rules
- Themes only at this stage: house wrappers, obsolete units, project-specific properties, or none.

## Method
- Files opened:
- Searches run:
- Confirm you did not read the whole tree.

Stop after the brief. Do not customise rules or run reFind yet.
```

## What a good answer looks like

- The stack claim is backed by the counts above it.
- Custom descendants are named, with their ancestor.
- The connection section has real values from the source, not a description of how the library usually works.
- The risk list contains things the rule file genuinely cannot express: alias bootstrap code, batch move wiring, provider-specific APIs, local table formats.
