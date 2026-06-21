SELECT
    n.IDArtikal,
    n.Kolicina,
    n.StaraCena,
    n.NovaCena,
    n.IDDnevnik
FROM tblNivelacije AS n
LEFT JOIN tblDnevnikPromena AS d
    ON n.IDDnevnik = d.IDDnevnik
WHERE d.IDDnevnik Is Null;
