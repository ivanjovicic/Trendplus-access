# ACCESS 2020 Cutoff Test Matrix

Status: pre-implementation test matrix for the read-only 2020 reporting plan.

The goal is to prove the cutoff, preserve historical meaning where needed, and block any accidental change to base data.

## Baseline Numbers

- `tblDnevnikPromena` total rows: `16,394`
- Pre-2020 journal rows: `11,991`
- 2020+ journal rows: `4,403`
- Orphan rows:
  - `tblProdaja`: `347`
  - `tblUnosRobe`: `109`
  - `tblPrenosRobe`: `45`
  - `tblPovratnice`: `567`
  - `tblNivelacije`: `0`

## Test Cases

| ID | Area | Scenario | Expected result |
| --- | --- | --- | --- |
| T01 | Journal baseline | Count all rows in `tblDnevnikPromena`. | Returns `16,394`. |
| T02 | Cutoff boundary | Filter `Datum < 2020-01-01` and `Datum >= 2020-01-01`. | Returns `11,991` and `4,403`, respectively. |
| T03 | Boundary date inclusion | Test `2019-12-31 23:59:59` and `2020-01-01 00:00:00`. | First row excluded, second row included. |
| T04 | Reporting query | Run `qryDnevnikPregled2020`. | Returns only rows with `Datum >= DateSerial(2020,1,1)`. |
| T05 | Reporting query | Run `qryProdajaPregled2020`. | Returns `26,213` joined child rows, with no orphan rows. |
| T06 | Reporting query | Run `qryUnosRobePregled2020`. | Returns `3,608` joined child rows, with correction filter preserved. |
| T07 | Reporting query | Run `qryPrenosRobePregled2020`. | Returns `199` joined child rows. |
| T08 | Reporting query | Run `qryPovratnicePregled2020`. | Returns `182` joined child rows. |
| T09 | Reporting query | Run `qryNivelacijePregled2020`. | Returns `2,093` joined child rows. |
| T10 | Audit query | Run `qryAuditDnevnikCountByYear`. | One row per year from 2011 to 2026, matching the documented year counts. |
| T11 | Audit query | Run `qryAuditDnevnikCountByTipPromene`. | Matches documented totals for `PRODAJA`, `UNOS ROBE`, `PRENOS ROBE`, `POVRATNICA`, and `NIVELACIJA`. |
| T12 | Orphan audit | Run orphan audit queries for sales, receipt, transfer, returns, and leveling. | Returns `347`, `109`, `45`, `567`, and `0` rows respectively. |
| T13 | Destructive query safety | Verify that `Query10` is not executed by any path under test. | No call site or runtime execution observed. |
| T14 | UI default date | Open `frmStatistika` in review mode. | `txtDatumOd` defaults to `2020-01-01` or clamps earlier input to that date. |
| T15 | UI validation | Enter `Null`, earlier than cutoff, and inverted date ranges in `frmStatistika`. | The form rejects or clamps invalid ranges without changing data. |
| T16 | Stock semantics | Review `frmLager` with the new plan. | No cutoff switch until stock meaning is confirmed. |
| T17 | Card semantics | Review `frmKartica` with the new plan. | No cutoff switch until opening balance or full-history behavior is confirmed. |
| T18 | Popis semantics | Review `rptPopis` and `rptPopisProslost`. | Classified before any rewrite; no blanket cutoff. |
| T19 | Archive path | Exercise archive/full-history access. | A separate archive path is available before any default UI switch. |
| T20 | Data safety | Validate that no base table rows were deleted or modified by the read-only plan. | All data remains unchanged. |
| T21 | Analytics totals | Run `qryAuditProdajaAnalitikaTotals2020`. | Base sales totals, analytics totals, supplier totals, and shoe type totals match. |
| T22 | Analytics dimensions | Run `qryAuditProdajaAnalitikaMissingDimensions2020`. | Returns counts for missing article, supplier, type, season, sales object, journal object, null quantity, null price, negative quantity, and negative price rows. |
| T23 | Analytics object mismatch | Run `qryAuditProdajaObjekatMismatch2020`. | Returns sales rows where sales object and journal object differ or one side is missing. |
| T24 | Supplier analytics | Run `qryProdajaPoDobavljacima2020`. | Returns grouped supplier analytics with explicit columns and no row loss from missing dimensions. |
| T25 | Shoe type analytics | Run `qryProdajaPoTipuObuce2020`. | Returns grouped shoe type analytics with explicit columns and no row loss from missing dimensions. |
| T26 | Supplier/article distinct helper | Run `qryProdajaDobavljacArtikalDistinct2020`. | Returns unique supplier/article combinations for distinct-count support. |
| T27 | Shoe type/article distinct helper | Run `qryProdajaTipObuceArtikalDistinct2020`. | Returns unique shoe type/article combinations for distinct-count support. |
| T28 | Supplier monthly trend | Run `qryProdajaDobavljacMesec2020`. | Returns monthly supplier totals that reconcile to the same grand total. |
| T29 | Shoe type monthly trend | Run `qryProdajaTipObuceMesec2020`. | Returns monthly shoe type totals that reconcile to the same grand total. |
| T30 | Top article by supplier | Run `qryProdajaTopArtikliPoDobavljacu2020`. | Returns supplier/article drilldown rows with explicit totals. |
| T31 | Top article by shoe type | Run `qryProdajaTopArtikliPoTipuObuce2020`. | Returns shoe type/article drilldown rows with explicit totals. |
| T32 | Object parity | Run `qryAuditProdajaAnalitikaByObject2020`. | Object breakdown totals reconcile to the same grand total. |
| T33 | Month parity | Run `qryAuditProdajaAnalitikaByMonth2020`. | Month breakdown totals reconcile to the same grand total. |

## Expected Year Counts

| Year | Rows |
| --- | ---: |
| 2011 | 1,418 |
| 2012 | 1,276 |
| 2013 | 1,567 |
| 2014 | 1,520 |
| 2015 | 1,464 |
| 2016 | 1,461 |
| 2017 | 1,497 |
| 2018 | 849 |
| 2019 | 939 |
| 2020 | 683 |
| 2021 | 754 |
| 2022 | 765 |
| 2023 | 661 |
| 2024 | 700 |
| 2025 | 668 |
| 2026 | 172 |

## Expected Type Counts

| TipPromene | Total | Pre-2020 | From 2020 |
| --- | ---: | ---: | ---: |
| `PRODAJA` | 7,388 | 5,120 | 2,268 |
| `UNOS ROBE` | 6,503 | 4,608 | 1,895 |
| `PRENOS ROBE` | 1,169 | 1,147 | 22 |
| `POVRATNICA` | 1,030 | 885 | 145 |
| `NIVELACIJA` | 304 | 231 | 73 |

## Pass Criteria

- The cutoff is applied only in read-only reporting queries.
- Orphan rows remain audited, not silently reassigned.
- Stock/card/popis objects are not blanket-cut off.
- Sales analytics stays read-only and is validated against the sales review base query.
- Helper, trend, and top-article analytics queries are read-only and reconcile to the same grand total.
- No existing base table content changes.
- `Query10` stays isolated from all test flows.
