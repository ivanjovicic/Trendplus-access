SELECT
    u.*,
    d.Datum,
    d.TipPromene,
    d.BrojKalkulacije,
    d.IDObjekat
FROM tblUnosRobe AS u
INNER JOIN qryDnevnikPregled2020 AS d
    ON u.IDDnevnik = d.IDDnevnik
WHERE Nz(d.BrojKalkulacije, '') <> 'KOREKCIJA';

