SELECT
    p.*,
    d.Datum,
    d.TipPromene,
    d.BrojKalkulacije,
    d.IDObjekat
FROM tblPovratnice AS p
INNER JOIN qryDnevnikPregled2020 AS d
    ON p.IDDnevnik = d.IDDnevnik;

