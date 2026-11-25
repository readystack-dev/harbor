# Harbor: ReadyStack build kit

The offline build kit for the Docker image `readystack/harbor:v2.16.0-CE-ubuntu24.04-r1`. It holds what the image is built from (upstream source, base images, toolchain, pinned dependencies) and the documents, so the image can be rebuilt with no network access (`docker build --network=none`).

- Release: [v2.16.0-CE-ubuntu24.04-r1](https://github.com/readystack-dev/harbor/releases/tag/v2.16.0-CE-ubuntu24.04-r1)
- Image: [`docker.io/readystack/harbor:v2.16.0-CE-ubuntu24.04-r1`](https://hub.docker.com/r/readystack/harbor/tags), manifest digest `sha256:b5147d42aaaf6036e8de3cd25960fbee87eab90069c9dbc869c3a16b35592d19`
- Product page: https://readystack.dev/products/harbor
- Defects: this repository's Issues (defects recorded from 25 November 2026 on) and https://readystack.dev/defects.html?product=harbor

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

`recipe/` holds the kit's recipe files (Dockerfiles, build scripts, pins) as published at https://readystack.dev/products/harbor/recipe. The complete kit is the release download. Each release is a tag here.
