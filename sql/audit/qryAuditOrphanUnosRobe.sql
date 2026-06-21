SELECT
    u.IDUnos,
    u.IDArtikal,
    u.Kolicina,
    u.ProdajnaCena,
    u.TipUnosa,
    u.IDDnevnik
FROM tblUnosRobe AS u
LEFT JOIN tblDnevnikPromena AS d
    ON u.IDDnevnik = d.IDDnevnik
WHERE d.IDDnevnik Is Null;
