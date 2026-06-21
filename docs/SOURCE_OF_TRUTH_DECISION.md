# Source of Truth Decision

Status: pending business confirmation.

This document records the current recommendation for the cutoff implementation source of truth.
It does not replace business sign-off.

## Candidate Files

| File | Current assessment | Why it matters |
| --- | --- | --- |
| `Trend plus.mdb` | Implementation candidate | Analysis docs show the newer journal data, newer Access object metadata, and the stronger likelihood of being the active working database. |
| `TRENDPLUS.accdb` | Archive/snapshot candidate | Analysis docs indicate it lacks 2020+ journal rows and looks like an older snapshot/archive of the same line of data. |

## Recommendation

Recommended working source of truth for cutoff implementation:

- `Trend plus.mdb`

Recommended treatment of the ACCDB file:

- `TRENDPLUS.accdb` should be treated as archive/snapshot only unless business explicitly says otherwise.

## Why the MDB is the implementation candidate

The current repository documentation indicates that `Trend plus.mdb` is the stronger candidate because:

- it contains journal data through 2026,
- it has the newer form/report metadata in the analysis,
- it has the broader post-2020 data set required to validate cutoff behavior,
- it is the file that best matches the active journal-driven reporting plan.

## Why the ACCDB should stay archive/snapshot unless business overrides

The current repository documentation indicates that `TRENDPLUS.accdb` should stay archived because:

- it has no 2020+ journal rows in the analysis,
- it looks like a pre-2020 snapshot of the same application line,
- using it as the working source would make the 2020 cutoff plan meaningless for real validation.

## Business Sign-Off Placeholder

Business decision:

- [ ] Use Trend plus.mdb as source of truth for cutoff implementation
- [ ] Treat TRENDPLUS.accdb as archive/snapshot only

Signed by:

Date:

## Usage Rule

Until the business decision above is signed, the repository must treat the source-of-truth status as unresolved and keep implementation blocked.
