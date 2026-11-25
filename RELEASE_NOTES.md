# Harbor v2.16.0 — ReadyStack release `v2.16.0-CE-ubuntu24.04-r1`

Generated 2026-11-22 from this release's build records and strategy. Statements that come from a single record name it in brackets; the others come from this release's strategy and build log.

## Release

- **Image:** `readystack/harbor:v2.16.0-CE-ubuntu24.04-r1` (linux/amd64). Index digest `sha256:c389a1530c67ad5d45ef88146328d08040dd25e84f0cf0b82ccf5e61b500d86b` [`docs/provenance/LOCKED_DIGEST.txt`].
- **Image manifest digest:** `sha256:b5147d42aaaf6036e8de3cd25960fbee87eab90069c9dbc869c3a16b35592d19` [`TARGET_DIGEST.txt`].
- **Upstream:** Harbor v2.16.0 built from source at `v2.16.0` of https://github.com/goharbor/harbor — upstream notes: https://github.com/goharbor/harbor/releases/tag/v2.16.0 [`docs/provenance/BUILD_RECIPE.json`].
- **Base image:** `ubuntu:24.04`; runtime user `harbor`.
- **Build:** `source-rebuild-go`, compiled offline with `--network=none`.
- **Supersedes:** ReadyStack release `v2.15.4-CE-ubuntu24.04-r5`.

## What changed in this release

- Upstream version v2.15.4 → v2.16.0.
- Minimum dependency versions ReadyStack enforces on top of upstream (raised only where upstream's own version was lower); shipped versions from the SBOM [`docs/sbom/SBOM.json`]:
  - `github.com/Azure/go-ntlmssp` at least `v0.1.1`: not raised, upstream already pins `v0.1.1` (shipped: `v0.1.1`)
  - `golang.org/x/net` raised from upstream's `v0.60.0` to at least `v0.62.0` (shipped: `v0.62.0`)
  - `github.com/klauspost/compress` raised from upstream's `v1.18.7` to at least `v1.20.2` (shipped: `v1.20.2`)
  - `github.com/satori/go.uuid` raised from upstream's `v1.2.0` to at least `v1.2.1-0.20181016170032-d91630c85102` (shipped: `v1.2.1-0.20181016170032-d91630c85102`)
  - `github.com/go-jose/go-jose/v4` at least `v4.1.6`: not raised, upstream already pins `v4.1.6` (shipped: `v4.1.6`)
  - `google.golang.org/grpc` raised from upstream's `v1.83.1` to at least `v1.83.2` (shipped: `v1.83.2`)
- This release moves Harbor from 2.15.4 to 2.16.0, a release of upstream's newer 2.16.x line. Upstream's release notes list what changed: https://github.com/goharbor/harbor/releases/tag/v2.16.0

## Security status at release (measured 2026-11-22)

- **Docker Scout:** 0 fixable critical/high vulnerabilities; runs as `harbor` (non-root); SBOM + provenance attestations present (SPDX SBOM + SLSA v1) [`docs/provenance/SCOUT_VERDICT.json`].
- **OSV cross-check:** no fixable critical/high vulnerability beyond Docker Scout's findings.
- **Signature:** cosign signature verified by ReadyStack's release gate before publishing; check it yourself with `cosign verify --key https://readystack.dev/keys/cosign.pub readystack/harbor:v2.16.0-CE-ubuntu24.04-r1` (signatures are recorded in the public Sigstore transparency log).
- **ReadyStack release check at release:** passed (ReadyStack's own test, not a Docker Scout grade). Vulnerabilities are disclosed every day and the image never changes, so it is re-checked daily, beside Docker Scout's own dated grade, at https://readystack.dev/queue.
- **Before exposing this service:** HARBOR_ADMIN_PASSWORD is only applied when the database is first initialised; change the admin password in the portal afterwards and keep the variable out of shell history.
- **Before exposing this service:** Port 8080 is plain HTTP. Put a TLS-terminating proxy in front of it and set EXT_ENDPOINT to its https:// URL before exposing Harbor beyond localhost. The proxy must pass on the Host header the client sent, including its port, send X-Forwarded-Proto: https and accept request bodies of any size (nginx: `proxy_set_header Host $http_host;`, `proxy_set_header X-Forwarded-Proto https;`, `client_max_body_size 0;`); without them every docker push through the proxy fails.
- **Before exposing this service:** /data/secret holds the key that decrypts credentials stored in the database; protect and back it up with the database.

## Reproducibility

Rebuilds offline from this archive to the identical image digest `sha256:b5147d42aaaf6036e8de3cd25960fbee87eab90069c9dbc869c3a16b35592d19`: run `./BUILD_OFFLINE.sh`, then `./VERIFY_OFFLINE.sh` (add `--online` to confirm the Docker Hub tag holds the same digest). Before publishing, ReadyStack rebuilt the kit with `./BUILD_OFFLINE.sh` and compared the result with the published digest [`docs/provenance/REPRO_VERIFICATION.json`], then ran `./BUILD_OFFLINE.sh` and `./VERIFY_OFFLINE.sh` from this archive (without `--online`).

## Validation

- 4 of 5 use cases passed (5 authored) against the running image [`docs/validation/test-results.json`].
- Failed cases are listed in `docs/validation/FAILED_TESTS.md`.

## Known issues

- **low** (ReadyStack package): The image refuses to start without HARBOR_ADMIN_PASSWORD, although Harbor uses it only when it first initialises its database [`RSD-harbor-f6d4db7c02`] (carried from `v2.15.4-CE-ubuntu24.04-r2`, recorded there as `RSD-harbor-8f5f574c48`)
- Build-time check `harbor-labels-001` (GET http://127.0.0.1:8080/api/v2.0/labels) returned 400, expected 200.

## Defects fixed

- 30 problems found before release and fixed before it shipped (30 by review); each is listed in `docs/defects/defects.json`.

## Verify this archive

```
sha256sum -c CHECKSUMS.sha256
./BUILD_OFFLINE.sh && ./VERIFY_OFFLINE.sh --online
cosign verify --key https://readystack.dev/keys/cosign.pub readystack/harbor:v2.16.0-CE-ubuntu24.04-r1
```

ReadyStack records every signature in the public Sigstore transparency log (Rekor), so the command needs no extra flags.

