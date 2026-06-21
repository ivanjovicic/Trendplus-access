SELECT
    p.IDPrenos,
    p.IDArtikal,
    p.Kolicina,
    p.ProdajnaCena,
    p.IDDnevnik,
    p.IDArtikalPrenos
FROM tblPrenosRobe AS p
LEFT JOIN tblDnevnikPromena AS d
    ON p.IDDnevnik = d.IDDnevnik
WHERE d.IDDnevnik Is Null;
