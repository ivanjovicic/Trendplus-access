SELECT
    p.IDArtikal,
    p.Kolicina,
    p.ProdajnaCena,
    p.IDObjekat,
    p.IDDnevnik
FROM tblPovratnice AS p
LEFT JOIN tblDnevnikPromena AS d
    ON p.IDDnevnik = d.IDDnevnik
WHERE d.IDDnevnik Is Null;
