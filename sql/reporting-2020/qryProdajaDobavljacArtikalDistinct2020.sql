SELECT
    IDDobavljac,
    Dobavljac,
    IDArtikal
FROM qryProdajaAnalitikaStavke2020
GROUP BY
    IDDobavljac,
    Dobavljac,
    IDArtikal;
