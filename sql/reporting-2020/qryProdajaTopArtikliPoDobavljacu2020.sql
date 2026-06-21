SELECT
    s.IDDobavljac,
    s.Dobavljac,
    s.IDArtikal,
    s.PLU,
    s.Artikal,
    Count(s.IDDnevnikProdaja) AS BrojStavki,
    Sum(Nz(s.Kolicina, 0)) AS UkupnoKomada,
    Sum(Nz(s.IznosProdaje, 0)) AS UkupanPromet,
    IIf(
        Sum(Nz(s.Kolicina, 0)) = 0,
        Null,
        Sum(Nz(s.IznosProdaje, 0)) / Sum(Nz(s.Kolicina, 0))
    ) AS ProsecnaCenaPoKomadu,
    Min(s.DatumDnevnika) AS PrvaProdaja,
    Max(s.DatumDnevnika) AS PoslednjaProdaja
FROM qryProdajaAnalitikaStavke2020 AS s
GROUP BY
    s.IDDobavljac,
    s.Dobavljac,
    s.IDArtikal,
    s.PLU,
    s.Artikal
ORDER BY
    s.IDDobavljac,
    Sum(Nz(s.IznosProdaje, 0)) DESC,
    s.Artikal;
