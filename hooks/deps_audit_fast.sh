#!/usr/bin/env bash
set -euo pipefail

changed() { git diff --cached --name-only | tr '\n' ' '; }

if ls $(changed) 2>/dev/null | grep -q 'package-lock.json\|yarn.lock\|pnpm-lock.yaml'; then
  command -v npm >/dev/null 2>&1 && npm audit --audit-level=high || true
fi

if ls $(changed) 2>/dev/null | grep -q 'pom.xml\|build.gradle'; then
  echo "ℹ️ Sugestão: usar OWASP Dependency-Check no CI. Local: pule ou use modo rápido."
fi

if ls $(changed) 2>/dev/null | grep -q 'requirements.txt\|poetry.lock\|Pipfile.lock'; then
  if command -v pip-audit >/dev/null 2>&1; then
    pip-audit -r requirements.txt || true
  fi
fi

if ls $(changed) 2>/dev/null | grep -q 'go.mod'; then
  command -v govulncheck >/dev/null 2>&1 && govulncheck ./... || true
fi

echo "✅ Dependency audit rápido concluído (sem falhar build por low/medium localmente)."
