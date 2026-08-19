# OpenCLI CDP adapter contract for ACCUITY

Status: `POC_PENDING`. This is the proposed bank-intranet runtime for CAP-02, not a validated production adapter.

## Why this route

OpenCLI can reuse a logged-in Chromium session and expose structured `state`, `find`, `click`, `fill`, `get`, `extract`, `network` and `eval` operations. Its default Browser Bridge requires an extension. When extensions are prohibited, the official alternative is a local Chrome DevTools Protocol endpoint supplied through `OPENCLI_CDP_ENDPOINT`.

Keep CDP on `127.0.0.1`. Do not expose the debugging port to another machine, use a public tunnel, or add broad cross-origin flags in the bank environment without security approval. Anyone with CDP access can effectively control the browser session.

## Target architecture

```text
CDD orchestrator
  -> OpenCLI commands
  -> localhost CDP endpoint
  -> dedicated Chromium profile with authorized ACCUITY login
  -> accuity-evidence.json
  -> CAP-03 mapping and CAP-04 validation
```

OpenCLI must output evidence only. It must not write final CDD decisions directly.

## Preflight gates

1. Approve the OpenCLI binary/package, Node runtime if the npm distribution is used, and its Apache-2.0 license through bank software governance.
2. Approve a dedicated Chromium profile and localhost remote debugging. Do not attach automation to a general personal banking browser profile.
3. Confirm proxy, TLS inspection, SSO/MFA and download controls in the target workstation.
4. Confirm a dedicated download directory, file retention rule and antivirus/DLP behavior.
5. Run `opencli doctor`; stop when browser connectivity or authentication is not healthy.
6. Verify OpenCLI and browser versions and record them in the Run manifest.

## Local CDP bootstrap

The official documentation shows Chrome started with a dedicated profile and `--remote-debugging-port=9222`. For a same-machine bank POC, bind only to localhost and omit remote tunnels. Set:

```powershell
$env:OPENCLI_CDP_ENDPOINT = 'http://127.0.0.1:9222'
$env:OPENCLI_CDP_TARGET = 'bankersalmanac.lexisnexisrisk.com'
opencli doctor
```

Have the authorized user complete SSO/MFA in the dedicated browser profile. Never pass passwords, OTPs or session cookies through the command line or Solution files.

## One-case interaction sequence

Use a stable session name and refresh state after every navigation:

```powershell
opencli browser accuity-cdd open 'https://bankersalmanac.lexisnexisrisk.com/home'
opencli browser accuity-cdd state
opencli browser accuity-cdd find --label 'SWIFT/BIC'
opencli browser accuity-cdd fill <fresh-ref> 'BIDVVNVX'
opencli browser accuity-cdd get value <fresh-ref>
opencli browser accuity-cdd find --role button --name 'Search'
opencli browser accuity-cdd click <fresh-ref>
opencli browser accuity-cdd wait text 'BIDVVNVX' --timeout 20000
opencli browser accuity-cdd state
```

The labels and roles above are hypotheses for POC discovery, not approved selectors. Always obtain fresh refs from `state` or `find`. Record `matches_n` and `match_level`; stop on ambiguity or `reidentified` matches until the visible entity is rechecked.

After opening the unique entity, capture legal name, BIC, country, head-office/branch status, BA ID, URL and query time. Navigate to Documents/Due Diligence using fresh state. Prefer `network` plus one selected response body when the digital CBDDQ is loaded from structured JSON; otherwise extract exact visible question/answer locations.

## Download handling

OpenCLI's documented `browser wait download` depends on Browser Bridge extension 1.0.8 or later. Therefore do not assume that command works in CDP-only mode.

For the CDP-only POC:

1. Snapshot the dedicated download directory before clicking.
2. Use OpenCLI `find` and `click` on the verified download control.
3. Watch locally for a new file, reject temporary extensions, and wait until size and last-write time are stable.
4. Verify the file type, expected entity/document identity, readable content and SHA-256.
5. Move nothing automatically outside the controlled case directory until DLP/antivirus checks finish.
6. If Chrome does not save the file in a deterministically observable directory, mark `DOWNLOAD_CONTROL_UNSUPPORTED` and test either an approved Browser Bridge deployment or a site-specific adapter that uses an observed authenticated network response. Do not export cookies or replay authenticated requests until security approves that design.

## Evidence output

Write `accuity-evidence.json` conforming to `../../contracts/accuity-evidence.schema.json`, including:

- entity search input and exact result state;
- source URL, BA ID and checked time;
- document title, version/date, status, local controlled path and SHA-256;
- CBDDQ raw answers and locations, especially 19h, 49d and 49e;
- selector/ref match metadata and any ambiguity;
- runtime versions and acquisition errors.

Never turn `NO_RESULT`, `ACCESS_BLOCKED`, `STALE`, `AMBIGUOUS`, unreadable content or a failed download into `No`.

## POC acceptance

Run one authorized non-production institution through these gates:

1. entity search returns exactly one verified legal entity;
2. Documents/Due Diligence navigation survives a fresh session;
3. one CBDDQ is either downloaded with a stable hash or read through a verified structured response;
4. questions 19h, 49d and 49e retain raw values and source locations;
5. a forced ambiguous entity and a missing/unreadable document both stop safely;
6. CAP-03 consumes the resulting evidence JSON without site-specific browser state;
7. CAP-04 rejects a false negative when acquisition is incomplete.

Only after this POC passes should the observed workflow be crystallized into a private OpenCLI site adapter and versioned with its selectors/network contract and regression fixture.
