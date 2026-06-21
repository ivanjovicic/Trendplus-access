# Sales by Supplier and Shoe Type Plan

Status: documentation and read-only SQL proposal only.

This document is an analytical extension to the 2020 cutoff work. It does not authorize MDB edits, UI rewires, report rewires, or data changes.

## Release Notes

What this package adds:

- a read-only sales analytics extension built on `qryProdajaPregled2020`,
- supplier and shoe-type rollups for 2020+ sales,
- parity and data-quality audits for analytics totals, missing dimensions, and object mismatches,
- documentation links and import-map entries for the new proposal files.

What it does not do:

- it does not modify the MDB,
- it does not change existing Access objects,
- it does not lift the `S0-S9` gates,
- it does not authorize UI rollout.

## 1. Purpose

Add two read-only sales analytics views on top of the existing 2020 reporting layer:

1. Sales by supplier.
2. Sales by shoe type.

The proposal is intentionally conservative:

- reuse `qryProdajaPregled2020` as the sales line base,
- keep the cutoff logic centralized in the 2020 reporting layer,
- treat supplier/type/season as current article dimensions unless business explicitly approves historical dimension logic,
- keep orphan handling separate from analytics,
- keep all SQL files read-only and proposal-only.

## 2. Scope

### In scope

- `docs/SALES_BY_SUPPLIER_AND_SHOE_TYPE_PLAN.md`
- read-only SQL proposal files under `sql/reporting-2020/`
- read-only audit SQL proposal files under `sql/audit/`
- documentation updates in the import map and object classification docs

### Out of scope

- MDB edits
- Access form creation in the production source
- report rewires
- replacing existing saved queries
- changing `Query10`
- data repair

## 3. Dependency chain

The analytical layer should reuse the approved read-only sales query:

```text
qryDnevnikPregled2020
    ->
qryProdajaPregled2020
    ->
qryProdajaAnalitikaStavke2020
        -> qryProdajaPoDobavljacima2020
        -> qryProdajaPoTipuObuce2020
```

Important:

- do not reimplement the `tblProdaja` to journal join in the new analytics SQL,
- do not bypass `qryProdajaPregled2020`,
- keep the 2020 cutoff in one place.

## 4. Analytics model

### Base line source

`qryProdajaAnalitikaStavke2020` should expose one normalized sales analytics line per sales row.

Recommended fields:

- sales row identifiers and journal context,
- article metadata,
- supplier metadata,
- shoe type metadata,
- season metadata,
- journal object and sales object IDs,
- current-dimension labels,
- calculated revenue,
- quality flags for missing dimensions and object mismatch.

### Aggregates

`qryProdajaPoDobavljacima2020`

- group by supplier,
- summarize row count, quantity, revenue, first sale date, last sale date,
- use a weighted average price metric if possible.

`qryProdajaPoTipuObuce2020`

- group by shoe type,
- summarize row count, quantity, revenue, first sale date, last sale date,
- use a weighted average price metric if possible.

## 5. Business caveat

The first release should be documented as:

> sales grouped by current article supplier and current article shoe type

This is not the same thing as historical sale-time supplier/type. If the business later requires historical dimensions, that becomes a separate investigation.

## 6. Audit requirements

Before any UI work, the copied MDB should validate these points:

- base sales totals from `qryProdajaPregled2020`,
- analytics line totals from `qryProdajaAnalitikaStavke2020`,
- supplier aggregate totals,
- shoe type aggregate totals,
- missing article rows,
- missing supplier rows,
- missing shoe type rows,
- missing season rows,
- missing sales object rows,
- missing journal object rows,
- object mismatch rows,
- null and negative quantity/price rows.

Known rule:

- orphan `tblProdaja` rows stay excluded from the journal-driven 2020 reporting path and remain in the orphan audit set.

## 7. Proposed UI objects

The UI objects below are proposals only and stay blocked until the query parity and audit checks are finished.

| Object | Proposed class | Notes |
| --- | --- | --- |
| `frmProdajaPoDobavljacima` | `UNKNOWN_REVIEW_REQUIRED` | Candidate read-only supplier analytics form. |
| `frmProdajaPoTipuObuce` | `UNKNOWN_REVIEW_REQUIRED` | Candidate read-only shoe type analytics form. |

## 8. SQL proposal files

### Reporting

- [qryProdajaAnalitikaStavke2020.sql](../sql/reporting-2020/qryProdajaAnalitikaStavke2020.sql)
- [qryProdajaPoDobavljacima2020.sql](../sql/reporting-2020/qryProdajaPoDobavljacima2020.sql)
- [qryProdajaPoTipuObuce2020.sql](../sql/reporting-2020/qryProdajaPoTipuObuce2020.sql)

### Audit

- [qryAuditProdajaAnalitikaTotals2020.sql](../sql/audit/qryAuditProdajaAnalitikaTotals2020.sql)
- [qryAuditProdajaAnalitikaMissingDimensions2020.sql](../sql/audit/qryAuditProdajaAnalitikaMissingDimensions2020.sql)
- [qryAuditProdajaObjekatMismatch2020.sql](../sql/audit/qryAuditProdajaObjekatMismatch2020.sql)

## 9. Acceptance criteria

The analytics extension is ready for UI design only when all of the following are true:

1. `qryProdajaPregled2020` still passes the cutoff test matrix.
2. `qryProdajaAnalitikaStavke2020` matches the base sales totals.
3. Supplier totals match analytics line totals.
4. Shoe type totals match analytics line totals.
5. Missing dimension counts are documented and accepted.
6. Object mismatch counts are documented and accepted.
7. No existing Access object or base table is modified.
8. All new SQL files are listed in `SQL_IMPORT_PREP.md`.
9. The business accepts current-dimension grouping for supplier/type.

## 10. Recommended next step

Keep the package in proposal mode:

- update the import map,
- update the object classification document,
- keep the go/no-go gates closed,
- import into a copy of the MDB only after the read-only cutoff layer is validated.
