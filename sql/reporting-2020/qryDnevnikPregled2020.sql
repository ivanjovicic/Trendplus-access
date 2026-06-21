SELECT
    d.IDDnevnik,
    d.RedniBroj,
    d.Datum,
    d.BrojKalkulacije,
    d.TipPromene,
    d.IznosPromene,
    d.IDObjekat,
    d.Napomena
FROM tblDnevnikPromena AS d
WHERE d.Datum >= DateSerial(2020, 1, 1);

