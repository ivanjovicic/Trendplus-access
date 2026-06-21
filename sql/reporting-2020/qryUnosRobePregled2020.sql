SELECT
    u.IDUnos,
    u.IDArtikal,
    u.Kolicina,
    u.ProdajnaCena,
    u.TipUnosa,
    u.IDDnevnik,
    d.Datum,
    d.TipPromene,
    d.BrojKalkulacije,
    d.IDObjekat
FROM tblUnosRobe AS u
INNER JOIN qryDnevnikPregled2020 AS d
    ON u.IDDnevnik = d.IDDnevnik
WHERE Nz(d.BrojKalkulacije, '') <> 'KOREKCIJA';
