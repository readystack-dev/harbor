[![ReadyStack](https://readystack.dev/logo.svg)](https://readystack.dev)

**Stable, Open-source Releases, Automated** · [readystack.dev](https://readystack.dev)

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-readystack%2Fharbor-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/readystack/harbor) [![Docker pulls](https://img.shields.io/docker/pulls/readystack/harbor)](https://hub.docker.com/r/readystack/harbor) [![Grade at release](https://img.shields.io/badge/grade%20at%20release-A%20%2894%25%29-2ea44f)](https://readystack.dev/products/harbor) [![Signed: cosign](https://img.shields.io/badge/signed-cosign-2ea44f)](https://readystack.dev/keys/cosign.pub) ![SBOM: SPDX](https://img.shields.io/badge/SBOM-SPDX-2ea44f) ![Provenance: SLSA v1](https://img.shields.io/badge/provenance-SLSA%20v1-2ea44f) ![Offline rebuild: verified](https://img.shields.io/badge/offline%20rebuild-verified-2ea44f)

# Harbor: ReadyStack build kit

The offline build kit for the Docker image `readystack/harbor:v2.16.0-CE-ubuntu24.04-r1`. It holds what the image is built from (upstream source, base images, toolchain, pinned dependencies) and the documents, so the image can be rebuilt with no network access (`docker build --network=none`).

- Release: [v2.16.0-CE-ubuntu24.04-r1](https://github.com/readystack-dev/harbor/releases/tag/v2.16.0-CE-ubuntu24.04-r1)
- Image: [`docker.io/readystack/harbor:v2.16.0-CE-ubuntu24.04-r1`](https://hub.docker.com/r/readystack/harbor/tags), manifest digest `sha256:b5147d42aaaf6036e8de3cd25960fbee87eab90069c9dbc869c3a16b35592d19`
- Product page: https://readystack.dev/products/harbor
- Source and build recipe: https://readystack.dev/products/harbor/recipe
- Build trail: https://readystack.dev/products/harbor/trail/v2.16.0-CE-ubuntu24.04-r1
- Defects: this repository's Issues (defects recorded from 25 November 2026 on) and https://readystack.dev/defects.html?product=harbor

## The image

One non-root container running Harbor's own processes under supervisord: core (API, auth, token service, /v2 proxy), jobservice (replication, garbage collection, retention and other jobs), registryctl, the registry, and nginx serving the web portal on port 8080. PostgreSQL and Redis are NOT inside the image: point it at your own PostgreSQL database and Redis server. No vulnerability scanner is bundled; register an external scanner (for example a Trivy adapter) in Administration > Interrogation Services if you want scanning.

## Who uses Harbor and why

Platform and DevOps teams who run their own container registry for Kubernetes and other container platforms.

Harbor is an open-source registry that stores container images, scans them for vulnerabilities, signs them, controls access by role, and replicates images between registries.

A typical use: A company wants every image its clusters run to come from a registry it controls. Teams push images to their projects in Harbor, each image is scanned for vulnerabilities, a policy check keeps vulnerable images from being deployed, and replication copies images to a second registry near another data centre.

From the upstream project's own description: https://github.com/goharbor/harbor, https://goharbor.io/.

## This release

- Docker Scout policy grade at release: **A** (94%), graded 2026-11-22 with `docker scout policy` (CLI 1.26.0, docker-default configuration).
  - Docker Scout counts 115 packages with copyleft licences (GPL, LGPL, MPL), all of them operating-system packages (it counts only packages whose licence it can read; the SBOM lists every component).
- Signed with ReadyStack's release key (fingerprint `04daa92344a52dbc`): https://readystack.dev/keys/cosign.pub.
- Runs as a non-root user (`harbor`).
- Attestations on the image: an SPDX SBOM and SLSA provenance v1.
- Rebuilt from this kit with network egress blocked on 2026-11-22; the rebuilt image digest is the published one.
- Base: Ubuntu 24.04.

The current grade, measured again every day, is on https://readystack.dev/products/harbor.

Harbor is distributed under its upstream licence (Apache-2.0); the kit contains upstream's source under that licence, and each vendored component under its own.

## Download

From the [v2.16.0-CE-ubuntu24.04-r1 release](https://github.com/readystack-dev/harbor/releases/tag/v2.16.0-CE-ubuntu24.04-r1): `ReadyStack-harbor-v2.16.0-CE-ubuntu24.04-r1.tar.gz` (504.2 MB), SHA-256 `14287f1b155bad64b8368934486e318bf042458a393e383a7b25f6a7f460ca66`.

```sh
sha256sum --check --ignore-missing SHA256SUMS
```

## Verify and rebuild

The rebuild statement is signed with the ReadyStack release key. Check the signature before you rely on it:

```sh
cosign verify-blob --key https://readystack.dev/keys/cosign.pub \
  --bundle ReadyStack-harbor-v2.16.0-CE-ubuntu24.04-r1.rebuild.json.sigstore ReadyStack-harbor-v2.16.0-CE-ubuntu24.04-r1.rebuild.json
```

Unpack with `-p` so file modes are kept, then follow the kit's own README.md and docs/REBUILD.md:

```sh
tar -xpzf ReadyStack-harbor-v2.16.0-CE-ubuntu24.04-r1.tar.gz
cd v2.16.0-CE-ubuntu24.04-r1
less README.md docs/REBUILD.md
```

The build trail (`ReadyStack-harbor-v2.16.0-CE-ubuntu24.04-r1.trail.json`, signed the same way, and its Markdown copy) records how this release was built and checked.

## This repository

`recipe/` holds the kit's recipe files (Dockerfiles, build scripts, pins) as published at https://readystack.dev/products/harbor/recipe. The complete kit is the release download. Each release is a tag here. How to report a vulnerability: [SECURITY.md](SECURITY.md).

## About ReadyStack

**Stable, Open-source Releases, Automated.** ReadyStack releases popular open-source apps every week with every available critical and high security fix applied, plus full documentation, reference data, tests and a build recipe that recreates each release bit-for-bit. Each release is rebuilt from its pinned inputs with the network off, checked against its published digest, signed, and scanned and graded again every day. The images and build kits are free, and ReadyStack is soon to be a nonprofit.

[readystack.dev](https://readystack.dev) · [All products](https://readystack.dev/products.html) · [Build kits on GitHub](https://github.com/readystack-dev) · [Defect log](https://readystack.dev/defects.html) · contact@readystack.dev

— ReadyStack · https://readystack.dev
