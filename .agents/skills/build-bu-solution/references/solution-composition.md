# Solution composition contract

Decompose a business outcome into independently testable capability units, then compose them. A capability is smaller than the end-to-end Solution and larger than a helper function.

## Required capability contract

For every capability record:

- `capability_id` and responsibility expressed as one observable outcome;
- classification: `source-adapter`, `extractor`, `transformer`, `decision`, `validator`, `renderer`, `sink`, `human-task` or `orchestrator`;
- approved step, decision, flow, data-object, requirement and acceptance IDs it implements;
- input and output schemas, including version and required fields;
- preconditions, permissions and allowed side effects;
- deterministic, AI-assisted, human-review or human-only boundary;
- success result, typed failure states, retry and escalation behavior;
- dependencies and the artifact or state passed on each edge;
- implementation path, owner and isolated acceptance test.

## Split rules

Create a capability boundary when at least one of these changes materially:

- source or destination system;
- authentication or permission context;
- input or output data shape;
- acquisition, extraction, transformation, judgment, validation or presentation responsibility;
- deterministic versus AI-assisted versus human-owned execution;
- retry, stop, audit or evidence-retention behavior;
- ability to verify the outcome independently.

Typical capability shapes include reading a roster, acquiring a web document, extracting controlled fields, mapping values into a canonical case, evaluating a bounded rule, capturing evidence, validating completeness, writing a workbook and rendering a review artifact. These are examples of boundaries, not mandatory modules.

## Granularity guardrails

Do not split a unit when the pieces cannot produce or consume a stable contract, have no useful isolated test, and always change together. Do not combine units merely because one agent or one UI session can execute them sequentially.

A good capability can be replaced without rewriting unrelated capabilities, can be tested with a fixture or controlled human check, and exposes no hidden dependency on prose, transient browser state or another module's internals.

## Composition rules

- Exchange versioned JSON, CSV, files or explicitly typed state between executable capabilities.
- Keep source-specific navigation inside source adapters and acquisition capabilities.
- Keep business mapping and decision rules outside browser automation.
- Keep validation independent from generation so invalid outputs can be rejected.
- Keep rendering independent from canonical data so output formats can change without redoing acquisition.
- Represent human-only work as a named task contract with required evidence and resume state; never hide it inside an automated module.
- Use a thin orchestrator only for sequencing, checkpointing, status propagation and recovery.

## Build layout

Prefer this shape when multiple capabilities are justified:

```text
40_solution/build/<solution-name>/
  capability-manifest.yaml
  contracts/
  capabilities/<capability-id>/
  orchestrator/
  tests/contract/
  tests/integration/
```

The exact folders may vary by runtime, but capability ownership, interfaces and tests must remain visible.

## Verification gate

Fail composition when:

- the brief lists modules but no module has an interface and isolated test;
- the orchestrator contains source parsing, business mapping, decisions and rendering together;
- browser instructions directly write final outputs without a canonical intermediate;
- one end-to-end smoke test is the only evidence that individual capabilities work;
- a dependency edge has no schema, handoff artifact or contract test;
- a human-only decision is represented as automation;
- a capability is reported as built when it is only specified.

Validate bottom-up: schema and parser checks, isolated capability tests, dependency contract tests, composed happy path, stop paths, then participant validation.
