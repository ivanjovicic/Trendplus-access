# Reporting 2020 SQL

These files are read-only SQL proposals for the 2020 cutoff plan.
They include the core 2020+ reporting layer, sales analytics extension, helper distinct queries, monthly trend queries, and top-article drilldown queries built on top of `qryProdajaPregled2020`.

- Use them as source material for a copy of the MDB, not on the production source.
- They are meant for new reporting queries only.
- They do not replace existing Access objects.
- Review the classification and go/no-go docs before turning any proposal into an Access query.
- See [../../docs/SQL_IMPORT_PREP.md](../../docs/SQL_IMPORT_PREP.md) for the file-to-object mapping and import order.
- Keep each file stem aligned with its intended Access query name.
- See [Sales by Supplier and Shoe Type Plan](../../docs/SALES_BY_SUPPLIER_AND_SHOE_TYPE_PLAN.md) for the analytics design notes.
