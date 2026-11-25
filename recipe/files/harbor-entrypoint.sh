#!/bin/bash
# ReadyStack Harbor entrypoint (runs as the non-root harbor user).
# Upstream's `prepare` step renders one env file per Harbor container from harbor.yml; this image has
# one container, so this script does the same job at every start: it reads the operator's settings,
# creates the deployment secrets ONCE under /data/secret (kept on the /data volume, so restarts and
# upgrades keep them), writes one env file per Harbor process and hands over to supervisord, which
# runs registry, registryctl, core, jobservice and nginx. Each process sees ONLY its own env file
# (supervisord is started with a clean environment): the registry treats every REGISTRY_* variable
# as a config override, and core's REGISTRY_STORAGE_PROVIDER_NAME would otherwise reconfigure it.
set -euo pipefail
die() { echo "harbor: $*" >&2; exit 1; }

[ -n "${POSTGRESQL_HOST:-}" ] || die "set POSTGRESQL_HOST to your PostgreSQL server (Harbor keeps all of its metadata there)"
[ -n "${POSTGRESQL_PASSWORD:-}" ] || die "set POSTGRESQL_PASSWORD (the password of POSTGRESQL_USERNAME)"
# Harbor core writes the password unquoted into a libpq keyword/value connection string: a space ends the value, a
# backslash escapes, a leading single quote opens a quoted string. Core then cannot log in, and with a space its FATAL
# log line printed the rest of the password in clear text (held chain 519, review rounds 3-4). Stop before that.
case "$POSTGRESQL_PASSWORD" in
  *[[:space:]]* | *\\* | \'*) die "POSTGRESQL_PASSWORD must not contain a space or a backslash or begin with a single quote (Harbor core puts it unquoted into its database connection string); give the database user another password and set it here" ;;
esac
[ -n "${REDIS_HOST:-}" ] || die "set REDIS_HOST to your Redis server (job queue, sessions and registry cache)"
[ -n "${HARBOR_ADMIN_PASSWORD:-}" ] || die "set HARBOR_ADMIN_PASSWORD: it becomes the admin password when Harbor first initialises its database (later changes are made in the UI or API)"
POSTGRESQL_PORT="${POSTGRESQL_PORT:-5432}"
POSTGRESQL_USERNAME="${POSTGRESQL_USERNAME:-postgres}"
POSTGRESQL_DATABASE="${POSTGRESQL_DATABASE:-registry}"
POSTGRESQL_SSLMODE="${POSTGRESQL_SSLMODE:-disable}"
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_PASSWORD="${REDIS_PASSWORD:-}"
EXT_ENDPOINT="${EXT_ENDPOINT:-http://localhost:8080}"
LOG_LEVEL="${LOG_LEVEL:-info}"

S=/data/secret
mkdir -p "$S/core" "$S/registry" /data/registry /data/job_logs
umask 077
gen() { [ -s "$1" ] || { openssl rand -hex "$2" | tr -d '\n' > "$1.tmp" && mv "$1.tmp" "$1"; }; }
gen "$S/core/key" 8
gen "$S/core_secret" 8
gen "$S/jobservice_secret" 8
gen "$S/csrf_key" 16
gen "$S/registry/password" 16
gen "$S/registry/http_secret" 16
gen "$S/robot_prefix" 4
# Harbor core's token service reads only a PKCS#1 key ("BEGIN RSA PRIVATE KEY"); OpenSSL 3 writes PKCS#8 by default,
# and with a PKCS#8 key every docker login, push and pull answered HTTP 500 (held chain 519, review round 2).
[ -s "$S/core/private_key.pem" ] || openssl genrsa -traditional -out "$S/core/private_key.pem" 4096 2>/dev/null
if head -n 1 "$S/core/private_key.pem" | grep -q "BEGIN PRIVATE KEY"; then
  openssl rsa -in "$S/core/private_key.pem" -traditional -out "$S/core/private_key.pem.tmp" 2>/dev/null \
    && mv "$S/core/private_key.pem.tmp" "$S/core/private_key.pem"
fi
REG_USER=harbor_registry_user
REG_PW="$(cat "$S/registry/password")"
if [ ! -s "$S/registry/passwd" ]; then
  htpasswd -bnB "$REG_USER" "$REG_PW" | sed '/^$/d' > "$S/registry/passwd.tmp" && mv "$S/registry/passwd.tmp" "$S/registry/passwd"
fi
CORE_SECRET="$(cat "$S/core_secret")"
JOBSERVICE_SECRET="$(cat "$S/jobservice_secret")"

urlenc() { local s="$1" o="" c i; for ((i = 0; i < ${#s}; i++)); do c="${s:i:1}"
  case "$c" in [A-Za-z0-9._~-]) o+="$c" ;; *) printf -v c '%%%02X' "'$c"; o+="$c" ;; esac; done; printf '%s' "$o"; }
RAUTH=""; [ -z "$REDIS_PASSWORD" ] || RAUTH=":$(urlenc "$REDIS_PASSWORD")@"
R="redis://${RAUTH}${REDIS_HOST}:${REDIS_PORT}"

RUN=/tmp/harbor-run
rm -rf "$RUN"; mkdir -p "$RUN" /tmp/nginx
w() { local f="$RUN/$1.env" kv; shift; : > "$f"; for kv in "$@"; do printf '%s=%q\n' "${kv%%=*}" "${kv#*=}" >> "$f"; done; }

w core CONFIG_PATH=/etc/harbor/core/app.conf PORT=8081 \
  KEY_PATH="$S/core/key" TOKEN_PRIVATE_KEY_PATH="$S/core/private_key.pem" \
  POSTGRES_MIGRATION_SCRIPTS_PATH=/harbor/migrations/postgresql/ \
  "_REDIS_URL_CORE=$R?idle_timeout_seconds=30" "_REDIS_URL_REG=$R/1?idle_timeout_seconds=30" \
  "LOG_LEVEL=$LOG_LEVEL" "EXT_ENDPOINT=$EXT_ENDPOINT" DATABASE_TYPE=postgresql \
  "POSTGRESQL_HOST=$POSTGRESQL_HOST" "POSTGRESQL_PORT=$POSTGRESQL_PORT" \
  "POSTGRESQL_USERNAME=$POSTGRESQL_USERNAME" "POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD" \
  "POSTGRESQL_DATABASE=$POSTGRESQL_DATABASE" "POSTGRESQL_SSLMODE=$POSTGRESQL_SSLMODE" \
  POSTGRESQL_MAX_IDLE_CONNS=100 POSTGRESQL_MAX_OPEN_CONNS=900 POSTGRESQL_CONN_MAX_LIFETIME=5m POSTGRESQL_CONN_MAX_IDLE_TIME=0 \
  REGISTRY_URL=http://127.0.0.1:5000 PORTAL_URL=http://127.0.0.1:8080 \
  TOKEN_SERVICE_URL=http://127.0.0.1:8081/service/token \
  "HARBOR_ADMIN_PASSWORD=$HARBOR_ADMIN_PASSWORD" MAX_JOB_WORKERS=10 \
  "CORE_SECRET=$CORE_SECRET" "JOBSERVICE_SECRET=$JOBSERVICE_SECRET" WITH_TRIVY=false \
  CORE_URL=http://127.0.0.1:8081 CORE_LOCAL_URL=http://127.0.0.1:8081 JOBSERVICE_URL=http://127.0.0.1:8082 \
  REGISTRY_STORAGE_PROVIDER_NAME=filesystem READ_ONLY=false REGISTRY_CONTROLLER_URL=http://127.0.0.1:8083 \
  "REGISTRY_CREDENTIAL_USERNAME=$REG_USER" "REGISTRY_CREDENTIAL_PASSWORD=$REG_PW" \
  "CSRF_KEY=$(cat "$S/csrf_key")" "ROBOT_SCANNER_NAME_PREFIX=$(cat "$S/robot_prefix")" \
  "HARBOR_ALLOW_PRIVATE_NETWORK_ACCESS=${HARBOR_ALLOW_PRIVATE_NETWORK_ACCESS:-true}" \
  PERMITTED_REGISTRY_TYPES_FOR_PROXY_CACHE=docker-hub,harbor,azure-acr,ali-acr,aws-ecr,google-gcr,docker-registry,github-ghcr,jfrog-artifactory \
  REPLICATION_ADAPTER_WHITELIST=ali-acr,aws-ecr,azure-acr,docker-hub,docker-registry,github-ghcr,google-gcr,harbor,huawei-SWR,jfrog-artifactory,tencent-tcr,volcengine-cr
w jobservice JOB_SERVICE_PORT=8082 "JOB_SERVICE_POOL_REDIS_URL=$R/2?idle_timeout_seconds=30" \
  "CORE_SECRET=$CORE_SECRET" "JOBSERVICE_SECRET=$JOBSERVICE_SECRET" CORE_URL=http://127.0.0.1:8081 \
  REGISTRY_URL=http://127.0.0.1:5000 REGISTRY_CONTROLLER_URL=http://127.0.0.1:8083 \
  "REGISTRY_CREDENTIAL_USERNAME=$REG_USER" "REGISTRY_CREDENTIAL_PASSWORD=$REG_PW" "LOG_LEVEL=$LOG_LEVEL" \
  JOBSERVICE_WEBHOOK_JOB_MAX_RETRY=3 JOBSERVICE_WEBHOOK_JOB_HTTP_CLIENT_TIMEOUT=3 \
  "HARBOR_ALLOW_PRIVATE_NETWORK_ACCESS=${HARBOR_ALLOW_PRIVATE_NETWORK_ACCESS:-true}"
w registry "REGISTRY_REDIS_ADDR=$REDIS_HOST:$REDIS_PORT" "REGISTRY_REDIS_PASSWORD=$REDIS_PASSWORD" \
  "REGISTRY_HTTP_SECRET=$(cat "$S/registry/http_secret")"
w registryctl PORT=8083 "CORE_SECRET=$CORE_SECRET" "JOBSERVICE_SECRET=$JOBSERVICE_SECRET" "LOG_LEVEL=$LOG_LEVEL" \
  "REGISTRY_REDIS_ADDR=$REDIS_HOST:$REDIS_PORT" "REGISTRY_REDIS_PASSWORD=$REDIS_PASSWORD" \
  "REGISTRY_HTTP_SECRET=$(cat "$S/registry/http_secret")"
w nginx

exec env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin HOME=/harbor LANG=C.UTF-8 TZ="${TZ:-UTC}" \
  /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
