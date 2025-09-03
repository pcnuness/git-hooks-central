# 🔧 **Guia de Troubleshooting Completo**

## 📋 **Índice**

1. [Diagnóstico Rápido](#-diagnóstico-rápido)
2. [Problemas de Instalação](#-problemas-de-instalação)
3. [Problemas de Execução](#-problemas-de-execução)
4. [Problemas de Segurança](#-problemas-de-segurança)
5. [Problemas de Performance](#-problemas-de-performance)
6. [Problemas de Compatibilidade](#-problemas-de-compatibilidade)
7. [Problemas de Rede](#-problemas-de-rede)
8. [Problemas de Permissão](#-problemas-de-permissão)
9. [Comandos de Diagnóstico](#-comandos-de-diagnóstico)
10. [Scripts de Automação](#-scripts-de-automação)

---

## ⚡ **Diagnóstico Rápido**

### **Checklist de Verificação**

```bash
# 1. Verificar dependências básicas
python3 --version    # Deve ser 3.6.0+
docker --version     # Deve estar instalado
docker info          # Deve estar rodando
git --version        # Deve estar instalado

# 2. Verificar configuração
ls -la .pre-commit-config.yaml
ls -la .git/hooks/

# 3. Verificar hooks instalados
pre-commit --version
pre-commit install --hook-type pre-push

# 4. Testar execução
pre-commit run --all-files --hook-stage push -v
```

### **Status do Sistema**

```bash
# Script de diagnóstico rápido
#!/bin/bash
# quick-diagnosis.sh

echo "=== Git Hooks Central - Diagnóstico Rápido ==="
echo "Data: $(date)"
echo

# Verificar Python
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo "✅ Python: $PYTHON_VERSION"
else
    echo "❌ Python: Não encontrado"
fi

# Verificar Docker
if command -v docker >/dev/null 2>&1; then
    DOCKER_VERSION=$(docker --version 2>&1)
    echo "✅ Docker: $DOCKER_VERSION"
    
    if docker info >/dev/null 2>&1; then
        echo "✅ Docker: Rodando"
    else
        echo "❌ Docker: Não está rodando"
    fi
else
    echo "❌ Docker: Não encontrado"
fi

# Verificar Git
if command -v git >/dev/null 2>&1; then
    GIT_VERSION=$(git --version 2>&1)
    echo "✅ Git: $GIT_VERSION"
else
    echo "❌ Git: Não encontrado"
fi

# Verificar pre-commit
if command -v pre-commit >/dev/null 2>&1; then
    PRECOMMIT_VERSION=$(pre-commit --version 2>&1)
    echo "✅ pre-commit: $PRECOMMIT_VERSION"
else
    echo "❌ pre-commit: Não encontrado"
fi

# Verificar configuração
if [ -f ".pre-commit-config.yaml" ]; then
    echo "✅ Configuração: .pre-commit-config.yaml encontrado"
else
    echo "❌ Configuração: .pre-commit-config.yaml não encontrado"
fi

# Verificar hooks instalados
if [ -f ".git/hooks/pre-push" ]; then
    echo "✅ Hooks: pre-push instalado"
else
    echo "❌ Hooks: pre-push não instalado"
fi

echo
echo "=== Fim do Diagnóstico ==="
```

---

## 🔧 **Problemas de Instalação**

### **1. Python não encontrado**

#### **Sintomas:**
```bash
python3: command not found
```

#### **Soluções:**

**Windows:**
```bash
# 1. Baixar Python do site oficial
# https://www.python.org/downloads/

# 2. Verificar PATH
echo $PATH

# 3. Adicionar Python ao PATH
# C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python311\
```

**Linux (Ubuntu/Debian):**
```bash
# Instalar Python
sudo apt-get update
sudo apt-get install python3 python3-pip python3-venv

# Verificar instalação
python3 --version
```

**Linux (CentOS/RHEL):**
```bash
# Instalar Python
sudo yum install python3 python3-pip

# Ou para versões mais recentes
sudo dnf install python3 python3-pip

# Verificar instalação
python3 --version
```

**macOS:**
```bash
# Usando Homebrew
brew install python3

# Verificar instalação
python3 --version
```

### **2. Docker não encontrado**

#### **Sintomas:**
```bash
docker: command not found
```

#### **Soluções:**

**Windows:**
```bash
# 1. Instalar Docker Desktop
# https://www.docker.com/products/docker-desktop

# 2. Iniciar Docker Desktop
# 3. Verificar se está rodando
docker --version
docker info
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker

# Verificar instalação
docker --version
docker info
```

**macOS:**
```bash
# Usando Homebrew
brew install --cask docker

# Ou baixar Docker Desktop
# https://www.docker.com/products/docker-desktop

# Verificar instalação
docker --version
docker info
```

### **3. pre-commit não encontrado**

#### **Sintomas:**
```bash
pre-commit: command not found
```

#### **Soluções:**
```bash
# Instalar pre-commit
pip install pre-commit

# Ou usando pip3
pip3 install pre-commit

# Verificar instalação
pre-commit --version

# Instalar hooks
pre-commit install --hook-type pre-push
```

### **4. Virtual Environment falha**

#### **Sintomas:**
```bash
[ERROR] Falha ao criar virtual environment
```

#### **Soluções:**
```bash
# 1. Verificar permissões
ls -la hooks/secrets_detection_wrapper.py
chmod +x hooks/secrets_detection_wrapper.py

# 2. Verificar Python
python3 --version  # Deve ser 3.6.0+

# 3. Verificar módulo venv
python3 -c "import venv; print('venv module available')"

# 4. Criar virtual environment manualmente
python3 -m venv .venv
source .venv/bin/activate  # Linux/macOS
# ou
.venv\Scripts\activate     # Windows

# 5. Verificar se foi criado
ls -la .venv/
```

---

## 🚀 **Problemas de Execução**

### **1. Hooks não executam**

#### **Sintomas:**
```bash
# Push não executa hooks
git push origin feature-branch
# (sem output dos hooks)
```

#### **Soluções:**
```bash
# 1. Verificar se hooks estão instalados
ls -la .git/hooks/

# 2. Reinstalar hooks
pre-commit install --hook-type pre-push

# 3. Verificar configuração
cat .pre-commit-config.yaml

# 4. Executar manualmente
pre-commit run --all-files --hook-stage push -v

# 5. Verificar permissões
chmod +x .git/hooks/pre-push
```

### **2. Hook específico falha**

#### **Sintomas:**
```bash
# Hook específico falha
pre-commit run secrets-detection-gitlab --all-files --hook-stage push
# [ERROR] Falha ao executar hook
```

#### **Soluções:**
```bash
# 1. Executar com verbose
pre-commit run secrets-detection-gitlab --all-files --hook-stage push -v

# 2. Verificar dependências
docker --version
docker info

# 3. Limpar cache
pre-commit clean

# 4. Reinstalar hook
pre-commit install --hook-type pre-push

# 5. Executar script diretamente
python3 hooks/secrets_detection_wrapper.py
```

### **3. Cache corrompido**

#### **Sintomas:**
```bash
# Hooks executam com versão antiga
# Comportamento inesperado
```

#### **Soluções:**
```bash
# 1. Limpar cache do pre-commit
pre-commit clean

# 2. Limpar cache do Docker
docker system prune -f

# 3. Limpar virtual environment
rm -rf .venv/

# 4. Reinstalar tudo
pre-commit install --hook-type pre-push
pre-commit run --all-files --hook-stage push
```

---

## 🔒 **Problemas de Segurança**

### **1. Segredos detectados**

#### **Sintomas:**
```bash
[ERROR] Secrets detectados: 2 vulnerabilidade(s)
• RSA private key em src/index.js:14 (Severidade: Critical)
• AWS access token em src/index.js:11 (Severidade: Critical)
```

#### **Soluções:**
```bash
# 1. REMOVER segredos do código
# Editar arquivo e remover linhas com segredos

# 2. Usar variáveis de ambiente
# Antes:
const apiKey = "AKIAQ3EGRIVCO7QPIKPI";

# Depois:
const apiKey = process.env.AWS_ACCESS_KEY_ID;

# 3. Adicionar ao .gitignore
echo ".env" >> .gitignore
echo "*.pem" >> .gitignore
echo "*.key" >> .gitignore

# 4. Rotacionar credenciais
# - AWS: Rotacionar access keys
# - GitHub: Regenerar tokens
# - Outros: Seguir procedimento específico

# 5. Testar novamente
pre-commit run secrets-detection-gitlab --all-files --hook-stage push
```

### **2. Falsos positivos**

#### **Sintomas:**
```bash
# Segredos detectados em arquivos de teste ou exemplo
• AWS access token em tests/mock-data.js:5 (Severidade: Critical)
```

#### **Soluções:**
```bash
# 1. Verificar se é realmente um falso positivo
# - É um arquivo de teste?
# - É um exemplo/documentação?
# - É um mock/placeholder?

# 2. Se for falso positivo, adicionar ao .gitignore
echo "tests/mock-data.js" >> .gitignore

# 3. Ou usar comentários para ignorar
# gitlab-secrets-ignore: AWS access token
const mockApiKey = "AKIAQ3EGRIVCO7QPIKPI";

# 4. Ou mover para arquivo de configuração
# Mover para .env.example (não commitado)
```

### **3. Branch desatualizada**

#### **Sintomas:**
```bash
❌ Branch não está atualizada em relação a origin/main.
❌ Execute: git pull origin main
```

#### **Soluções:**
```bash
# 1. Atualizar branch
git pull origin main

# 2. Resolver conflitos se houver
git status
git add .
git commit -m "resolve: merge conflicts"

# 3. Tentar push novamente
git push origin feature-branch

# 4. Se ainda falhar, verificar se há commits não sincronizados
git log --oneline origin/main..HEAD
```

---

## ⚡ **Problemas de Performance**

### **1. Hooks lentos**

#### **Sintomas:**
```bash
# Hooks demoram muito para executar
# Timeout ou interrupção
```

#### **Soluções:**
```bash
# 1. Medir tempo de execução
time pre-commit run --all-files --hook-stage push

# 2. Executar hooks individuais
time pre-commit run branch-ahead-check --all-files --hook-stage push
time pre-commit run secrets-detection-gitlab --all-files --hook-stage push

# 3. Otimizar Docker
# Limpar imagens não utilizadas
docker system prune -f

# Usar cache do Docker
docker pull registry.gitlab.com/gitlab-org/security-products/analyzers/secrets:latest

# 4. Reduzir escopo de arquivos
# Modificar .pre-commit-config.yaml para processar apenas arquivos relevantes
```

### **2. Docker overhead**

#### **Sintomas:**
```bash
# Docker demora para iniciar
# Imagens grandes
```

#### **Soluções:**
```bash
# 1. Verificar tamanho das imagens
docker images

# 2. Limpar imagens não utilizadas
docker image prune -f

# 3. Usar imagens menores
# Configurar Dockerfile para usar Alpine Linux

# 4. Configurar cache do Docker
docker system df
docker system prune -f
```

### **3. Virtual Environment lento**

#### **Sintomas:**
```bash
# Criação de virtual environment demora
# Dependências demoram para instalar
```

#### **Soluções:**
```bash
# 1. Verificar se .venv já existe
ls -la .venv/

# 2. Reutilizar virtual environment existente
# O script já faz isso automaticamente

# 3. Verificar espaço em disco
df -h

# 4. Limpar virtual environments antigos
find . -name ".venv" -type d -mtime +30 -exec rm -rf {} +
```

---

## 🔄 **Problemas de Compatibilidade**

### **1. Versões de Python**

#### **Sintomas:**
```bash
# Erro de versão Python
# Módulos não encontrados
```

#### **Soluções:**
```bash
# 1. Verificar versão Python
python3 --version

# 2. Usar pyenv para gerenciar versões
# Instalar pyenv
curl https://pyenv.run | bash

# Instalar Python 3.11
pyenv install 3.11.0
pyenv global 3.11.0

# 3. Verificar compatibilidade
python3 -c "import sys; print(sys.version_info >= (3, 6))"
```

### **2. Problemas de SO**

#### **Sintomas:**
```bash
# Comportamento diferente entre SOs
# Comandos não funcionam
```

#### **Soluções:**
```bash
# 1. Verificar SO
uname -a  # Linux/macOS
systeminfo  # Windows

# 2. Usar Docker para consistência
# O script já usa Docker para secrets detection

# 3. Verificar compatibilidade de comandos
# Usar comandos POSIX quando possível
```

### **3. Problemas de Encoding**

#### **Sintomas:**
```bash
# Caracteres especiais não funcionam
# Encoding errors
```

#### **Soluções:**
```bash
# 1. Verificar encoding do terminal
echo $LANG

# 2. Configurar UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 3. Verificar encoding dos arquivos
file -i .pre-commit-config.yaml
```

---

## 🌐 **Problemas de Rede**

### **1. Falha no download de imagens**

#### **Sintomas:**
```bash
# Docker pull falha
# Timeout de rede
```

#### **Soluções:**
```bash
# 1. Verificar conectividade
ping registry.gitlab.com

# 2. Testar download manual
docker pull registry.gitlab.com/gitlab-org/security-products/analyzers/secrets:latest

# 3. Configurar proxy se necessário
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# 4. Verificar DNS
nslookup registry.gitlab.com
```

### **2. Falha no acesso ao repositório**

#### **Sintomas:**
```bash
# Git clone/pull falha
# Acesso negado
```

#### **Soluções:**
```bash
# 1. Verificar acesso
git ls-remote https://github.com/pcnuness/git-hooks-central.git

# 2. Configurar autenticação
git config --global credential.helper store

# 3. Usar SSH em vez de HTTPS
git remote set-url origin git@github.com:pcnuness/git-hooks-central.git

# 4. Verificar chaves SSH
ssh -T git@github.com
```

### **3. Problemas de firewall**

#### **Sintomas:**
```bash
# Conexões bloqueadas
# Portas fechadas
```

#### **Soluções:**
```bash
# 1. Verificar portas necessárias
# Docker: 2375, 2376
# Git: 22, 443, 80

# 2. Configurar firewall
# Linux: ufw, iptables
# Windows: Windows Firewall
# macOS: pfctl

# 3. Verificar com administrador de rede
# Solicitar abertura de portas necessárias
```

---

## 🔐 **Problemas de Permissão**

### **1. Permissões de arquivo**

#### **Sintomas:**
```bash
# Permission denied
# Arquivos não executáveis
```

#### **Soluções:**
```bash
# 1. Verificar permissões
ls -la hooks/
ls -la .git/hooks/

# 2. Corrigir permissões
chmod +x hooks/*.sh
chmod +x hooks/*.py
chmod +x .git/hooks/pre-push

# 3. Verificar proprietário
ls -la hooks/secrets_detection_wrapper.py
chown $USER:$USER hooks/secrets_detection_wrapper.py
```

### **2. Permissões de Docker**

#### **Sintomas:**
```bash
# Docker permission denied
# Usuário não no grupo docker
```

#### **Soluções:**
```bash
# 1. Verificar grupo docker
groups $USER

# 2. Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# 3. Fazer logout/login ou usar newgrp
newgrp docker

# 4. Verificar se funcionou
docker info
```

### **3. Permissões de diretório**

#### **Sintomas:**
```bash
# Não consegue criar .venv/
# Não consegue escrever em .git/
```

#### **Soluções:**
```bash
# 1. Verificar permissões do diretório
ls -la .

# 2. Corrigir permissões
chmod 755 .
chmod 755 .git

# 3. Verificar proprietário
ls -la .git/
chown -R $USER:$USER .git/
```

---

## 🔍 **Comandos de Diagnóstico**

### **Scripts de Diagnóstico Avançado**

#### **1. Diagnóstico Completo**
```bash
#!/bin/bash
# full-diagnosis.sh

echo "=== Git Hooks Central - Diagnóstico Completo ==="
echo "Data: $(date)"
echo "Usuário: $(whoami)"
echo "Diretório: $(pwd)"
echo

# Verificar sistema
echo "=== Sistema ==="
uname -a
echo

# Verificar dependências
echo "=== Dependências ==="
echo "Python: $(python3 --version 2>&1 || echo 'Não encontrado')"
echo "Docker: $(docker --version 2>&1 || echo 'Não encontrado')"
echo "Git: $(git --version 2>&1 || echo 'Não encontrado')"
echo "pre-commit: $(pre-commit --version 2>&1 || echo 'Não encontrado')"
echo

# Verificar Docker
echo "=== Docker ==="
if command -v docker >/dev/null 2>&1; then
    docker info 2>&1 | head -10
else
    echo "Docker não encontrado"
fi
echo

# Verificar configuração
echo "=== Configuração ==="
if [ -f ".pre-commit-config.yaml" ]; then
    echo "✅ .pre-commit-config.yaml encontrado"
    echo "Tamanho: $(wc -l < .pre-commit-config.yaml) linhas"
else
    echo "❌ .pre-commit-config.yaml não encontrado"
fi
echo

# Verificar hooks
echo "=== Hooks ==="
if [ -f ".git/hooks/pre-push" ]; then
    echo "✅ pre-push hook instalado"
    echo "Tamanho: $(wc -l < .git/hooks/pre-push) linhas"
else
    echo "❌ pre-push hook não instalado"
fi
echo

# Verificar virtual environment
echo "=== Virtual Environment ==="
if [ -d ".venv" ]; then
    echo "✅ .venv encontrado"
    echo "Tamanho: $(du -sh .venv | cut -f1)"
else
    echo "❌ .venv não encontrado"
fi
echo

# Verificar artefatos
echo "=== Artefatos ==="
if [ -f ".git/hooks_artifacts/prepush.json" ]; then
    echo "✅ Artefato de auditoria encontrado"
    echo "Conteúdo:"
    cat .git/hooks_artifacts/prepush.json | jq . 2>/dev/null || cat .git/hooks_artifacts/prepush.json
else
    echo "❌ Artefato de auditoria não encontrado"
fi
echo

if [ -f "gl-secret-detection-report.json" ]; then
    echo "✅ Relatório de segredos encontrado"
    echo "Vulnerabilidades: $(jq '.vulnerabilities | length' gl-secret-detection-report.json 2>/dev/null || echo 'N/A')"
else
    echo "❌ Relatório de segredos não encontrado"
fi
echo

# Verificar espaço em disco
echo "=== Espaço em Disco ==="
df -h . | tail -1
echo

# Verificar memória
echo "=== Memória ==="
free -h 2>/dev/null || echo "Comando free não disponível"
echo

echo "=== Fim do Diagnóstico ==="
```

#### **2. Teste de Conectividade**
```bash
#!/bin/bash
# connectivity-test.sh

echo "=== Teste de Conectividade ==="

# Testar GitHub
echo "Testando GitHub..."
if curl -s https://github.com/pcnuness/git-hooks-central.git > /dev/null; then
    echo "✅ GitHub: Acessível"
else
    echo "❌ GitHub: Não acessível"
fi

# Testar GitLab Registry
echo "Testando GitLab Registry..."
if curl -s https://registry.gitlab.com > /dev/null; then
    echo "✅ GitLab Registry: Acessível"
else
    echo "❌ GitLab Registry: Não acessível"
fi

# Testar Docker Hub
echo "Testando Docker Hub..."
if curl -s https://hub.docker.com > /dev/null; then
    echo "✅ Docker Hub: Acessível"
else
    echo "❌ Docker Hub: Não acessível"
fi

# Testar DNS
echo "Testando DNS..."
if nslookup github.com > /dev/null 2>&1; then
    echo "✅ DNS: Funcionando"
else
    echo "❌ DNS: Não funcionando"
fi

echo "=== Fim do Teste ==="
```

#### **3. Teste de Performance**
```bash
#!/bin/bash
# performance-test.sh

echo "=== Teste de Performance ==="

# Testar tempo de execução dos hooks
echo "Testando tempo de execução..."

# Hook 1: branch-ahead-check
echo "1. branch-ahead-check:"
time pre-commit run branch-ahead-check --all-files --hook-stage push 2>/dev/null
echo

# Hook 2: audit-trail
echo "2. audit-trail:"
time pre-commit run audit-trail --all-files --hook-stage push 2>/dev/null
echo

# Hook 3: secrets-detection-gitlab
echo "3. secrets-detection-gitlab:"
time pre-commit run secrets-detection-gitlab --all-files --hook-stage push 2>/dev/null
echo

# Testar Docker
echo "Testando Docker..."
time docker --version > /dev/null
echo

# Testar Python
echo "Testando Python..."
time python3 --version > /dev/null
echo

echo "=== Fim do Teste ==="
```

---

## 🤖 **Scripts de Automação**

### **1. Script de Reparo Automático**
```bash
#!/bin/bash
# auto-fix.sh

echo "=== Reparo Automático ==="

# Reparar permissões
echo "Reparando permissões..."
chmod +x hooks/*.sh 2>/dev/null
chmod +x hooks/*.py 2>/dev/null
chmod +x .git/hooks/pre-push 2>/dev/null
echo "✅ Permissões reparadas"

# Limpar cache
echo "Limpando cache..."
pre-commit clean 2>/dev/null
docker system prune -f 2>/dev/null
echo "✅ Cache limpo"

# Reinstalar hooks
echo "Reinstalando hooks..."
pre-commit install --hook-type pre-push 2>/dev/null
echo "✅ Hooks reinstalados"

# Testar execução
echo "Testando execução..."
if pre-commit run --all-files --hook-stage push > /dev/null 2>&1; then
    echo "✅ Teste passou"
else
    echo "❌ Teste falhou - verificar logs"
fi

echo "=== Reparo Concluído ==="
```

### **2. Script de Monitoramento**
```bash
#!/bin/bash
# monitor.sh

echo "=== Monitoramento Git Hooks ==="

# Verificar status dos serviços
check_service() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "✅ $1: Disponível"
    else
        echo "❌ $1: Não disponível"
    fi
}

check_service python3
check_service docker
check_service git
check_service pre-commit

# Verificar hooks instalados
if [ -f ".git/hooks/pre-push" ]; then
    echo "✅ Hooks: Instalados"
else
    echo "❌ Hooks: Não instalados"
fi

# Verificar configuração
if [ -f ".pre-commit-config.yaml" ]; then
    echo "✅ Configuração: Presente"
else
    echo "❌ Configuração: Ausente"
fi

# Verificar virtual environment
if [ -d ".venv" ]; then
    echo "✅ Virtual Environment: Presente"
else
    echo "❌ Virtual Environment: Ausente"
fi

echo "=== Monitoramento Concluído ==="
```

### **3. Script de Backup**
```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "=== Backup de Configuração ==="

# Backup de configuração
if [ -f ".pre-commit-config.yaml" ]; then
    cp .pre-commit-config.yaml "$BACKUP_DIR/"
    echo "✅ Configuração: Backup realizado"
fi

# Backup de hooks
if [ -d "hooks" ]; then
    cp -r hooks "$BACKUP_DIR/"
    echo "✅ Hooks: Backup realizado"
fi

# Backup de artefatos
if [ -f ".git/hooks_artifacts/prepush.json" ]; then
    cp .git/hooks_artifacts/prepush.json "$BACKUP_DIR/"
    echo "✅ Artefatos: Backup realizado"
fi

# Backup de relatórios
if [ -f "gl-secret-detection-report.json" ]; then
    cp gl-secret-detection-report.json "$BACKUP_DIR/"
    echo "✅ Relatórios: Backup realizado"
fi

# Comprimir backup
tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

echo "✅ Backup comprimido: $BACKUP_DIR.tar.gz"
echo "=== Backup Concluído ==="
```

---

## 📞 **Suporte**

### **Níveis de Suporte**

#### **Nível 1: Autodiagnóstico**
- Use os scripts de diagnóstico fornecidos
- Consulte este guia de troubleshooting
- Verifique logs e mensagens de erro

#### **Nível 2: Suporte da Equipe**
- Compartilhe output dos scripts de diagnóstico
- Inclua logs de erro relevantes
- Descreva passos já tentados

#### **Nível 3: Suporte Especializado**
- Para problemas críticos de segurança
- Para problemas de integração complexa
- Para problemas de performance

### **Informações para Suporte**

Ao solicitar suporte, inclua:

1. **Output do diagnóstico:**
```bash
./full-diagnosis.sh > diagnosis.log
```

2. **Logs de erro:**
```bash
pre-commit run --all-files --hook-stage push -v > error.log 2>&1
```

3. **Informações do sistema:**
```bash
uname -a > system-info.log
python3 --version >> system-info.log
docker --version >> system-info.log
```

4. **Configuração:**
```bash
cat .pre-commit-config.yaml > config.log
```

### **Canais de Suporte**

- **Email**: git-hooks-support@company.com
- **Slack**: #git-hooks-support
- **Issues**: [GitHub Issues](https://github.com/pcnuness/git-hooks-central/issues)
- **Documentação**: [docs/](docs/)

---

## 🎉 **Conclusão**

Este guia de troubleshooting cobre os problemas mais comuns e suas soluções. Com os scripts de diagnóstico e automação fornecidos, você pode resolver a maioria dos problemas rapidamente.

**Lembre-se**: Sempre documente problemas e soluções para ajudar outros desenvolvedores! 📝

---

**Versão**: v1.0.3  
**Última atualização**: 2025-09-02  
**Próxima revisão**: 2025-10-02
