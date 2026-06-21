SELECT
    dnevnik.IDDnevnik,
    dnevnik.RedniBroj,
    dnevnik.Datum,
    dnevnik.BrojKalkulacije,
    dnevnik.TipPromene,
    dnevnik.IznosPromene,
    dnevnik.IDObjekat,
    dnevnik.Napomena
FROM tblDnevnikPromena AS dnevnik
WHERE dnevnik.Datum >= DateSerial(2020, 1, 1);
