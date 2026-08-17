# reFind syntax and behaviour

`reFind.exe` lives in the RAD Studio `bin` folder. Run it with no arguments to print the usage for the installed version and confirm the grammar below.

## Command line

```
reFind <filemasks> [/S] [/Y] [/B:0|1|2] [/V:0|1|2] [/C] [/I] [/W] [/L]
       [/P:<searchpattern> /R:<replacepattern>] [/X:<rule filename>]
```

| Switch | Effect |
|--------|--------|
| `/S` | Recurse into subdirectories. Without it, only the folder named by the mask is processed. |
| `/Y` | Modify read-only files too. |
| `/B:0` | If a `.bak` already exists, **skip the file**. This is the default. |
| `/B:1` | Overwrite the existing `.bak`. |
| `/B:2` | Do not create `.bak` files at all. |
| `/V:0` `/V:1` `/V:2` | Output: silent, normal, extended. `/V:2` lists what changed and is the fastest way to review a pass. |
| `/C` | Comment code out instead of deleting it. Applies to `#remove` rules. |
| `/I` | Ignore case. |
| `/W` | Whole words only. |
| `/L` | Multiline, ungreedy search. |
| `/P` `/R` | A single find and replace pattern pair, instead of a rule file. |
| `/X` | Rule file containing many rules. |

Typical migration run:

```bat
reFind.exe FireDAC_MyApp\*.pas FireDAC_MyApp\*.dfm /S /X:FireDAC_Migrate_BDE_MyApp.txt
```

## Rule file format

Rule files are plain text, one rule per line. Lines starting with `;` are comments, which is how the official templates document what they deliberately do not cover.

```
#unuse <unit>
#remove [PAS: | DFM:] <property>
#migrate [PAS: | DFM:] [<class>, ... :] [<obj> .] <old> -> <new> [, <unit>, ...]
#replaceunit <oldunit> -> <newunit>
<searchpattern> -> <replacepattern>
```

### `#unuse`

Removes a unit from the `uses` clause.

```
#unuse Bde.DBTables
```

### `#remove`

Removes a property from PAS code and from DFM or FMX files. Scope it with `PAS:` or `DFM:` when only one side should change.

```
#remove SessionName
#remove DFM: Origin
```

With `/C` on the command line these are commented out rather than deleted, which is useful on a first pass when you want to see what was hit.

### `#migrate`

Renames an identifier, optionally restricted to one or more classes or to a named object, and optionally adding units to the `uses` clause.

```
; plain rename
#migrate TSession -> TFDManager, FireDAC.Comp.Client

; rename plus every unit the new type needs
#migrate TQuery -> TFDQuery, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Comp.Client

; restricted to a class, so unrelated DataSource properties are left alone
#migrate TQuery: DataSource -> MasterSource

; restricted to several classes
#migrate TQuery, TTable: DatabaseName -> ConnectionName

; restricted to an object, wildcard on the member
#migrate Session.* -> FDManager.*, FireDAC.Comp.Client

; only in DFM files
#migrate DFM: TQuery -> TFDQuery
```

The unit list is what makes `#migrate` worth using over a regex: it keeps the `uses` clause consistent with the types it introduces.

### `#replaceunit`

Swaps one unit for another in the `uses` clause, without touching identifiers.

```
#replaceunit MyCompany.BdeLayer -> MyCompany.FireDACLayer
```

### Bare PCRE rules

Any line containing `->` that is not a directive is treated as a Perl-compatible search and replace pair. Useful for DFM property text and for shapes that are not Delphi identifiers.

```
DatabaseName = 'MYALIAS' -> ConnectionDefName = 'MYCONN'
```

Combine with `/L` for patterns that span lines, and remember that `\1` and friends refer to captured groups in the replacement.

## Behaviour that catches people out

- **The `.bak` guard.** By default reFind refuses to process a file that already has a `.bak` next to it. A second run over the same folder therefore appears to succeed and changes nothing. Either delete the copy and start again from the original sources, or pass `/B:1`.
- **Masks are not recursive on their own.** `*.pas` without `/S` misses every subfolder. Passing `Src\*.pas Src\gen\*.pas /S` is belt and braces, and harmless.
- **Only the masks you name are touched.** FireMonkey projects need `*.fmx`. Legacy types sometimes also live in `*.dpr`, `*.inc` or `*.dpk`.
- **Order matters.** Rules are applied in file order, so a broad rename placed before a narrow one will consume the narrow rule's matches. Additions belong at the end, where they see the already-renamed identifiers.
- **DFM edits are text edits.** Close the form in the designer first, or the IDE will write its in-memory copy back over the result.
- **reFind does not parse Delphi.** It matches identifiers, so an identifier that means two things in two contexts will be renamed in both. That is what class qualification is for.

## Validating a rule before a full run

1. Copy one representative unit and its DFM into a scratch folder.
2. Run reFind there with `/V:2` and the single rule under test.
3. Compare the result against the `.bak`.
4. Search the tree for the old identifier afterwards; the count should be the one you predicted.
