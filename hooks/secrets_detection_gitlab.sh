#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# SECRETS DETECTION VIA GITLAB ANALYZER (Docker)
# =============================================================================
# Executa a imagem oficial do GitLab Secrets Analyzer antes do push
# Requisitos: Docker instalado e em execução
# =============================================================================

IMAGE="registry.gitlab.com/gitlab-org/security-products/analyzers/secrets:latest"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log() {
  case "$1" in
    INFO) echo -e "${BLUE}[INFO]${NC} $2" ;;
    SUCCESS) echo -e "${GREEN}[SUCCESS]${NC} $2" ;;
    WARNING) echo -e "${YELLOW}[WARNING]${NC} $2" ;;
    ERROR) echo -e "${RED}[ERROR]${NC} $2" ;;
  esac
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    log ERROR "Docker não encontrado. Instale Docker Desktop/Engine."
    exit 1
  fi
  if ! docker info >/dev/null 2>&1; then
    log ERROR "Docker não está em execução. Inicie o Docker Desktop/daemon."
    exit 1
  fi
}

pull_image_if_needed() {
  if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    log INFO "Baixando imagem do GitLab Secrets Analyzer..."
    docker pull "$IMAGE" >/dev/null
  fi
}

run_analyzer() {
  log INFO "Executando GitLab Secrets Analyzer..."
  # Monta o repo no /code e roda o analisador padrão
  # O analisador utiliza o git internamente para identificar alterações
  if docker run --rm \
    -v "$PROJECT_ROOT:/code" \
    -w /code \
    "$IMAGE" ./analyzer run; then
    log SUCCESS "Nenhum segredo sensível detectado"
    return 0
  else
    log ERROR "Secrets detectados. Revise e remova credenciais antes do push."
    log INFO "Dicas: rotacione chaves, use variáveis de ambiente, adicione ao .gitignore"
    return 1
  fi
}

main() {
  require_docker
  pull_image_if_needed
  run_analyzer
}

main "$@"
