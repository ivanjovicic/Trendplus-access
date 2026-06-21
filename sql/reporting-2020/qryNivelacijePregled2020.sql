SELECT
    n.IDArtikal,
    n.Kolicina,
    n.StaraCena,
    n.NovaCena,
    n.IDDnevnik,
    d.Datum,
    d.TipPromene,
    d.BrojKalkulacije,
    d.IDObjekat
FROM tblNivelacije AS n
INNER JOIN qryDnevnikPregled2020 AS d
    ON n.IDDnevnik = d.IDDnevnik;
