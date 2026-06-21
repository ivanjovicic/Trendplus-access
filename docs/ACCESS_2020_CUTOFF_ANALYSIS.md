# Trendplus Access 2020 Cutoff Analysis and Safe Rollout Plan

## 1. Executive Summary

Status dokumenta: **analiza i plan; nije odobrenje za direktnu implementaciju**.

MDB je legacy retail inventory/sales aplikacija sa journal-centered modelom, ali nema jedan cist reporting sloj. Dokazi pokazuju:

- `tblDnevnikPromena` is the central journal table.
- `tblDnevnikPromena.Datum` is the best global lower-bound cutoff field.
- Most journal rows are older than 2020: 11,991 of 16,394 rows, or 73.1%.
- The database already contains stock snapshot tables (`tblArtikli`, `tblArtikliProslost`) and dynamic query generation, so a blanket cutoff applied everywhere would be risky.
- There are orphan child rows in several transaction tables, especially `tblPovratnice`, so join-based filtering must be handled carefully.
- `TRENDPLUS.accdb` nije ekvivalentna novija kopija MDB-a: sadrzi samo podatke do `2019-11-13`, pa cutoff od 2020 u njoj vraca nula redova.
- Oba fajla su pushovana na `main`, ali je MDB sadrzajno noviji: ima podatke do `2026-04-05` i vise form/report objekata menjanih tokom 2026.

Recommendation in one sentence:

> Napraviti novi read-only reporting/query sloj za regularne journal-driven preglede sa `Datum >= DateSerial(2020,1,1)`, ne menjati base tabele ni postojece query-je, ne dirati lager/karticu/popise dok se ne klasifikuju, i obezbediti archive/full-history putanju pre prebacivanja UI-a.

Related repo artifacts:

- [ACCESS_OBJECT_CLASSIFICATION.md](ACCESS_OBJECT_CLASSIFICATION.md)
- [ACCESS_2020_TEST_MATRIX.md](ACCESS_2020_TEST_MATRIX.md)
- [ACCESS_2020_GO_NO_GO.md](ACCESS_2020_GO_NO_GO.md)
- [sql/reporting-2020](../sql/reporting-2020/)
- [sql/audit](../sql/audit/)

### Odluka o spremnosti

| Stavka | Status |
| --- | --- |
| Smer arhitekture | Odobren za proof-of-concept |
| Direktna produkcijska implementacija | **Nije odobrena** |
| MDB source of truth | Najjaci kandidat, ali poslovno potvrditi pre rada |
| ACCDB kao 2020+ baza | Odbaceno; nema nijedan journal red od 2020 nadalje |
| Lager/kartica/popis strategija | Otvoren blocking gate |
| Dynamic SQL/VBA dependency map | Otvoren blocking gate |
| Orphan politika | Otvoren blocking gate |

U ovoj fazi ne menjati MDB/ACCDB, ne implementirati cutoff i ne brisati podatke.

### Provera naknadne ocene kompletnosti

Tvrdnja da resenje nije spremno za direktan produkcijski rollout stoji. Medjutim, ocena `75-80%` opisuje stariju verziju review-a bolje nego ovu dopunjenu kanonsku verziju.

Treba odvojiti tri razlicita statusa:

| Dimenzija | Status | Obrazlozenje |
| --- | --- | --- |
| Kompletnost arhitektonskog plana | Visoka | Definisani su slojevi, klasifikacije, faze, rollback i `S0-S9` gate-ovi |
| Zatvorenost tehnickih dokaza | Delimicna | Nedostaju puni RecordSource/VBA export i poslovne odluke za stock/orphan slucajeve |
| Stanje implementacije | 0% u ovom zadatku | Nijedan Access objekat niti podatak nije promenjen |
| Produkcijska spremnost | `NO-GO` | Otvoreni su `S0`, `S2`, `S3`, `S5`, `S7`, `S8` i `S9` |

Ocena tvrdnji iz naknadnog review-a:

| Tvrdnja | Ocena prema trenutnim fajlovima i MDB dokazima |
| --- | --- |
| Ne brisati podatke/base tabele i ne menjati `qryDnevnik` | Potvrdjeno |
| Novi 2020+ reporting sloj je najbolji pravac | Potvrdjeno samo za journal-driven preglede |
| Lager/kartica/popisi su najveca funkcionalna rupa | Potvrdjeno |
| Nedostaje klasifikacija svakog objekta | Vise nije tacno; dodata je u 7.6, ali `UNKNOWN_REVIEW_REQUIRED` stavke jos cekaju dokaz |
| Nedostaju go/no-go uslovi | Vise nije tacno; definisani su `S0-S9` gate-ovi |
| Nedostaju ocekivane audit brojke | Delimicno; journal i child baseline su dokumentovani, ali Access audit query objekti jos nisu implementirani |
| Nedostaje orphan odluka | Delimicno; tehnicka politika je definisana, poslovna legitimnost orphan redova ostaje otvorena |
| Nedostaje potvrda MDB source of truth | Potvrdjeno kao otvoren poslovni gate; tehnicki dokazi snazno favorizuju MDB |
| Nedostaje popis dynamic SQL mesta i `Query10` caller-a | Potvrdjeno; zahteva uspesan full source export |
| UI ne treba odmah menjati | Potvrdjeno |

Prakticni zakljucak: dokument je dovoljno potpun da vodi kontrolisan proof-of-concept, ali dokazi nisu dovoljno zatvoreni za produkcijski rollout.

## 2. MDB Extraction Method and Limitations

### What was extracted

I used DAO/ACE metadata access from Python (`DAO.DBEngine.120`) to read:

- table names
- column names and types
- row counts
- indexes
- relationships
- saved query names and SQL
- forms, reports, modules, and container names
- database startup properties

I also used binary string inspection on `Trend plus.mdb` to find:

- embedded SQL strings
- control names
- some event procedure names
- dynamic query-generation traces
- date-filtering traces inside VBA-like code strings

### What was not fully extracted

I could not reliably export the full VBA source text or the exact RecordSource/ControlSource text for every form/report without opening Microsoft Access in a stable automation session.

`olevba` je takodje proveren, ali ova verzija alata ne podrzava MDB/ACCDB kao ulaz. `SaveAsText` automatizacija je probana iskljucivo nad privremenom kopijom MDB-a sa uklonjenim startup formularom u toj kopiji; Access proces je ostao blokiran i export nije proizveo pouzdan rezultat. Originalni MDB/ACCDB nisu menjani.

Because of that, the following are only partially confirmed:

- exact form/report RecordSource values
- exact event procedure bodies
- all runtime-created temporary queries

Status for these items: `nije potvrdeno`

Manual verification command if you want full source export later from inside Access VBA:

```vba
Application.SaveAsText acModule, "Prodaja", "C:\temp\Prodaja.txt"
Application.SaveAsText acForm, "frmStatistika", "C:\temp\frmStatistika.txt"
Application.SaveAsText acReport, "rptProdaja", "C:\temp\rptProdaja.txt"
Application.SaveAsText acQuery, "qryDnevnik", "C:\temp\qryDnevnik.txt"
```

### MDB naspram ACCDB

Git istorija potvrduje da su oba fajla na `main`:

| Fajl | Commit | Journal rows | Raspon datuma | 2020+ rows | Zakljucak |
| --- | --- | ---: | --- | ---: | --- |
| `Trend plus.mdb` | `4f8add4` | 16,394 | 2011-01-01 do 2026-04-05 | 4,403 | Aktuelniji kandidat za produkcioni source of truth |
| `TRENDPLUS.accdb` | `922d383` | 11,870 | 2011-01-01 do 2019-11-13 | 0 | Verovatni pre-2020 snapshot/archive; poslovno potvrditi |

Dodatni dokaz:

- ACCDB ima 61,885 redova u `tblProdaja`; MDB ima 88,733.
- ACCDB ima iste nazive formi, reporta i modula, ali starije verzije vise report objekata.
- MDB reporti `rptProdaja`, `rptPrenos`, `rptPovratnica`, `rptUnos`, `rptNivelacija` i `rptPopis`, kao i `frmPrenosRobe`, imaju metadata `LastUpdated` tokom 2026; njihove ACCDB kopije su starije.
- ACCDB nema `Query1` do `Query10`; MDB ih ima, ukljucujuci destruktivni `Query10`.
- Isti orphan brojevi postoje u obe baze, sto ukazuje da je ACCDB stariji snapshot iste linije podataka.

**Gate S0 - Source of truth:** pre bilo kakve implementacije vlasnik sistema mora eksplicitno potvrditi da se radi na kopiji `Trend plus.mdb`. Ako je ACCDB namerno arhiva do 2019, treba je oznaciti kao read-only archive i ne dodavati joj 2020 cutoff sloj.

## 3. Confirmed Schema Facts

### Database shape

- User tables: 18 core tables plus `zstblZoomBox`
- Saved queries: 20 total query objects in `Trend plus.mdb`
- Forms: 22
- Reports: 11
- Modules: 11
- Macros/Scripts container: 0

### Core table list and counts

| Table | Rows | Notes |
| --- | ---: | --- |
| `tblArtikli` | 12,341 | Current article snapshot |
| `tblArtikliProslost` | 12,313 | Historical article snapshot |
| `tblDnevnikPromena` | 16,394 | Central journal |
| `tblDobavljaci` | 114 | Suppliers |
| `tblNivelacije` | 10,765 | Leveling adjustments, linked to journal |
| `tblNivelacijePrivremena` | 24 | Temporary leveling staging |
| `tblObjekat` | 6 | Stores/objects |
| `tblPodesavanja` | 1 | Settings row |
| `tblPovratnice` | 2,500 | Returns, linked to journal |
| `tblPovratnicePrivremena` | 7 | Temporary returns staging |
| `tblPrenosPrivremena` | 9 | Temporary transfer staging |
| `tblPrenosRobe` | 8,942 | Transfers, linked to journal |
| `tblProdaja` | 88,733 | Sales, indexed by journal |
| `tblProdajaPrivremena` | 6 | Temporary sales staging |
| `tblSezona` | 15 | Seasons with dates |
| `tblTipObuce` | 27 | Shoe types |
| `tblUnosPrivremena` | 1 | Temporary receiving staging |
| `tblUnosRobe` | 19,588 | Goods receipt, indexed by journal |
| `zstblZoomBox` | 1 | UI helper table |

### Key columns in the core tables

| Table | Key columns |
| --- | --- |
| `tblDnevnikPromena` | `IDDnevnik`, `RedniBroj`, `Datum`, `BrojKalkulacije`, `TipPromene`, `IznosPromene`, `IDObjekat`, `Napomena` |
| `tblProdaja` | `IDArtikal`, `Kolicina`, `ProdajnaCena`, `IDObjekat`, `IDDnevnik` |
| `tblUnosRobe` | `IDUnos`, `IDArtikal`, `Kolicina`, `ProdajnaCena`, `TipUnosa`, `IDDnevnik` |
| `tblPrenosRobe` | `IDPrenos`, `IDArtikal`, `Kolicina`, `ProdajnaCena`, `IDDnevnik`, `IDArtikalPrenos` |
| `tblPovratnice` | `IDArtikal`, `Kolicina`, `ProdajnaCena`, `IDObjekat`, `IDDnevnik` |
| `tblNivelacije` | `IDArtikal`, `Kolicina`, `StaraCena`, `NovaCena`, `IDDnevnik` |
| `tblArtikli` | `IDArtikal`, `PLU`, `Artikal`, `IDTipObuce`, `IDDobavljac`, `NabavnaCena`, `NabavnaCenaDin`, `PrvaProdajnaCena`, `ProdajnaCena`, `Kolicina`, `Komentar`, `IDObjekat`, `IDSezona` |
| `tblArtikliProslost` | same shape as `tblArtikli` |
| `tblObjekat` | `IDObjekat`, `Ime`, `Adresa`, `BrTelObjekt`, `Direktor` |
| `tblDobavljaci` | `IDDobavljac`, `Dobavljac`, `Adresa`, `BrTelDobav`, `Napomena` |
| `tblSezona` | `IDSezona`, `Sezona`, `SezonaPocetak`, `SezonaKraj` |
| `tblTipObuce` | `IDTipObuce`, `Naziv` |
| `tblPodesavanja` | `BackupPutanja`, `BackupBrojKopija`, `PocetakSezone`, `ExportPutanja` |
| `zstblZoomBox` | `OneAndOnlyRecord`, `FontName`, `FontSize`, `Bold`, `Italic` |

## 4. Confirmed / Refuted Assumptions

| # | Assumption | Status | Evidence |
| --- | --- | --- | --- |
| 1 | `tblDnevnikPromena` is the central journal table | Potvrdeno | It is referenced by the core transaction queries and linked to `tblNivelacije`, `tblPrenosRobe`, `tblPovratnice`, and `tblObjekat` |
| 2 | `tblDnevnikPromena.Datum` is the correct global cutoff date | Potvrdeno kao primarni kandidat | It is the only confirmed journal date field; it is indexed; it has no nulls |
| 3 | `tblProdaja` links to `tblDnevnikPromena` through `IDDnevnik` | Potvrdeno | Query SQL uses `tblProdaja.IDDnevnik IN (SELECT IDDnevnik FROM qryDnevnik)` and `tblProdaja` has an `IDDnevnik` index |
| 4 | `tblUnosRobe` links to `tblDnevnikPromena` through `IDDnevnik` | Potvrdeno | Query SQL uses `tblUnosRobe.IDDnevnik IN (SELECT IDDnevnik FROM qryDnevnik ...)` and `tblUnosRobe` has an `IDDnevnik` index |
| 5 | `tblPrenosRobe` links to `tblDnevnikPromena` through `IDDnevnik` | Potvrdeno | Formal relationship exists and query SQL uses `qryDnevnik` |
| 6 | `tblPovratnice` links to `tblDnevnikPromena` through `IDDnevnik` | Potvrdeno | Formal relationship exists and query SQL uses `IDDnevnik` |
| 7 | `tblNivelacije` links to `tblDnevnikPromena` through `IDDnevnik` | Potvrdeno | Formal relationship exists and query SQL uses `IDDnevnik` |
| 8 | Regular views/reports can safely be filtered through `tblDnevnikPromena.Datum` | Delimicno / ne kao blanket pravilo | Safe for journal-driven review reports, not safe as a universal rule for stock/card/snapshot views |
| 9 | `frmPregled` contains `txtDatumOd` and `txtDatumDo` | Refutovano / nije potvrdeno | Binary strings place `txtDatumOd`, `txtDatumDo`, `tabStatistika`, `pageProdaja`, `pageNabavljeno`, and `CreateAccessQuery` together, which points to `frmStatistika`, not `frmPregled` |
| 10 | `frmLager` and `frmKartica` can be filtered from 2020 without breaking business meaning | Nije potvrdeno, verovatno rizicno | Stock and card logic appears to mix snapshot tables and movement history; opening-balance logic may be required |
| 11 | There are no hidden queries/macros/VBA routines that bypass the proposed query layer | Refutovano / nije potvrdeno | Dynamic query creation strings (`CreateAccessQuery`, `QueryName`, `SQLStr`, `DeleteObject`) and many VBA event names are present |
| 12 | Reports use query sources that can be safely redirected to filtered query versions | Delimicno potvrdeno | Journal-driven reports look redirectable; stock/history reports need object-by-object review |

## 5. Date Column Analysis

### Confirmed date-like columns

| Table | Column | Type | Usage | Should cutoff use this? |
| --- | --- | --- | --- | --- |
| `tblDnevnikPromena` | `Datum` | Date/Time | Journal date | Yes, this is the primary cutoff field |
| `tblSezona` | `SezonaPocetak` | Date/Time | Season start | No, this is business season metadata |
| `tblSezona` | `SezonaKraj` | Date/Time | Season end | No, this is business season metadata |

### Journal date facts

- `tblDnevnikPromena.Datum` has an index named `Datum`.
- `tblDnevnikPromena.Datum` has no nulls in the current data.
- Date range spans `2011-01-01` to `2026-04-05`.
- Pre-2020 rows: 11,991
- From 2020 onward: 4,403

### Year distribution in `tblDnevnikPromena`

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

### Transaction type distribution in journal

| Type | Total | Pre-2020 | From 2020 |
| --- | ---: | ---: | ---: |
| `PRODAJA` | 7,388 | 5,120 | 2,268 |
| `UNOS ROBE` | 6,503 | 4,608 | 1,895 |
| `PRENOS ROBE` | 1,169 | 1,147 | 22 |
| `POVRATNICA` | 1,030 | 885 | 145 |
| `NIVELACIJA` | 304 | 231 | 73 |

### Edge cases seen in data or code

- Journal sadrzi redove do `2026-04-05`. Poslovni zahtev definise samo donju granicu, pa se ne uvodi nenavedena gornja granica.
- There are no null journal dates, which simplifies filtering.
- Several VBA-generated SQL strings use `DateValue(Datum)` and `Year(DateValue(Datum))`, so date handling is already mixed with runtime query building.
- `Query10` is destructive and deletes rows older than 2024; it must not be reused for the 2020 cutoff.

## 6. Relationship Analysis

### Formal relations extracted from DAO

| Parent | Child | Field |
| --- | --- | --- |
| `tblDnevnikPromena` | `tblNivelacije` | `IDDnevnik` |
| `tblDnevnikPromena` | `tblPrenosRobe` | `IDDnevnik` |
| `tblObjekat` | `tblDnevnikPromena` | `IDObjekat` |
| `tblDnevnikPromena` | `tblPovratnice` | `IDDnevnik` |
| `tblObjekat` | `tblPovratnice` | `IDObjekat` |

### Implied but not formally enforced links

These tables are filtered through journal-based queries and have an `IDDnevnik` index, but no formal relationship was listed in DAO:

- `tblProdaja`
- `tblUnosRobe`
- `tblPrenosRobe` is formally related, but also used directly in query chains
- `tblPovratnice` is formally related, but has a large orphan count

### Important integrity observation

There are child rows whose `IDDnevnik` value does not match any row in `tblDnevnikPromena`:

| Table | Orphan rows | Share of table |
| --- | ---: | ---: |
| `tblProdaja` | 347 | 0.39% |
| `tblUnosRobe` | 109 | 0.56% |
| `tblPrenosRobe` | 45 | 0.50% |
| `tblPovratnice` | 567 | 22.68% |
| `tblNivelacije` | 0 | 0.00% |

This is a significant risk for any cutoff implementation that assumes perfect referential integrity.

### Obavezna orphan politika

Child tabele nemaju sopstveni potvrdjeni datum transakcije. Zato orphan red bez parent reda u `tblDnevnikPromena` **nema dokaziv datum** i ne moze se korektno svrstati ni u period pre 2020 ni u period 2020+.

Pravila za prvu implementaciju:

1. Ne popravljati i ne brisati orphan redove automatski.
2. Ne koristiti `LEFT JOIN` sa pretpostavljenim datumom da bi se orphan redovi nasilno ukljucili u 2020+ pregled.
3. Regularni 2020+ query sme da prikaze samo redove sa postojecim journal parentom i datumom koji prolazi cutoff.
4. Svaki per-document query mora imati prateci `qryAuditOrphan...` query.
5. Izvestaj validacije mora odvojeno prikazati `eligible`, `pre-cutoff` i `unclassifiable orphan` redove.
6. Posebno za `tblPovratnice` poslovni vlasnik mora objasniti 567 orphan redova pre UI switch-a.

Ovo nije tvrdnja da orphan redove treba sakriti zauvek. To je kontrola da redovi bez datuma ne budu lazno predstavljeni kao 2020+ promet.

### Child reconciliation baseline za MDB

Brojevi ispod su line-row brojevi iz child tabela, ne broj journal dokumenata:

| Child table | Total lines | Parent pre-2020 | Parent 2020+ | Orphan | 2020+ `Kolicina` | Wrong journal type | Negative/zero qty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `tblProdaja` | 88,733 | 62,173 | 26,213 | 347 | 26,889 | 0 | 0 / 0 |
| `tblUnosRobe` | 19,588 | 15,871 | 3,608 | 109 | 28,841 | 0 | 0 / 0 |
| `tblPrenosRobe` | 8,942 | 8,698 | 199 | 45 | 936 | 0 | 0 / 0 |
| `tblPovratnice` | 2,500 | 1,751 | 182 | 567 | 304 | 0 | 0 / 0 |
| `tblNivelacije` | 10,765 | 8,672 | 2,093 | 0 | 13,948 | 0 | 0 / 0 |

Za svaku tabelu vazi `Total = pre-2020 + 2020+ + orphan`. Nema child reda vezanog za journal parent pogresnog `TipPromene`, niti negativne/nulte kolicine u ovih pet tabela. Ovo je koristan baseline, ali ne resava poslovnu legitimnost orphan redova.

## 7. Object Impact Review

### 7.1 Saved queries

| Object | Type | Current source/query | Uses date? | Uses `tblDnevnikPromena`? | Cutoff impact | Recommendation |
| --- | --- | --- | --- | --- | --- | --- |
| `qryArtikli` | Query | Filters articles by object and supplier | No | No | Low | Keep as-is; this is not a journal view |
| `qryDnevnik` | Query | Hardcoded 2014 date range, hardcoded object/supplier IDs | Yes | Yes | Very high | Do not repurpose; create a new `qryDnevnikPregled2020` instead |
| `qryPrenos` | Query | Joins `tblPrenosRobe` to `qryDnevnik` and `qryArtikli` | Yes, indirectly | Yes | High | Repoint to a new filtered journal query |
| `qryPrenosGroup` | Query | Aggregates `qryPrenos` | Yes, indirectly | Yes | High | Repoint as a child of new filtered query |
| `qryProdaja` | Query | Joins `tblProdaja` to `qryDnevnik` and `qryArtikli` | Yes, indirectly | Yes | High | Repoint to a new filtered journal query |
| `qryUnos` | Query | Joins `tblUnosRobe` to `qryDnevnik`, excludes correction docs | Yes, indirectly | Yes | High | Repoint to a new filtered journal query |
| `qryUnosGroup` | Query | Aggregates `qryUnos` | Yes, indirectly | Yes | High | Repoint as a child of new filtered query |
| `qryUnetoCisto` | Query | Joins `qryUnosGroup` and `qryPrenosGroup` | Yes, indirectly | Yes | High | Repoint after base queries are replaced |
| `qryUnetoPrenos` | Query | Computes net unreceived quantity after transfer | Yes, indirectly | Yes | High | Repoint after base queries are replaced |
| `qryUnetoUkupno` | Query | UNION of `qryUnetoCisto` and `qryUnetoPrenos` | Yes, indirectly | Yes | High | Repoint after base queries are replaced |
| `Query1` | Query | Broken/legacy `WHERE datum between ''` | Yes | Yes | Unknown | Review manually; likely unused |
| `Query2` | Query | Journal rows after `2024-01-01` | Yes | Yes | High | Treat as archive/maintenance query only |
| `Query3` | Query | Malformed select involving `tblNivelacije` | Maybe | Yes | Unknown | Review manually; likely broken or unused |
| `Query4` | Query | Reads `tblArtikliProslost` | No direct date | No direct | Medium | Likely report/support query; review before redirect |
| `Query5` | Query | Journal tip/date projection | Yes | Yes | Medium | Review if used by a report |
| `Query7` | Query | Broken typo query on `tblDnevnikPromea` | Yes | Intended yes | Unknown | Review manually; likely broken |
| `Query8` | Query | Malformed select involving `tblArtikli` and journal | Maybe | Yes | Unknown | Review manually; likely broken |
| `Query9` | Query | Broken typo query with `Datum < #2024-01-01#` | Yes | Intended yes | High | Treat as legacy archive query only |
| `Query10` | Query | `DELETE` journal rows older than `2024-01-01` | Yes | Yes | Critical | Do not use for the cutoff; this is destructive |
| `UpitProba` | Query | Sales aggregation by article | No direct date | Yes via `tblProdaja` | Medium | Safe only if its source is intentional and reviewed |

### 7.2 Forms

| Form | Current source/query evidence | Uses date? | Uses journal? | Cutoff impact | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `frmDnevnik` | Report launcher and journal-browser strings | Likely yes | Likely yes | High | Review first; likely should get a filtered review mode |
| `frmDobavljaci` | Master-data form | No | No | Low | Keep unchanged |
| `frmGlavni` | Navigation shell | No | No | Low | Keep unchanged |
| `frmKartica` | Strings around article-card and value logic; exact source not fully extracted | Likely yes | Likely yes | High | High-risk object; likely needs archive mode or opening balance |
| `frmLager` | Listed in workspace and helper strings; exact source not fully extracted | Likely yes | Unknown/likely | High | High-risk object; do not blanket-filter without stock analysis |
| `frmNivelacija` | Transaction form | Possibly | Yes via journal flow | Medium | Review before redirecting sources |
| `frmObjekat` | Master-data form | No | No | Low | Keep unchanged |
| `frmPodesavanja` | Settings form | No | No | Low | Keep unchanged |
| `frmPregled` | Exact source not extracted | Unknown | Unknown | Medium | Review manually; do not assume the date controls are here |
| `frmPrenosRobe` | Transaction form | Possibly | Yes | Medium | Review before redirecting sources |
| `frmPretraga` | Binary strings show article snapshot queries on `tblArtikli` / `tblArtikliProslost` with `Kolicina>0` | No direct journal cutoff | No | Low/Medium | Likely should stay snapshot-based, not journal-cutoff based |
| `frmProdaja` | Transaction form | Possibly | Yes | Medium | Review before redirecting sources |
| `frmPromenaArtikla` | Binary strings show `SUM(Kolicina*ProdajnaCena)` from `tblArtikli` and `tblArtikliProslost` | Yes, but snapshot-oriented | No direct journal | High | Review carefully; likely stock/snapshot sensitive |
| `frmReset` | Maintenance/reset strings | Maybe | Maybe | High | Review manually; destructive-leaning behavior likely |
| `frmSezona` | Season date controls / season logic | Yes | No | Low | Keep separate from 2020 reporting cutoff |
| `frmStatistika` | Binary strings show `txtDatumOd`, `txtDatumDo`, `CreateAccessQuery`, `QueryName`, `SQLStr`, `tabStatistika` | Yes | Likely yes | High | This is the confirmed UI place for default cutoff/date clamping |
| `frmTest` | Test form | Unknown | Unknown | Low | Ignore unless referenced by startup or QA |
| `frmTipObuce` | Master-data form | No | No | Low | Keep unchanged |
| `frmUnosArtikal` | Transaction/data-entry form | Possibly | Possibly | Medium | Review before redirecting sources |
| `frmUnosDobavljac` | Master-data form | No | No | Low | Keep unchanged |
| `zsfrmCalc` | Utility form | No | No | Low | Keep unchanged |
| `zsfrmCalendar` | Utility form | No | No | Low | Keep unchanged |
| `zsfrmZoomBox` | Utility form | No | No | Low | Keep unchanged |

### 7.3 Reports

| Report | Current source/query evidence | Uses date? | Uses journal? | Cutoff impact | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `rptProdaja` | Embedded strings show `rptProdaja` near journal-driven report logic | Yes | Yes | High | Redirect to filtered reporting query |
| `rptPrenos` | Embedded strings show `rptPrenos` and `tblDnevnikPromena.IDDnevnik` | Yes | Yes | High | Redirect to filtered reporting query |
| `rptPovratnica` | Embedded strings show `rptPovratnica` with journal logic | Yes | Yes | High | Redirect to filtered reporting query |
| `rptNivelacija` | Embedded strings show `rptNivelacija` with journal logic | Yes | Yes | High | Redirect to filtered reporting query |
| `rptUnos` | Embedded strings show `rptUnos` with journal logic | Yes | Yes | High | Redirect to filtered reporting query |
| `rptPopis` | Appears to be stock/reporting output; exact source not fully extracted | Likely no journal-only | Possibly indirect | High | Review as stock/snapshot-sensitive |
| `rptPopisBlanko` | Likely print template / blank stock report | Unknown | Unknown | Medium | Review manually |
| `rptPopisProslost` | Historical stock report counterpart | No direct journal | No direct | Medium | Keep historical/archive path distinct |
| `Copy of rptNivelacija` | Duplicate/legacy report object | Unknown | Unknown | Medium | Review or archive |
| `Copy of rptPopis` | Duplicate/legacy report object | Unknown | Unknown | Medium | Review or archive |
| `desktop` | Legacy/odd report object name | Unknown | Unknown | Medium | Review manually; likely artifact |

### 7.4 Modules and macros

| Module/Macro | Evidence | Cutoff impact | Recommendation |
| --- | --- | --- | --- |
| `Osnovni` | Core VBA module listed in DAO | High | Review for shared query builders and navigation |
| `Prodaja` | Core sales VBA module listed in DAO | High | Review for report launching and filters |
| `UnosRobe` | Core receipt VBA module listed in DAO | High | Review for transaction entry and query generation |
| `PrenosRobe` | Core transfer VBA module listed in DAO | High | Review for transfer logic and query generation |
| `Nivelacija` | Core leveling VBA module listed in DAO | High | Review for stock/value impacts |
| `Povratnica` | Core returns VBA module listed in DAO | High | Review for return flows |
| `VremenskaMasina` | Date-navigation helper module listed in DAO | Medium | Review for date logic and date stepping |
| `basCalc` | Utility module listed in DAO | Medium | Likely okay, but check for report helpers |
| `basCalendar` | Utility module listed in DAO | Medium | Likely okay, but check for date range helpers |
| `basMB_CONSTANTS` | Constants module | Low | Keep unchanged |
| `basZoomBox` | UI helper module | Low | Keep unchanged |
| Macros/Scripts | DAO `Scripts` container count = 0 | Low | No saved macros found |

### 7.5 Deep dive on the three highest-risk screens

#### `frmStatistika`

Confirmed binary-string evidence:

- `Form_frmStatistika`
- `tabStatistika`
- `pageProdaja`
- `pageNabavljeno`
- `txtDatumOd`
- `txtDatumDo`
- `lstTopArtikli`
- `lstTopNabavljeno`
- `cmdObradi`
- `cmbDobavljac`
- `cmbTipObuce`
- `chkSnizeni`
- `strDatumOd`
- `strDatumDo`
- `CreateAccessQuery`
- `QueryName`
- `SQLStr`

Interpretation:

- This is the most likely UI entry point for a 2020 cutoff default.
- The presence of `CreateAccessQuery`, `QueryName`, and `SQLStr` indicates the form probably generates SQL dynamically, not only through saved queries.

Status:

- Exact RecordSource: `nije potpuno potvrdeno`
- Exact event bodies: `nije potvrdeno`

#### `frmLager`

Confirmed binary-string evidence:

- `Form_frmLager`
- `cmdLager_Click`
- `strLager`
- `rstLager`
- `cmbSezona`
- `cmdIzlaz_Click`
- `Form_frmUnosArtikal`
- `txtNabavnaZ`
- `txtNabavnaDin`
- `txtProdajna`
- `txtKomentar2`
- `cmdPotvrdi_Click`
- `cmdUnesi_Click`

Relevant extracted SQL/string evidence nearby:

- `SELECT tblArtikli.IDArtikal, tblArtikli.Artikal FROM tblArtikli WHERE tblArtikli.Kolicina>0 AND tblArtikli.IDObjekat=... ORDER BY Artikal`
- `SELECT tblArtikliProslost.IDArtikal, tblArtikliProslost.Artikal FROM tblArtikliProslost WHERE tblArtikliProslost.Kolicina>0 AND tblArtikliProslost.IDObjekat=... ORDER BY Artikal`

Interpretation:

- `frmLager` is strongly snapshot-oriented and appears to depend on `tblArtikli` and `tblArtikliProslost`, not only on journal rows.
- Because of that, a simple journal-date filter is not enough to prove correct current stock behavior.

Status:

- Exact source/RecordSource: `nije potpuno potvrdeno`
- Stock meaning: `potrebna dodatna provera`

#### `frmKartica`

Confirmed binary-string evidence:

- `Form_frmKartica`
- `lstKartica`
- `cmdKartica_Click`
- `Report_Copy of rptPopis`
- `rptPopis`
- `rptPopisProslost`
- `rstArtikliProslost`
- `sngStanje`
- `strResetDatum`
- `DMax`
- `SetWarnings`

Interpretation:

- The card/history screen is likely tied to stock history and possibly to reset/rebuild routines.
- The presence of `rstArtikliProslost`, `sngStanje`, and `DMax` suggests historical calculation logic rather than a simple one-table list.
- Because exact source was not exported, this screen should be treated as high-risk until its source query chain is verified.

Status:

- Exact source/RecordSource: `nije potvrdeno`
- Whether it can be safely cutoff-filtered: `nije potvrdeno`
- Recommendation: use archive mode or opening-balance strategy until proven otherwise

### 7.6 Obavezna klasifikacija objekata

Nijedan postojeci objekat ne sme promeniti source/filter dok nema jednu od sledecih klasa i dokaz za tu klasu:

| Klasa | Pravilo |
| --- | --- |
| `FILTER_2020_SAFE` | Semantika je periodicki journal pregled; cutoff ne menja stanje ni operativnu logiku |
| `FULL_HISTORY_REQUIRED` | Racun ili prikaz zahteva celu istoriju |
| `OPENING_BALANCE_REQUIRED` | Prikaz kretanja od 2020 mora poceti stanjem na 2020-01-01 |
| `ARCHIVE_ONLY` | Namerno prikazuje staru/full-history putanju i nije default regularni pregled |
| `DO_NOT_TOUCH` | Base/master/settings/utility/maintenance ili operativni unos van reporting scope-a |
| `UNKNOWN_REVIEW_REQUIRED` | Nema dovoljno izvornog koda ili poslovnog dokaza; promena blokirana |

Trenutna konzervativna klasifikacija:

| Objekti | Trenutna klasa | Ciljna odluka |
| --- | --- | --- |
| Sve `tbl*` tabele i `zstblZoomBox` | `DO_NOT_TOUCH` | Nikada ne filtrirati niti menjati podatke zbog cutoff-a |
| Novi `qryDnevnikPregled2020` i validirani novi per-document query-ji | `FILTER_2020_SAFE` | Jedini centralni 2020+ reporting sloj |
| `qryDnevnik`, `qryArtikli`, `qryProdaja`, `qryUnos`, `qryPrenos`, `qryPrenosGroup`, `qryUnosGroup`, `qryUnetoCisto`, `qryUnetoPrenos`, `qryUnetoUkupno` | `DO_NOT_TOUCH` | Ostaviti legacy chain; klonovi zadrzavaju sve postojece filtere osim eksplicitno promenjenog perioda |
| `Query1`, `Query2`, `Query3`, `Query4`, `Query5`, `Query7`, `Query8`, `Query9`, `UpitProba` | `UNKNOWN_REVIEW_REQUIRED` | Potvrditi dependency/use; ne koristiti kao osnovu novog sloja |
| `Query10` | `DO_NOT_TOUCH` | Kritican destruktivni objekat; dokazati da nema poziva, ne pokretati i ne preimenovati u ovoj fazi |
| `frmStatistika` | `UNKNOWN_REVIEW_REQUIRED` | Kandidat za `FILTER_2020_SAFE` tek nakon exporta dynamic SQL-a i testa oba taba |
| `frmDnevnik`, `frmPregled` | `UNKNOWN_REVIEW_REQUIRED` | Kandidati za regular/archive dual mode nakon potvrde source-a |
| `frmKartica`, `frmLager` | `UNKNOWN_REVIEW_REQUIRED` | Prebaciti u `FULL_HISTORY_REQUIRED` ili `OPENING_BALANCE_REQUIRED` tek nakon dokaza |
| `frmPretraga`, `frmPromenaArtikla` | `FULL_HISTORY_REQUIRED` | Zadrzati snapshot semantiku; cutoff samo ako poseban pregled to eksplicitno trazi |
| `frmProdaja`, `frmUnosArtikal`, `frmPrenosRobe`, `frmNivelacija` | `DO_NOT_TOUCH` | Operativni unos ne menjati reporting cutoff-om; zasebno pregledati report-launch kod |
| `frmDobavljaci`, `frmObjekat`, `frmPodesavanja`, `frmSezona`, `frmTipObuce`, `frmUnosDobavljac` | `DO_NOT_TOUCH` | Master/settings forme |
| `frmGlavni` | `DO_NOT_TOUCH` | Menjati tek u posebnoj UI fazi ako dodaje archive navigaciju |
| `frmReset` | `DO_NOT_TOUCH` | Maintenance/high-risk; van cutoff scope-a |
| `frmTest`, `zsfrmCalc`, `zsfrmCalendar`, `zsfrmZoomBox` | `DO_NOT_TOUCH` | Test/utility objekti |
| `rptProdaja`, `rptPrenos`, `rptPovratnica`, `rptNivelacija`, `rptUnos` | `UNKNOWN_REVIEW_REQUIRED` | Kandidati za `FILTER_2020_SAFE` nakon RecordSource/WhereCondition dokaza i parity testa |
| `rptPopis`, `rptPopisProslost`, `rptPopisBlanko`, `Copy of rptPopis` | `UNKNOWN_REVIEW_REQUIRED` | Stock/archive klasifikacija obavezna; bez blanket cutoff-a |
| `Copy of rptNivelacija`, `desktop` | `UNKNOWN_REVIEW_REQUIRED` | Utvrditi da li su aktivni ili artefakti |
| `Osnovni`, `Prodaja`, `UnosRobe`, `PrenosRobe`, `Nivelacija`, `Povratnica`, `VremenskaMasina` | `UNKNOWN_REVIEW_REQUIRED` | Export i pretraga dynamic SQL/report launch logike su blocking gate |
| `basCalc`, `basCalendar`, `basMB_CONSTANTS`, `basZoomBox` | `DO_NOT_TOUCH` | Utility moduli; menjati samo uz direktan dokaz zavisnosti |
| `TRENDPLUS.accdb` | `ARCHIVE_ONLY` kandidat | Potvrditi poslovnu namenu; trenutno nema 2020+ podatke |

Napomena: `frmPovratnica` nije pronadjena u listi formi; povratnica postoji kao modul/report i transakciona tabela. Ne izmisljati form objekat tokom implementacije.

## 8. Analysis of Reporting-Cutoff Risk

### Why a blanket cutoff is risky

The database does not appear to be a pure event log. It has:

- live snapshot tables (`tblArtikli`)
- historical snapshot tables (`tblArtikliProslost`)
- journal-driven movement tables (`tblProdaja`, `tblUnosRobe`, `tblPrenosRobe`, `tblPovratnice`, `tblNivelacije`)
- runtime query generation in VBA strings

That means a cutoff on `tblDnevnikPromena.Datum` will be safe only for objects whose meaning is strictly journal review.

### Inventory / lager risk

The biggest risk is hidden stock logic.

Evidence that stock-related screens use snapshot tables:

- `frmPretraga` strings show queries like `tblArtikli WHERE Kolicina>0` and `tblArtikliProslost WHERE Kolicina>0`
- `frmPromenaArtikla` strings show `SUM(Kolicina * ProdajnaCena)` from both `tblArtikli` and `tblArtikliProslost`

This suggests at least some inventory views are snapshot-based, not movement-based.

However, journal-driven summary queries also exist:

- `qryUnos`
- `qryPrenos`
- `qryUnetoUkupno`
- `qryProdaja`

So the safest conclusion is:

> Do not assume every lager/card/report can be filtered by journal date without changing meaning.

### Safest pattern for this MDB

Recommended pattern:

- Pattern A for journal-driven review screens: cutoff only on regular review/report queries.
- Pattern B for stock/card calculations if they are movement-based: opening balance as of `2020-01-01`.
- Pattern C for admin/archive access: a separate full-history mode.

For this MDB, the safest combination is:

- default regular views: Pattern A
- stock/card: Pattern B or archive mode
- admin access: Pattern C

### Precizan dizajn novog query sloja

Centralni query treba da bude mali i da definise samo eligible journal header-e:

```sql
SELECT d.*
FROM tblDnevnikPromena AS d
WHERE d.Datum >= DateSerial(2020, 1, 1);
```

Per-document query-ji zatim rade `INNER JOIN` na `IDDnevnik`. Ne treba menjati cutoff u pet razlicitih query-ja niti direktno citati `tblDnevnikPromena` iz svakog reporta.

Vazna ogranicenja:

- Novi query-ji nisu slepe kopije samo po nazivu. Svaki mora sacuvati postojece store/article/supplier/correction filtere konkretnog consumer-a.
- `qryUnos` trenutno iskljucuje `BrojKalkulacije='KOREKCIJA'`; taj uslov ne sme nestati u klonu bez poslovne odluke.
- `qryArtikli` i `qryDnevnik` sadrze hardcoded ID/date vrednosti. Njihova semantika se ne sme slucajno preneti u univerzalni query.
- Orphan child redovi ostaju van regularnog 2020+ rezultata i idu u poseban audit rezultat.
- Povratnica ili nivelacija sa journal datumom od 2020+ ulazi u regularni period cak i ako se odnosi na stariji artikal/prodaju; veza sa originalnom prodajom nije potvrdjena u semi i mora se testirati poslovno.

Za prvi rollout je najbezbedniji fiksni datum u jednom centralnom query-ju. Ako cutoff kasnije postane promenljiv, vrednost treba ucitati jednom i proslediti parametrizovanom QueryDef-u ili filteru. `DLookup` po svakom redu nije preporucen zbog performansi i tezeg testiranja.

### Ispravna arhitektura grananja

Regularni UI, arhiva i stock/card nisu serijski slojevi jedan ispod drugog. To su odvojeni consumer putevi sa razlicitim pravilima:

```text
                         +-> Reporting 2020+ -> Regular journal UI/reporti
Base tables (untouched) -+-> Full history    -> Archive/admin UI
                         +-> Snapshot/opening -> Lager/kartica/popis
```

Ovo je vazno jer archive i stock put ne smeju naslediti 2020 filter samo zato sto dele iste base tabele ili navigation formu.

## 9. Options Comparison

| Option | Description | Pros | Cons | Risk | Recommendation |
| --- | --- | --- | --- | --- | --- |
| A | Central reporting/query layer with `qryDnevnikPregled2020` and per-document filtered queries | Clean separation, easy to audit, low blast radius | Requires touching query chain and some forms/reports | Low/Medium | **Best option** |
| B | Modify existing core query like `qryDnevnik` | Minimal object count, quick to implement | Dangerous because `qryDnevnik` is already hardcoded and likely legacy-specific | High | Not recommended except for a strictly display-only clone |
| C | Form/report-level filters (`Me.Filter`, `DoCmd.OpenReport ... , "Datum >= ..."`) | Fast for isolated UI screens | Inconsistent, easy to miss hidden entry points | Medium/High | Useful as a temporary UI layer, not the main design |
| D | Configurable cutoff in settings table | Flexible, future-proof | More moving parts; current settings table has no date cutoff field | Medium | Acceptable later, but not needed for first fixed 2020 rollout |
| E | Archive database copy | Good for legal/archive separation | Duplicates logic, not a real solution for daily use | Medium | Use only as backup/archive, not primary |

### Ranking

1. Option A
2. Option C as a UI supplement
3. Option D only if cutoff must be configurable later
4. Option E for archive only
5. Option B only if you are working on a report-only clone and have tested the entire dependency chain

## 10. Recommended Strategy

### Direct answers

1. **Where exactly should the cutoff be applied?**
   - In a new reporting/query layer built on top of `tblDnevnikPromena.Datum`.

2. **Which objects should NOT be filtered?**
   - Base tables.
   - Snapshot-based stock views unless you verify them first.
   - Settings and master-data forms.
   - Maintenance/utility modules.
   - Archive/admin queries that intentionally access full history.

3. **Which objects should be filtered?**
   - Journal-driven review queries.
   - Sales/receipt/transfer/return/leveling review reports.
   - `frmStatistika` review range defaults.
   - Samo dokazani regularni display/report consumer-i koji danas zavise od `qryDnevnik`; operativni, stock i archive consumer-i se ne prebacuju automatski.

4. **Should stock/lager use all history or opening balance?**
   - If the screen is movement-based, use opening balance as of `2020-01-01`.
   - If the screen is snapshot-based (`tblArtikli` / `tblArtikliProslost`), leave that logic alone and verify the source first.

5. **Should cutoff be hardcoded or configurable?**
   - For the first release, hardcode `2020-01-01` in the new reporting layer.
   - Add configurability later only if the business expects the cutoff date to change.

6. **What indexes are needed?**
   - `tblDnevnikPromena.Datum` already has an index.
   - Keep the existing `IDDnevnik`/`IDObjekat`/`TipPromene` indexes.
   - Consider a composite `IDObjekat, Datum` index only if measured performance requires it.

7. **What are the biggest risks?**
   - Breaking stock/card meaning by filtering away needed history.
   - Missing dynamic query builders that do not use saved queries.
   - Orphan child rows, especially in `tblPovratnice`.
   - `qryDnevnik` is not generic and should not be reused as the main cutoff query.

8. **What is the safest implementation sequence?**
   - Confirm the MDB as source of truth and create a verified backup copy.
   - Export full source and classify every consumer.
   - Build filtered clones and audit queries without changing UI.
   - Validate counts, amounts and quantities.
   - Build/test archive access before changing the default UI.
   - Switch one journal-driven consumer at a time.

### Go/no-go gates

| Gate | Uslov za prolaz | Ako ne prodje |
| --- | --- | --- |
| `S0 Source` | Potvrdjeno da je radna baza kopija aktuelnog MDB-a | Nema implementacije |
| `S1 Backup` | Hashovana, otvariva backup kopija i definisan rollback | Nema izmena |
| `S2 Source export` | Izvezeni svi query/form/report/module tekstovi | Objekti bez source-a ostaju `UNKNOWN_REVIEW_REQUIRED` |
| `S3 Dependency map` | Nadjeni svi `CreateQueryDef/CreateAccessQuery/SQLStr/RunSQL/OpenRecordset/RecordSource/RowSource/OpenReport` pozivi | Nema UI switch-a |
| `S4 Classification` | Svaki consumer ima klasu i vlasnika odluke | Menja se samo dokazani podskup |
| `S5 Data quality` | Orphan izvestaj pregledan; posebno 567 povratnica | Nema povratnica switch-a |
| `S6 Query parity` | Baseline + 2020+ + orphan zbir daju objasnjivu sliku po tipu i objektu | Vratiti query dizajn na analizu |
| `S7 Stock semantics` | Lager/kartica/popis dokazano snapshot/full-history/opening-balance | Ti objekti ostaju netaknuti |
| `S8 Archive` | Full-history/archive putanja radi i ima kontrolisan pristup | Nema default cutoff switch-a |
| `S9 UAT` | Poslovni korisnik potpisao test matricu | Nema produkcijskog rollout-a |

### Rollback princip

Novi query-ji i novi UI put treba da budu aditivni. Rollback je vracanje RecordSource/poziva na prethodni objekat ili gasenje novog entry point-a, bez restauracije podataka. Ako rollback zahteva vracanje obrisanih redova, dizajn je prekrsio osnovni uslov zadatka.

## 11. Implementation Plan

### Phase 0 - source of truth, backup and rollback

- Poslovno potvrditi uloge `Trend plus.mdb` i `TRENDPLUS.accdb`.
- Napraviti timestamped kopiju aktuelnog MDB-a i raditi samo na kopiji.
- Zabeleziti SHA-256, velicinu, row counts i da se kopija otvara.
- Dokumentovati rollback pre prve izmene objekta.

Deliverable: potvrdjen `S0/S1`; bez promene Access objekata.

### Phase 1 - full source export and dependency map

- `SaveAsText` export svih query-ja, formi, reporta, modula i makroa na masini gde Access automatizacija radi stabilno.
- Pretraziti: `CreateQueryDef`, `CreateAccessQuery`, `SQLStr`, `QueryName`, `DeleteObject`, `RunSQL`, `OpenRecordset`, `RecordSource`, `RowSource`, `Filter`, `WhereCondition`, `OpenReport`, `DateValue`, `Year(` i direktne reference na core tabele.
- Mapirati startup/navigation/report-launch putanje.
- Dokazati da li se `Query10` igde poziva; ne pokretati ga.

Deliverable: dependency mapa i zatvoreni `S2/S3`; objekti bez izvora ostaju blokirani.

### Phase 2 - classification and business semantics

- Dodeliti klasu svakom query/form/report consumer-u.
- Za `frmLager`, `frmKartica`, `rptPopis` i `rptPopisProslost` dokazati snapshot naspram cumulative movement semantike.
- Definisati tretman povratnica/nivelacija posle 2020 koje se odnose na starije artikle ili dokumente.
- Poslovno odluciti kako se prikazuju orphan redovi; ne menjati ih.

Deliverable: `S4/S5/S7` odluke; i dalje bez cutoff implementacije u UI-u.

### Phase 3 - read-only query and audit layer

- Dodati samo nove objekte na radnoj kopiji:
  - `qryDnevnikPregled2020`
  - `qryProdajaPregled2020`
  - `qryUnosRobePregled2020`
  - `qryPrenosRobePregled2020`
  - `qryPovratnicePregled2020`
  - `qryNivelacijePregled2020`
- Dodati audit query-je po godini, tipu, objektu i orphan tabeli.
- Ne menjati postojece query-je, forme, reporte ni VBA.

Deliverable: izolovan proof-of-concept sloj sa jednostavnim rollback-om.

### Phase 4 - numeric reconciliation

Za svaki dokument tip i objekat uporediti:

- broj journal dokumenata, ne samo broj line redova
- broj child redova
- zbir `Kolicina`
- finansijske zbirove koji postoje u aktuelnom reportu
- pre-2020, 2020+, orphan/unclassifiable i ukupno
- granicne datume `2019-12-31` i `2020-01-01`

Osnovni MDB baseline je 16,394 journal redova = 11,991 pre 2020 + 4,403 od 2020. Child tabele se ne mogu dokazati prostim sabiranjem zbog orphan redova i vise line redova po dokumentu.

Deliverable: potvrdjen `S6`; svako odstupanje ima objasnjenje i owner-a.

### Phase 5 - report proof-of-concept

- Testirati kopije journal-driven reporta sa novim query-jima.
- Ne preusmeravati produkcijske report objekte u ovoj fazi.
- Proveriti layout, grupisanje, totals, store/supplier/article filtere i stampu/export.

Deliverable: lista reporta spremnih za `FILTER_2020_SAFE`.

### Phase 6 - archive/full-history path

- Obezbediti kontrolisan full-history prikaz pre sakrivanja stare istorije u regularnom UI-u.
- Jasno oznaciti period i rezim (`Redovni pregled 2020+` / `Arhiva - svi podaci`).
- Archive put ne sme koristiti ACCDB automatski dok njegova poslovna uloga nije potvrdjena.

Deliverable: potvrdjen `S8`.

### Phase 7 - UI switch, jedan consumer po iteraciji

- Prvo prebaciti najjednostavniji journal-driven pregled/report.
- Za `frmStatistika` tek sada dodati default/clamp na `2020-01-01`, uz validaciju null/invalidnog opsega i `DatumDo < DatumOd`.
- Posle svakog consumer-a ponoviti numeric parity i UAT.
- Lager/kartica/popis menjati samo po zasebno odobrenom snapshot/opening-balance dizajnu.

Deliverable: kontrolisan rollout bez blanket promene.

### Phase 8 - regression, monitoring and sign-off

- Izvrsiti kompletnu checklistu iz sledece sekcije.
- Sacuvati audit rezultate, klasifikaciju, backup hash i odobrenje korisnika.
- Tek nakon `S9` proglasiti rollout produkcijski spremnim.

### Najmanji sledeci implementacioni paket, kada bude posebno odobren

Predlog "implementirati samo Phase 2 i Phase 3" je dobar po nameri, ali brojevi faza se razlikuju izmedju review-a i ovog kanonskog plana. Scope zato treba zadati imenima, ne samo brojevima.

Dozvoljeni izolovani proof-of-concept scope:

- rad samo na verifikovanoj backup kopiji MDB-a posle `S0/S1`
- novi read-only `qryDnevnikPregled2020`
- novi per-document 2020 query-ji, bez povezivanja sa postojecim UI-em
- novi full-history/archive alias query-ji, bez promene prava/navigacije
- novi audit query-ji za journal baseline, tip, godinu, objekat i orphan redove
- dokumentovanje rezultata i odstupanja

Eksplicitno van scope-a:

- izmene formi, reporta, VBA modula, base tabela ili postojecih query-ja
- promena `frmStatistika` default datuma
- promena `frmLager`, `frmKartica`, `rptPopis` ili `rptPopisProslost`
- popravljanje ili brisanje orphan redova
- pokretanje, preimenovanje ili brisanje `Query10`
- produkcijski rollout

Ako `S2/S3` source export jos nije zavrsen, ovaj paket moze biti samo tehnicki proof-of-concept. Ne sme se proglasiti consumer-parity resenjem niti prikljuciti UI-u dok dependency mapa nije zatvorena.

## 12. Test Checklist

Before any implementation is considered done, verify:

- Radna baza je potvrdjena MDB kopija, ne ACCDB snapshot bez 2020+ podataka
- `qryDnevnikPregled2020` returns only `Datum >= 2020-01-01`
- MDB baseline je 16,394 = 11,991 pre cutoff-a + 4,403 od cutoff-a
- `qryProdajaPregled2020` matches expected 2020+ totals
- `qryUnosRobePregled2020` matches expected 2020+ totals
- `qryPrenosRobePregled2020` matches expected 2020+ totals
- `qryPovratnicePregled2020` matches expected 2020+ totals
- `qryNivelacijePregled2020` matches expected 2020+ totals
- Provereni su document counts, line counts, `Kolicina` i finansijski totals po tipu i objektu
- Red sa datumom `2019-12-31 23:59:59` ne ulazi; red sa `2020-01-01 00:00:00` ulazi
- Nijedan validan red posle cutoff-a nije iskljucen nenavedenom gornjom granicom
- 347/109/45/567/0 orphan baseline ostaje nepromenjen i vidljiv u audit-u
- Nijedan orphan nije lazno klasifikovan kao 2020+ transakcija
- Post-2020 povratnice i nivelacije nad starim artiklima imaju dogovorenu poslovnu interpretaciju
- `frmStatistika` defaults to `2020-01-01`
- `frmStatistika` odbija/clamp-uje raniji datum, null i obrnut opseg bez menjanja podataka
- Dynamic SQL ne moze da zaobidje cutoff u regularnom rezimu niti da ga primeni u archive rezimu
- `frmLager` still returns correct current stock meaning
- `frmKartica` still shows correct movement history or opening balance
- `rptPopis` and `rptPopisProslost` still match business expectations
- Archive/full-history putanja radi pre default UI switch-a
- Store/supplier/article/correction filteri iz starih consumer-a nisu izgubljeni
- Stampa, preview i export daju iste totals kao query source
- `Query10` nije pozvan ni iz jednog testiranog toka
- Nije doslo do brisanja/izmene podataka ili base tabela; sve izmene objekata su samo na odobrenoj radnoj kopiji

## 13. Open Questions

These require manual Access verification or later source export:

1. Da li je `Trend plus.mdb` aktivna produkciona baza, a `TRENDPLUS.accdb` arhiva/snapshot do 2019?
2. Exact RecordSource, RowSource, Filter i event source za `frmLager`
3. Exact RecordSource, RowSource, Filter i event source za `frmKartica`
4. Exact RecordSource i event source za `rptPopis` i `rptPopisProslost`
5. Koje dynamic query-je generisu `CreateAccessQuery`, `SQLStr` i `QueryName`?
6. Da li `Query10` ili druga action-query logika ima production caller?
7. Da li su orphan redovi, posebno 567 u `tblPovratnice`, legitimni istorijski artefakti ili integrity problem?
8. Da li `frmPregled` ima date controls u drugoj reviziji od izvucene MDB verzije?
9. Da li je poslovna definicija cutoff-a datum dokumenta/journal-a ili datum originalnog poslovnog dogadjaja?
10. Kako treba prikazati povratnicu posle 2020 za prodaju pre 2020?
11. Da li lager/kartica zahtevaju stanje na pocetku dana 2020-01-01 ili na kraju 2019-12-31?
12. Ko ima pravo na archive mode i da li archive treba da bude read-only?

## 14. Appendix - Useful SQL / VBA Snippets

### A. Count journal rows before and after cutoff

```sql
SELECT Count(*) AS C
FROM tblDnevnikPromena
WHERE Datum < DateSerial(2020, 1, 1);
```

```sql
SELECT Count(*) AS C
FROM tblDnevnikPromena
WHERE Datum >= DateSerial(2020, 1, 1);
```

### B. Proposed reporting journal query

```sql
SELECT *
FROM tblDnevnikPromena
WHERE Datum >= DateSerial(2020, 1, 1);
```

### C. Safer date-bound filter

Prefer:

```sql
WHERE Datum >= DateSerial(2020, 1, 1)
```

over:

```sql
WHERE Year(Datum) >= 2020
```

### D. Opening balance concept for stock/card

```sql
OpeningBalance + MovementsFrom2020Onward
```

This is the safest pattern if `frmLager` or `frmKartica` depend on cumulative movement history.

### E. Form default clamp in VBA

```vba
Private Sub Form_Load()
    If IsNull(Me.txtDatumOd) Or Me.txtDatumOd < DateSerial(2020, 1, 1) Then
        Me.txtDatumOd = DateSerial(2020, 1, 1)
    End If
End Sub
```

### F. Manual source export commands in Access

```vba
Application.SaveAsText acQuery, "qryDnevnik", "C:\temp\qryDnevnik.txt"
Application.SaveAsText acForm, "frmStatistika", "C:\temp\frmStatistika.txt"
Application.SaveAsText acReport, "rptProdaja", "C:\temp\rptProdaja.txt"
Application.SaveAsText acModule, "Prodaja", "C:\temp\Prodaja.txt"
```

### G. Why a new query is better than editing `qryDnevnik`

`qryDnevnik` is already a legacy-specific query with hardcoded object and date filters, so it should be treated as a source object, not the new universal reporting base.

### H. Orphan audit pattern

```sql
SELECT p.*
FROM tblPovratnice AS p
LEFT JOIN tblDnevnikPromena AS d
    ON p.IDDnevnik = d.IDDnevnik
WHERE d.IDDnevnik Is Null;
```

Ovaj query je read-only audit. Ne dodavati pretpostavljeni datum orphan redovima.

### I. Reconciliation po tipu i periodu

```sql
SELECT
    TipPromene,
    Sum(IIf(Datum < DateSerial(2020,1,1), 1, 0)) AS Pre2020,
    Sum(IIf(Datum >= DateSerial(2020,1,1), 1, 0)) AS Od2020,
    Count(*) AS Ukupno
FROM tblDnevnikPromena
GROUP BY TipPromene;
```

### J. Primer per-document join-a

```sql
SELECT p.*
FROM tblProdaja AS p
INNER JOIN qryDnevnikPregled2020 AS d
    ON p.IDDnevnik = d.IDDnevnik;
```

Ovo je samo minimalni obrazac. Produkcijski klon mora sacuvati sve dodatne filtere i join-ove konkretnog starog consumer-a.

### K. Source export checklist

Nakon `SaveAsText` exporta pretraziti najmanje:

```powershell
rg -n -i 'CreateQueryDef|CreateAccessQuery|SQLStr|QueryName|DeleteObject|RunSQL|OpenRecordset|RecordSource|RowSource|OpenReport|WhereCondition|DateValue|Year\(' C:\temp\trendplus-export
```

### L. Performance pravilo

Predikat ostaje sargable u odnosu na indeksirani `Datum`:

```sql
WHERE d.Datum >= DateSerial(2020, 1, 1)
```

Ne koristiti funkciju nad kolonom:

```sql
WHERE Year(d.Datum) >= 2020
```

Postojeci single-column indeks `tblDnevnikPromena.Datum` je dovoljan za proof-of-concept. Composite indeks `IDObjekat, Datum` razmatrati tek posle merenja realnih query planova i vremena izvrsavanja na radnoj kopiji.
