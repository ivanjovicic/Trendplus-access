SELECT
    IDTipObuce,
    TipObuce,
    IDDobavljac,
    Dobavljac
FROM qryProdajaAnalitikaStavke2020
GROUP BY
    IDTipObuce,
    TipObuce,
    IDDobavljac,
    Dobavljac;
