#!/usr/bin/env bash
set -euo pipefail

DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"  # ou master, parametrizável
git fetch origin "$DEFAULT_BRANCH" --quiet

# Se houver commits no default não presentes na HEAD do dev, falha:
if ! git merge-base --is-ancestor "origin/$DEFAULT_BRANCH" HEAD; then
  echo "❌ Sua branch não está atualizada com origin/$DEFAULT_BRANCH."
  echo "   Atualize antes de dar push: git pull --rebase origin $DEFAULT_BRANCH"
  exit 1
fi

echo "✅ Branch atualizada em relação a origin/$DEFAULT_BRANCH."