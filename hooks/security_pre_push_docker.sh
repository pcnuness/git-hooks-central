#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# SECURITY PRE-PUSH HOOK - DOCKER WRAPPER
# =============================================================================
# Executa verificações de segurança dentro de container Docker
# Garante compatibilidade Mac/Linux/Windows
# =============================================================================

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
DOCKER_IMAGE="git-hooks-central:latest"
DOCKER_CONTAINER="git-hooks-$(date +%s)"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função de logging
log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# Função para verificar se Docker está disponível
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        log "ERROR" "Docker não encontrado. Instale o Docker Desktop ou Docker Engine."
        log "ERROR" "https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log "ERROR" "Docker não está rodando. Inicie o Docker Desktop ou Docker daemon."
        exit 1
    fi
    
    log "SUCCESS" "Docker disponível e funcionando"
}

# Função para construir imagem Docker se necessário
build_docker_image() {
    if ! docker image inspect "$DOCKER_IMAGE" >/dev/null 2>&1; then
        log "INFO" "Construindo imagem Docker para hooks..."
        
        # Navegar para diretório com Dockerfile
        cd "$SCRIPT_DIR/../docker" || {
            log "ERROR" "Diretório docker/ não encontrado"
            exit 1
        }
        
        # Construir imagem
        if docker build -f Dockerfile.hooks -t "$DOCKER_IMAGE" .; then
            log "SUCCESS" "Imagem Docker construída com sucesso"
        else
            log "ERROR" "Falha ao construir imagem Docker"
            exit 1
        fi
        
        # Voltar ao diretório original
        cd "$PROJECT_ROOT" || exit 1
    else
        log "INFO" "Imagem Docker já existe"
    fi
}

# Função para executar hook dentro do container
run_hook_in_docker() {
    local hook_script="$1"
    local hook_name="$2"
    
    log "INFO" "Executando $hook_name via Docker..."
    
    # Executar script dentro do container
    if docker run --rm \
        --name "$DOCKER_CONTAINER" \
        -v "$PROJECT_ROOT:/workspace" \
        -v "$HOME/.gitconfig:/root/.gitconfig:ro" \
        -w /workspace \
        -e GIT_AUTHOR_NAME="$(git config user.name || echo 'Git Hooks')" \
        -e GIT_AUTHOR_EMAIL="$(git config user.email || echo 'hooks@example.com')" \
        -e GIT_COMMITTER_NAME="$(git config user.name || echo 'Git Hooks')" \
        -e GIT_COMMITTER_EMAIL="$(git config user.email || echo 'hooks@example.com')" \
        "$DOCKER_IMAGE" \
        "/hooks/$hook_script"; then
        
        log "SUCCESS" "$hook_name executado com sucesso"
        return 0
    else
        log "ERROR" "$hook_name falhou"
        return 1
    fi
}

# Função principal
main() {
    log "INFO" "=== INICIANDO VERIFICAÇÕES DE SEGURANÇA PRE-PUSH (DOCKER) ==="
    
    # Verificar Docker
    check_docker
    
    # Construir imagem se necessário
    build_docker_image
    
    # Executar hooks em sequência
    local exit_code=0
    
    # 1. Branch Ahead Check
    if ! run_hook_in_docker "branch_ahead_check.sh" "Branch Ahead Check"; then
        exit_code=1
    fi
    
    # 2. Security Pre-Push Hook (versão Docker)
    if ! run_hook_in_docker "security_pre_push.sh" "Security Pre-Push Hook"; then
        exit_code=1
    fi
    
    # 3. Dependency Audit
    if ! run_hook_in_docker "deps_audit_fast.sh" "Dependency Audit"; then
        exit_code=1
    fi
    
    # 4. Audit Trail
    if ! run_hook_in_docker "audit_trail.sh" "Audit Trail"; then
        exit_code=1
    fi
    
    # Resumo final
    if [[ $exit_code -eq 0 ]]; then
        log "SUCCESS" "=== TODAS AS VERIFICAÇÕES DE SEGURANÇA PASSARAM ==="
    else
        log "ERROR" "=== ALGUMAS VERIFICAÇÕES DE SEGURANÇA FALHARAM ==="
        log "ERROR" "Corrija os problemas antes de fazer push"
    fi
    
    return $exit_code
}

# Tratamento de erros
trap 'log "ERROR" "Hook interrompido"; exit 1' INT TERM

# Executar hook
main "$@"
