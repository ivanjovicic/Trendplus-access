SELECT
    Year(dnevnik.Datum) AS GodinaDnevnika,
    Count(dnevnik.IDDnevnik) AS BrojRedovaDnevnika
FROM tblDnevnikPromena AS dnevnik
GROUP BY Year(dnevnik.Datum)
ORDER BY Year(dnevnik.Datum);
