SELECT
    p.IDArtikal,
    p.Kolicina,
    p.ProdajnaCena,
    p.IDObjekat,
    p.IDDnevnik,
    d.Datum,
    d.TipPromene,
    d.BrojKalkulacije,
    d.IDObjekat AS IDObjekatDnevnik
FROM tblProdaja AS p
INNER JOIN qryDnevnikPregled2020 AS d
    ON p.IDDnevnik = d.IDDnevnik;
