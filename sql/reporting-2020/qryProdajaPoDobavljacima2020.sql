SELECT
    s.IDDobavljac,
    s.Dobavljac,
    Count(s.IDDnevnikProdaja) AS BrojStavki,
    Sum(Nz(s.Kolicina, 0)) AS UkupnoKomada,
    Sum(Nz(s.IznosProdaje, 0)) AS UkupanPromet,
    Sum(Nz(s.IznosProdaje, 0)) / Sum(IIf(Nz(s.Kolicina, 0) = 0, Null, Nz(s.Kolicina, 0))) AS ProsecnaCenaPoKomadu,
    Min(s.DatumDnevnika) AS PrvaProdaja,
    Max(s.DatumDnevnika) AS PoslednjaProdaja
FROM qryProdajaAnalitikaStavke2020 AS s
GROUP BY
    s.IDDobavljac,
    s.Dobavljac
ORDER BY
    Sum(Nz(s.IznosProdaje, 0)) DESC,
    s.Dobavljac;
