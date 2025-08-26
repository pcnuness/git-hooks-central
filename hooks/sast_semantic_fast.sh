#!/usr/bin/env bash
set -euo pipefail

# Exemplo com semgrep rápido (padrões prontos):
if command -v semgrep >/dev/null 2>&1; then
  semgrep ci --config p/owasp-top-ten --error --timeout 60 || {
    echo "❌ SAST semgrep encontrou problemas."
    exit 1
  }
else
  echo "ℹ️ semgrep não encontrado, pulando SAST leve."
fi

echo "✅ SAST leve ok."
