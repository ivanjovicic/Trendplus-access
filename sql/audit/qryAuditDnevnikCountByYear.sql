SELECT
    Year(d.Datum) AS Godina,
    Count(d.IDDnevnik) AS BrojRedova
FROM tblDnevnikPromena AS d
GROUP BY Year(d.Datum)
ORDER BY Year(d.Datum);
