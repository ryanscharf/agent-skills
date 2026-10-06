---
name: tsql-conventions
description: Conventions and safety rules for writing, reviewing, or tuning Microsoft SQL Server T-SQL — queries, stored procedures, views, functions, indexes, and migration scripts. Use whenever the work targets SQL Server, Azure SQL, SSMS, sqlcmd, or mentions T-SQL, even if the user just says "SQL" and the codebase is SQL Server.
---

# T-SQL conventions

Apply these when writing or reviewing SQL Server code. For engine-agnostic review or tuning, the `sql-code-review` and `sql-optimization` skills also apply; this skill adds SQL Server specifics and takes precedence where they differ.

## Safety first
- Never run DDL or DML against a server without stating which server and database it targets. Prefer generating a script for the user to run.
- Wrap multi-statement changes in `BEGIN TRY / BEGIN TRANSACTION ... COMMIT / END TRY BEGIN CATCH ... IF @@TRANCOUNT > 0 ROLLBACK; THROW; END CATCH`.
- Put `SET XACT_ABORT ON;` at the top of procedures that modify data.
- Write migration scripts to be re-runnable: guard with `IF OBJECT_ID(...) IS NULL`, `IF COL_LENGTH(...) IS NULL`, or `CREATE OR ALTER` for procs, views, functions, and triggers.
- Before `UPDATE` or `DELETE`, show the equivalent `SELECT` with the same `WHERE` and the expected row count.

## Style
- Schema-qualify every object (`dbo.Orders`, not `Orders`).
- Uppercase keywords; one clause per line for anything beyond a trivial query.
- Explicit column lists: no `SELECT *` in procedures or views, no `INSERT` without a column list.
- Terminate statements with `;`. A CTE must follow a terminated statement.
- Use `SET NOCOUNT ON;` at the top of stored procedures.
- Name constraints and indexes explicitly (`PK_Orders`, `IX_Orders_CustomerId`) so they are stable across environments.

## Correctness traps
- `NOT IN` against a subquery returns nothing if any value is NULL; use `NOT EXISTS`.
- Use `datetime2` (or `datetimeoffset` when time zone matters) for new columns, not `datetime`.
- Use half-open date ranges: `WHERE d >= @start AND d < @end`, not `BETWEEN` or `CONVERT(date, d) = ...`.
- `MERGE` has known concurrency and bug history; prefer separate `UPDATE` + `INSERT` with appropriate locking unless the user wants `MERGE`.
- `@@IDENTITY` can return a trigger's identity; use `SCOPE_IDENTITY()` or `OUTPUT inserted.Id`.
- `NOLOCK` / `READ UNCOMMITTED` can skip or double-read rows. Do not add it to "fix" blocking; raise RCSI (`READ_COMMITTED_SNAPSHOT`) as the option instead.

## Performance
- Keep predicates sargable: no functions or implicit conversions on indexed columns. Match parameter types to column types (`varchar` vs `nvarchar` mismatches cause scans).
- Read the actual execution plan before proposing indexes; note key lookups, scans on large tables, spills, and estimate-vs-actual gaps.
- When proposing an index, give key columns in equality-then-range order, `INCLUDE` columns separately, and mention write overhead and existing overlapping indexes.
- Suspect parameter sniffing when a proc is fast for some inputs and slow for others; discuss `OPTION (RECOMPILE)`, `OPTIMIZE FOR`, or Query Store plan forcing rather than applying one silently.
- Prefer set-based logic over cursors and row-by-row loops; prefer inline table-valued functions over multi-statement TVFs and scalar UDFs in hot paths.

## Security
- Never build SQL by concatenating user input. Use parameters; for unavoidable dynamic SQL use `sp_executesql` with parameters and `QUOTENAME()` for identifiers.
- Grant `EXECUTE` on procedures rather than table-level rights to application logins.
