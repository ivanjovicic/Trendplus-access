SELECT
    povratnice.IDArtikal,
    povratnice.Kolicina,
    povratnice.ProdajnaCena,
    povratnice.IDObjekat AS IDObjekatPovratnice,
    povratnice.IDDnevnik AS IDDnevnikPovratnice,
    dnevnik.Datum AS DatumDnevnika,
    dnevnik.TipPromene AS TipPromeneDnevnika,
    dnevnik.BrojKalkulacije AS BrojKalkulacijeDnevnika,
    dnevnik.IDObjekat AS IDObjekatDnevnik
FROM tblPovratnice AS povratnice
INNER JOIN qryDnevnikPregled2020 AS dnevnik
    ON povratnice.IDDnevnik = dnevnik.IDDnevnik;
