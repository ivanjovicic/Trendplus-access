# SQL Import Prep

Status: preparation only.

This document connects the checked-in SQL proposal files with their intended Access query object names and a safe import order for a working copy of the MDB.

## Naming Policy

- The SQL filename stem should match the intended Access query object name.
- Keep the object name, the file name, and the doc references aligned.
- If an Access object name changes later, update the SQL filename and the docs together.

## Query Map

### Core cutoff reporting

| SQL file | Intended Access object | Purpose |
| --- | --- | --- |
| `sql/reporting-2020/qryDnevnikPregled2020.sql` | `qryDnevnikPregled2020` | Central 2020+ journal header query. |
| `sql/reporting-2020/qryProdajaPregled2020.sql` | `qryProdajaPregled2020` | Sales review query. |
| `sql/reporting-2020/qryUnosRobePregled2020.sql` | `qryUnosRobePregled2020` | Goods receipt review query. |
| `sql/reporting-2020/qryPrenosRobePregled2020.sql` | `qryPrenosRobePregled2020` | Transfer review query. |
| `sql/reporting-2020/qryPovratnicePregled2020.sql` | `qryPovratnicePregled2020` | Returns review query. |
| `sql/reporting-2020/qryNivelacijePregled2020.sql` | `qryNivelacijePregled2020` | Leveling review query. |

### Sales analytics extension

| SQL file | Intended Access object | Purpose |
| --- | --- | --- |
| `sql/reporting-2020/qryProdajaAnalitikaStavke2020.sql` | `qryProdajaAnalitikaStavke2020` | Enriched sales analytics line source. |
| `sql/reporting-2020/qryProdajaPoDobavljacima2020.sql` | `qryProdajaPoDobavljacima2020` | Sales by supplier aggregate. |
| `sql/reporting-2020/qryProdajaPoTipuObuce2020.sql` | `qryProdajaPoTipuObuce2020` | Sales by shoe type aggregate. |
| `sql/reporting-2020/qryProdajaDobavljacArtikalDistinct2020.sql` | `qryProdajaDobavljacArtikalDistinct2020` | Supplier/article distinct helper. |
| `sql/reporting-2020/qryProdajaTipObuceArtikalDistinct2020.sql` | `qryProdajaTipObuceArtikalDistinct2020` | Shoe type/article distinct helper. |
| `sql/reporting-2020/qryProdajaTipObuceDobavljacDistinct2020.sql` | `qryProdajaTipObuceDobavljacDistinct2020` | Shoe type/supplier distinct helper. |
| `sql/reporting-2020/qryProdajaDobavljacTipObuceDistinct2020.sql` | `qryProdajaDobavljacTipObuceDistinct2020` | Supplier/shoe type distinct helper. |
| `sql/reporting-2020/qryProdajaDobavljacMesec2020.sql` | `qryProdajaDobavljacMesec2020` | Supplier monthly trend query. |
| `sql/reporting-2020/qryProdajaTipObuceMesec2020.sql` | `qryProdajaTipObuceMesec2020` | Shoe type monthly trend query. |
| `sql/reporting-2020/qryProdajaTopArtikliPoDobavljacu2020.sql` | `qryProdajaTopArtikliPoDobavljacu2020` | Top articles by supplier. |
| `sql/reporting-2020/qryProdajaTopArtikliPoTipuObuce2020.sql` | `qryProdajaTopArtikliPoTipuObuce2020` | Top articles by shoe type. |

### Sales analytics audits

| SQL file | Intended Access object | Purpose |
| --- | --- | --- |
| `sql/audit/qryAuditProdajaAnalitikaTotals2020.sql` | `qryAuditProdajaAnalitikaTotals2020` | Analytics totals parity audit. |
| `sql/audit/qryAuditProdajaAnalitikaMissingDimensions2020.sql` | `qryAuditProdajaAnalitikaMissingDimensions2020` | Missing article/supplier/type/season/sales object/journal object audit. |
| `sql/audit/qryAuditProdajaObjekatMismatch2020.sql` | `qryAuditProdajaObjekatMismatch2020` | Sales object mismatch audit. |
| `sql/audit/qryAuditProdajaAnalitikaByObject2020.sql` | `qryAuditProdajaAnalitikaByObject2020` | Analytics by-object parity audit. |
| `sql/audit/qryAuditProdajaAnalitikaByMonth2020.sql` | `qryAuditProdajaAnalitikaByMonth2020` | Analytics by-month parity audit. |

### Existing data-quality audits

| SQL file | Intended Access object | Purpose |
| --- | --- | --- |
| `sql/audit/qryAuditDnevnikCountByYear.sql` | `qryAuditDnevnikCountByYear` | Journal year audit. |
| `sql/audit/qryAuditDnevnikCountByTipPromene.sql` | `qryAuditDnevnikCountByTipPromene` | Journal type audit. |
| `sql/audit/qryAuditOrphanProdaja.sql` | `qryAuditOrphanProdaja` | Sales orphan audit. |
| `sql/audit/qryAuditOrphanUnosRobe.sql` | `qryAuditOrphanUnosRobe` | Receipt orphan audit. |
| `sql/audit/qryAuditOrphanPrenosRobe.sql` | `qryAuditOrphanPrenosRobe` | Transfer orphan audit. |
| `sql/audit/qryAuditOrphanPovratnice.sql` | `qryAuditOrphanPovratnice` | Returns orphan audit. |
| `sql/audit/qryAuditOrphanNivelacije.sql` | `qryAuditOrphanNivelacije` | Leveling orphan audit. |

## Recommended Import Order

1. Import `qryDnevnikPregled2020` first.
2. Import `qryProdajaPregled2020`.
3. Import `qryProdajaAnalitikaStavke2020` after `qryProdajaPregled2020`.
4. Import the distinct helper queries.
5. Import the supplier and shoe type aggregate queries.
6. Import the monthly trend queries.
7. Import the top article queries.
8. Import the sales analytics audit queries after the reporting base exists.
9. Import the existing journal and orphan audits after the reporting base exists.
10. Validate row counts and boundary dates before wiring any form or report.

## Access Import Notes

- Use a copy of the MDB, not the original.
- Import only read-only query definitions in this phase.
- Do not import or run `Query10`.
- Do not change forms or reports until the query parity checks pass.
- If a query name collides with an existing Access object, stop and resolve the collision before proceeding.
- Treat the sales analytics extension as read-only proposal SQL until the existing gates and parity checks pass.

## Practical Check

Before any UI work, verify:

- the query object name exactly matches the intended target
- the SQL file content still matches the repository version
- the classification doc still marks the target as allowed
- the go/no-go doc still keeps UI changes blocked
