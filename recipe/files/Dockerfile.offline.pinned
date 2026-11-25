# GENERATED L-009 hermetic build (--network=none, SBOM+SLSA-attestation-producing).
# Pinned bases from BASE_IMAGE_DIGESTS.lock; vendored Go tree + debs from Dockerfile.vendor.
FROM golang:1.27.4-bookworm@sha256:4fa7c968ba93f1635670522dbb01a2c78150443e1385746924566079f36570ea AS build_harbor_core
COPY vendored/harbor-src/ /src/
WORKDIR /src/src
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOWORK=off GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off SOURCE_DATE_EPOCH=1794989415
RUN go build -trimpath -ldflags='-s -w -X github.com/goharbor/harbor/src/pkg/version.GitCommit=e69b1bfa -X github.com/goharbor/harbor/src/pkg/version.ReleaseVersion=v2.16.0' -o /harbor_core ./core && /harbor_core -h
FROM golang:1.27.4-bookworm@sha256:4fa7c968ba93f1635670522dbb01a2c78150443e1385746924566079f36570ea AS build_harbor_jobservice
COPY vendored/harbor-src/ /src/
WORKDIR /src/src
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOWORK=off GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off SOURCE_DATE_EPOCH=1794989415
RUN go build -trimpath -ldflags='-s -w' -o /harbor_jobservice ./jobservice && /harbor_jobservice -h >/dev/null 2>&1; test -x /harbor_jobservice
FROM golang:1.27.4-bookworm@sha256:4fa7c968ba93f1635670522dbb01a2c78150443e1385746924566079f36570ea AS build_harbor_registryctl
COPY vendored/harbor-src/ /src/
WORKDIR /src/src
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOWORK=off GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off SOURCE_DATE_EPOCH=1794989415
RUN go build -trimpath -ldflags='-s -w' -o /harbor_registryctl ./registryctl && /harbor_registryctl -h
FROM golang:1.27.4-bookworm@sha256:4fa7c968ba93f1635670522dbb01a2c78150443e1385746924566079f36570ea AS build_registry
COPY vendored/harbor-src/ /src/
WORKDIR /src/third_party/distribution
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOWORK=off GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off SOURCE_DATE_EPOCH=1794989415
RUN go build -trimpath -tags "include_oss include_gcs" -ldflags='-s -w -X github.com/docker/distribution/version.Revision=72e8fdc1ff9021b77e618568a967e4b53689ce32' -o /registry ./cmd/registry && /registry --version
FROM ubuntu:24.04@sha256:9c7f200c07e3d4a03e7249d2c16bf66a51120fb876aa2242cf31451412543289
ENV DEBIAN_FRONTEND=noninteractive TZ=UTC LANG=C.UTF-8
RUN --mount=type=bind,source=vendored/debs,target=/tmp/debs \
    set --; for f in /tmp/debs/*.deb; do [ -e "$f" ] && set -- "$@" "$f"; done; \
    for pass in 1 2 3 4 5; do [ $# -eq 0 ] || dpkg -i --skip-same-version "$@" >/dev/null 2>&1 && break; done; \
    dpkg --configure -a && bad= && for d in "$@"; do p=$(dpkg-deb -f "$d" Package) v=$(dpkg-deb -f "$d" Version); \
      case "$(dpkg-query -W -f='${Version} ${db:Status-Abbrev}' "$p" 2>/dev/null)" in "$v ii"*) ;; *) bad="$bad $p=$v" ;; esac; done && \
    { [ -z "$bad" ] || { echo "vendored debs not installed at their vendored version:$bad" >&2; false; }; } && \
    rm -rf /var/lib/apt/lists/* \
           /var/log/dpkg.log /var/log/alternatives.log /var/log/apt /var/cache/ldconfig/aux-cache /var/cache/fontconfig
ARG SOURCE_DATE_EPOCH=1794989415
RUN groupadd -r harbor && useradd -r -g harbor -d /harbor -m harbor && \
    mkdir -p /data /data/registry /data/secret /data/job_logs && chown -R harbor:harbor /data /data/registry /data/secret /data/job_logs && \
    : "${SOURCE_DATE_EPOCH:?SOURCE_DATE_EPOCH must be set for a reproducible build}" && \
    sed -ri "s/^([^:]*:[^:]*):[0-9]*:/\1:$((SOURCE_DATE_EPOCH/86400)):/" /etc/shadow && \
    rm -f /etc/passwd- /etc/shadow- /etc/group- /etc/gshadow-
COPY --from=build_harbor_core /harbor_core /harbor/harbor_core
COPY --from=build_harbor_jobservice /harbor_jobservice /harbor/harbor_jobservice
COPY --from=build_harbor_registryctl /harbor_registryctl /harbor/harbor_registryctl
COPY --from=build_registry /registry /usr/local/bin/registry
COPY --from=build_harbor_core /src/make/migrations /harbor/migrations
COPY --from=build_harbor_core /src/src/core/views /harbor/views
COPY --from=build_harbor_core /src/icons /harbor/icons
COPY --from=build_harbor_core /src/readystack-portal /usr/share/harbor/portal
COPY harbor-entrypoint.sh /usr/local/bin/harbor-entrypoint.sh
COPY harbor-svc /usr/local/bin/harbor-svc
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY nginx.conf /etc/harbor/nginx.conf
COPY core-app.conf /etc/harbor/core/app.conf
COPY registry-config.yml /etc/harbor/registry/config.yml
COPY registryctl-config.yml /etc/harbor/registryctl/config.yml
COPY jobservice-config.yml /etc/harbor/jobservice/config.yml
RUN chmod 755 /harbor/harbor_core; chmod 755 /harbor/harbor_jobservice; chmod 755 /harbor/harbor_registryctl; chmod 755 /usr/local/bin/registry; chown -R harbor:harbor /harbor/migrations; chown -R harbor:harbor /harbor/views; chown -R harbor:harbor /harbor/icons; chown harbor:harbor /usr/local/bin/harbor-entrypoint.sh; chown harbor:harbor /usr/local/bin/harbor-svc; chown harbor:harbor /etc/supervisor/supervisord.conf; chown harbor:harbor /etc/harbor/nginx.conf; chown harbor:harbor /etc/harbor/core/app.conf; chown harbor:harbor /etc/harbor/registry/config.yml; chown harbor:harbor /etc/harbor/registryctl/config.yml; chown harbor:harbor /etc/harbor/jobservice/config.yml; chmod 0755 /usr/local/bin/harbor-entrypoint.sh; chmod 0755 /usr/local/bin/harbor-svc; chmod 0644 /etc/supervisor/supervisord.conf; chmod 0644 /etc/harbor/nginx.conf; chmod 0644 /etc/harbor/core/app.conf; chmod 0644 /etc/harbor/registry/config.yml; chmod 0644 /etc/harbor/registryctl/config.yml; chmod 0644 /etc/harbor/jobservice/config.yml
LABEL org.opencontainers.image.title="Harbor"
LABEL org.opencontainers.image.description="Harbor cloud native registry (core, jobservice, registry, portal) in one non-root image; external PostgreSQL and Redis"
LABEL org.opencontainers.image.source="https://github.com/goharbor/harbor"
LABEL org.opencontainers.image.version="v2.16.0-CE-ubuntu24.04-r1"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.vendor="ReadyStack.dev"
LABEL readystack.product="harbor"
LABEL readystack.edition="CE"
LABEL readystack.build_method="source-rebuild-go"
LABEL org.opencontainers.image.revision="e69b1bfab9c945cdbddf74d04d19200011108af0"
HEALTHCHECK --interval=10s --timeout=600s --start-period=180s \
  CMD curl -fsS http://127.0.0.1:8080/api/v2.0/ping || exit 1
WORKDIR /harbor
USER harbor
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/harbor-entrypoint.sh"]
