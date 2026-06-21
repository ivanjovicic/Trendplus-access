SELECT
    'qryProdajaPregled2020' AS SourceName,
    Count(prodaja.IDDnevnikProdaja) AS BrojStavki,
    Sum(Nz(prodaja.Kolicina, 0)) AS UkupnoKomada,
    Sum(Nz(prodaja.Kolicina, 0) * Nz(prodaja.ProdajnaCena, 0)) AS UkupanPromet
FROM qryProdajaPregled2020 AS prodaja
UNION ALL
SELECT
    'qryProdajaAnalitikaStavke2020' AS SourceName,
    Count(analitika.IDDnevnikProdaja) AS BrojStavki,
    Sum(Nz(analitika.Kolicina, 0)) AS UkupnoKomada,
    Sum(Nz(analitika.IznosProdaje, 0)) AS UkupanPromet
FROM qryProdajaAnalitikaStavke2020 AS analitika
UNION ALL
SELECT
    'qryProdajaPoDobavljacima2020' AS SourceName,
    Sum(dobavljaci.BrojStavki) AS BrojStavki,
    Sum(dobavljaci.UkupnoKomada) AS UkupnoKomada,
    Sum(dobavljaci.UkupanPromet) AS UkupanPromet
FROM qryProdajaPoDobavljacima2020 AS dobavljaci
UNION ALL
SELECT
    'qryProdajaPoTipuObuce2020' AS SourceName,
    Sum(tipovi.BrojStavki) AS BrojStavki,
    Sum(tipovi.UkupnoKomada) AS UkupnoKomada,
    Sum(tipovi.UkupanPromet) AS UkupanPromet
FROM qryProdajaPoTipuObuce2020 AS tipovi;

