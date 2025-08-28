#!/usr/bin/env bash
set -euo pipefail

# Script de Teste para Git Hooks Central
# Uso: ./scripts/test-hooks.sh [--verbose] [--clean]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Flags
VERBOSE=false
CLEAN=false

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    local level=$1
    shift
    case $level in
        "INFO") echo -e "${BLUE}[INFO]${NC} $*" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $*" ;;
        "WARNING") echo -e "${YELLOW}[WARNING]${NC} $*" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $*" ;;
    esac
}

# Função para mostrar ajuda
show_help() {
    cat << EOF
Uso: $0 [OPÇÕES]

OPÇÕES:
    -v, --verbose    Executar com output detalhado
    -c, --clean      Limpar cache antes dos testes
    -h, --help       Mostrar esta ajuda

EXEMPLOS:
    $0                    # Teste básico
    $0 --verbose         # Teste com output detalhado
    $0 --clean          # Limpar cache e testar
    $0 -v -c            # Verbose + clean

EOF
}

# Função para processar argumentos
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -c|--clean)
                CLEAN=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log "ERROR" "Argumento desconhecido: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Função para verificar dependências
check_dependencies() {
    log "INFO" "Verificando dependências..."
    
    local missing_deps=()
    
    # Verificar pre-commit
    if ! command -v pre-commit &> /dev/null; then
        missing_deps+=("pre-commit")
    fi
    
    # Verificar jq
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    # Verificar git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log "ERROR" "Dependências faltando: ${missing_deps[*]}"
        log "INFO" "Instale com: pip install pre-commit && brew install jq"
        exit 1
    fi
    
    log "SUCCESS" "Todas as dependências estão instaladas"
}

# Função para limpar cache
clean_cache() {
    if [[ "$CLEAN" == "true" ]]; then
        log "INFO" "Limpando cache..."
        pre-commit clean
        log "SUCCESS" "Cache limpo"
    fi
}

# Função para instalar hooks
install_hooks() {
    log "INFO" "Instalando hooks pre-push..."
    cd "$PROJECT_ROOT"
    pre-commit install --hook-type pre-push
    log "SUCCESS" "Hooks instalados"
}

# Função para testar hooks individuais
test_individual_hooks() {
    log "INFO" "Testando hooks individuais..."
    
    local hooks=("audit-trail" "branch-ahead-check" "deps-audit-fast" "sast-semantic-fast")
    local failed_hooks=()
    
    for hook in "${hooks[@]}"; do
        log "INFO" "Testando hook: $hook"
        
        if [[ "$VERBOSE" == "true" ]]; then
            if pre-commit run "$hook" --all-files --hook-stage push -v; then
                log "SUCCESS" "Hook $hook passou"
            else
                log "ERROR" "Hook $hook falhou"
                failed_hooks+=("$hook")
            fi
        else
            if pre-commit run "$hook" --all-files --hook-stage push --quiet; then
                log "SUCCESS" "Hook $hook passou"
            else
                log "ERROR" "Hook $hook falhou"
                failed_hooks+=("$hook")
            fi
        fi
    done
    
    if [[ ${#failed_hooks[@]} -gt 0 ]]; then
        log "ERROR" "Hooks que falharam: ${failed_hooks[*]}"
        return 1
    fi
    
    log "SUCCESS" "Todos os hooks individuais passaram"
}

# Função para testar todos os hooks juntos
test_all_hooks() {
    log "INFO" "Testando todos os hooks juntos..."
    
    local start_time=$(date +%s)
    
    if [[ "$VERBOSE" == "true" ]]; then
        if pre-commit run --all-files --hook-stage push -v; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log "SUCCESS" "Todos os hooks passaram em ${duration}s"
        else
            log "ERROR" "Alguns hooks falharam"
            return 1
        fi
    else
        if pre-commit run --all-files --hook-stage push --quiet; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            log "SUCCESS" "Todos os hooks passaram em ${duration}s"
        else
            log "ERROR" "Alguns hooks falharam"
            return 1
        fi
    fi
}

# Função para verificar artefato de auditoria
check_audit_artifact() {
    log "INFO" "Verificando artefato de auditoria..."
    
    local artifact_file=".git/hooks_artifacts/prepush.json"
    
    if [[ ! -f "$artifact_file" ]]; then
        log "ERROR" "Artefato de auditoria não encontrado: $artifact_file"
        return 1
    fi
    
    log "INFO" "Artefato encontrado:"
    cat "$artifact_file" | jq '.'
    
    # Validar estrutura
    if jq -e '.commit and .author and .date and .precommit_config_sha1 and .status == "passed-local"' "$artifact_file" > /dev/null; then
        log "SUCCESS" "Artefato de auditoria é válido"
    else
        log "ERROR" "Artefato de auditoria tem estrutura inválida"
        return 1
    fi
}

# Função para verificar permissões dos scripts
check_script_permissions() {
    log "INFO" "Verificando permissões dos scripts..."
    
    local scripts_dir="$PROJECT_ROOT/hooks"
    local scripts_without_exec=()
    
    while IFS= read -r -d '' script; do
        if [[ ! -x "$script" ]]; then
            scripts_without_exec+=("$script")
        fi
    done < <(find "$scripts_dir" -name "*.sh" -type f -print0)
    
    if [[ ${#scripts_without_exec[@]} -gt 0 ]]; then
        log "WARNING" "Scripts sem permissão de execução:"
        for script in "${scripts_without_exec[@]}"; do
            echo "  - $script"
        done
        
        log "INFO" "Corrigindo permissões..."
        chmod +x "${scripts_without_exec[@]}"
        log "SUCCESS" "Permissões corrigidas"
    else
        log "SUCCESS" "Todos os scripts têm permissão de execução"
    fi
}

# Função para mostrar resumo dos testes
show_test_summary() {
    log "SUCCESS" "Testes concluídos com sucesso!"
    echo
    echo "📋 Resumo dos testes:"
    echo "   ✅ Dependências verificadas"
    echo "   ✅ Hooks instalados"
    echo "   ✅ Hooks individuais testados"
    echo "   ✅ Todos os hooks testados juntos"
    echo "   ✅ Artefato de auditoria validado"
    echo "   ✅ Permissões dos scripts verificadas"
    echo
    echo "🚀 Sistema pronto para uso!"
    echo
    echo "📚 Comandos úteis:"
    echo "   - Executar hooks: pre-commit run --all-files --hook-stage push"
    echo "   - Limpar cache: pre-commit clean"
    echo "   - Ver status: pre-commit run --all-files --hook-stage push --show-diff-on-failure"
}

# Função principal
main() {
    parse_args "$@"
    
    log "INFO" "Iniciando testes dos Git Hooks Central..."
    echo
    
    # Executar testes
    check_dependencies
    clean_cache
    install_hooks
    check_script_permissions
    test_individual_hooks
    test_all_hooks
    check_audit_artifact
    
    # Mostrar resumo
    show_test_summary
}

# Executar script
main "$@"
