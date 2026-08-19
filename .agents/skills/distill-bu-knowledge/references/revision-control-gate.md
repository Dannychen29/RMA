# Canonical BRD revision control gate

Use this gate whenever a participant corrects, rewrites, adds, removes, reprioritizes or questions content in a draft `BRD.html`.

## One truth, flexible feedback

- Keep `20_distilled/BRD.html` as the only canonical draft BRD. Do not create a Markdown, YAML, JSON or second HTML BRD for easier editing.
- Accept tuning feedback as natural language, comments or an annotated request. Treat it as change input, not approved business knowledge and not a second source of truth.
- Preserve raw evidence and approved versions. Never rewrite evidence to match a requested change.
- Maintain `revision-register.csv` only after the first revision. It is an audit trail and may not own business facts.

## Change classification

Classify each atomic request before editing:

1. `wording_only`: improve clarity without changing actor, action, rule, scope, priority, date, threshold, evidence meaning or readiness.
2. `evidence_correction`: align terminology or facts with existing authorized evidence or an explicit participant correction.
3. `business_semantics`: change an operational fact, rule, exception, owner, deliverable, acceptance condition or human-control boundary.
4. `scope_priority`: add, remove or reprioritize an outcome, requirement, action or solution scope.
5. `contract_structure`: repair IDs, references, schemas or representation without changing business meaning.

Split a request when it contains more than one class or affects independently reviewable facts.

## Revision contract

Use one CSV row per atomic request with:

`revision_id,previous_version,current_version,requested_change,change_class,target_ids,source_or_authority,evidence_ids,affected_projection_ids,disposition,rationale,validation_status`

Allowed `disposition` values are `applied`, `deferred` and `rejected`. Use stable HTML IDs separated by spaces. For `evidence_correction`, `business_semantics` and `scope_priority`, require an authorized evidence ID or an explicit participant authority reference. A request from the participant can authorize a correction or preference, but must be labelled as participant-supplied rather than retroactively attributed to the original evidence.

## Synchronization rules

1. Locate every canonical contract and review projection affected by the request.
2. For `wording_only`, change the derived review projection only and prove that its `data-derived-from` contracts still support every material statement.
3. For semantic changes, update the canonical contract first, then regenerate or revise every derived projection, traceability row, gap, requirement and acceptance scenario that depends on it.
4. Preserve stable IDs when identity remains the same. Create a new ID when the business object or contract identity changes; do not reuse a retired ID for a different meaning.
5. Update evidence mode, confidence, readiness and gaps when the authority or evidence strength changes.
6. Increment the draft version for every presented review cycle. Include a concise visible revision summary in the same HTML; do not copy full audit prose into participant-facing sections.
7. Re-run structural, evidence-alignment, gap, transcript and human-readability gates affected by the change. Mark `validation_status=passed` only after those checks pass.

## Conflict and approval behavior

- When requested wording contradicts evidence, do not silently apply it. Show the conflict and request the smallest clarification.
- When a change would invalidate an approved version, create a new draft from that approved version. Never mutate `30_approved/` in place.
- Approval covers the exact version and hashes reviewed. Any later semantic change requires a new approval cycle before `$build-bu-solution`.
- Do not let downstream Solution tuning patch missing business knowledge. Route business corrections back through this gate.

Fail the gate when human-facing wording and canonical contracts disagree, a semantic change lacks evidence or participant authority, affected downstream contracts remain stale, the draft version is not advanced, or a revision register becomes a competing BRD.
