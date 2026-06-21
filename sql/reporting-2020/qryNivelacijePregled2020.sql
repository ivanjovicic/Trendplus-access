SELECT
    n.*,
    d.Datum,
    d.TipPromene,
    d.BrojKalkulacije,
    d.IDObjekat
FROM tblNivelacije AS n
INNER JOIN qryDnevnikPregled2020 AS d
    ON n.IDDnevnik = d.IDDnevnik;

