SELECT
    prodaja.IDArtikal,
    prodaja.Kolicina,
    prodaja.ProdajnaCena,
    prodaja.IDObjekat AS IDObjekatProdaja,
    prodaja.IDDnevnik AS IDDnevnikProdaja,
    dnevnik.Datum AS DatumDnevnika,
    dnevnik.TipPromene AS TipPromeneDnevnika,
    dnevnik.BrojKalkulacije AS BrojKalkulacijeDnevnika,
    dnevnik.IDObjekat AS IDObjekatDnevnik
FROM tblProdaja AS prodaja
INNER JOIN qryDnevnikPregled2020 AS dnevnik
    ON prodaja.IDDnevnik = dnevnik.IDDnevnik;
