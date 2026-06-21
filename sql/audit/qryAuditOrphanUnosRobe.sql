SELECT u.*
FROM tblUnosRobe AS u
LEFT JOIN tblDnevnikPromena AS d
    ON u.IDDnevnik = d.IDDnevnik
WHERE d.IDDnevnik Is Null;

