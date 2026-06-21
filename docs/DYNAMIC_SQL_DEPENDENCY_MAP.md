# Dynamic SQL Dependency Map

Status: pre-export dependency map.

No full source export bundle exists yet in the repository, so every finding below remains a source-export-required placeholder.

## Search Targets

These are the exact keywords and object markers to scan in the exported source:

- `CreateAccessQuery`
- `CreateQueryDef`
- `SQLStr`
- `QueryName`
- `DeleteObject`
- `DoCmd.RunSQL`
- `OpenRecordset`
- `RecordSource`
- `RowSource`
- `OpenReport`
- `txtDatumOd`
- `txtDatumDo`
- `tabStatistika`
- `pageProdaja`
- `pageNabavljeno`
- `Query10`

## Current Findings

| Object | Type | Matched keyword | Context | Risk | Recommendation | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `frmStatistika` | Form | `CreateAccessQuery`, `SQLStr`, `QueryName`, `txtDatumOd`, `txtDatumDo`, `tabStatistika`, `pageProdaja`, `pageNabavljeno` | Mentioned in analysis docs only; no exported source bundle is available yet. | High | Export source first, then verify whether the form generates dynamic SQL and how the date clamp is applied. | `Status: source export required` |
| `qryDnevnik` | Query | `RecordSource`, `CreateQueryDef` | Legacy query is documented as hardcoded and not reusable as the new cutoff base. | High | Keep as legacy only; inspect exported definition before any rewrite. | `Status: source export required` |
| `qryDnevnikPregled2020` | Query | `CreateQueryDef` | Intended new read-only cutoff query, currently proposal-only. | Medium | Verify exported SQL matches the naming and cutoff policy. | `Status: source export required` |
| `qryProdajaPregled2020` | Query | `RecordSource`, `OpenReport` | Intended read-only sales review query, currently proposal-only. | Medium | Verify the query is only used by approved read-only consumers. | `Status: source export required` |
| `qryUnosRobePregled2020` | Query | `RecordSource` | Intended read-only receipt review query, currently proposal-only. | Medium | Preserve any correction filter once source export exists. | `Status: source export required` |
| `qryPrenosRobePregled2020` | Query | `RecordSource` | Intended read-only transfer review query, currently proposal-only. | Medium | Verify join path and read-only behavior. | `Status: source export required` |
| `qryPovratnicePregled2020` | Query | `RecordSource` | Intended read-only returns review query, currently proposal-only. | Medium | Verify orphan policy before any UI wiring. | `Status: source export required` |
| `qryNivelacijePregled2020` | Query | `RecordSource` | Intended read-only leveling review query, currently proposal-only. | Medium | Verify read-only use only. | `Status: source export required` |
| `Query10` | Query | `DeleteObject`, `DoCmd.RunSQL` | Documented as destructive in the analysis docs. No runtime execution is allowed. | Critical | Do not run. Export only if needed for inspection, then keep it blocked. | `Status: source export required` |

## Source-Export-Required Rule

Because no exported source bundle exists yet:

- treat every dynamic SQL caller as unverified,
- do not rewire forms or reports,
- do not assume any `RecordSource` or `RowSource`,
- do not execute `Query10`,
- keep the implementation blocked until export and mapping are complete.

## Next Step

Run the copied-MDB export workflow, then replace the placeholder rows above with actual exported-source findings.
