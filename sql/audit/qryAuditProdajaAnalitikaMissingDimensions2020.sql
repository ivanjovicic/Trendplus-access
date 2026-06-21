SELECT
    Sum(IIf(analitika.MissingArtikal, 1, 0)) AS MissingArtikalRows,
    Sum(IIf(analitika.MissingDobavljac, 1, 0)) AS MissingDobavljacRows,
    Sum(IIf(analitika.MissingTipObuce, 1, 0)) AS MissingTipObuceRows,
    Sum(IIf(analitika.MissingSezona, 1, 0)) AS MissingSezonaRows,
    Sum(IIf(analitika.MissingObjekatProdaja, 1, 0)) AS MissingObjekatProdajaRows,
    Sum(IIf(analitika.MissingObjekatDnevnik, 1, 0)) AS MissingObjekatDnevnikRows,
    Sum(IIf(analitika.Kolicina Is Null, 1, 0)) AS NullKolicinaRows,
    Sum(IIf(analitika.ProdajnaCena Is Null, 1, 0)) AS NullProdajnaCenaRows,
    Sum(IIf(analitika.Kolicina < 0, 1, 0)) AS NegativeKolicinaRows,
    Sum(IIf(analitika.ProdajnaCena < 0, 1, 0)) AS NegativeProdajnaCenaRows
FROM qryProdajaAnalitikaStavke2020 AS analitika;
