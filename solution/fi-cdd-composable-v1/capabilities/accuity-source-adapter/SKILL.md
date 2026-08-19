---
name: acquire-accuity-cdd-evidence
description: Acquire read-only entity, document, rating and CBDDQ evidence from an authorized Bankers Almanac session for one financial-institution BIC and return the controlled ACCUITY evidence JSON contract. Use only for CAP-02 of the approved FI CDD solution; do not make CDD, risk or approval decisions.
---

# Acquire ACCUITY CDD Evidence

Read `../../contracts/accuity-evidence.schema.json` before navigation.

1. Open `https://bankersalmanac.lexisnexisrisk.com/home` in the authorized browser session.
2. Search by exact BIC, then compare legal name and country. Record `AMBIGUOUS`, `ENTITY_MISMATCH`, `NO_RESULT` or `ACCESS_BLOCKED` instead of guessing. GAP-016 prevents automated selection when multiple entities or branch/head-office conflicts remain.
3. For a matched entity, capture BA ID, entity URL, legal name, BIC, country, branch/head-office state, query timestamp and visible evidence location.
4. Open Documents/Due Diligence. Record each required document separately with title, version/date, availability, visible location, document ID and downloaded hash when a file is actually downloaded.
5. If CBDDQ is available, open and read its content. Capture exact raw answers and locations for 19h, 49d and 49e plus mapped fields. Never infer `No` from absence, an unread page or access failure.
6. Save one `accuity-evidence.json`; do not write CDD forms or final risk decisions.
7. Stop and create a human task for ambiguity, mismatch, unreadable content or unresolved freshness. Preserve screenshots only when required as completion evidence and avoid unnecessary personal data.

The adapter implements ST-02–ST-04 and FLOW-PORTAL. It does not implement screening, UBO exceptions, acceptance/rejection, risk override or approval.
