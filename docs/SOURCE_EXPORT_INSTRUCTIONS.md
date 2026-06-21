# Source Export Instructions

Status: preparation-only instructions for the Access source export step.

These instructions are for a copied MDB only.
Do not export from the original `Trend plus.mdb`.
Do not open or modify `TRENDPLUS.accdb` for this step unless business later approves it as a separate archive workflow.

## Goal

Create a full read-only source export for:

- queries
- forms
- reports
- modules

If the PowerShell automation script fails, use the manual Access VBA path below.

## Export Folder

Use a dedicated export location such as:

```text
exported-access-source/
```

The PowerShell script creates a timestamped run folder under that root and stores:

- `queries/`
- `forms/`
- `reports/`
- `modules/`

## PowerShell Entry Point

Preferred script:

```text
scripts/Export-AccessSource.ps1
```

Example call:

```powershell
.\scripts\Export-AccessSource.ps1 -SourceMdbCopyPath "C:\path\to\Trend plus_2026-06-21_153000_pre-cutoff-backup.mdb"
```

## Manual VBA Commands

If automation fails, open the copied MDB in Access and run the `SaveAsText` commands manually.

```vba
Application.SaveAsText acQuery, "qryDnevnik", "C:\temp\qryDnevnik.txt"
Application.SaveAsText acForm, "frmStatistika", "C:\temp\frmStatistika.txt"
Application.SaveAsText acReport, "rptProdaja", "C:\temp\rptProdaja.txt"
Application.SaveAsText acModule, "Prodaja", "C:\temp\Prodaja.txt"
```

You can continue with the remaining objects using the same pattern:

- `acQuery` for saved queries
- `acForm` for forms
- `acReport` for reports
- `acModule` for standard modules

## Manual Export Procedure

1. Open the copied MDB, not the original.
2. Ensure no destructive startup logic is executed.
3. Run the `SaveAsText` commands for every query, form, report, and module.
4. Save the resulting text files into the export folder.
5. Record any object that fails to export.
6. Do not run `Query10`.

## What to Record

For each exported object, keep:

- object name
- object type
- export path
- timestamp
- any export error

## Safety Notes

- Export is read-only.
- Do not alter object definitions during export.
- If the copied MDB path is not known with certainty, stop and verify before proceeding.
