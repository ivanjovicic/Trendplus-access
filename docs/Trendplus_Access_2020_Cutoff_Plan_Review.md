# Review plana — Trendplus Access 2020 cutoff

> Status 2026-06-21: nalazi iz ovog review-a ugrađeni su u kanonski dokument `ACCESS_2020_CUTOFF_ANALYSIS.md`. Naknadna DAO/Git provera dodala je važan nalaz: oba Access fajla jesu na `main`, ali `TRENDPLUS.accdb` sadrži samo podatke do `2019-11-13` i ima 0 journal redova od 2020, dok MDB ima podatke do `2026-04-05`. Zbog toga je potvrda MDB-a kao source of truth obavezan prvi gate.

Ovaj dokument ostaje review trag. Za implementacioni redosled i go/no-go kriterijume merodavan je kanonski dokument, a repo sada ima i zasebne artefakte za klasifikaciju objekata, test matricu, go/no-go i read-only SQL predloge.

## Naknadna verifikacija ocene

Ocena da rešenje nije spremno za direktne UI promene i produkcijski rollout i dalje stoji. Međutim, tvrdnja da samom planu još nedostaju klasifikacija, go/no-go uslovi i konkretne audit brojke više nije potpuno aktuelna, jer su te stavke naknadno dodate u kanonski dokument.

Ako se insistira na procentualnoj oceni, treba razdvojiti:

| Predmet ocene | Trenutni status |
|---|---|
| Arhitektonski i rollout plan | Oko 90% kompletan kao dokument |
| Zatvorenost tehničkih dokaza | Delimična |
| Implementacija Access objekata | 0% u ovom zadatku |
| Produkcijska spremnost | `NO-GO` |

Provera pojedinačnih tvrdnji:

| Tvrdnja iz nove ocene | Status |
|---|---|
| Ne brisati podatke, base tabele i postojeći `qryDnevnik` | Potvrđeno |
| Novi `qryDnevnikPregled2020` je najbolji centralni filter | Potvrđeno za journal-driven preglede |
| Lager/kartica/popisi su najveći funkcionalni rizik | Potvrđeno |
| Nedostaje klasifikacija svakog objekta | Zastarelo; klasifikacija je sada u kanonskom dokumentu, ali više objekata opravdano ostaje `UNKNOWN_REVIEW_REQUIRED` |
| Nedostaju go/no-go uslovi | Zastarelo; uvedeni su gate-ovi `S0-S9` |
| Nedostaju audit brojke | Delimično zastarelo; dokumentovani su journal i child baseline brojevi, ali Access audit query-ji nisu implementirani |
| Nedostaje orphan odluka | Delimično tačno; tehnička politika je definisana, poslovna legitimnost orphan redova nije |
| Nedostaje potvrda MDB source of truth | Tačno kao poslovni gate; DAO/Git dokazi snažno ukazuju na MDB |
| Nedostaje potpuni dynamic SQL/VBA popis | Tačno; full `SaveAsText` export nije uspeo u trenutnom okruženju |
| Nedostaje provera caller-a za `Query10` | Tačno |

Najprecizniji zaključak nije „plan je 75–80% implementiran”, već:

> Plan je dovoljno kompletan za kontrolisan read-only proof-of-concept, implementacija nije započeta, a produkcijski rollout ostaje blokiran dok se ne zatvore source export, stock semantika, orphan odluka, archive putanja i UAT.

Arhitektura takođe nije serijski lanac u kome archive dolazi posle regularnog UI-a. Ispravno je grananje:

```text
                         +-> Reporting 2020+ -> Regular journal UI/reporti
Base tables (untouched) -+-> Full history    -> Archive/admin UI
                         +-> Snapshot/opening -> Lager/kartica/popis
```

Ovim se sprečava da archive ili stock putanja slučajno naslede 2020 filter.

## Kratak zaključak

Plan iz dokumenta `Trendplus Access 2020 Cutoff Analysis` je uglavnom ispravan i ide u dobrom smeru: ne brišu se podaci, ne menja se baza direktno, već se predlaže poseban reporting/query sloj za redovne preglede od 2020. godine.

Međutim, plan još nije dovoljan kao “bezbedan za implementaciju bez rizika”. Najveći rizici su:

1. `frmLager`, `frmKartica`, `rptPopis` i `rptPopisProslost` mogu zavisiti od cele istorije ili snapshot tabela.
2. Postoje dinamički generisani query-ji kroz VBA (`CreateAccessQuery`, `SQLStr`, `QueryName`) koji mogu zaobići novi query sloj.
3. Postoje orphan redovi, naročito u `tblPovratnice`, pa običan `INNER JOIN` kroz `tblDnevnikPromena` može sakriti podatke koji se ranije možda vide u aplikaciji.
4. `qryDnevnik` je legacy/hardcoded query i ne sme se samo prepraviti.
5. `Query10` je destruktivan `DELETE` query i mora biti izolovan / ne sme se koristiti za cutoff.

Zato je najbolje rešenje:

- kreirati novi reporting sloj,
- ne dirati base tabele,
- ne dirati postojeći `qryDnevnik` dok se ne potvrde zavisnosti,
- posebno tretirati lager/karticu/popise,
- dodati archive mode,
- pre implementacije napraviti test matricu po objektima i uporediti rezultate.

---

## Ocena postojećeg plana

| Oblast | Ocena | Komentar |
|---|---|---|
| Ne brisati podatke | Dobro | Ovo je najvažnija odluka i ispravna je. |
| Koristiti `tblDnevnikPromena.Datum` | Dobro | To je najbolji centralni kandidat za journal-driven preglede. |
| Ne koristiti blanket cutoff svuda | Dobro | Dokument ispravno upozorava da to nije bezbedno. |
| Novi `qryDnevnikPregled2020` | Dobro | Najmanji blast radius, lako se testira. |
| Stock/lager/kartica | Nedovoljno zatvoreno | Potrebna je dodatna analiza tačnog izvora i poslovnog značenja. |
| Dinamički query-ji | Rizik ostaje | Mora se pronaći sav VBA koji pravi SQL u runtime-u. |
| Orphan redovi | Rizik ostaje | Potrebna odluka: sakriti, prikazati kao orphan, ili popravljati? |
| Test plan | Dobar ali treba proširiti | Potrebni su konkretni očekivani brojevi pre/posle cut-off-a. |
| Implementacija | Još ne | Plan je spreman za proof-of-concept, ne za direktan rollout. |

---

## Da li je `qryDnevnikPregled2020` najbolje rešenje?

Da, ali samo za redovne preglede koji su journal-driven.

Predloženi query:

```sql
SELECT *
FROM tblDnevnikPromena
WHERE Datum >= DateSerial(2020, 1, 1);
```

je dobar kao centralni filter za:

- prodaju,
- unos robe,
- prenos robe,
- povratnice,
- nivelacije,
- dnevnik promena,
- statistiku koja radi po periodu.

Ali ne sme automatski da zameni logiku za:

- lager,
- karticu artikla,
- popis,
- istorijski popis,
- snapshot tabele `tblArtikli` i `tblArtikliProslost`,
- maintenance/reset forme,
- archive/reporting starijih podataka.

---

## Najveći funkcionalni rizik: lager i kartica

Ako su `frmLager` ili `frmKartica` zasnovani na kumulativnim promenama, cutoff od 2020 može napraviti pogrešno stanje.

Primer problema:

```text
Artikal ima stanje 10 komada na 31.12.2019.
U 2020. je prodato 2 komada.
Ako sakrijemo sve pre 2020 i računamo samo kretanja od 2020,
sistem može pokazati -2 umesto 8.
```

Zato za lager/karticu treba jedno od ova dva rešenja:

## Rešenje A — ostaviti stock/snapshot logiku netaknutu

Ako `tblArtikli.Kolicina` već predstavlja trenutno stanje, ne filtrirati to preko journal datuma.

## Rešenje B — opening balance

Ako kartica mora da prikazuje kretanja od 2020, prikaz mora imati početno stanje:

```text
Početno stanje na 01.01.2020 + kretanja od 2020 nadalje
```

To je najtačniji poslovni model za “presek”.

---

## Rizik: orphan redovi

U dokumentu su navedeni orphan redovi:

| Tabela | Orphan rows |
|---|---:|
| `tblProdaja` | 347 |
| `tblUnosRobe` | 109 |
| `tblPrenosRobe` | 45 |
| `tblPovratnice` | 567 |
| `tblNivelacije` | 0 |

Ovo znači da neki child redovi imaju `IDDnevnik`, ali nema odgovarajućeg parent reda u `tblDnevnikPromena`.

Ako novi pregled radi ovako:

```sql
FROM tblDnevnikPromena AS d
INNER JOIN tblPovratnice AS p ON d.IDDnevnik = p.IDDnevnik
WHERE d.Datum >= DateSerial(2020, 1, 1)
```

orphan redovi se neće prikazati.

To možda jeste poželjno za čist pregled, ali je promena ponašanja ako su se ranije ti redovi videli kroz direktnu child tabelu.

Pre implementacije treba odlučiti:

1. Da li orphan redovi treba da budu sakriveni?
2. Da li treba da postoje u posebnom “Data Quality” pregledu?
3. Da li treba da se popravljaju?
4. Da li su posebno problematični u `tblPovratnice`, gde ih ima preko 20%?

Preporuka: ne popravljati automatski, nego napraviti poseban `qryOrphan...` audit set.

---

## Rizik: dinamički query-ji

Dokument ispravno navodi tragove:

- `CreateAccessQuery`
- `QueryName`
- `SQLStr`
- `DeleteObject`
- `txtDatumOd`
- `txtDatumDo`

To znači da aplikacija verovatno generiše SQL u runtime-u.

Novi saved query sloj neće biti dovoljan ako `frmStatistika` ili drugi moduli sami generišu SQL koji direktno čita:

```sql
tblDnevnikPromena
```

ili koristi:

```sql
DateValue(Datum)
Year(DateValue(Datum))
```

Preporuka:

- pronaći sve `CreateQueryDef`, `CreateAccessQuery`, `SQLStr`, `DoCmd.RunSQL`, `OpenRecordset`, `RecordSource =`, `RowSource =`;
- posebno proveriti module:
  - `Osnovni`
  - `Prodaja`
  - `UnosRobe`
  - `PrenosRobe`
  - `Nivelacija`
  - `Povratnica`
  - `VremenskaMasina`.

---

## Rizik: `Query10`

`Query10` je označen kao destruktivan `DELETE` query za podatke starije od 2024.

To je kritičan rizik.

Preporuka:

- ne koristiti ga;
- ne kopirati njegov pattern;
- preimenovati ga u nešto očigledno opasno ako se bude radilo održavanje, npr. `zz_DO_NOT_RUN_Query10_DeleteOldJournalRows`;
- proveriti da li ga negde poziva VBA;
- ako nije potreban, ukloniti ga tek nakon backup-a i potvrde.

---

## Šta bih promenio u planu pre implementacije

## 1. Dodati strogu klasifikaciju objekata

Svaki objekat mora dobiti jednu od oznaka:

| Klasa | Značenje |
|---|---|
| `FILTER_2020_SAFE` | Može koristiti 2020 cutoff |
| `FULL_HISTORY_REQUIRED` | Mora koristiti celu istoriju |
| `OPENING_BALANCE_REQUIRED` | Mora imati početno stanje na 01.01.2020 |
| `ARCHIVE_ONLY` | Samo arhivski/admin režim |
| `DO_NOT_TOUCH` | Master data / utility / maintenance |
| `UNKNOWN_REVIEW_REQUIRED` | Ne dirati dok se ne proveri |

Bez toga je lako napraviti regresiju.

## 2. Ne menjati postojeće query-je direktno

Umesto menjanja:

```text
qryProdaja
qryUnos
qryPrenos
qryDnevnik
```

napraviti nove:

```text
qryDnevnikPregled2020
qryProdajaPregled2020
qryUnosRobePregled2020
qryPrenosRobePregled2020
qryPovratnicePregled2020
qryNivelacijePregled2020
```

Tako se stari sistem može vratiti odmah ako nešto pođe loše.

## 3. Dodati audit query-je za upoređivanje

Primeri:

```text
qryAuditDnevnikCountByYear
qryAuditDnevnikCountByTipPromene
qryAuditOrphanProdaja
qryAuditOrphanPovratnice
qryAuditOrphanUnosRobe
qryAuditOrphanPrenosRobe
```

Ovo mora postojati pre promene UI-a.

## 4. Dodati “archive mode” pre gašenja stare istorije u UI-u

Ne treba prvo sakriti stare podatke pa kasnije praviti arhivu. Bolji redosled je:

1. Napravi novi 2020 pregled.
2. Napravi arhivski/full-history pregled.
3. Tek onda default prebaci na 2020.

## 5. Za `frmStatistika` koristiti centralnu funkciju, ne razbacane hardcode filtere

Predlog:

```vba
Public Function GetPregledCutoffDate() As Date
    GetPregledCutoffDate = DateSerial(2020, 1, 1)
End Function
```

Zatim svuda:

```vba
If Me.txtDatumOd < GetPregledCutoffDate() Then
    Me.txtDatumOd = GetPregledCutoffDate()
End If
```

Kasnije se funkcija može povezati sa `tblPodesavanja`.

---

## Preporučena finalna arhitektura

```text
Base tables
    tblDnevnikPromena
    tblProdaja
    tblUnosRobe
    tblPrenosRobe
    tblPovratnice
    tblNivelacije
    tblArtikli
    tblArtikliProslost
        |
        | ne menjati
        v

Reporting layer 2020+
    qryDnevnikPregled2020
    qryProdajaPregled2020
    qryUnosRobePregled2020
    qryPrenosRobePregled2020
    qryPovratnicePregled2020
    qryNivelacijePregled2020
        |
        v

UI regular views
    frmStatistika
    journal-driven reports
    regular sales/receipts/transfers/returns/nivelation reports

Archive/full-history layer
    qryDnevnikArhiva
    full-history reports
    admin-only archive screen

Stock/card special layer
    either current snapshots
    or opening balance + movements from 2020
```

---

## Najbezbedniji redosled rada

## Phase 0 — backup

- Napraviti fizičku kopiju MDB-a.
- Nikad ne raditi direktno na originalu.

## Phase 1 — source export

Ako Access može da se pokrene na nekoj drugoj mašini, izvesti:

- sve query-je,
- sve forme,
- sve report-e,
- sve module.

Ako ne može, nastaviti sa binary/string analizom, ali sve “unknown” ostaje blokirano za promene.

## Phase 2 — read-only 2020 query layer

Dodati samo nove query-je. Ne menjati forme.

## Phase 3 — audit brojevi

Uporediti:

- ukupan dnevnik,
- pre 2020,
- od 2020,
- po `TipPromene`,
- po objektu,
- po godini,
- orphan redove.

## Phase 4 — test izveštaji

Testirati nove query-je kao izvor za report-e, bez promene postojećih ekrana.

## Phase 5 — archive mode

Dodati jasno dugme ili režim:

```text
Prikaži arhivu pre 2020
```

Archive/full-history putanja mora biti testirana pre nego što regularni UI sakrije starije podatke.

## Phase 6 — UI switch

Tek kada su brojevi potvrđeni i archive mode radi, prebacivati redovne journal-driven preglede jedan po jedan.

## Phase 7 — regression test

Proći checklistu:

- prodaja,
- unos,
- prenos,
- povratnice,
- nivelacije,
- lager,
- kartica,
- popis,
- sezona,
- izvoz,
- štampa,
- backup,
- reset/maintenance forme.

---

## Konačna preporuka

Plan je dobar kao analiza i smer, ali nije još potpun za direktnu implementaciju.

Najbolje rešenje je:

1. `qryDnevnikPregled2020` kao novi centralni reporting query.
2. Novi per-document query-ji, bez izmene postojećih.
3. `frmStatistika` dobija default/clamp datuma na 01.01.2020.
4. Lager/kartica/popisi se ne filtriraju dok se ne potvrdi da li koriste snapshot ili kretanja.
5. Orphan redovi idu u audit, ne popravljaju se automatski.
6. Query10 i destructive maintenance logika se posebno proveravaju.
7. Archive mode se pravi pre prebacivanja korisnika na 2020 default.
8. Tek posle toga se radi implementacija.

Drugim rečima: preporučeni plan je ispravan. Klasifikacija i audit baseline sada su dokumentovani u kanonskom planu; pre produkcije i dalje moraju biti implementirani audit query-ji i dokazima zatvorena posebna strategija za stock/card, jer tu nastaju najskuplji bagovi.

## Preciziran sledeći scope

Predlog da sledeći zadatak obuhvati samo read-only query sloj i audit je prihvaćen kao najbezbedniji naredni tehnički korak, ali tek kada se posebno odobri implementacija i potvrde MDB source of truth i backup kopija.

Dozvoljeno u tom paketu:

- novi 2020+ query-ji,
- novi full-history/archive alias query-ji,
- novi audit query-ji,
- dokumentovanje brojeva i razlika.

Nije dozvoljeno u tom paketu:

- menjanje formi, reporta, VBA, base tabela ili postojećih query-ja,
- UI switch,
- promena lager/kartica/popis logike,
- popravljanje orphan redova,
- bilo kakvo pokretanje ili menjanje `Query10`.

Ako full source export i dependency mapa još nisu završeni, novi query sloj ostaje izolovan proof-of-concept i ne priključuje se nijednom postojećem consumer-u.
