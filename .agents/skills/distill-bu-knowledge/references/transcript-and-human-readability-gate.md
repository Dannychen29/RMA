# Transcript calibration and human-readable BRD gate

Apply this gate whenever timecoded speech is material or `BRD.html` is presented for human approval.

## Transcript layers

Preserve two distinct artifacts when raw ASR is not reliably readable:

1. Raw ASR: immutable adapter output with original segments, timestamps and uncertainty.
2. Calibrated transcript: a review surface derived from raw ASR and authorized engagement-local context.

Never silently overwrite raw ASR. Do not call a raw adapter dump a reviewed transcript.

For the calibrated transcript:

- join fragments into complete conversational turns without changing their order;
- reconcile repeated spelling variants and named entities against authorized terminology, later repetitions and participant corrections;
- retain time ranges for every paragraph or turn;
- distinguish a direct correction from a contextual inference;
- use `[inaudible]`, `[overlap]`, `[speaker uncertain]` or `[term uncertain: ...]` instead of inventing fluent text;
- keep questions, decisions, corrections, conditions, numbers, deadlines and commitments at their original granularity;
- identify speakers only when supported by diarization or strong conversational context, and disclose the basis;
- run a second pass specifically for names, product names, acronyms, numbers, dates, enumerations and conditional language.

Fail transcript calibration when material named entities remain as obvious phonetic garbage, fragments are presented as readable prose without joining, corrections are undocumented, or a paraphrase is labelled verbatim.

## One canonical HTML, two reading depths

Keep one canonical `BRD.html`. Do not create independent human and machine BRDs.

The machine-readable contract layer owns all business meaning. The first reading depth is a derived review projection and must let a reviewer quickly understand:

- the outcome and scope;
- the few material decisions and why they matter;
- prioritized next actions, owners, dependencies, target timing and completion proof;
- material risks, assumptions and questions requiring confirmation.

The second reading depth contains the complete step, decision, field, flow, requirement, acceptance and evidence contracts. Use semantic sections, tables, anchors and optional `details` elements so this precision remains accessible without overwhelming the opening review surface. Mark each review projection with the stable IDs from which it is derived; never maintain its facts independently.

## Human-language editing pass

After contract rendering and before final validation:

1. Read the HTML from top to bottom as the intended participant.
2. Replace schema-shaped fragments with complete plain-language sentences on the opening review surface.
3. Remove visible validator tokens, internal aliases and implementation scaffolding.
4. Expand unexplained acronyms once and keep engagement terminology consistent.
5. Separate confirmed commitments from examples, recommendations and inferred dates.
6. Ensure every priority action answers: what to do, why now, who owns it, what it depends on, when to revisit it and what proves completion.
7. Confirm that no material claim present in detailed contracts is missing from the human review surface solely because it was difficult to phrase.

Fail the human-readable gate when a reviewer must inspect machine-contract fields to discover the main decision, when next steps are only generic verbs, when visible prose reads like schema serialization, or when a separate summary can diverge from the canonical HTML.

## Cross-layer consistency

- Link each material review-surface statement to stable step, decision, requirement or claim IDs through `data-derived-from` and visible anchors where useful.
- Generate the review projection from the machine contracts when a renderer exists. Otherwise verify both directions: every projection fact maps to a source contract, and every material source contract appears or is intentionally omitted with a review reason.
- Re-run structural and evidence-alignment validation after human-language edits.
- Present the calibrated transcript and canonical HTML together for approval when spoken evidence is central.
