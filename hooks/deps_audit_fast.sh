#!/usr/bin/env bash
set -euo pipefail

changed() { git diff --cached --name-only | tr '\n' ' '; }

# Verificar se é projeto Node.js
if [[ -f "package.json" ]]; then
  echo "🔍 Projeto Node.js detectado..."
  
  # Verificar se tem lockfile
  if [[ ! -f "package-lock.json" && ! -f "yarn.lock" && ! -f "pnpm-lock.yaml" ]]; then
    echo "⚠️  Lockfile não encontrado. Criando package-lock.json..."
    if command -v npm >/dev/null 2>&1; then
      npm install --package-lock-only --no-audit
    fi
  fi
  
  # Executar audit se tiver lockfile
  if [[ -f "package-lock.json" ]] && command -v npm >/dev/null 2>&1; then
    echo "🔒 Executando npm audit..."
    npm audit --audit-level=high || true
  elif [[ -f "yarn.lock" ]] && command -v yarn >/dev/null 2>&1; then
    echo "🔒 Executando yarn audit..."
    yarn audit --level high || true
  elif [[ -f "pnpm-lock.yaml" ]] && command -v pnpm >/dev/null 2>&1; then
    echo "🔒 Executando pnpm audit..."
    pnpm audit --audit-level high || true
  fi
fi

# Verificar outros tipos de projeto
if ls $(changed) 2>/dev/null | grep -q 'pom.xml\|build.gradle'; then
  echo "Sugestao: usar OWASP Dependency-Check no CI. Local: pule ou use modo rápido."
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
