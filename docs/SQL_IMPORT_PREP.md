# SQL Import Prep

Status: preparation only.

This document connects the checked-in SQL proposal files with their intended Access query object names and a safe import order for a working copy of the MDB.

## Naming Policy

- The SQL filename stem should match the intended Access query object name.
- Keep the object name, the file name, and the doc references aligned.
- If an Access object name changes later, update the SQL filename and the docs together.

## Query Map

| SQL file | Intended Access object | Purpose |
| --- | --- | --- |
| `sql/reporting-2020/qryDnevnikPregled2020.sql` | `qryDnevnikPregled2020` | Central 2020+ journal header query. |
| `sql/reporting-2020/qryProdajaPregled2020.sql` | `qryProdajaPregled2020` | Sales review query. |
| `sql/reporting-2020/qryUnosRobePregled2020.sql` | `qryUnosRobePregled2020` | Goods receipt review query. |
| `sql/reporting-2020/qryPrenosRobePregled2020.sql` | `qryPrenosRobePregled2020` | Transfer review query. |
| `sql/reporting-2020/qryPovratnicePregled2020.sql` | `qryPovratnicePregled2020` | Returns review query. |
| `sql/reporting-2020/qryNivelacijePregled2020.sql` | `qryNivelacijePregled2020` | Leveling review query. |
| `sql/audit/qryAuditDnevnikCountByYear.sql` | `qryAuditDnevnikCountByYear` | Journal year audit. |
| `sql/audit/qryAuditDnevnikCountByTipPromene.sql` | `qryAuditDnevnikCountByTipPromene` | Journal type audit. |
| `sql/audit/qryAuditOrphanProdaja.sql` | `qryAuditOrphanProdaja` | Sales orphan audit. |
| `sql/audit/qryAuditOrphanUnosRobe.sql` | `qryAuditOrphanUnosRobe` | Receipt orphan audit. |
| `sql/audit/qryAuditOrphanPrenosRobe.sql` | `qryAuditOrphanPrenosRobe` | Transfer orphan audit. |
| `sql/audit/qryAuditOrphanPovratnice.sql` | `qryAuditOrphanPovratnice` | Returns orphan audit. |
| `sql/audit/qryAuditOrphanNivelacije.sql` | `qryAuditOrphanNivelacije` | Leveling orphan audit. |

## Recommended Import Order

1. Import `qryDnevnikPregled2020` first.
2. Import the remaining reporting queries.
3. Import the audit queries after the reporting base exists.
4. Validate row counts and boundary dates before wiring any form or report.

## Access Import Notes

- Use a copy of the MDB, not the original.
- Import only read-only query definitions in this phase.
- Do not import or run `Query10`.
- Do not change forms or reports until the query parity checks pass.
- If a query name collides with an existing Access object, stop and resolve the collision before proceeding.

## Practical Check

Before any UI work, verify:

- the query object name exactly matches the intended target
- the SQL file content still matches the repository version
- the classification doc still marks the target as allowed
- the go/no-go doc still keeps UI changes blocked

