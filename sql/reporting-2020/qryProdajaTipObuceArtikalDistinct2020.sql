SELECT
    IDTipObuce,
    TipObuce,
    IDArtikal
FROM qryProdajaAnalitikaStavke2020
GROUP BY
    IDTipObuce,
    TipObuce,
    IDArtikal;
