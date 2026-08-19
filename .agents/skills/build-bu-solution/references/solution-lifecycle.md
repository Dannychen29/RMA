# Solution lifecycle and defect routing

Keep four artifacts distinct:

- `Knowledge version`: approved business meaning and acceptance contracts.
- `Solution package`: reusable implementations, interfaces, runtime adapters, configuration, tests and operating entry point.
- `Run`: one execution with immutable Solution version, configuration and input/evidence hashes.
- `Output`: case- or batch-specific files and states created by a Run.

## Default lifecycle

1. Approve one knowledge version.
2. Confirm the solution brief and capability decomposition.
3. Build and test capabilities bottom-up.
4. Hand off the versioned runnable Solution package.
5. Execute that exact Solution against a registered fixture or evidence set.
6. Label the generated artifacts `demo` or `UAT` until the participant accepts them.
7. Record participant acceptance as `business_validated`; promote the accepted Solution version without rewriting its validation Outputs.
8. Execute production runs separately and retain Solution version, configuration, input hashes, evidence IDs and logs.

If the participant asks to build a Solution, do not skip directly to a manually produced Output. If the participant asks to execute an already accepted Solution, do not redesign it silently; run the named version or state why a revision is required.

## Defect routing

| Observed defect | Owning layer | Change | Required regression |
|---|---|---|---|
| Required field, rule, branch, control or expected result is missing or wrong | Approved knowledge | Revise through `$distill-bu-knowledge`, reapprove a new version, then rebuild affected capabilities | All affected traceability, capability and acceptance tests |
| Capability boundary, dependency or input/output contract is wrong | Solution design | Update solution brief, capability manifest and schemas | Contract tests on affected edges plus composed flow |
| Code produces the wrong result despite a correct contract | Capability implementation | Fix the named script, Skill, prompt, adapter or integration | Isolated happy/stop tests plus downstream integration |
| Source website, API, browser, desktop app or authentication mechanism changed | Runtime/source adapter | Fix adapter selectors, navigation, network extraction, download handling or runtime configuration | Adapter fixture/live controlled test plus downstream mapping |
| Field mapping or transformation is wrong | Mapping contract or transformer | Fix field registry/schema/transformation; return upstream only if business meaning is uncertain | Field-level mapping tests and representative generated Output |
| Values are correct but Excel, Word, HTML or UI is defective | Renderer/exporter | Fix presentation capability only | Render/content inspection; canonical data must remain unchanged |
| One case has missing, stale, mismatched or conflicting evidence | Run/input evidence | Correct or reacquire that case input; preserve the failed Run | Rerun the affected case; do not revise the Solution unless the failure handling was wrong |
| Environment lacks a dependency, permission, certificate, proxy or executable | Deployment/runtime configuration | Update deployment package or environment preflight | Preflight and target-environment smoke test |

## Revision rules

- Give every Solution release a version. Never overwrite an accepted release in place.
- Link every Run to its exact Solution version and approved knowledge version.
- Preserve failed Outputs and logs when audit requirements apply; mark them superseded instead of silently replacing them.
- Regenerate Outputs after a Solution change. A manually corrected Output is a temporary business workaround, not validation of the fix.
- Promote a change only after the smallest affected regression set passes and one representative composed Output is inspected.
