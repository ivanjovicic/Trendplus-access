SELECT
    s.IDObjekatDnevnik,
    s.ObjekatDnevnik,
    s.IDObjekatProdaja,
    s.ObjekatProdaja,
    Count(s.IDDnevnikProdaja) AS BrojStavki,
    Sum(Nz(s.Kolicina, 0)) AS UkupnoKomada,
    Sum(Nz(s.IznosProdaje, 0)) AS UkupanPromet,
    Sum(IIf(s.ObjekatMismatch, 1, 0)) AS ObjekatMismatchRows
FROM qryProdajaAnalitikaStavke2020 AS s
GROUP BY
    s.IDObjekatDnevnik,
    s.ObjekatDnevnik,
    s.IDObjekatProdaja,
    s.ObjekatProdaja
ORDER BY
    s.IDObjekatDnevnik,
    s.IDObjekatProdaja;
