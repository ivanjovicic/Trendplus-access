SELECT
    analitika.IDDnevnikProdaja,
    analitika.DatumDnevnika,
    analitika.IDArtikal,
    analitika.Artikal,
    analitika.IDObjekatProdaja,
    analitika.IDObjekatDnevnik,
    analitika.ObjekatDnevnik,
    analitika.Kolicina,
    analitika.ProdajnaCena,
    analitika.IznosProdaje
FROM qryProdajaAnalitikaStavke2020 AS analitika
WHERE analitika.ObjekatMismatch = True
   OR (analitika.IDObjekatProdaja Is Null AND analitika.IDObjekatDnevnik Is Not Null)
   OR (analitika.IDObjekatProdaja Is Not Null AND analitika.IDObjekatDnevnik Is Null)
ORDER BY
    analitika.DatumDnevnika,
    analitika.IDDnevnikProdaja,
    analitika.IDArtikal;
