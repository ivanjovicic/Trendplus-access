SELECT
    IDDobavljac,
    Dobavljac,
    IDTipObuce,
    TipObuce
FROM qryProdajaAnalitikaStavke2020
GROUP BY
    IDDobavljac,
    Dobavljac,
    IDTipObuce,
    TipObuce;
