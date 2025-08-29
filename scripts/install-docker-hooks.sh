#!/usr/bin/env bash
set -euo pipefail

# 🐳 INSTALADOR DE HOOKS DOCKER
# Sistema de Git Hooks Centralizado com Docker

echo "🐳 INSTALANDO HOOKS DOCKER PARA GIT"
echo "===================================="

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

# Verificar requisitos
check_requirements() {
    log "INFO" "Verificando requisitos..."
    
    # Docker
    if ! command -v docker >/dev/null 2>&1; then
        log "ERROR" "Docker não encontrado!"
        log "ERROR" "Instale o Docker Desktop (Mac/Windows) ou Docker Engine (Linux)"
        log "ERROR" "https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Git
    if ! command -v git >/dev/null 2>&1; then
        log "ERROR" "Git não encontrado!"
        exit 1
    fi
    
    # pre-commit
    if ! command -v pre-commit >/dev/null 2>&1; then
        log "WARNING" "pre-commit não encontrado. Instalando..."
        if command -v pip3 >/dev/null 2>&1; then
            pip3 install pre-commit
        elif command -v pip >/dev/null 2>&1; then
            pip install pre-commit
        else
            log "ERROR" "pip não encontrado. Instale o Python primeiro."
            exit 1
        fi
    fi
    
    log "SUCCESS" "Todos os requisitos atendidos!"
}

# Construir imagem Docker
build_docker_image() {
    log "INFO" "Construindo imagem Docker para hooks..."
    
    # Verificar se Dockerfile existe
    if [[ ! -f "docker/Dockerfile.hooks" ]]; then
        log "ERROR" "Dockerfile.hooks não encontrado em docker/"
        exit 1
    fi
    
    # Construir imagem
    if docker build -f docker/Dockerfile.hooks -t git-hooks-central:latest docker/; then
        log "SUCCESS" "Imagem Docker construída com sucesso!"
    else
        log "ERROR" "Falha ao construir imagem Docker"
        exit 1
    fi
}

# Testar imagem Docker
test_docker_image() {
    log "INFO" "Testando imagem Docker..."
    
    # Executar teste simples
    if docker run --rm git-hooks-central:latest echo "✅ Docker funcionando!"; then
        log "SUCCESS" "Imagem Docker testada com sucesso!"
    else
        log "ERROR" "Falha ao testar imagem Docker"
        exit 1
    fi
}

# Configurar pre-commit
setup_precommit() {
    log "INFO" "Configurando pre-commit..."
    
    # Verificar se .pre-commit-config.yaml existe
    if [[ ! -f ".pre-commit-config.yaml" ]]; then
        log "WARNING" ".pre-commit-config.yaml não encontrado"
        log "INFO" "Copiando configuração de exemplo..."
        cp examples/pre-commit-config-node.yaml .pre-commit-config.yaml
    fi
    
    # Instalar hooks
    if pre-commit install --hook-type pre-push; then
        log "SUCCESS" "Hooks pre-commit instalados!"
    else
        log "ERROR" "Falha ao instalar hooks pre-commit"
        exit 1
    fi
}

# Criar script de inicialização
create_init_script() {
    log "INFO" "Criando script de inicialização..."
    
    cat > scripts/init-docker-hooks.sh << 'EOF'
#!/usr/bin/env bash
# Script de inicialização para hooks Docker

echo "🚀 Inicializando hooks Docker..."

# Verificar se Docker está rodando
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker não está rodando. Inicie o Docker Desktop ou Docker daemon."
    exit 1
fi

# Verificar se imagem existe
if ! docker image inspect git-hooks-central:latest >/dev/null 2>&1; then
    echo "🔨 Construindo imagem Docker..."
    docker build -f docker/Dockerfile.hooks -t git-hooks-central:latest docker/
fi

echo "✅ Hooks Docker prontos para uso!"
echo "💡 Use: git push (hooks executam automaticamente)"
EOF

    chmod +x scripts/init-docker-hooks.sh
    log "SUCCESS" "Script de inicialização criado!"
}

# Mostrar instruções de uso
show_usage() {
    echo ""
    echo "🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo "====================================="
    echo ""
    echo "📋 PRÓXIMOS PASSOS:"
    echo ""
    echo "1. Inicializar hooks Docker:"
    echo "   ./scripts/init-docker-hooks.sh"
    echo ""
    echo "2. Fazer push (hooks executam automaticamente):"
    echo "   git add ."
    echo "   git commit -m 'Teste hooks Docker'"
    echo "   git push"
    echo ""
    echo "3. Para testar manualmente:"
    echo "   pre-commit run --all-files --hook-stage push"
    echo ""
    echo "🔧 CONFIGURAÇÃO:"
    echo "- Hooks executam dentro de container Docker"
    echo "- Compatível com Mac, Linux e Windows"
    echo "- Todas as ferramentas pré-instaladas"
    echo ""
    echo "📚 DOCUMENTAÇÃO:"
    echo "- docs/PRESENTATION_RUNBOOK.md"
    echo "- docs/USAGE.md"
    echo ""
}

# Função principal
main() {
    echo ""
    log "INFO" "Iniciando instalação dos hooks Docker..."
    echo ""
    
    # Verificar requisitos
    check_requirements
    echo ""
    
    # Construir imagem Docker
    build_docker_image
    echo ""
    
    # Testar imagem
    test_docker_image
    echo ""
    
    # Configurar pre-commit
    setup_precommit
    echo ""
    
    # Criar script de inicialização
    create_init_script
    echo ""
    
    # Mostrar instruções
    show_usage
}

# Executar instalação
main "$@"
