SELECT
    prodaja.IDArtikal,
    prodaja.Kolicina,
    prodaja.ProdajnaCena,
    prodaja.IDObjekat AS IDObjekatProdaja,
    prodaja.IDDnevnik AS IDDnevnikProdaja
FROM tblProdaja AS prodaja
LEFT JOIN tblDnevnikPromena AS dnevnik
    ON prodaja.IDDnevnik = dnevnik.IDDnevnik
WHERE dnevnik.IDDnevnik Is Null;
