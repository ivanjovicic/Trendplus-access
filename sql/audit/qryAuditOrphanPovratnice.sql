SELECT
    povratnice.IDArtikal,
    povratnice.Kolicina,
    povratnice.ProdajnaCena,
    povratnice.IDObjekat AS IDObjekatPovratnice,
    povratnice.IDDnevnik AS IDDnevnikPovratnice
FROM tblPovratnice AS povratnice
LEFT JOIN tblDnevnikPromena AS dnevnik
    ON povratnice.IDDnevnik = dnevnik.IDDnevnik
WHERE dnevnik.IDDnevnik Is Null;
