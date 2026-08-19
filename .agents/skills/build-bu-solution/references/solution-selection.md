# Solution selection

| Signal | Prefer |
|---|---|
| Deterministic repeated transformation | Script |
| Reusable judgment, explanation or guided procedure | Skill |
| Narrow one-off drafting task | Prompt |
| Human-owned sequence with structured checkpoints | Workflow or template |
| Repeated retrieval of approved knowledge across users or tasks | Knowledge base |
| Live data, authentication or controlled external action | Tool/API/system integration |
| Repeated form filling or document generation | Structured data + validation + Excel review workbook; add a renderer for required final formats |

Combinations are expected when capability boundaries have different execution characteristics. Choose the smallest type for each capability, then compose only the units needed for the business outcome.

Do not interpret "smallest sufficient solution" as "fewest artifacts." Minimize unnecessary complexity while preserving independently testable boundaries. A thin orchestrator plus several focused capabilities is often smaller in maintenance risk than one monolithic Skill.

Record rejected options when their trade-off matters to the decision.

Do not choose a knowledge base solely because `knowledge.json` exists. Prefer direct BRD or file use when Codex can consume the approved artifacts within one bounded task and no shared retrieval, access, freshness or lifecycle requirement exists.

## Document output rule

Use Word as a presentation or submission format, not the canonical data model. Choose direct Word-only production only when all of the following are true:

- the participant or governing process requires `.docx`;
- the exact template and version are controlled;
- field-to-document mapping can be tested;
- the rendered document will receive content and visual verification.

Otherwise, keep values in JSON, CSV or another machine-readable structure and provide an Excel workbook for business review. A combined solution may validate structured values, expose them in Excel, and render the approved values into Word.
