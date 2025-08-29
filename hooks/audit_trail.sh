#!/usr/bin/env bash
set -euo pipefail

mkdir -p .git/hooks_artifacts
OUT=".git/hooks_artifacts/prepush.json"

# Obter informações do git
COMMIT=$(git rev-parse HEAD)
AUTHOR=$(git log -1 --pretty=format:'%an <%ae>')
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CONFIG_HASH=$(sha1sum .pre-commit-config.yaml 2>/dev/null | awk '{print $1}' || echo "unknown")

# Criar JSON manualmente (sem depender do jq)
cat > "$OUT" << EOF
{
  "commit": "$COMMIT",
  "author": "$AUTHOR",
  "date": "$DATE",
  "precommit_config_sha1": "$CONFIG_HASH",
  "status": "passed-local"
}
EOF

echo "📝 Artefato local salvo em $OUT"
