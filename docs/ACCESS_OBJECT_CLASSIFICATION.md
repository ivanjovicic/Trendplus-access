# Access Object Classification

Status: working classification for the 2020 cutoff plan.

This document is the object-by-object control list for any future 2020+ reporting work.
Nothing in here authorizes UI changes, MDB edits, or destructive maintenance.

## Legend

- `FILTER_2020_SAFE` - journal-driven reporting object that can use the 2020 cutoff
- `FULL_HISTORY_REQUIRED` - object that must preserve full history semantics
- `OPENING_BALANCE_REQUIRED` - stock/card/popis object that needs a 2020 opening balance model
- `ARCHIVE_ONLY` - intentionally historical or maintenance-only path
- `DO_NOT_TOUCH` - master, utility, settings, or destructive object that must remain unchanged
- `UNKNOWN_REVIEW_REQUIRED` - still needs source export or business sign-off

## Tables

| Object | Class | Notes |
| --- | --- | --- |
| `tblArtikli` | `DO_NOT_TOUCH` | Current snapshot table. |
| `tblArtikliProslost` | `DO_NOT_TOUCH` | Historical snapshot table. |
| `tblDnevnikPromena` | `DO_NOT_TOUCH` | Base journal table. Use only through read-only clones. |
| `tblDobavljaci` | `DO_NOT_TOUCH` | Master data. |
| `tblNivelacije` | `DO_NOT_TOUCH` | Base transaction table. |
| `tblNivelacijePrivremena` | `DO_NOT_TOUCH` | Staging table. |
| `tblObjekat` | `DO_NOT_TOUCH` | Master data. |
| `tblPodesavanja` | `DO_NOT_TOUCH` | Settings. |
| `tblPovratnice` | `DO_NOT_TOUCH` | Base transaction table. |
| `tblPovratnicePrivremena` | `DO_NOT_TOUCH` | Staging table. |
| `tblPrenosPrivremena` | `DO_NOT_TOUCH` | Staging table. |
| `tblPrenosRobe` | `DO_NOT_TOUCH` | Base transaction table. |
| `tblProdaja` | `DO_NOT_TOUCH` | Base transaction table. |
| `tblProdajaPrivremena` | `DO_NOT_TOUCH` | Staging table. |
| `tblSezona` | `DO_NOT_TOUCH` | Business metadata. |
| `tblTipObuce` | `DO_NOT_TOUCH` | Master data. |
| `tblUnosPrivremena` | `DO_NOT_TOUCH` | Staging table. |
| `tblUnosRobe` | `DO_NOT_TOUCH` | Base transaction table. |
| `zstblZoomBox` | `DO_NOT_TOUCH` | UI helper table. |

## Saved Queries

| Object | Class | Notes |
| --- | --- | --- |
| `qryDnevnikPregled2020` | `FILTER_2020_SAFE` | New central reporting query for `Datum >= DateSerial(2020,1,1)`. |
| `qryProdajaPregled2020` | `FILTER_2020_SAFE` | New read-only clone for sales review. |
| `qryProdajaAnalitikaStavke2020` | `FILTER_2020_SAFE` | Read-only analytics line source built on `qryProdajaPregled2020`. |
| `qryProdajaPoDobavljacima2020` | `FILTER_2020_SAFE` | Read-only supplier aggregate. |
| `qryProdajaPoTipuObuce2020` | `FILTER_2020_SAFE` | Read-only shoe type aggregate. |
| `qryProdajaDobavljacArtikalDistinct2020` | `FILTER_2020_SAFE` | Supplier/article distinct helper. |
| `qryProdajaTipObuceArtikalDistinct2020` | `FILTER_2020_SAFE` | Shoe type/article distinct helper. |
| `qryProdajaTipObuceDobavljacDistinct2020` | `FILTER_2020_SAFE` | Shoe type/supplier distinct helper. |
| `qryProdajaDobavljacTipObuceDistinct2020` | `FILTER_2020_SAFE` | Supplier/shoe type distinct helper. |
| `qryProdajaDobavljacMesec2020` | `FILTER_2020_SAFE` | Supplier monthly trend query. |
| `qryProdajaTipObuceMesec2020` | `FILTER_2020_SAFE` | Shoe type monthly trend query. |
| `qryProdajaTopArtikliPoDobavljacu2020` | `FILTER_2020_SAFE` | Top articles by supplier. |
| `qryProdajaTopArtikliPoTipuObuce2020` | `FILTER_2020_SAFE` | Top articles by shoe type. |
| `qryAuditProdajaAnalitikaTotals2020` | `FILTER_2020_SAFE` | Read-only analytics totals parity audit. |
| `qryAuditProdajaAnalitikaMissingDimensions2020` | `FILTER_2020_SAFE` | Read-only missing dimension audit. |
| `qryAuditProdajaObjekatMismatch2020` | `FILTER_2020_SAFE` | Read-only object mismatch audit. |
| `qryAuditProdajaAnalitikaByObject2020` | `FILTER_2020_SAFE` | Read-only analytics by-object parity audit. |
| `qryAuditProdajaAnalitikaByMonth2020` | `FILTER_2020_SAFE` | Read-only analytics by-month parity audit. |
| `qryUnosRobePregled2020` | `FILTER_2020_SAFE` | New read-only clone for receipt review. |
| `qryPrenosRobePregled2020` | `FILTER_2020_SAFE` | New read-only clone for transfer review. |
| `qryPovratnicePregled2020` | `FILTER_2020_SAFE` | New read-only clone for returns review. |
| `qryNivelacijePregled2020` | `FILTER_2020_SAFE` | New read-only clone for leveling review. |
| `qryDnevnik` | `DO_NOT_TOUCH` | Legacy query with hardcoded filters. Do not repurpose. |
| `qryArtikli` | `DO_NOT_TOUCH` | Snapshot/article filter query. |
| `qryPrenos` | `DO_NOT_TOUCH` | Legacy chain that depends on `qryDnevnik`. |
| `qryPrenosGroup` | `DO_NOT_TOUCH` | Legacy aggregate chain. |
| `qryProdaja` | `DO_NOT_TOUCH` | Legacy chain that depends on `qryDnevnik`. |
| `qryUnos` | `DO_NOT_TOUCH` | Legacy chain that excludes correction docs. |
| `qryUnosGroup` | `DO_NOT_TOUCH` | Legacy aggregate chain. |
| `qryUnetoCisto` | `DO_NOT_TOUCH` | Legacy derived query. |
| `qryUnetoPrenos` | `DO_NOT_TOUCH` | Legacy derived query. |
| `qryUnetoUkupno` | `DO_NOT_TOUCH` | Legacy union query. |
| `Query1` | `UNKNOWN_REVIEW_REQUIRED` | Broken/legacy `WHERE datum between ''` trace. |
| `Query2` | `ARCHIVE_ONLY` | Journal rows after `2024-01-01`; maintenance/archive intent. |
| `Query3` | `UNKNOWN_REVIEW_REQUIRED` | Malformed or broken select. |
| `Query4` | `FULL_HISTORY_REQUIRED` | Reads `tblArtikliProslost`; likely historical support. |
| `Query5` | `UNKNOWN_REVIEW_REQUIRED` | Journal tip/date projection; confirm caller. |
| `Query7` | `UNKNOWN_REVIEW_REQUIRED` | Broken typo query on `tblDnevnikPromea`. |
| `Query8` | `UNKNOWN_REVIEW_REQUIRED` | Malformed select involving articles and journal. |
| `Query9` | `ARCHIVE_ONLY` | Broken legacy `Datum < #2024-01-01#` query. |
| `Query10` | `DO_NOT_TOUCH` | Destructive `DELETE` query. Must not be used for cutoff work. |
| `UpitProba` | `UNKNOWN_REVIEW_REQUIRED` | Sales aggregation prototype. |

## Forms

| Object | Class | Notes |
| --- | --- | --- |
| `frmStatistika` | `UNKNOWN_REVIEW_REQUIRED` | Candidate for `FILTER_2020_SAFE` after export and parity tests. |
| `frmProdajaPoDobavljacima` | `UNKNOWN_REVIEW_REQUIRED` | Proposed read-only supplier analytics form. |
| `frmProdajaPoTipuObuce` | `UNKNOWN_REVIEW_REQUIRED` | Proposed read-only shoe type analytics form. |
| `frmDnevnik` | `UNKNOWN_REVIEW_REQUIRED` | Journal browser/report launcher. |
| `frmPregled` | `UNKNOWN_REVIEW_REQUIRED` | Exact source not confirmed. |
| `frmKartica` | `UNKNOWN_REVIEW_REQUIRED` | Likely `OPENING_BALANCE_REQUIRED` or `FULL_HISTORY_REQUIRED`. |
| `frmLager` | `UNKNOWN_REVIEW_REQUIRED` | Likely `OPENING_BALANCE_REQUIRED`. |
| `frmPretraga` | `FULL_HISTORY_REQUIRED` | Snapshot/history search screen. |
| `frmPromenaArtikla` | `FULL_HISTORY_REQUIRED` | Snapshot/history dependent. |
| `frmProdaja` | `DO_NOT_TOUCH` | Operational entry form. |
| `frmUnosArtikal` | `DO_NOT_TOUCH` | Operational entry form. |
| `frmPrenosRobe` | `DO_NOT_TOUCH` | Operational entry form. |
| `frmNivelacija` | `DO_NOT_TOUCH` | Operational entry form. |
| `frmReset` | `DO_NOT_TOUCH` | Maintenance/high-risk form. |
| `frmGlavni` | `DO_NOT_TOUCH` | Navigation shell. |
| `frmDobavljaci` | `DO_NOT_TOUCH` | Master data form. |
| `frmObjekat` | `DO_NOT_TOUCH` | Master data form. |
| `frmPodesavanja` | `DO_NOT_TOUCH` | Settings form. |
| `frmSezona` | `DO_NOT_TOUCH` | Season metadata form. |
| `frmTipObuce` | `DO_NOT_TOUCH` | Master data form. |
| `frmUnosDobavljac` | `DO_NOT_TOUCH` | Master data form. |
| `frmTest` | `DO_NOT_TOUCH` | Test form. |
| `zsfrmCalc` | `DO_NOT_TOUCH` | Utility form. |
| `zsfrmCalendar` | `DO_NOT_TOUCH` | Utility form. |
| `zsfrmZoomBox` | `DO_NOT_TOUCH` | Utility form. |

## Reports

| Object | Class | Notes |
| --- | --- | --- |
| `rptProdaja` | `UNKNOWN_REVIEW_REQUIRED` | Candidate for `FILTER_2020_SAFE` after source export. |
| `rptPrenos` | `UNKNOWN_REVIEW_REQUIRED` | Candidate for `FILTER_2020_SAFE` after source export. |
| `rptPovratnica` | `UNKNOWN_REVIEW_REQUIRED` | Candidate for `FILTER_2020_SAFE` after source export. |
| `rptNivelacija` | `UNKNOWN_REVIEW_REQUIRED` | Candidate for `FILTER_2020_SAFE` after source export. |
| `rptUnos` | `UNKNOWN_REVIEW_REQUIRED` | Candidate for `FILTER_2020_SAFE` after source export. |
| `rptPopis` | `UNKNOWN_REVIEW_REQUIRED` | Stock-sensitive; do not blanket-cutoff. |
| `rptPopisBlanko` | `UNKNOWN_REVIEW_REQUIRED` | Needs manual review. |
| `rptPopisProslost` | `UNKNOWN_REVIEW_REQUIRED` | Historical stock/reporting path. |
| `Copy of rptNivelacija` | `UNKNOWN_REVIEW_REQUIRED` | Legacy copy/duplicate. |
| `Copy of rptPopis` | `UNKNOWN_REVIEW_REQUIRED` | Legacy copy/duplicate. |
| `desktop` | `UNKNOWN_REVIEW_REQUIRED` | Legacy/odd report object name. |

## Modules

| Object | Class | Notes |
| --- | --- | --- |
| `Osnovni` | `UNKNOWN_REVIEW_REQUIRED` | Core VBA module; dynamic query and navigation checks required. |
| `Prodaja` | `UNKNOWN_REVIEW_REQUIRED` | Core VBA module. |
| `UnosRobe` | `UNKNOWN_REVIEW_REQUIRED` | Core VBA module. |
| `PrenosRobe` | `UNKNOWN_REVIEW_REQUIRED` | Core VBA module. |
| `Nivelacija` | `UNKNOWN_REVIEW_REQUIRED` | Core VBA module. |
| `Povratnica` | `UNKNOWN_REVIEW_REQUIRED` | Core VBA module. |
| `VremenskaMasina` | `UNKNOWN_REVIEW_REQUIRED` | Date navigation helper. |
| `basCalc` | `DO_NOT_TOUCH` | Utility module. |
| `basCalendar` | `DO_NOT_TOUCH` | Utility module. |
| `basMB_CONSTANTS` | `DO_NOT_TOUCH` | Constants module. |
| `basZoomBox` | `DO_NOT_TOUCH` | UI helper module. |

## Repository Notes

- `TRENDPLUS.accdb` is an `ARCHIVE_ONLY` candidate until business confirms otherwise.
- `Query10` is intentionally treated as destructive and blocked from any cutoff work.
- Any object still marked `UNKNOWN_REVIEW_REQUIRED` must not be rewired before source export and sign-off.
