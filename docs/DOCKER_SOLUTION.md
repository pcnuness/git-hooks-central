# 🐳 **Solução Docker para Git Hooks Centralizados**

## 🎯 **Visão Geral**

Esta solução utiliza **Docker** para garantir que os hooks Git funcionem consistentemente em qualquer ambiente de desenvolvimento (Mac, Linux, Windows), eliminando problemas de dependências e compatibilidade.

## 🚀 **Benefícios da Solução Docker**

### **✅ Compatibilidade Universal**
- **Mac**: Docker Desktop
- **Linux**: Docker Engine
- **Windows**: Docker Desktop ou WSL2

### **✅ Dependências Garantidas**
- **SAST**: Semgrep (Python)
- **Secret Detection**: GitLeaks (Go), TruffleHog (Python)
- **Node.js**: npm, yarn, pnpm
- **Java**: Maven, Gradle
- **Python**: pip-audit

### **✅ Consistência**
- **Mesma versão** das ferramentas para todos
- **Ambiente isolado** e reproduzível
- **Sem conflitos** com dependências locais

### **✅ Fácil Manutenção**
- **Atualizações centralizadas** via Dockerfile
- **Rollback simples** para versões anteriores
- **Cache inteligente** do Docker

## 🏗️ **Arquitetura da Solução**

```
┌─────────────────────────────────────────────────────────────┐
│                    REPOSITÓRIO CONSUMIDOR                   │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   .pre-commit-  │    │   pre-commit    │                │
│  │   config.yaml   │───▶│   install       │                │
│  └─────────────────┘    └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    CATÁLOGO CENTRAL                         │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   hooks/*.sh    │    │   Dockerfile    │                │
│  └─────────────────┘    └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    CONTAINER DOCKER                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Ubuntu 22.04 + Todas as Ferramentas Pré-instaladas │   │
│  │  • Semgrep (SAST)                                   │   │
│  │  • GitLeaks (Secrets)                               │   │
│  │  • TruffleHog (Secrets)                             │   │
│  │  • Node.js + npm/yarn/pnpm                          │   │
│  │  • Java + Maven/Gradle                              │   │
│  │  • Python + pip-audit                               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 📁 **Estrutura de Arquivos**

```
git-hooks-central/
├── docker/
│   ├── Dockerfile.hooks          # Imagem Docker com todas as ferramentas
│   └── docker-compose.hooks.yml  # Orquestração Docker
├── hooks/
│   ├── security_pre_push.sh      # Hook original (Linux/Mac)
│   ├── security_pre_push_docker.sh # Hook Docker (Universal)
│   ├── branch_ahead_check.sh     # Verificação de branch
│   ├── deps_audit_fast.sh        # Auditoria de dependências
│   └── audit_trail.sh            # Rastreamento de execução
├── scripts/
│   ├── install-docker-hooks.sh   # Instalador automatizado
│   └── init-docker-hooks.sh      # Inicializador
└── examples/
    ├── pre-commit-config-node.yaml # Configuração Node.js
    └── pre-commit-config-java.yaml # Configuração Java
```

## 🛠️ **Instalação e Configuração**

### **1. Instalação Automatizada (Recomendada)**

```bash
# No repositório consumidor
git clone https://github.com/pcnuness/git-hooks-central.git
cd git-hooks-central

# Executar instalador Docker
./scripts/install-docker-hooks.sh
```

### **2. Instalação Manual**

```bash
# 1. Construir imagem Docker
docker build -f docker/Dockerfile.hooks -t git-hooks-central:latest docker/

# 2. Testar imagem
docker run --rm git-hooks-central:latest echo "✅ Docker funcionando!"

# 3. Configurar pre-commit
cp examples/pre-commit-config-node.yaml .pre-commit-config.yaml
pre-commit install --hook-type pre-push
```

### **3. Usando Docker Compose**

```bash
# Construir e executar via docker-compose
docker-compose -f docker/docker-compose.hooks.yml up --build

# Executar hook específico
docker-compose -f docker/docker-compose.hooks.yml run --rm git-hooks /hooks/security_pre_push.sh
```

## 🔧 **Configuração do Repositório Consumidor**

### **Para Projetos Node.js:**

```yaml
# .pre-commit-config.yaml
repos:
  # Hooks nativos
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: end-of-file-fixer
        stages: [pre-push]
      - id: check-json
        stages: [pre-push]

  # Catálogo central com Docker
  - repo: https://github.com/pcnuness/git-hooks-central.git
    rev: v1.0.3
    hooks:
      - id: security-pre-push-hook-docker  # Versão Docker
        stages: [pre-push]
        always_run: true
        pass_filenames: false
      
      - id: branch-ahead-check
        stages: [pre-push]
        pass_filenames: false
      
      - id: deps-audit-fast
        stages: [pre-push]
        pass_filenames: false
      
      - id: audit-trail
        stages: [pre-push]
        pass_filenames: false

  # Hooks específicos Node.js
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v9.34.0
    hooks:
      - id: eslint
        additional_dependencies: ['eslint@9.9.0']
        files: \.(js|jsx|ts|tsx)$
        stages: [pre-push]
```

### **Para Projetos Java:**

```yaml
# .pre-commit-config.yaml
repos:
  # Hooks nativos
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: end-of-file-fixer
        stages: [pre-push]
      - id: check-xml
        stages: [pre-push]

  # Catálogo central com Docker
  - repo: https://github.com/pcnuness/git-hooks-central.git
    rev: v1.0.3
    hooks:
      - id: security-pre-push-hook-docker  # Versão Docker
        stages: [pre-push]
        always_run: true
        pass_filenames: false
      
      - id: branch-ahead-check
        stages: [pre-push]
        pass_filenames: false
      
      - id: deps-audit-fast
        stages: [pre-push]
        pass_filenames: false
      
      - id: audit-trail
        stages: [pre-push]
        pass_filenames: false

  # Hooks específicos Java
  - repo: https://github.com/pre-commit/mirrors-checkstyle
    rev: v1.0.0
    hooks:
      - id: checkstyle
        stages: [pre-push]
```

## 🚀 **Uso Diário**

### **1. Push Automático (Recomendado)**

```bash
# Hooks executam automaticamente no push
git add .
git commit -m "Feature: nova funcionalidade"
git push origin feature-branch
```

### **2. Execução Manual**

```bash
# Executar todos os hooks
pre-commit run --all-files --hook-stage push

# Executar hook específico
pre-commit run security-pre-push-hook-docker --all-files --hook-stage push

# Executar hook diretamente via Docker
docker run --rm -v $(pwd):/workspace git-hooks-central:latest /hooks/security_pre_push.sh
```

### **3. Debug e Troubleshooting**

```bash
# Ver logs detalhados
pre-commit run --all-files --hook-stage push -v

# Limpar cache
pre-commit clean

# Reinstalar hooks
pre-commit install --hook-type pre-push
```

## 🔍 **Monitoramento e Logs**

### **1. Logs dos Hooks**

```bash
# Log principal de segurança
cat .security-hook.log

# Artefato auditável
cat .git/hooks_artifacts/prepush.json
```

### **2. Logs do Docker**

```bash
# Ver containers em execução
docker ps

# Ver logs de container específico
docker logs <container-id>

# Ver uso de recursos
docker stats
```

## 🚨 **Troubleshooting**

### **Problema: Docker não está rodando**

```bash
# macOS/Windows
# Iniciar Docker Desktop

# Linux
sudo systemctl start docker
sudo systemctl enable docker
```

### **Problema: Imagem não encontrada**

```bash
# Reconstruir imagem
docker build -f docker/Dockerfile.hooks -t git-hooks-central:latest docker/
```

### **Problema: Permissões de volume**

```bash
# Verificar permissões
ls -la ~/.gitconfig

# Ajustar permissões se necessário
chmod 644 ~/.gitconfig
```

### **Problema: Timeout dos hooks**

```bash
# Aumentar timeout no docker-compose
environment:
  - TIMEOUT_SECONDS=600

# Ou ajustar no script
TIMEOUT_SECONDS=600
```

## 📊 **Performance e Otimizações**

### **1. Cache de Dependências**

```bash
# Usar volume persistente para cache
volumes:
  - git-hooks-cache:/root/.cache
  - maven-cache:/root/.m2
  - npm-cache:/root/.npm
```

### **2. Multi-stage Build**

```dockerfile
# Otimizar tamanho da imagem
FROM ubuntu:22.04 as base
# ... instalações básicas

FROM base as security-tools
# ... ferramentas de segurança

FROM security-tools as final
# ... configuração final
```

### **3. Build Paralelo**

```bash
# Construir com paralelismo
docker build --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from git-hooks-central:latest \
  -f docker/Dockerfile.hooks \
  -t git-hooks-central:latest docker/
```

## 🔄 **Atualizações e Manutenção**

### **1. Atualizar Ferramentas**

```bash
# 1. Modificar Dockerfile.hooks
# 2. Reconstruir imagem
docker build -f docker/Dockerfile.hooks -t git-hooks-central:latest docker/

# 3. Atualizar tag no repositório central
git tag v1.1.0
git push origin v1.1.0
```

### **2. Atualizar Hooks**

```bash
# 1. Modificar scripts em hooks/
# 2. Testar localmente
# 3. Commit e push
git add hooks/
git commit -m "Update: melhorias nos hooks"
git push origin main
```

### **3. Rollback**

```bash
# Voltar para versão anterior
git checkout v1.0.3
docker build -f docker/Dockerfile.hooks -t git-hooks-central:v1.0.3 docker/
```

## 🌟 **Vantagens para AWS e Ambientes Corporativos**

### **1. Consistência de Ambiente**

- **Mesmas versões** em desenvolvimento e CI/CD
- **Reproduzibilidade** de builds
- **Isolamento** de dependências

### **2. Segurança**

- **Imagem base Ubuntu** oficial
- **Ferramentas atualizadas** automaticamente
- **Escaneamento** de vulnerabilidades na imagem

### **3. Escalabilidade**

- **Cache compartilhado** entre desenvolvedores
- **Build paralelo** em CI/CD
- **Deploy consistente** em múltiplos ambientes

### **4. Compliance**

- **Auditoria** de ferramentas utilizadas
- **Rastreabilidade** de execução
- **Padrões** de segurança aplicados

## 📚 **Recursos Adicionais**

### **1. Documentação**

- **README.md**: Visão geral do projeto
- **docs/USAGE.md**: Guia de uso detalhado
- **docs/PRESENTATION_RUNBOOK.md**: Runbook de apresentação

### **2. Exemplos**

- **examples/**: Configurações para diferentes stacks
- **scripts/**: Utilitários de instalação e teste

### **3. Suporte**

- **Issues**: Para bugs e melhorias
- **Discussions**: Para dúvidas e suporte
- **Releases**: Para novas versões

---

## 🎯 **Próximos Passos**

### **Fase 1: Implementação (1 semana)**
- [ ] Testar solução Docker localmente
- [ ] Validar em diferentes OS (Mac, Linux, Windows)
- [ ] Documentar casos de uso específicos

### **Fase 2: Expansão (2 semanas)**
- [ ] Implementar em projetos piloto
- [ ] Coletar feedback dos desenvolvedores
- [ ] Otimizar performance e recursos

### **Fase 3: Produção (1 mês)**
- [ ] Deploy em todos os projetos
- [ ] Monitoramento e alertas
- [ ] Treinamento da equipe

---

**🚀 A solução Docker garante que seus hooks funcionem perfeitamente em qualquer ambiente!**
