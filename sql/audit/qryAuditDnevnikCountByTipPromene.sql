SELECT
    d.TipPromene,
    Sum(IIf(d.Datum < DateSerial(2020, 1, 1), 1, 0)) AS Pre2020,
    Sum(IIf(d.Datum >= DateSerial(2020, 1, 1), 1, 0)) AS Od2020,
    Count(d.IDDnevnik) AS Ukupno
FROM tblDnevnikPromena AS d
GROUP BY d.TipPromene
ORDER BY d.TipPromene;
