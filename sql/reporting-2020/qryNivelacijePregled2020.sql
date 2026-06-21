SELECT
    nivelacije.IDArtikal,
    nivelacije.Kolicina,
    nivelacije.StaraCena,
    nivelacije.NovaCena,
    nivelacije.IDDnevnik AS IDDnevnikNivelacije,
    dnevnik.Datum AS DatumDnevnika,
    dnevnik.TipPromene AS TipPromeneDnevnika,
    dnevnik.BrojKalkulacije AS BrojKalkulacijeDnevnika,
    dnevnik.IDObjekat AS IDObjekatDnevnik
FROM tblNivelacije AS nivelacije
INNER JOIN qryDnevnikPregled2020 AS dnevnik
    ON nivelacije.IDDnevnik = dnevnik.IDDnevnik;
