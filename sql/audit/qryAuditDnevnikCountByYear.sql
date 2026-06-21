SELECT
    Year(d.Datum) AS Godina,
    Count(*) AS BrojRedova
FROM tblDnevnikPromena AS d
GROUP BY Year(d.Datum)
ORDER BY Year(d.Datum);

