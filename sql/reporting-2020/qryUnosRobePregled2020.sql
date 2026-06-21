SELECT
    unos.IDUnos,
    unos.IDArtikal,
    unos.Kolicina,
    unos.ProdajnaCena,
    unos.TipUnosa,
    unos.IDDnevnik AS IDDnevnikUnosa,
    dnevnik.Datum AS DatumDnevnika,
    dnevnik.TipPromene AS TipPromeneDnevnika,
    dnevnik.BrojKalkulacije AS BrojKalkulacijeDnevnika,
    dnevnik.IDObjekat AS IDObjekatDnevnik
FROM tblUnosRobe AS unos
INNER JOIN qryDnevnikPregled2020 AS dnevnik
    ON unos.IDDnevnik = dnevnik.IDDnevnik
WHERE Nz(dnevnik.BrojKalkulacije, '') <> 'KOREKCIJA';
