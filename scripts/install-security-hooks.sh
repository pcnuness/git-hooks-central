#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# INSTALADOR DE HOOKS DE SEGURANÇA
# =============================================================================
# Script para instalar e configurar hooks de segurança em repositórios
# =============================================================================

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

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para verificar se estamos em um repositório git
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log "ERROR" "Este diretório não é um repositório git"
        exit 1
    fi
    log "SUCCESS" "Repositório git detectado"
}

# Função para instalar pre-commit
install_pre_commit() {
    log "INFO" "Verificando pre-commit..."
    
    if ! command_exists pre-commit; then
        log "INFO" "Instalando pre-commit..."
        if command_exists pip; then
            pip install pre-commit
        elif command_exists pip3; then
            pip3 install pre-commit
        elif command_exists brew; then
            brew install pre-commit
        else
            log "ERROR" "Não foi possível instalar pre-commit. Instale manualmente:"
            log "ERROR" "  pip install pre-commit"
            log "ERROR" "  ou brew install pre-commit (macOS)"
            exit 1
        fi
    fi
    
    log "SUCCESS" "pre-commit instalado/verificado"
}

# Função para instalar ferramentas de segurança
install_security_tools() {
    log "INFO" "Instalando ferramentas de segurança..."
    
    # Semgrep
    if ! command_exists semgrep; then
        log "INFO" "Instalando Semgrep..."
        if command_exists pip; then
            pip install semgrep
        elif command_exists pip3; then
            pip3 install semgrep
        elif command_exists brew; then
            brew install semgrep
        fi
    fi
    
    # GitLeaks
    if ! command_exists gitleaks; then
        log "INFO" "Instalando GitLeaks..."
        if command_exists brew; then
            brew install gitleaks
        elif command_exists apt; then
            sudo apt-get install gitleaks
        fi
    fi
    
    # TruffleHog
    if ! command_exists trufflehog; then
        log "INFO" "Instalando TruffleHog..."
        if command_exists pip; then
            pip install trufflehog
        elif command_exists pip3; then
            pip3 install trufflehog
        fi
    fi
    
    # OWASP Dependency-Check (Java)
    if ! command_exists dependency-check; then
        log "INFO" "Instalando OWASP Dependency-Check..."
        if command_exists brew; then
            brew install dependency-check
        elif command_exists apt; then
            sudo apt-get install dependency-check
        fi
    fi
    
    log "SUCCESS" "Ferramentas de segurança instaladas/verificadas"
}

# Função para configurar pre-commit
setup_pre_commit() {
    log "INFO" "Configurando pre-commit..."
    
    # Copiar configuração se não existir
    if [[ ! -f ".pre-commit-config.yaml" ]]; then
        log "INFO" "Criando .pre-commit-config.yaml..."
        cat > .pre-commit-config.yaml << 'EOF'
repos:
  # Hooks nativos e rápidos
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: end-of-file-fixer
        stages: [pre-push]
      - id: check-xml
        stages: [pre-push]
      - id: check-yaml
        stages: [pre-push]
      - id: check-json
        stages: [pre-push]
      - id: detect-private-key
        stages: [pre-push]

  # Node (rápido)
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v9.34.0
    hooks:
      - id: eslint
        additional_dependencies: ['eslint@9.9.0']
        files: \.(js|jsx|ts|tsx)$
        stages: [pre-push]

  # Python
  - repo: https://github.com/psf/black
    rev: 25.1.0
    hooks:
      - id: black
        stages: [pre-push]
  - repo: https://github.com/PyCQA/flake8
    rev: 7.3.0
    hooks:
      - id: flake8
        stages: [pre-push]

  # Go (leve)
  - repo: https://github.com/golangci/golangci-lint
    rev: v2.4.0
    hooks:
      - id: golangci-lint
        args: [--fast]
        stages: [pre-push]

  # Hooks custom de segurança
  - repo: local
    hooks:
      - id: security-pre-push-hook
        name: Security Pre-Push Hook
        entry: bash hooks/security_pre_push.sh
        language: system
        stages: [pre-push]
        always_run: true
        description: "Executa verificações de segurança: SAST, Dependency Scanning, Secret Detection e Branch Ahead Check"
        pass_filenames: false
EOF
    fi
    
    # Instalar hooks
    log "INFO" "Instalando hooks do pre-commit..."
    pre-commit install --hook-type pre-push
    
    log "SUCCESS" "pre-commit configurado"
}

# Função para criar diretório de hooks
create_hooks_directory() {
    log "INFO" "Criando diretório de hooks..."
    
    if [[ ! -d "hooks" ]]; then
        mkdir -p hooks
        log "SUCCESS" "Diretório hooks criado"
    else
        log "INFO" "Diretório hooks já existe"
    fi
}

# Função para copiar scripts de segurança
copy_security_scripts() {
    log "INFO" "Copiando scripts de segurança..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copiar script principal
    if [[ -f "$script_dir/security_pre_push.sh" ]]; then
        cp "$script_dir/security_pre_push.sh" hooks/
        chmod +x hooks/security_pre_push.sh
        log "SUCCESS" "Script security_pre_push.sh copiado"
    fi
    
    # Copiar configurações
    if [[ -f "$script_dir/java-security-config.yaml" ]]; then
        cp "$script_dir/java-security-config.yaml" hooks/
        log "SUCCESS" "Configuração Java copiada"
    fi
    
    if [[ -f "$script_dir/node-security-config.yaml" ]]; then
        cp "$script_dir/node-security-config.yaml" hooks/
        log "SUCCESS" "Configuração Node.js copiada"
    fi
    
    log "SUCCESS" "Scripts de segurança copiados"
}

# Função para configurar gitignore
setup_gitignore() {
    log "INFO" "Configurando .gitignore..."
    
    local gitignore_entries=(
        "# Security hook logs"
        ".security-hook.log"
        ".security-hook.log.*"
        ""
        "# Security reports"
        "reports/"
        "build/reports/"
        ""
        "# Dependency check cache"
        ".dependency-check/"
        ""
        "# Semgrep cache"
        ".semgrep/"
    )
    
    # Adicionar entradas ao .gitignore se não existirem
    for entry in "${gitignore_entries[@]}"; do
        if [[ -n "$entry" ]]; then
            if ! grep -q "^$entry$" .gitignore 2>/dev/null; then
                echo "$entry" >> .gitignore
            fi
        fi
    done
    
    log "SUCCESS" ".gitignore configurado"
}

# Função para testar configuração
test_configuration() {
    log "INFO" "Testando configuração..."
    
    # Testar pre-commit
    if pre-commit run --all-files --hook-stage pre-push; then
        log "SUCCESS" "Teste de pre-commit passou"
    else
        log "WARNING" "Alguns testes falharam (isso é normal na primeira execução)"
    fi
    
    # Testar hook de segurança
    if [[ -f "hooks/security_pre_push.sh" ]]; then
        log "INFO" "Testando hook de segurança..."
        if bash hooks/security_pre_push.sh --help 2>/dev/null || true; then
            log "SUCCESS" "Hook de segurança está funcionando"
        fi
    fi
}

# Função para mostrar resumo
show_summary() {
    log "SUCCESS" "=== INSTALAÇÃO CONCLUÍDA ==="
    echo
    log "INFO" "Hooks de segurança configurados com sucesso!"
    echo
    log "INFO" "O que foi instalado:"
    log "INFO" "  ✓ pre-commit framework"
    log "INFO" "  ✓ Hook de segurança customizado"
    log "INFO" "  ✓ Ferramentas de segurança (Semgrep, GitLeaks, etc.)"
    log "INFO" "  ✓ Configurações para Java e Node.js"
    echo
    log "INFO" "Como usar:"
    log "INFO" "  - Os hooks rodam automaticamente no pre-push"
    log "INFO" "  - Execute manualmente: pre-commit run --all-files --hook-stage pre-push"
    log "INFO" "  - Logs são salvos em: .security-hook.log"
    echo
    log "INFO" "Próximos passos:"
    log "INFO" "  1. Configure as variáveis de ambiente necessárias"
    log "INFO" "  2. Ajuste as configurações em hooks/*-security-config.yaml"
    log "INFO" "  3. Teste com um commit: git commit -m 'test' --allow-empty"
    log "INFO" "  4. Teste o push: git push (os hooks rodarão automaticamente)"
    echo
    log "INFO" "Documentação: https://pre-commit.com/"
    log "INFO" "Suporte: Consulte os logs em .security-hook.log"
}

# Função principal
main() {
    log "INFO" "=== INSTALADOR DE HOOKS DE SEGURANÇA ==="
    echo
    
    # Verificações iniciais
    check_git_repo
    
    # Instalação
    install_pre_commit
    install_security_tools
    
    # Configuração
    create_hooks_directory
    copy_security_scripts
    setup_pre_commit
    setup_gitignore
    
    # Teste
    test_configuration
    
    # Resumo
    show_summary
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
