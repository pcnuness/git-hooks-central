#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# SECRETS DETECTION WRAPPER - GitLab Analyzer (Multi-OS)
# =============================================================================
# Executa o GitLab Secrets Analyzer e força falha se detectar segredos
# Compatível com: Windows (WSL/Git Bash), Linux, macOS
# =============================================================================

IMAGE="registry.gitlab.com/gitlab-org/security-products/analyzers/secrets:latest"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
REPORT_FILE="gl-secret-detection-report.json"

# Cores (compatível com Windows)
if [[ "${TERM:-}" == "xterm-color" ]] || [[ "${TERM:-}" == "xterm-256color" ]] || [[ "${OSTYPE:-}" == "darwin"* ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

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
  
  # Executar analisador
  docker run --rm \
    -v "$PROJECT_ROOT:/code" \
    -w /code \
    "$IMAGE" /analyzer run \
    --full-scan \
    --excluded-paths=node_modules,dist,build,.git \
    --artifact-dir=/code
  
  # Verificar se relatório foi gerado
  if [[ ! -f "$PROJECT_ROOT/$REPORT_FILE" ]]; then
    log WARNING "Relatório não encontrado: $REPORT_FILE"
    return 0
  fi
  
  # Verificar se há vulnerabilidades (sem depender do jq)
  local vuln_count=0
  
  # Método 1: Tentar usar jq se disponível
  if command -v jq >/dev/null 2>&1; then
    vuln_count=$(jq '.vulnerabilities | length' "$PROJECT_ROOT/$REPORT_FILE" 2>/dev/null || echo "0")
  else
    # Método 2: Usar grep/sed como fallback (compatível com Windows)
    vuln_count=$(grep -c '"vulnerabilities"' "$PROJECT_ROOT/$REPORT_FILE" 2>/dev/null || echo "0")
    if [[ "$vuln_count" -gt 0 ]]; then
      # Contar objetos dentro do array vulnerabilities
      vuln_count=$(grep -o '"id":' "$PROJECT_ROOT/$REPORT_FILE" | wc -l 2>/dev/null || echo "0")
    fi
  fi
  
  if [[ "$vuln_count" -gt 0 ]]; then
    log ERROR "Secrets detectados: $vuln_count vulnerabilidade(s)"
    log ERROR "Arquivo: $REPORT_FILE"
    
    # Mostrar resumo das vulnerabilidades (sem jq se necessário)
    if command -v jq >/dev/null 2>&1; then
      jq -r '.vulnerabilities[] | "• \(.name) em \(.location.file):\(.location.start_line) (Severidade: \(.severity))"' "$PROJECT_ROOT/$REPORT_FILE" 2>/dev/null || true
    else
      # Fallback: mostrar arquivos com problemas
      grep -o '"file":"[^"]*"' "$PROJECT_ROOT/$REPORT_FILE" | sed 's/"file":"//g' | sed 's/"//g' | sort -u | while read -r file; do
        echo "• Arquivo com segredos: $file"
      done
    fi
    
    log ERROR "Revise e remova credenciais antes do push"
    log INFO "Dicas: rotacione chaves, use variáveis de ambiente, adicione ao .gitignore"
    return 1
  else
    log SUCCESS "Nenhum segredo sensível detectado"
    return 0
  fi
}

main() {
  require_docker
  pull_image_if_needed
  run_analyzer
}

main "$@"
