SELECT
    Year(s.DatumDnevnika) AS Godina,
    Month(s.DatumDnevnika) AS Mesec,
    Count(s.IDDnevnikProdaja) AS BrojStavki,
    Sum(Nz(s.Kolicina, 0)) AS UkupnoKomada,
    Sum(Nz(s.IznosProdaje, 0)) AS UkupanPromet
FROM qryProdajaAnalitikaStavke2020 AS s
GROUP BY
    Year(s.DatumDnevnika),
    Month(s.DatumDnevnika)
ORDER BY
    Year(s.DatumDnevnika),
    Month(s.DatumDnevnika);
