# ACCESS 2020 Cutoff Go / No-Go

Status: current repository state is `NO-GO` for any UI or MDB implementation switch.

The reason is simple: the plan is strong enough for controlled read-only preparation, but not yet signed off for production cutover.

## Mandatory Gates

| Gate | Required evidence | Current state |
| --- | --- | --- |
| `S0 Source` | Business confirmation that `Trend plus.mdb` is the working source of truth and `TRENDPLUS.accdb` is archive-only or otherwise explicitly scoped. | Open |
| `S1 Backup` | Verified backup copy with hash and rollback note. | Open |
| `S2 Source export` | Full source export of queries, forms, reports, and modules. | Open |
| `S3 Dependency map` | Search results for dynamic SQL and runtime object creation (`CreateAccessQuery`, `SQLStr`, `QueryName`, `RunSQL`, `OpenRecordset`, `RecordSource`, `RowSource`, `OpenReport`). | Open |
| `S4 Classification` | Every relevant object has a class and owner decision. | Open |
| `S5 Data quality` | Orphan audits are documented, especially `tblPovratnice`. | Open |
| `S6 Query parity` | Numeric parity for journal baseline, 2020+ subset, and orphan buckets. | Open |
| `S7 Stock semantics` | `frmLager`, `frmKartica`, `rptPopis`, and `rptPopisProslost` are classified as snapshot, full-history, or opening-balance driven. | Open |
| `S8 Archive` | A working archive/full-history path exists before default UI changes. | Open |
| `S9 UAT` | Business sign-off on the test matrix. | Open |

## Go Criteria

Implementation can start only when all of the following are true:

1. `S0` through `S9` are closed.
2. The read-only reporting SQL set exists and is validated.
3. The object classification document is complete enough to block accidental rewiring.
4. The test matrix has expected counts and boundary cases.
5. The archive path is usable before any default switch in the UI.

## No-Go Criteria

Any one of the following keeps the repo in `NO-GO`:

- Source-of-truth status is not confirmed.
- Full export is missing.
- Dynamic SQL callers are not mapped.
- Stock/card/popis semantics are unresolved.
- Orphan handling is not decided.
- `Query10` caller risk is not ruled out.
- A change would require deleting or repairing data.

## Safe Scope Before Go

Allowed:

- docs only
- read-only SQL proposal files
- audit query specs
- classification and test artifacts

Blocked:

- MDB edits
- form edits
- report rewires
- saved query rewires
- data cleanup
- any use of `Query10`

## Decision Summary

- Read-only planning work: allowed
- MDB or UI implementation: blocked
- Production rollout: blocked

