SELECT
    nivelacije.IDArtikal,
    nivelacije.Kolicina,
    nivelacije.StaraCena,
    nivelacije.NovaCena,
    nivelacije.IDDnevnik AS IDDnevnikNivelacije
FROM tblNivelacije AS nivelacije
LEFT JOIN tblDnevnikPromena AS dnevnik
    ON nivelacije.IDDnevnik = dnevnik.IDDnevnik
WHERE dnevnik.IDDnevnik Is Null;
