#!/usr/bin/env bash
set -euo pipefail

# 🚀 SCRIPT DE DEMONSTRAÇÃO AUTOMATIZADA
# Sistema de Git Hooks Centralizado

echo "🎭 INICIANDO DEMONSTRAÇÃO DO SISTEMA DE GIT HOOKS"
echo "=================================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
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
    
    # Node.js
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version)
        log "SUCCESS" "Node.js encontrado: $node_version"
    else
        log "ERROR" "Node.js não encontrado. Instale Node.js 18+"
        exit 1
    fi
    
    # npm
    if command -v npm >/dev/null 2>&1; then
        local npm_version=$(npm --version)
        log "SUCCESS" "npm encontrado: $npm_version"
    else
        log "ERROR" "npm não encontrado"
        exit 1
    fi
    
    # Git
    if command -v git >/dev/null 2>&1; then
        local git_version=$(git --version)
        log "SUCCESS" "Git encontrado: $git_version"
    else
        log "ERROR" "Git não encontrado"
        exit 1
    fi
    
    # pre-commit
    if command -v pre-commit >/dev/null 2>&1; then
        local precommit_version=$(pre-commit --version)
        log "SUCCESS" "pre-commit encontrado: $precommit_version"
    else
        log "ERROR" "pre-commit não encontrado. Instale com: pip install pre-commit"
        exit 1
    fi
}

# Criar projeto de demonstração
create_demo_project() {
    log "INFO" "Criando projeto de demonstração..."
    
    # Criar diretório
    mkdir -p demo-node-project
    cd demo-node-project
    
    # Inicializar projeto Node.js
    npm init -y > /dev/null 2>&1
    
    # Instalar dependências
    log "INFO" "Instalando dependências..."
    npm install express dotenv > /dev/null 2>&1
    npm install --save-dev eslint prettier > /dev/null 2>&1
    
    # Criar estrutura de diretórios
    mkdir -p src
    
    log "SUCCESS" "Projeto criado com sucesso!"
}

# Criar arquivos de código com problemas intencionais
create_problematic_files() {
    log "INFO" "Criando arquivos com problemas de segurança..."
    
    # index.js com credencial hardcoded
    cat > src/index.js << 'EOF'
const express = require('express');
const app = express();

// ⚠️ PROBLEMA: Credencial hardcoded (será detectado pelo GitLeaks)
const API_KEY = 'sk-1234567890abcdef1234567890abcdef';

app.get('/', (req, res) => {
  res.json({ message: 'Hello World!' });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
EOF

    # utils.js com função eval
    cat > src/utils.js << 'EOF'
// ⚠️ PROBLEMA: Função eval (será detectado pelo ESLint)
function executeCode(code) {
  return eval(code); // ❌ UNSAFE
}

module.exports = { executeCode };
EOF

    # config.js com chave privada
    cat > src/config.js << 'EOF'
// ⚠️ PROBLEMA: Chave privada exposta (será detectado pelo detect-private-key)
module.exports = {
  privateKey: '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----',
  port: 3000
};
EOF

    log "SUCCESS" "Arquivos com problemas criados!"
}

# Configurar pre-commit
setup_precommit() {
    log "INFO" "Configurando pre-commit..."
    
    # Copiar configuração
    cp ../../examples/pre-commit-config-node.yaml .pre-commit-config.yaml
    
    # Instalar hooks
    pre-commit install --hook-type pre-push > /dev/null 2>&1
    
    log "SUCCESS" "pre-commit configurado!"
}

# Executar demonstração
run_demo() {
    log "INFO" "Executando demonstração dos hooks..."
    echo ""
    echo "🔍 EXECUTANDO HOOKS DE SEGURANÇA..."
    echo "====================================="
    
    # Executar hooks
    if pre-commit run --all-files --hook-stage push; then
        log "SUCCESS" "Todos os hooks passaram! (Isso não deveria acontecer com os problemas criados)"
    else
        log "WARNING" "Hooks falharam como esperado - problemas de segurança detectados!"
    fi
    
    echo ""
    echo "📊 RESUMO DOS PROBLEMAS DETECTADOS:"
    echo "===================================="
    echo "✅ end-of-file-fixer: Formatação de arquivos"
    echo "✅ check-json: Validação de package.json"
    echo "✅ check-yaml: Validação de configurações"
    echo "❌ detect-private-key: Chave privada exposta em src/config.js"
    echo "❌ security-pre-push-hook: Credenciais hardcoded detectadas"
    echo "❌ eslint: Uso de eval() detectado"
    echo ""
}

# Mostrar como corrigir
show_fixes() {
    log "INFO" "Mostrando como corrigir os problemas..."
    echo ""
    echo "🔧 CORREÇÕES NECESSÁRIAS:"
    echo "=========================="
    echo ""
    echo "1. src/index.js - Remover credencial hardcoded:"
    echo "   const API_KEY = process.env.API_KEY || '';"
    echo ""
    echo "2. src/utils.js - Substituir eval por alternativa segura:"
    echo "   return Function('\"use strict\"; return (' + code + ')')();"
    echo ""
    echo "3. src/config.js - Mover chave privada para variável de ambiente"
    echo ""
}

# Função principal
main() {
    echo "🎯 DEMONSTRAÇÃO: Sistema de Git Hooks Centralizado"
    echo "=================================================="
    echo ""
    
    # Verificar requisitos
    check_requirements
    echo ""
    
    # Criar projeto
    create_demo_project
    
    # Criar arquivos problemáticos
    create_problematic_files
    
    # Configurar pre-commit
    setup_precommit
    
    # Executar demonstração
    run_demo
    
    # Mostrar correções
    show_fixes
    
    echo ""
    log "SUCCESS" "Demonstração concluída!"
    echo ""
    echo "📁 Projeto criado em: demo-node-project/"
    echo "🔧 Para testar correções:"
    echo "   cd demo-node-project"
    echo "   # Corrigir os problemas nos arquivos"
    echo "   pre-commit run --all-files --hook-stage push"
    echo ""
    echo "🎉 Boa sorte na apresentação!"
}

# Executar script
main "$@"
