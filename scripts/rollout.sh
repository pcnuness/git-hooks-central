#!/usr/bin/env bash
set -euo pipefail

# Script de Rollout para Git Hooks Central
# Uso: ./scripts/rollout.sh [vX.Y.Z]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Função para verificar se estamos no branch correto
check_branch() {
    local current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "main" ]]; then
        log "ERROR" "Você deve estar no branch 'main' para fazer rollout. Atual: $current_branch"
        exit 1
    fi
}

# Função para verificar se há mudanças não commitadas
check_working_directory() {
    if ! git diff-index --quiet HEAD --; then
        log "WARNING" "Há mudanças não commitadas no working directory"
        git status --short
        read -p "Continuar mesmo assim? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Função para verificar se a tag já existe
check_tag_exists() {
    local version=$1
    if git tag -l | grep -q "^$version$"; then
        log "ERROR" "A tag $version já existe"
        exit 1
    fi
}

# Função para executar testes
run_tests() {
    log "INFO" "Executando testes..."
    
    # Verificar se pre-commit está instalado
    if ! command -v pre-commit &> /dev/null; then
        log "WARNING" "pre-commit não está instalado. Instalando..."
        pip install pre-commit
    fi
    
    # Executar hooks
    cd "$PROJECT_ROOT"
    pre-commit run --all-files --hook-stage push -v
    
    log "SUCCESS" "Testes executados com sucesso"
}

# Função para criar e fazer push da tag
create_tag() {
    local version=$1
    local message="Release $version"
    
    log "INFO" "Criando tag $version..."
    git tag -a "$version" -m "$message"
    
    log "INFO" "Fazendo push da tag..."
    git push origin "$version"
    
    log "SUCCESS" "Tag $version criada e enviada com sucesso"
}

# Função para atualizar arquivos de exemplo
update_examples() {
    local version=$1
    
    log "INFO" "Atualizando arquivos de exemplo com versão $version..."
    
    # Atualizar versões nos exemplos
    find "$PROJECT_ROOT/examples" -name "*.yaml" -type f -exec sed -i.bak "s/rev: v[0-9]\+\.[0-9]\+\.[0-9]\+/rev: $version/g" {} \;
    
    # Remover arquivos .bak
    find "$PROJECT_ROOT/examples" -name "*.bak" -type f -delete
    
    log "SUCCESS" "Arquivos de exemplo atualizados"
}

# Função para gerar changelog
generate_changelog() {
    local version=$1
    local changelog_file="$PROJECT_ROOT/CHANGELOG.md"
    
    log "INFO" "Gerando changelog..."
    
    # Criar CHANGELOG.md se não existir
    if [[ ! -f "$changelog_file" ]]; then
        cat > "$changelog_file" << EOF
# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

## [$version] - $(date +%Y-%m-%d)

### Added
- Nova funcionalidade

### Changed
- Mudança em funcionalidade existente

### Deprecated
- Funcionalidade que será removida em breve

### Removed
- Funcionalidade removida

### Fixed
- Correção de bug

### Security
- Correção de vulnerabilidade de segurança

EOF
    else
        # Adicionar nova versão no topo
        sed -i.bak "1i\\\n## [$version] - $(date +%Y-%m-%d)\\n\\n### Added\\n- Nova funcionalidade\\n\\n### Changed\\n- Mudança em funcionalidade existente\\n\\n### Fixed\\n- Correção de bug\\n\\n" "$changelog_file"
        rm "${changelog_file}.bak"
    fi
    
    log "SUCCESS" "Changelog atualizado"
}

# Função para mostrar resumo do rollout
show_summary() {
    local version=$1
    
    log "SUCCESS" "Rollout da versão $version concluído com sucesso!"
    echo
    echo "📋 Resumo do que foi feito:"
    echo "   ✅ Testes executados"
    echo "   ✅ Tag $version criada e enviada"
    echo "   ✅ Arquivos de exemplo atualizados"
    echo "   ✅ Changelog atualizado"
    echo
    echo "🚀 Próximos passos:"
    echo "   1. Verificar se a tag foi criada: git tag -l | grep $version"
    echo "   2. Verificar se o push foi feito: git ls-remote --tags origin | grep $version"
    echo "   3. Atualizar documentação se necessário"
    echo "   4. Notificar equipes sobre a nova versão"
    echo
    echo "📚 Para consumidores atualizarem:"
    echo "   - Alterar rev: para '$version' no .pre-commit-config.yaml"
    echo "   - Executar: pre-commit clean && pre-commit install --hook-type pre-push"
}

# Função principal
main() {
    local version=${1:-}
    
    if [[ -z "$version" ]]; then
        log "ERROR" "Uso: $0 [vX.Y.Z]"
        log "INFO" "Exemplo: $0 v1.1.0"
        exit 1
    fi
    
    # Validar formato da versão
    if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log "ERROR" "Formato de versão inválido. Use: vX.Y.Z (ex: v1.1.0)"
        exit 1
    fi
    
    log "INFO" "Iniciando rollout da versão $version..."
    
    # Verificações pré-rollout
    check_branch
    check_working_directory
    check_tag_exists "$version"
    
    # Executar rollout
    run_tests
    update_examples "$version"
    generate_changelog "$version"
    create_tag "$version"
    
    # Mostrar resumo
    show_summary "$version"
}

# Executar script
main "$@"
