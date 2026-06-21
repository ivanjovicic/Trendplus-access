SELECT
    prenos.IDPrenos,
    prenos.IDArtikal,
    prenos.Kolicina,
    prenos.ProdajnaCena,
    prenos.IDDnevnik AS IDDnevnikPrenosa,
    prenos.IDArtikalPrenos
FROM tblPrenosRobe AS prenos
LEFT JOIN tblDnevnikPromena AS dnevnik
    ON prenos.IDDnevnik = dnevnik.IDDnevnik
WHERE dnevnik.IDDnevnik Is Null;
