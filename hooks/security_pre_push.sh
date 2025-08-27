#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# SECURITY PRE-PUSH HOOK
# =============================================================================
# Executa verificações de segurança e conformidade para Java e Node
# Compatível com: Java 8+, Node 16+, npm 8+, yarn 1.22+
# =============================================================================

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
LOG_FILE="${PROJECT_ROOT}/.security-hook.log"
TIMEOUT_SECONDS=300
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

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
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para detectar o tipo de projeto
detect_project_type() {
    if [[ -f "pom.xml" || -f "build.gradle" || -f "build.gradle.kts" ]]; then
        echo "java"
    elif [[ -f "package.json" ]]; then
        echo "node"
    else
        echo "unknown"
    fi
}

# Função para verificar versões das ferramentas
check_versions() {
    log "INFO" "Verificando versões das ferramentas..."
    
    # Java
    if command_exists java; then
        local java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        log "INFO" "Java version: $java_version"
        
        # Extrair versão principal (ex: 8, 11, 17)
        local major_version=$(echo "$java_version" | cut -d'.' -f1 | sed 's/[^0-9]//g')
        if [[ "$major_version" -lt 8 ]]; then
            log "WARNING" "Java $major_version detectado. Recomendado: Java 8+"
        fi
    else
        log "WARNING" "Java não encontrado"
    fi
    
    # Node
    if command_exists node; then
        local node_version=$(node --version)
        log "INFO" "Node version: $node_version"
        
        # Extrair versão principal
        local major_version=$(echo "$node_version" | cut -d'v' -f2 | cut -d'.' -f1)
        if [[ "$major_version" -lt 16 ]]; then
            log "WARNING" "Node $major_version detectado. Recomendado: Node 16+"
        fi
    else
        log "WARNING" "Node não encontrado"
    fi
    
    # npm
    if command_exists npm; then
        local npm_version=$(npm --version)
        log "INFO" "npm version: $npm_version"
    fi
}

# =============================================================================
# 1. BRANCH AHEAD CHECK
# =============================================================================
check_branch_ahead() {
    log "INFO" "Verificando se a branch está à frente da master..."
    
    # Fetch da branch padrão
    if ! git fetch origin "$DEFAULT_BRANCH" --quiet 2>/dev/null; then
        log "WARNING" "Não foi possível fazer fetch de origin/$DEFAULT_BRANCH"
        return 0
    fi
    
    # Verificar se há commits no default não presentes na HEAD
    if ! git merge-base --is-ancestor "origin/$DEFAULT_BRANCH" HEAD 2>/dev/null; then
        log "ERROR" "Sua branch não está atualizada com origin/$DEFAULT_BRANCH"
        log "ERROR" "Atualize antes de dar push: git pull --rebase origin $DEFAULT_BRANCH"
        return 1
    fi
    
    log "SUCCESS" "Branch atualizada em relação a origin/$DEFAULT_BRANCH"
    return 0
}

# =============================================================================
# 2. SAST (Static Application Security Testing)
# =============================================================================
run_sast() {
    local project_type="$1"
    log "INFO" "Executando SAST para projeto $project_type..."
    
    case "$project_type" in
        "java")
            run_java_sast
            ;;
        "node")
            run_node_sast
            ;;
        *)
            log "WARNING" "Tipo de projeto não suportado para SAST: $project_type"
            ;;
    esac
}

run_java_sast() {
    log "INFO" "Executando SAST para Java..."
    
    # Semgrep para Java (OWASP Top 10)
    if command_exists semgrep; then
        log "INFO" "Executando Semgrep (OWASP Top 10)..."
        if timeout "$TIMEOUT_SECONDS" semgrep ci --config p/owasp-top-ten --error --timeout 60 .; then
            log "SUCCESS" "Semgrep SAST concluído sem problemas críticos"
        else
            log "ERROR" "Semgrep SAST encontrou problemas de segurança"
            return 1
        fi
    else
        log "WARNING" "Semgrep não encontrado. Instale com: pip install semgrep"
    fi
    
    # SpotBugs (se disponível)
    if command_exists spotbugs; then
        log "INFO" "Executando SpotBugs..."
        if timeout "$TIMEOUT_SECONDS" spotbugs -textui -effort:max -low .; then
            log "SUCCESS" "SpotBugs SAST concluído"
        else
            log "WARNING" "SpotBugs encontrou problemas (não crítico para push)"
        fi
    fi
}

run_node_sast() {
    log "INFO" "Executando SAST para Node.js..."
    
    # Semgrep para JavaScript/TypeScript
    if command_exists semgrep; then
        log "INFO" "Executando Semgrep para Node.js..."
        if timeout "$TIMEOUT_SECONDS" semgrep ci --config p/owasp-top-ten --error --timeout 60 .; then
            log "SUCCESS" "Semgrep SAST concluído sem problemas críticos"
        else
            log "ERROR" "Semgrep SAST encontrou problemas de segurança"
            return 1
        fi
    else
        log "WARNING" "Semgrep não encontrado. Instale com: pip install semgrep"
    fi
    
    # ESLint security plugin (se configurado)
    if [[ -f ".eslintrc" ]] && command_exists eslint; then
        log "INFO" "Executando ESLint com regras de segurança..."
        if timeout "$TIMEOUT_SECONDS" eslint --ext .js,.jsx,.ts,.tsx .; then
            log "SUCCESS" "ESLint security check concluído"
        else
            log "WARNING" "ESLint encontrou problemas (não crítico para push)"
        fi
    fi
}

# =============================================================================
# 3. DEPENDENCY SCANNING
# =============================================================================
run_dependency_scanning() {
    local project_type="$1"
    log "INFO" "Executando Dependency Scanning para projeto $project_type..."
    
    case "$project_type" in
        "java")
            run_java_dependency_scanning
            ;;
        "node")
            run_node_dependency_scanning
            ;;
        *)
            log "WARNING" "Tipo de projeto não suportado para Dependency Scanning: $project_type"
            ;;
    esac
}

run_java_dependency_scanning() {
    log "INFO" "Executando Dependency Scanning para Java..."
    
    # OWASP Dependency-Check (se disponível)
    if command_exists dependency-check; then
        log "INFO" "Executando OWASP Dependency-Check..."
        if timeout "$TIMEOUT_SECONDS" dependency-check --scan . --format HTML --out .; then
            log "SUCCESS" "OWASP Dependency-Check concluído"
        else
            log "WARNING" "OWASP Dependency-Check encontrou vulnerabilidades"
        fi
    else
        log "WARNING" "OWASP Dependency-Check não encontrado"
        log "INFO" "Instale com: brew install dependency-check (macOS) ou apt-get install dependency-check (Ubuntu)"
    fi
    
    # Gradle dependency check (se for projeto Gradle)
    if [[ -f "build.gradle" || -f "build.gradle.kts" ]] && command_exists gradle; then
        log "INFO" "Executando Gradle dependency check..."
        if timeout "$TIMEOUT_SECONDS" gradle dependencyCheckAnalyze; then
            log "SUCCESS" "Gradle dependency check concluído"
        else
            log "WARNING" "Gradle dependency check encontrou problemas"
        fi
    fi
}

run_node_dependency_scanning() {
    log "INFO" "Executando Dependency Scanning para Node.js..."
    
    # npm audit
    if command_exists npm; then
        log "INFO" "Executando npm audit..."
        if timeout "$TIMEOUT_SECONDS" npm audit --audit-level=high; then
            log "SUCCESS" "npm audit concluído sem vulnerabilidades críticas"
        else
            log "ERROR" "npm audit encontrou vulnerabilidades críticas"
            return 1
        fi
    fi
    
    # yarn audit (se for projeto yarn)
    if [[ -f "yarn.lock" ]] && command_exists yarn; then
        log "INFO" "Executando yarn audit..."
        if timeout "$TIMEOUT_SECONDS" yarn audit --level high; then
            log "SUCCESS" "yarn audit concluído sem vulnerabilidades críticas"
        else
            log "ERROR" "yarn audit encontrou vulnerabilidades críticas"
            return 1
        fi
    fi
    
    # pnpm audit (se for projeto pnpm)
    if [[ -f "pnpm-lock.yaml" ]] && command_exists pnpm; then
        log "INFO" "Executando pnpm audit..."
        if timeout "$TIMEOUT_SECONDS" pnpm audit --audit-level high; then
            log "SUCCESS" "pnpm audit concluído sem vulnerabilidades críticas"
        else
            log "ERROR" "pnpm audit encontrou vulnerabilidades críticas"
            return 1
        fi
    fi
}

# =============================================================================
# 4. SECRET DETECTION
# =============================================================================
run_secret_detection() {
    log "INFO" "Executando Secret Detection..."
    
    # Detect secrets (pre-commit hook já configurado)
    log "INFO" "Secret detection já configurado via pre-commit hooks"
    
    # GitLeaks (se disponível)
    if command_exists gitleaks; then
        log "INFO" "Executando GitLeaks..."
        if timeout "$TIMEOUT_SECONDS" gitleaks detect --source . --verbose; then
            log "SUCCESS" "GitLeaks não encontrou secrets expostos"
        else
            log "ERROR" "GitLeaks encontrou secrets expostos"
            return 1
        fi
    else
        log "WARNING" "GitLeaks não encontrado. Instale com: brew install gitleaks (macOS)"
    fi
    
    # TruffleHog (se disponível)
    if command_exists trufflehog; then
        log "INFO" "Executando TruffleHog..."
        if timeout "$TIMEOUT_SECONDS" trufflehog --only-verified --fail .; then
            log "SUCCESS" "TruffleHog não encontrou secrets expostos"
        else
            log "ERROR" "TruffleHog encontrou secrets expostos"
            return 1
        fi
    else
        log "WARNING" "TruffleHog não encontrado. Instale com: pip install trufflehog"
    fi
}

# =============================================================================
# FUNÇÃO PRINCIPAL
# =============================================================================
main() {
    log "INFO" "=== INICIANDO VERIFICAÇÕES DE SEGURANÇA PRE-PUSH ==="
    
    # Mudar para o diretório do projeto
    cd "$PROJECT_ROOT" || {
        log "ERROR" "Não foi possível acessar o diretório do projeto"
        exit 1
    }
    
    # Verificar versões
    check_versions
    
    # Detectar tipo do projeto
    local project_type=$(detect_project_type)
    log "INFO" "Tipo de projeto detectado: $project_type"
    
    # Executar verificações
    local exit_code=0
    
    # 1. Branch Ahead Check
    if ! check_branch_ahead; then
        exit_code=1
    fi
    
    # 2. SAST
    if ! run_sast "$project_type"; then
        exit_code=1
    fi
    
    # 3. Dependency Scanning
    if ! run_dependency_scanning "$project_type"; then
        exit_code=1
    fi
    
    # 4. Secret Detection
    if ! run_secret_detection; then
        exit_code=1
    fi
    
    # Resumo final
    if [[ $exit_code -eq 0 ]]; then
        log "SUCCESS" "=== TODAS AS VERIFICAÇÕES DE SEGURANÇA PASSARAM ==="
        log "INFO" "Log completo disponível em: $LOG_FILE"
    else
        log "ERROR" "=== ALGUMAS VERIFICAÇÕES DE SEGURANÇA FALHARAM ==="
        log "ERROR" "Corrija os problemas antes de fazer push"
        log "INFO" "Log completo disponível em: $LOG_FILE"
    fi
    
    return $exit_code
}

# Tratamento de erros
trap 'log "ERROR" "Hook interrompido ou timeout"; exit 1' INT TERM

# Executar hook
main "$@"
