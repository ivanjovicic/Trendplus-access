SELECT
    p.IDPrenos,
    p.IDArtikal,
    p.Kolicina,
    p.ProdajnaCena,
    p.IDDnevnik,
    p.IDArtikalPrenos,
    d.Datum,
    d.TipPromene,
    d.BrojKalkulacije,
    d.IDObjekat
FROM tblPrenosRobe AS p
INNER JOIN qryDnevnikPregled2020 AS d
    ON p.IDDnevnik = d.IDDnevnik;
