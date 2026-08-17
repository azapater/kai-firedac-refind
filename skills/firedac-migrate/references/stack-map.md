# Stack map

Detection symbols, official template, and the work each stack leaves behind after reFind.

All template paths are relative to the installed Samples tree:

```
C:\Users\Public\Documents\Embarcadero\Studio\<ver>\Samples\Object Pascal\Database\FireDAC\Tool\reFind
```

`<ver>` is the folder under `C:\Users\Public\Documents\Embarcadero\Studio\` for the installation in use. It changes with every major release. If the tree is absent, Samples were not installed.

## Choosing a template

| Stack | Template |
|-------|----------|
| BDE | `BDE2FDMigration\FireDAC_Migrate_BDE.txt` |
| ADO | `ADO2FDMigration\FireDAC_Migrate_ADO.txt` |
| dbExpress | `DBX2FDMigration\FireDAC_Migrate_DBX.txt` |
| IBX | `IBX2FDMigration\FireDAC_Migrate_IBX.txt` |
| AnyDAC | `AD2FDMigration\FireDAC_Rename_Units.txt`, `FireDAC_Rename_API.txt`, `FireDAC_Rename_Other.txt` |
| FireDAC XE7 to XE8 API rename | `XE72XE8Migration\FireDAC_Rename_API.txt` |

Background reading, where it exists:

- <https://docwiki.embarcadero.com/RADStudio/en/Migrating_BDE_Applications_to_FireDAC>
- <https://docwiki.embarcadero.com/RADStudio/en/Migrating_DBX_Applications_to_FireDAC>
- <https://docwiki.embarcadero.com/RADStudio/en/Migrating_AnyDAC_Applications_to_FireDAC>

## BDE

**Units:** `Bde.DBTables`, `Bde.Bde`, `Bde.DBCommon`, `BDEConst`, and the pre-namespace `DBTables`, `BDE`.

**Types:** `TSession`, `TDatabase`, `TTable`, `TQuery`, `TStoredProc`, `TUpdateSQL`, `TBatchMove`, `TBDEDataSet`, `TDBDataSet`, `EDBEngineError`.

**Connection markers:** `DatabaseName`, `AliasName`, `SessionName`, `PrivateDir`, `Session.AddAlias`, `IsAlias`, `ModifyAlias`, `SaveConfigFile`, references to `idapi32.cfg` or the BDE Administrator.

**Usual leftovers:**

- Alias bootstrap code. FireDAC has connection definitions instead: `FDManager.AddConnectionDef`, an `FDConnectionDefs.ini` entry, or `DriverID` plus `Params` set directly on the connection.
- `TBatchMove`. `TFDBatchMove` needs an explicit reader and writer component pair; the rename alone does not compile into working code.
- Cached updates and `TUpdateSQL` chains, which map onto `UpdateOptions` and `TFDUpdateSQL` with different semantics.
- **Paradox and dBASE data.** FireDAC has no driver for either. If the application reads local tables, the data itself has to move to a supported engine (InterBase, SQLite, SQL Server and so on). No rule file can do that, and it should be flagged in the brief on day one, not discovered in step 6.

## ADO

**Units:** `Data.Win.ADODB`, `Data.Win.ADOInt`, `Data.Win.ADOConst`, and the pre-namespace `ADODB`, `ADOInt`.

**Types:** `TADOConnection`, `TADOQuery`, `TADOTable`, `TADOStoredProc`, `TADOCommand`, `TADODataSet`, `TADOBlobStream`, `TCustomADODataSet`.

**Connection markers:** `ConnectionString`, `Provider=`, `Data Source=`, `.udl` files, `CursorLocation`, `CursorType`, `LockType`.

**Usual leftovers:**

- The connection string. The provider has to be read and turned into a FireDAC `DriverID` plus `Params`; there is no mechanical mapping.
- Direct OLE DB access: `Recordset`, `_Recordset`, `NextRecordset`, `Properties[...]`, `OpenSchema`, `Supports`, `FilterOnBookmarks`. The official template lists these under `Not supported` and it means it.
- Batch update code (`UpdateBatch`, `CancelBatch`, `RecordStatus`) which becomes `CachedUpdates` and `UpdateOptions`.
- `Seek` and `Sort` on ADO datasets, which have FireDAC equivalents with different behaviour.

## dbExpress

**Units:** `Data.SqlExpr`, `Data.DBXCommon`, `Data.SimpleDS`, the `Data.DBX*` driver units, and the pre-namespace `SqlExpr`, `DBXpress`.

**Types:** `TSQLConnection`, `TSQLQuery`, `TSQLDataSet`, `TSQLTable`, `TSQLStoredProc`, `TSQLMonitor`, `TSimpleDataSet`.

**Connection markers:** `dbxconnections.ini`, `dbxdrivers.ini`, `DriverName`, `ConnectionName`, `GetDriverFunc`, `LibraryName`, `VendorLib`, `LoadParamsOnConnect`.

**Usual leftovers:**

- `dbxconnections.ini` loading, which becomes a FireDAC connection definition.
- `TSQLMonitor`. The FireDAC equivalent is the monitoring and tracing layer (`TFDMoniRemoteClientLink` and friends), not a drop-in component.
- The `TSQLDataSet` + `TDataSetProvider` + `TClientDataSet` trio. FireDAC datasets are bidirectional and buffered, so the provider layer is often redundant, but removing it changes how the forms are wired. Decide deliberately, in the brief.
- `TSimpleDataSet`, which has no direct counterpart.

## IBX

**Units:** `IBX.IBDatabase`, `IBX.IBCustomDataSet`, `IBX.IBQuery`, `IBX.IBTable`, `IBX.IBStoredProc`, `IBX.IBSQL`, `IBX.IBUpdateSQL`, `IBX.IBEvents`, `IBX.IBDatabaseInfo`, `IBX.IBServices`, and their pre-namespace forms.

**Types:** `TIBDatabase`, `TIBTransaction`, `TIBQuery`, `TIBTable`, `TIBDataSet`, `TIBStoredProc`, `TIBSQL`, `TIBUpdateSQL`, `TIBEvents`, `TIBDatabaseInfo`, the `TIB*Service` family.

**Connection markers:** `DatabaseName` holding a path or `server:path`, `Params` with `user_name`, `password`, `lc_ctype`, `sql_role_name`, plus `SQLDialect` and `DefaultTransaction`.

**Usual leftovers:**

- Explicit transaction objects. `TIBTransaction` is mandatory in IBX; in FireDAC, `TFDConnection.TxOptions` covers most cases and `TFDTransaction` is only needed for multiple concurrent transactions. Simplifying is usually right but it is a behaviour change.
- `TIBSQL`, which is closest to `TFDCommand`.
- `TIBEvents`, which becomes `TFDEventAlerter`.
- `TIBDatabaseInfo`, `TIBExtract` and the services components, which map onto `FireDAC.Phys.IBWrapper` and the IB service components, not one-to-one.

## FireDAC plumbing every migrated project needs

Independent of the source stack:

| Piece | Component | Unit |
|-------|-----------|------|
| Wait cursor (VCL) | `TFDGUIxWaitCursor` | `FireDAC.VCLUI.Wait` |
| Wait cursor (FMX) | `TFDGUIxWaitCursor` | `FireDAC.FMXUI.Wait` |
| Wait cursor (console, service) | `TFDGUIxWaitCursor` | `FireDAC.ConsoleUI.Wait` |
| Driver link | `TFDPhysXxxDriverLink` | `FireDAC.Phys.Xxx` |

Common driver links and their `DriverID` values:

| RDBMS | Driver link | DriverID |
|-------|-------------|----------|
| InterBase | `TFDPhysIBDriverLink` | `IB` |
| Firebird | `TFDPhysFBDriverLink` | `FB` |
| SQL Server | `TFDPhysMSSQLDriverLink` | `MSSQL` |
| Oracle | `TFDPhysOracleDriverLink` | `Ora` |
| MySQL, MariaDB | `TFDPhysMySQLDriverLink` | `MySQL` |
| PostgreSQL | `TFDPhysPgDriverLink` | `PG` |
| SQLite | `TFDPhysSQLiteDriverLink` | `SQLite` |
| MS Access | `TFDPhysMSAccessDriverLink` | `MSAcc` |
| ODBC data source | `TFDPhysODBCDriverLink` | `ODBC` |

Missing the wait cursor or the driver link produces runtime errors, not compiler errors, so they will not show up in the compile-fix loop. Add them in the structural step.
