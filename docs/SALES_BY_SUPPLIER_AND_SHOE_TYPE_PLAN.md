# Sales by Supplier and Shoe Type Plan

Status: documentation and read-only SQL proposal only.

This document is an analytical extension to the 2020 cutoff work. It does not authorize MDB edits, UI rewires, report rewires, or data changes.

## Release Notes

What this package adds:

- a read-only sales analytics extension built on `qryProdajaPregled2020`,
- supplier and shoe-type rollups for 2020+ sales,
- distinct helper queries for cross-dimension counts,
- monthly trend queries,
- top-article drilldown queries,
- parity and data-quality audits for analytics totals, missing dimensions, and object mismatches,
- documentation links and import-map entries for the new proposal files.

What it does not do:

- it does not modify the MDB,
- it does not change existing Access objects,
- it does not lift the `S0-S9` gates,
- it does not authorize UI rollout.

## Statistics Scope

This package covers the planned read-only statistics screens for:

1. `frmProdajaPoDobavljacima`
2. `frmProdajaPoTipuObuce`

The screens are analytical consumers of the 2020 reporting layer, not replacements for the existing cutoff or stock logic.

## Existing `frmStatistika` Relationship

`frmStatistika` remains the existing statistics form candidate.

If source export becomes available, search for these strings before any future change:

- `txtDatumOd`
- `txtDatumDo`
- `CreateAccessQuery`
- `SQLStr`
- `QueryName`
- `tabStatistika`
- `pageProdaja`
- `pageNabavljeno`

If source export is not available, keep `frmStatistika` as `UNKNOWN_REVIEW_REQUIRED`.

## New Analytics Query Chain

The read-only query path must stay chained through the approved 2020 sales review layer:

```text
qryDnevnikPregled2020
    ->
qryProdajaPregled2020
    ->
qryProdajaAnalitikaStavke2020
    ->
qryProdajaPoDobavljacima2020
    ->
qryProdajaPoTipuObuce2020
```

Do not bypass `qryProdajaPregled2020`.

## Distinct Helper Query Approach

Access does not have a direct `COUNT DISTINCT` pattern that is easy to keep readable in this repo, so helper queries are proposed for distinct article and cross-dimension counts.

Use helper queries for:

- distinct supplier/article pairs,
- distinct shoe type/article pairs,
- distinct shoe type/supplier pairs,
- distinct supplier/shoe type pairs.

Do not overload the main aggregate queries with hidden distinct logic.

## Monthly Trend Query Approach

Monthly trend queries are proposal-only reporting helpers.

They should group by:

- `Year(DatumDnevnika)` as `Godina`,
- `Month(DatumDnevnika)` as `Mesec`,
- the relevant supplier or shoe type dimensions.

These queries are for trend display only and do not change the reporting cutoff.

## Top Article Detail Query Approach

Top-article queries are proposal-only drilldown helpers.

They should group by:

- supplier or shoe type,
- `IDArtikal`,
- `PLU`,
- `Artikal`.

These queries will later support the planned detail screens, but the screens themselves remain blocked.

## Current vs Historical Dimensions Caveat

The first release groups sales by current article dimensions from `tblArtikli`.

Explicitly:

> These screens group sales by current article supplier/type from `tblArtikli`.
> They do not prove historical sale-time supplier/type unless `tblArtikliProslost` logic is separately investigated and approved.

That caveat must stay visible in the docs and audit notes.

## UI Design Gate

UI design remains blocked until query parity passes.

Do not create or rewire forms until:

- analytics totals match the sales review base query,
- missing-dimension counts are documented,
- object mismatch counts are documented,
- by-object and by-month breakdowns reconcile to the same grand total.

## Acceptance Criteria for Statistics Screens

The statistics screens are complete only when:

1. All new SQL proposal files exist.
2. Existing SQL files use the Null-safe mismatch and safe weighted average formulas.
3. All new SQL files are listed in `SQL_IMPORT_PREP.md`.
4. All new query names are classified in `ACCESS_OBJECT_CLASSIFICATION.md`.
5. Proposed forms remain `UNKNOWN_REVIEW_REQUIRED`.
6. No MDB, existing query, form, report, or data has been modified.
7. Audit totals prove no row loss and no double counting.
8. Missing dimension counts are documented.
9. Object mismatch counts are documented.
10. Business accepts current article supplier/type semantics.
11. UI work remains blocked until Go/No-Go permits it.

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
- by-object breakdown totals,
- by-month breakdown totals,
- distinct helper query counts,
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

## 7. Statistics UI Plan

The UI objects below are proposals only and stay blocked until the query parity and audit checks are finished.

### Screen 1: `frmProdajaPoDobavljacima`

Status:

```text
proposal only
UNKNOWN_REVIEW_REQUIRED
```

Main filters:

- `DatumOd`
- `DatumDo`
- `Objekat`
- `Sezona`
- `TipObuce`
- `Dobavljac`
- `Regular/Archive mode`

Default:

- `DatumOd = 2020-01-01`
- regular mode only

Main grid:

- `Dobavljac`
- `UkupnoKomada`
- `UkupanPromet`
- `ProsecnaCenaPoKomadu`
- `BrojStavki`
- `BrojRazlicitihArtikala`
- `BrojTipovaObuce`
- `PrvaProdaja`
- `PoslednjaProdaja`
- `UcesceUPrometu`

Detail drilldown later:

- top articles for the supplier
- supplier sales by shoe type
- supplier sales by month
- supplier sales by object

### Screen 2: `frmProdajaPoTipuObuce`

Status:

```text
proposal only
UNKNOWN_REVIEW_REQUIRED
```

Main filters:

- `DatumOd`
- `DatumDo`
- `Objekat`
- `Sezona`
- `Dobavljac`
- `TipObuce`
- `Regular/Archive mode`

Default:

- `DatumOd = 2020-01-01`
- regular mode only

Main grid:

- `TipObuce`
- `UkupnoKomada`
- `UkupanPromet`
- `ProsecnaCenaPoKomadu`
- `BrojStavki`
- `BrojRazlicitihArtikala`
- `BrojDobavljaca`
- `PrvaProdaja`
- `PoslednjaProdaja`
- `UcesceUPrometu`

Detail drilldown later:

- top articles for the shoe type
- shoe type sales by supplier
- shoe type sales by month
- shoe type sales by object

### Relationship with existing `frmStatistika`

Do not edit `frmStatistika`.

Document it as:

> Existing statistics form candidate.
> Needs source export and dynamic SQL map before any modification.

If source export is available, search/document these strings:

- `txtDatumOd`
- `txtDatumDo`
- `CreateAccessQuery`
- `SQLStr`
- `QueryName`
- `tabStatistika`
- `pageProdaja`
- `pageNabavljeno`

If source export is not available, mark it as:

```text
Status: UNKNOWN_REVIEW_REQUIRED
```

| Object | Proposed class | Notes |
| --- | --- | --- |
| `frmProdajaPoDobavljacima` | `UNKNOWN_REVIEW_REQUIRED` | Candidate read-only supplier analytics form. |
| `frmProdajaPoTipuObuce` | `UNKNOWN_REVIEW_REQUIRED` | Candidate read-only shoe type analytics form. |

## 8. SQL proposal files

### Reporting

- [qryProdajaAnalitikaStavke2020.sql](../sql/reporting-2020/qryProdajaAnalitikaStavke2020.sql)
- [qryProdajaPoDobavljacima2020.sql](../sql/reporting-2020/qryProdajaPoDobavljacima2020.sql)
- [qryProdajaPoTipuObuce2020.sql](../sql/reporting-2020/qryProdajaPoTipuObuce2020.sql)
- [qryProdajaDobavljacArtikalDistinct2020.sql](../sql/reporting-2020/qryProdajaDobavljacArtikalDistinct2020.sql)
- [qryProdajaTipObuceArtikalDistinct2020.sql](../sql/reporting-2020/qryProdajaTipObuceArtikalDistinct2020.sql)
- [qryProdajaTipObuceDobavljacDistinct2020.sql](../sql/reporting-2020/qryProdajaTipObuceDobavljacDistinct2020.sql)
- [qryProdajaDobavljacTipObuceDistinct2020.sql](../sql/reporting-2020/qryProdajaDobavljacTipObuceDistinct2020.sql)
- [qryProdajaDobavljacMesec2020.sql](../sql/reporting-2020/qryProdajaDobavljacMesec2020.sql)
- [qryProdajaTipObuceMesec2020.sql](../sql/reporting-2020/qryProdajaTipObuceMesec2020.sql)
- [qryProdajaTopArtikliPoDobavljacu2020.sql](../sql/reporting-2020/qryProdajaTopArtikliPoDobavljacu2020.sql)
- [qryProdajaTopArtikliPoTipuObuce2020.sql](../sql/reporting-2020/qryProdajaTopArtikliPoTipuObuce2020.sql)

### Audit

- [qryAuditProdajaAnalitikaTotals2020.sql](../sql/audit/qryAuditProdajaAnalitikaTotals2020.sql)
- [qryAuditProdajaAnalitikaMissingDimensions2020.sql](../sql/audit/qryAuditProdajaAnalitikaMissingDimensions2020.sql)
- [qryAuditProdajaObjekatMismatch2020.sql](../sql/audit/qryAuditProdajaObjekatMismatch2020.sql)
- [qryAuditProdajaAnalitikaByObject2020.sql](../sql/audit/qryAuditProdajaAnalitikaByObject2020.sql)
- [qryAuditProdajaAnalitikaByMonth2020.sql](../sql/audit/qryAuditProdajaAnalitikaByMonth2020.sql)

## 10. Package Acceptance Criteria

The analytics extension is ready for UI design only when all of the following are true:

1. `qryProdajaPregled2020` still passes the cutoff test matrix.
2. `qryProdajaAnalitikaStavke2020` matches the base sales totals.
3. Supplier totals match analytics line totals.
4. Shoe type totals match analytics line totals.
5. Helper query counts are documented and accepted.
6. By-object and by-month audit totals reconcile to the same grand total.
7. Missing dimension counts are documented and accepted.
8. Object mismatch counts are documented and accepted.
9. No existing Access object or base table is modified.
10. All new SQL files are listed in `SQL_IMPORT_PREP.md`.
11. The business accepts current-dimension grouping for supplier/type.

## 11. Recommended next step

Keep the package in proposal mode:

- update the import map,
- update the object classification document,
- keep the go/no-go gates closed,
- import into a copy of the MDB only after the read-only cutoff layer is validated.
