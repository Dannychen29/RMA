# Solution contract

Every solution brief must identify:

- target users and problem;
- trigger and required inputs;
- expected outputs and where they go;
- approved knowledge version;
- supported normal flow and known exceptions;
- deterministic, AI-assisted, human-review and human-only boundaries;
- permissions, sensitive-data handling and audit needs;
- failure and escalation behavior;
- maintenance owner and unresolved validation work.

For a multi-step software, automation or integration solution, also identify:

- capability decomposition and the reason for each boundary;
- one selected solution type per capability;
- versioned input/output contracts and directed dependencies;
- implementation path and owner per capability;
- isolated acceptance tests and dependency contract tests;
- the thin orchestration boundary and resumable state;
- capability status, distinguishing specified, implemented and tested.

For a knowledge base, also identify:

- approved corpus and excluded sources;
- target questions and retrieval behavior;
- access-control boundary;
- citation and unsupported-answer behavior;
- freshness, update, review and retirement process;
- retrieval and answer-quality evaluation set;
- index or deployment rebuild trigger and owner.

Do not lock output format before the task demands it. Do not describe a draft as production-ready.
