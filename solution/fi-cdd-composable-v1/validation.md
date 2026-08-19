# Validation

- Knowledge gate: `cdd-solution-input-v1` BRD hash matched the approval record.
- Parser: every PowerShell capability and test script passed the PowerShell parser.
- CAP-01 isolated test: one-row CSV passed; the registered XLSX roster was also read successfully with 10 rows and the expected BIDV legal name/BIC.
- CAP-02 preflight: the Bankers Almanac home URL was reachable in the authorized browser and returned the expected page title. A full fresh acquisition was not repeated because the BIDV source-grounded evidence already exists and live fields remain participant-controlled.
- CAP-04 happy path: the registered BIDV case passed validation.
- CAP-04 stop path: a forced sanctions value of `No` while Factimize was unavailable was rejected.
- Composition: BIDV evidence traversed roster, mapper, validator and two-table exporter. The checklist contains 32 mapped template fields and the risk-assessment table contains 8 mapped template fields.
- Representative mapping: CBDDQ 19h became `risk.payable_through_accounts=False`, status `CONFIRMED`, with its evidence ID retained.
- Validation level: `source_grounded_passed` for the implemented BIDV roster-to-review path; `business_validated` remains pending participant comparison.
- Output limitation: the required spreadsheet artifact dependency loader was unavailable, so the current review outputs are UTF-8 CSV files for Excel rather than a native XLSX workbook.
