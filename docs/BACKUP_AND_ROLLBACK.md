# Backup and Rollback

Status: preparation document for the 2020 cutoff work.

This file is documentation-only and deliberately read-only in spirit:

- never use it to modify the MDB in place
- never use it to run destructive cleanup
- never use it as a substitute for source export or UAT
- never work on the original MDB as the execution target

## Purpose

The goal is to make every future change to the cutoff plan reversible without restoring data from a partially modified database.

Rollback must be possible by:

- switching back to the previous query, form, or report source
- disabling the new entry point
- leaving base tables untouched

If rollback would require restoring deleted rows, the design is already too risky.

## Source Files

Record the actual files used for the work package here:

| Item | Value |
| --- | --- |
| Working source file | `Trend plus.mdb` |
| Archive/scoped file | `TRENDPLUS.accdb` |
| Original file name | `Trend plus.mdb` |
| Backup file name pattern | `Trend plus_YYYY-MM-DD_HHMMSS_pre-cutoff-backup.mdb` |
| Backup location | `backups\cutoff\` under the repo root, or another approved out-of-tree location |
| Backup created at | `TBD` |
| Backup created by | `TBD` |

## Backup Checklist

Before any implementation work:

1. Confirm which file is the working source of truth.
2. Copy the source MDB to a separate backup location.
3. Verify the backup opens.
4. Record the file size.
5. Record the SHA-256 hash for both original and backup.
6. Record the exact timestamp of the copy.
7. Store the backup path in a place that will not be overwritten by the Access work copy.

## Suggested Backup Naming

Use a timestamped name that clearly identifies the source and the purpose.

Example pattern:

```text
Trend plus_2026-06-21_153000_pre-cutoff-backup.mdb
```

If a second backup is made after the source export, use a new timestamp instead of overwriting the first copy.

## SHA-256 Recording

Record the hash values in this table after the backup is created.

| Field | Value |
| --- | --- |
| Source file | `Trend plus.mdb` |
| Source SHA-256 | `TBD` |
| Backup file | `TBD` |
| Backup SHA-256 | `TBD` |
| Source size | `TBD` |
| Backup size | `TBD` |
| Last verified | `TBD` |

Recommended commands on Windows:

```powershell
Get-FileHash "C:\Users\Ivan\source\repos\Trendplus-access\Trend plus.mdb" -Algorithm SHA256
Get-FileHash "C:\path\to\backups\cutoff\Trend plus_2026-06-21_153000_pre-cutoff-backup.mdb" -Algorithm SHA256
```

## Rollback Principles

Rollback should be a source-level reversal, not a data repair operation.

Allowed rollback actions:

- restore a previous query definition
- restore a previous form/report RecordSource
- disable a new UI entry point
- remove a proof-of-concept query from the working copy if it was never adopted

Disallowed rollback actions:

- deleting rows from base tables to "undo" a test
- reclassifying orphan rows without a business decision
- replacing the archive copy with the working copy
- using `Query10` or any destructive query as a rollback tool

## Rollback Steps

If a change needs to be reverted:

1. Stop using the changed working copy.
2. Restore the previous Access object definition from the last known good source.
3. Re-open the database and confirm the object list is unchanged except for the intended revert.
4. Re-run the relevant read-only counts or audit query.
5. Confirm no base table rows were added, removed, or edited.

If the revert cannot be done at the object/source level, stop and treat the work as blocked.

## Rollback Matrix

| Change type | Revert method | Data restore needed? |
| --- | --- | --- |
| New read-only query | Remove or replace the query definition | No |
| Form/report source change | Restore previous RecordSource/RowSource/WhereCondition | No |
| New archive entry point | Disable or hide the entry point | No |
| Default date clamp in UI | Restore previous VBA logic | No |
| Base table edit | Not allowed in this phase | Yes, therefore blocked |

## Verification After Rollback

After any rollback, verify:

- the backup file still exists
- the working copy opens
- query counts are unchanged
- the relevant forms/reports still behave as before the attempted change
- `Query10` was not invoked

## Operational Rule

Never work on the original MDB.

All experimentation, source export, import, and UI verification must happen against a timestamped copy created from `Trend plus.mdb`.

## Notes

- This file is a preparation artifact, not an execution log.
- Fill in the `TBD` fields when the backup is actually created.
- Keep this file alongside the cutoff analysis and test matrix so the implementation gates remain traceable.
