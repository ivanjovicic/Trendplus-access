# Audit SQL

These files are read-only audit proposals for the 2020 cutoff plan.

- Use them in a working copy of the MDB, not as direct production changes.
- They are intended to document counts, orphan rows, and reconciliation checks.
- They do not repair data.
- They do not authorize any destructive query, including `Query10`.
- See [../../docs/SQL_IMPORT_PREP.md](../../docs/SQL_IMPORT_PREP.md) for the file-to-object mapping and import order.
- Keep each file stem aligned with its intended Access query name.
