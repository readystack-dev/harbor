# Provenance — Harbor (`v2.16.0-CE-ubuntu24.04-r1`)

Every item below is copied from a record in this archive; the record is named in brackets.

## Source

- Upstream repository: https://github.com/goharbor/harbor
- Revision built: `v2.16.0` (commit `e69b1bfab9c945cdbddf74d04d19200011108af0`)
- Source tree: `0890277b81e054ed217d0e5003b1205e22622cd24812d60ed97ecbcffc82071a` over 3311 files [`docs/provenance/SOURCE_TREE_HASH.json`]
- Community Edition only: enterprise code is removed or refused before the build (CE audit at acquire).

## Build

- Method: `source-rebuild-go`; base image `ubuntu:24.04`
- Compiled with `--network=none` from vendored source, dependencies and base images; BuildKit pinned to `moby/buildkit:v0.31.2` (shipped in `toolchain/`).
- SOURCE_DATE_EPOCH: `1794989415` [`SOURCE_DATE_EPOCH.txt`]
- Frozen inputs: [`docs/provenance/FREEZE_MANIFEST.json`], build recipe: [`docs/provenance/BUILD_RECIPE.json`].

## Output

- Published image: `readystack/harbor:v2.16.0-CE-ubuntu24.04-r1` — index digest `sha256:c389a1530c67ad5d45ef88146328d08040dd25e84f0cf0b82ccf5e61b500d86b` [`docs/provenance/LOCKED_DIGEST.txt`]
- linux/amd64 image digest `sha256:b5147d42aaaf6036e8de3cd25960fbee87eab90069c9dbc869c3a16b35592d19` — reproduced from this archive before publishing [`docs/provenance/REPRO_VERIFICATION.json`].

## Attestations and signature

- SBOM + SLSA provenance attached to the image: attached: an SPDX SBOM and SLSA v1 provenance [`docs/provenance/SCOUT_VERDICT.json`]
- cosign signature by the ReadyStack release key: verified before publishing. Check it: `cosign verify --key https://readystack.dev/keys/cosign.pub readystack/harbor:v2.16.0-CE-ubuntu24.04-r1`

## Pinned inputs, and why

- 39 pinned inputs, each with where it came from, why this one, how it was checked and when it was decided: `docs/PINS.md` [`docs/provenance/PINS.json`] (upstream source 2, base and build images 3, image digests 2, language runtimes and toolchains 1, dependency versions readystack sets 13, pins in the kit's dockerfiles 11, readystack's build engine 1, dependencies upstream chose 2, services the release checks run beside 4).

## Build trail

- How this release passed through the ReadyStack harness, record by record (every chain, drive, stage, review round, defect and check, each naming the record it is copied from): `ReadyStack-harbor-v2.16.0-CE-ubuntu24.04-r1.trail.json`, published beside this archive and signed with the release key (`ReadyStack-harbor-v2.16.0-CE-ubuntu24.04-r1.trail.json.sigstore`), and readable at https://readystack.dev/products/harbor/trail/v2.16.0-CE-ubuntu24.04-r1.

