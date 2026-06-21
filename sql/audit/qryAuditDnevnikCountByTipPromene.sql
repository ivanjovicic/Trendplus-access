SELECT
    dnevnik.TipPromene,
    Sum(IIf(dnevnik.Datum < DateSerial(2020, 1, 1), 1, 0)) AS BrojPre2020Dnevnika,
    Sum(IIf(dnevnik.Datum >= DateSerial(2020, 1, 1), 1, 0)) AS BrojOd2020Dnevnika,
    Count(dnevnik.IDDnevnik) AS BrojUkupnoDnevnika
FROM tblDnevnikPromena AS dnevnik
GROUP BY dnevnik.TipPromene
ORDER BY dnevnik.TipPromene;
