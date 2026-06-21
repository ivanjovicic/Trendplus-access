SELECT
    Year(s.DatumDnevnika) AS Godina,
    Month(s.DatumDnevnika) AS Mesec,
    s.IDTipObuce,
    s.TipObuce,
    Count(s.IDDnevnikProdaja) AS BrojStavki,
    Sum(Nz(s.Kolicina, 0)) AS UkupnoKomada,
    Sum(Nz(s.IznosProdaje, 0)) AS UkupanPromet,
    IIf(
        Sum(Nz(s.Kolicina, 0)) = 0,
        Null,
        Sum(Nz(s.IznosProdaje, 0)) / Sum(Nz(s.Kolicina, 0))
    ) AS ProsecnaCenaPoKomadu
FROM qryProdajaAnalitikaStavke2020 AS s
GROUP BY
    Year(s.DatumDnevnika),
    Month(s.DatumDnevnika),
    s.IDTipObuce,
    s.TipObuce
ORDER BY
    Year(s.DatumDnevnika),
    Month(s.DatumDnevnika),
    s.IDTipObuce,
    s.TipObuce;
