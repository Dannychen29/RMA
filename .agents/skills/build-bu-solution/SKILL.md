---
name: build-bu-solution
description: Decompose and build a fit-for-purpose BU solution from one participant-approved knowledge version. Use after distill-bu-knowledge when Codex must split an end-to-end need into independently testable capability units, select the right Skill, Script, Prompt, guided workflow, document template, tool, API or system integration for each unit, define their contracts, and compose only the justified deliverables without forcing one monolithic Skill or a fixed output bundle.
---

# Build BU Solution

Read [solution-selection.md](references/solution-selection.md), [solution-contract.md](references/solution-contract.md), [solution-composition.md](references/solution-composition.md), and [solution-lifecycle.md](references/solution-lifecycle.md).

## Generality boundary

Keep this Skill domain-neutral and reusable across organizational units. Do not embed any participant, department, industry, system, form, policy, field, threshold, workflow or domain acronym from a specific engagement in this Skill, its references, scripts or templates. Obtain all such knowledge from the selected approved engagement version. Put engagement-specific instructions, mappings, terminology, examples and tests only in that engagement's final Solution under `40_solution/build/`.

## 1. Verify the knowledge gate

1. Select one engagement and one version under `30_approved/`.
2. Verify approval scope and artifact hashes.
3. Stop and return to `$distill-bu-knowledge` when approval is missing, stale or outside the intended task.
4. Never build from raw evidence or silently add business rules from general knowledge.
5. For software, integration or automation work, verify the approved knowledge includes development-ready operational steps and directed data flows with stable IDs, source/destination locations, payload fields/schema, transport, validation and failure behavior. Return unresolved nodes or edges to `$distill-bu-knowledge`; do not infer interfaces from a narrative flowchart.

## 2. Decompose the outcome into capability units

Before selecting a solution type, derive a capability graph from the approved steps, decisions, data objects, flows and deliverables. Do not treat the end-to-end workflow as one implementation unit merely because it has one business outcome.

1. Split at boundaries where the source or destination system changes, the data object changes shape, deterministic processing changes to judgment, a human control begins, or a result can be verified independently.
2. Define one capability contract for each unit: stable capability ID, responsibility, inputs, outputs, preconditions, allowed side effects, failure states, human boundary, source contract IDs and acceptance tests.
3. Classify each unit as `source-adapter`, `extractor`, `transformer`, `decision`, `validator`, `renderer`, `sink`, `human-task` or `orchestrator`.
4. Draw the directed dependencies between units. Pass structured artifacts across boundaries; do not pass undocumented prose or browser state.
5. Keep the orchestrator thin. It sequences units, propagates state and records results; it must not absorb extraction, mapping, decision or rendering logic that can be tested separately.

Use [solution-composition.md](references/solution-composition.md) for decomposition, granularity and repository rules. A module list in prose or a table is not decomposition unless each module has its own contract, implementation or explicit human-task artifact, and isolated acceptance test.

## 3. Choose the smallest sufficient solution type per capability

Assess each capability's repeatability, variability, data volume, deterministic logic, judgment, tool access, risk, auditability, maintenance owner and human controls.

Possible solution types include:

- Skill for reusable judgment or guided work that benefits from managed instructions and references;
- Script for deterministic transformation or repetitive file handling;
- Prompt for a narrow, low-risk, low-maintenance interaction;
- guided workflow or template for structured human execution;
- knowledge base when approved knowledge must be searched, browsed, reused or governed across users or tasks;
- tool/API/system integration when live data or controlled actions are required;
- a justified combination of the above.

Do not choose one solution type for the whole workflow by default. Different capabilities may require different types. Do not choose a Skill merely because Skills are easy to manage. Record why each selected type fits better than the rejected alternatives.

When considering a knowledge base, read [knowledge-base-selection.md](references/knowledge-base-selection.md). Treat an approved `knowledge.json` as source content, not as a finished knowledge base. Select a knowledge base only when retrieval or knowledge lifecycle needs justify a product beyond direct BRD use.

For regulated, template-driven or repeated form-filling and document-generation work, use structured data as the canonical intermediate. Default to a machine-readable schema and values plus an Excel review workbook when fields require comparison, correction, validation or batch processing. Add a Word renderer only when the participant explicitly requests Word or a controlled template, legal process or external submission requires it. Do not make direct `.docx` editing the primary data layer.

## 4. Specify before building

Complete `40_solution/solution-brief.yaml` with the user, problem, inputs, outputs, approved knowledge version, composition strategy, capability contracts, chosen type per capability, dependency graph, human controls, limitations and acceptance conditions.

For software, integration or automation solutions, derive interfaces, capabilities and acceptance tests from approved step IDs, decision IDs, data-object IDs, data-flow edges and deliverable contracts. Preserve those IDs in implementation requirements and tests. Require an acceptance test for each capability and at least one contract test for every dependency edge.

For a knowledge-base solution, define the approved corpus, user questions, retrieval method, access controls, source citations, freshness and update workflow, versioning, fallback behavior, evaluation set and human ownership before building.

Ask for confirmation when different solution types would materially change cost, risk, ownership or user experience.

After writing the proposed brief, set `engagement.yaml.current_gate: solution_selection` and immediately present the smallest required selection question. Do not return a brief link without guiding the participant to the decision.

## 5. Separate Solution delivery from Output execution

Build and hand off the reusable Solution package before treating any generated business Output as the result of the build phase. The Solution contains its capability implementations, interfaces, configuration, runtime adapters, tests, manifest and operating entry point. An Output is a case-, batch- or run-specific artifact produced by that Solution.

Unless the participant explicitly requests only one of them, deliver both in this order:

1. the runnable Solution package;
2. one labelled `demo` or `UAT` Output produced by the delivered Solution from registered evidence or an approved fixture.

Never substitute a manually authored Output for a missing Solution. Never present a demo Output as proof that every runtime adapter or business scenario works. Preserve the exact Solution version, configuration, input hashes and command that produced each validation Output.

## 6. Build composable approved deliverables

1. Create outputs under `40_solution/build/` using the appropriate creator or implementation workflow. Give every executable capability its own implementation boundary and test entry point. Shared schemas may live in a common contracts directory.
2. When the selected solution type includes a Skill, invoke `$skill-creator` to create or update it under `40_solution/build/`, following its initialization, resource design, metadata and validation workflow. Do not invoke `$skill-creator` when another solution type is sufficient.
3. Keep approved business knowledge in references or data files and operational instructions in the solution logic.
4. Preserve claim IDs or source mappings for material rules and decisions.
5. Validate inputs, expose assumptions, stop on unsupported exceptions and retain required human approvals.
6. Do not copy raw recordings, credentials or unnecessary personal information into reusable solutions.
7. When producing Word, validate the structured values first, render into the identified template version, then inspect the resulting document for missing fields, overflow, broken tables, pagination and unsupported controls before delivery.
8. When producing a knowledge base, ingest only approved knowledge artifacts; preserve knowledge and claim IDs through indexing and responses; enforce access labels before retrieval; return citations and uncertainty; and test representative questions, unsupported questions, conflicting content and stale content.
9. Build the orchestrator only after its required capabilities pass their isolated tests. The orchestrator may coordinate retries, checkpoints and handoffs but may not be the sole location of business logic.
10. Generate `capability-manifest.yaml` in the Solution root. It must list every capability ID, type, path, interface, dependencies, source contract IDs, test command, status and owner. Do not report a capability as built when it exists only as a row in the manifest.

### Deliverable-first contract

Treat the participant's requested usable artifact as the deliverable. A solution brief, plan, gap report, readiness report, blocker report, test log or validation note is supporting process evidence and never satisfies a request to produce a Solution.

Before building, write one sentence internally in the form: `The participant will use <artifact> to <outcome>.` The artifact named there must exist under `40_solution/build/` and be the first item reported at handoff. Do not mark the build complete when only YAML, Markdown, specifications or diagnostics exist unless one of those formats is itself the participant-requested Solution.

When the participant narrows or corrects scope, immediately realign `solution-brief.yaml`, remove or clearly archive agent-created out-of-scope draft artifacts, and build the corrected deliverable in the same task. Do not make the participant restate the correction.

### Runtime preflight and fallback

Perform a minimal runtime and dependency preflight before writing substantial implementation code. Distinguish between:

- authoring the participant's final artifact now; and
- building a runnable Solution that will author or transform the artifact in the participant's intended runtime.

If a format-specific creator cannot author the final artifact in the current environment, follow that creator's restrictions for the final artifact. Still build a runnable Solution for the participant's available target runtime when this remains within the confirmed solution type and can be tested without inventing business behavior. For example, a script intended to run against a controlled local application may be a valid Solution even when the current environment cannot use that application to author the final business file. Record the unexecuted end-to-end validation honestly.

Stop with only a blocker report only when no in-scope implementation path can produce a usable artifact. State the exact missing capability and the smallest resume condition. Do not let a missing preferred tool hide an available, policy-compliant implementation path.

### Mandatory implementation verification

For every executable capability and for the composed deliverable:

1. Run the language parser, compiler, type checker or linter before the first smoke test. For PowerShell, parse the script or invoke it with a minimal safe fixture; do not assume generated syntax is valid.
2. Run at least one representative happy-path smoke test and one unsupported, invalid or stop-path test when the Solution contains validation or business controls.
3. Inspect the actual output, not only the process exit code. Verify key values, formulas, files, states or API results against the acceptance conditions.
4. If parsing, execution or output verification fails, fix the implementation and rerun the affected checks in the same task. A first failure is work in progress, not a handoff condition.
5. Never describe an executable as built, runnable, completed or validated while its latest parser, smoke or output check is failing.

For artifact-producing Solutions, verify a representative generated artifact when the runtime is available. When it is unavailable, deliver the tested implementation with an explicit `end_to_end_validation_pending` limitation; do not substitute planning documents for the implementation.

### Source-grounded validation gate

Do not confuse executable-code validation with business-solution validation. Before claiming that a Solution can produce a business deliverable:

1. Inventory the registered current-engagement source artifacts and test fixtures. If a relevant real, anonymized or participant-provided fake artifact exists, use it in the end-to-end test. Do not replace it with model-invented values.
2. Build a field-level coverage map from each material output field to its evidence ID, source file, page/question/cell or source field, transformation, target field, and validation result. Mark fields supplied by human judgment separately.
3. Use registered fake data or an anonymized case for at least one end-to-end validation when production data cannot be used. Preserve provenance showing who supplied or derived it and which source structure it represents.
4. Treat model-invented data only as a structural fixture for parser, schema or formula smoke tests. Label it `synthetic_structural_only`; it cannot satisfy source mapping, business-rule or end-to-end acceptance conditions.
5. Exercise the actual source-to-output path. Parse the registered source artifact or registered fake equivalent, map supported source fields to the target deliverable, combine explicitly required additional sources or human inputs, generate the output, and inspect mapped fields and calculated results.
6. When required sources are missing, produce a partially completed artifact with explicit unresolved fields when safe and useful. Do not fabricate values to make the happy path pass.

Record validation level explicitly:

- `structural_smoke_passed`: syntax, schema or formula mechanism passed using model-invented or minimal structural values;
- `registered_fake_data_passed`: a registered fake or anonymized source traversed the actual source-to-output path;
- `source_grounded_passed`: registered engagement evidence traversed the actual path and material mappings were checked;
- `business_validated`: the participant or named owner compared the output with an expected completed case and accepted it.

Never report a higher level than the evidence supports. A generated final-format file is not proof of source-grounded correctness by itself.

## 7. Classify defects and revise the owning layer

Apply [solution-lifecycle.md](references/solution-lifecycle.md) whenever a participant reports a defective Output. Reproduce the defect, identify its owning layer, change the canonical source at that layer, rerun affected isolated and integration tests, then regenerate the Output. Do not edit the Output by hand to hide a Solution defect.

Return to `$distill-bu-knowledge` only when the approved business meaning, rule, field, workflow, control or acceptance condition is missing, wrong or contradictory. Keep implementation, interface, runtime-adapter, configuration, case-evidence and presentation defects inside solution iteration.

## 8. Report status without inventing validation

Report what was built by capability, its knowledge version, supported scope, dependency status, limitations, required human controls and what still needs validation. Distinguish `implemented`, `isolated_test_passed`, `integration_test_passed`, `human_task` and `not_built`. Mark the overall solution `draft` or `validation_pending`; do not claim that it passed formal validation because that mechanism is intentionally deferred.

Lead the report with the usable Solution artifact. Link process metadata only after the deliverable and only when it helps the participant act. If no usable Solution artifact exists, say the build is incomplete; do not present supporting documents as the requested result.

## Mandatory continuation contract

1. Verify that the invoked engagement is at `current_gate: solution_selection` or `solution_build` and that its approved knowledge version is immutable and hash-valid.
2. If the participant has already confirmed the proposed solution type, update `solution-brief.yaml.status: confirmed`, set `current_gate: solution_build`, and begin building in the same task. Do not ask for the same confirmation again.
3. If confirmation is still required, ask exactly one decision question that explains the material trade-off; do not stop with a recommendation-only report.
4. After building, set `engagement.yaml.status: solution_draft` and `current_gate: solution_validation`, then guide the participant to the smallest next validation action.
5. Stop without building only for a precise knowledge gap, permission boundary or participant-requested pause. Record the reason and route back to the named upstream gate.

## Loop rule

If building reveals missing or contradictory business knowledge, create a precise gap report and return to `$conduct-bu-interview` for targeted confirmation, then re-run affected distillation. Do not patch uncertain logic directly into the solution.
