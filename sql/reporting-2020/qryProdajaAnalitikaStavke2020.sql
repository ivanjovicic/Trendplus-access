SELECT
    prodaja.IDDnevnikProdaja,
    prodaja.DatumDnevnika,
    prodaja.TipPromeneDnevnika,
    prodaja.BrojKalkulacijeDnevnika,
    prodaja.IDObjekatProdaja,
    prodaja.IDObjekatDnevnik,
    objekatDnevnik.Ime AS ObjekatDnevnik,
    prodaja.IDArtikal,
    artikli.PLU,
    Nz(artikli.Artikal, 'NEPOZNAT ARTIKAL') AS Artikal,
    artikli.IDDobavljac,
    Nz(dobavljaci.Dobavljac, 'NEPOZNAT DOBAVLJAC') AS Dobavljac,
    artikli.IDTipObuce,
    Nz(tipObuce.Naziv, 'NEPOZNAT TIP OBUCE') AS TipObuce,
    artikli.IDSezona,
    Nz(sezone.Sezona, 'NEPOZNATA SEZONA') AS Sezona,
    prodaja.Kolicina,
    prodaja.ProdajnaCena,
    Nz(prodaja.Kolicina, 0) * Nz(prodaja.ProdajnaCena, 0) AS IznosProdaje,
    IIf(artikli.IDArtikal Is Null, True, False) AS MissingArtikal,
    IIf(artikli.IDDobavljac Is Null, True, False) AS MissingDobavljac,
    IIf(artikli.IDTipObuce Is Null, True, False) AS MissingTipObuce,
    IIf(artikli.IDSezona Is Null, True, False) AS MissingSezona,
    IIf(prodaja.IDObjekatProdaja Is Null, True, False) AS MissingObjekatProdaja,
    IIf(objekatDnevnik.IDObjekat Is Null, True, False) AS MissingObjekatDnevnik,
    IIf(prodaja.IDObjekatProdaja <> prodaja.IDObjekatDnevnik, True, False) AS ObjekatMismatch
FROM
    (((((qryProdajaPregled2020 AS prodaja
    LEFT JOIN tblArtikli AS artikli
        ON prodaja.IDArtikal = artikli.IDArtikal)
    LEFT JOIN tblDobavljaci AS dobavljaci
        ON artikli.IDDobavljac = dobavljaci.IDDobavljac)
    LEFT JOIN tblTipObuce AS tipObuce
        ON artikli.IDTipObuce = tipObuce.IDTipObuce)
    LEFT JOIN tblSezona AS sezone
        ON artikli.IDSezona = sezone.IDSezona)
    LEFT JOIN tblObjekat AS objekatDnevnik
        ON prodaja.IDObjekatDnevnik = objekatDnevnik.IDObjekat;
