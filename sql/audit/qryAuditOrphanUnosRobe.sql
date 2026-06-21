SELECT
    unos.IDUnos,
    unos.IDArtikal,
    unos.Kolicina,
    unos.ProdajnaCena,
    unos.TipUnosa,
    unos.IDDnevnik AS IDDnevnikUnosa
FROM tblUnosRobe AS unos
LEFT JOIN tblDnevnikPromena AS dnevnik
    ON unos.IDDnevnik = dnevnik.IDDnevnik
WHERE dnevnik.IDDnevnik Is Null;
