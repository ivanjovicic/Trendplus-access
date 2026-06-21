SELECT
    prenos.IDPrenos,
    prenos.IDArtikal,
    prenos.Kolicina,
    prenos.ProdajnaCena,
    prenos.IDDnevnik AS IDDnevnikPrenosa,
    prenos.IDArtikalPrenos,
    dnevnik.Datum AS DatumDnevnika,
    dnevnik.TipPromene AS TipPromeneDnevnika,
    dnevnik.BrojKalkulacije AS BrojKalkulacijeDnevnika,
    dnevnik.IDObjekat AS IDObjekatDnevnik
FROM tblPrenosRobe AS prenos
INNER JOIN qryDnevnikPregled2020 AS dnevnik
    ON prenos.IDDnevnik = dnevnik.IDDnevnik;
