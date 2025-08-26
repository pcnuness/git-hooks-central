#!/usr/bin/env bash
set -euo pipefail

mkdir -p .git/hooks_artifacts
OUT=".git/hooks_artifacts/prepush.json"

jq -n \
  --arg commit "$(git rev-parse HEAD)" \
  --arg author "$(git log -1 --pretty=format:'%an <%ae>')" \
  --arg date "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --arg config_hash "$(sha1sum .pre-commit-config.yaml | awk '{print $1}')" \
  '{
    commit: $commit,
    author: $author,
    date: $date,
    precommit_config_sha1: $config_hash,
    status: "passed-local"
  }' > "$OUT"

echo "📝 Artefato local salvo em $OUT"
