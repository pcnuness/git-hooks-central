# Hooks de Segurança Pre-Push

Este repositório contém hooks de segurança robustos para projetos Java e Node.js, implementados usando o framework pre-commit.

## 🚀 Funcionalidades

### ✅ Verificações de Segurança Implementadas

1. **SAST (Static Application Security Testing)**
   - Semgrep com padrões OWASP Top 10
   - SpotBugs para Java
   - ESLint com regras de segurança para Node.js

2. **Branch Ahead Check**
   - Verifica se a branch está atualizada com a master/main
   - Previne push de branches desatualizadas

3. **Dependency Scanning**
   - OWASP Dependency-Check para Java
   - npm/yarn/pnpm audit para Node.js
   - Gradle dependency check plugin

4. **Secret Detection**
   - GitLeaks para detecção de secrets
   - TruffleHog para análise de código
   - Padrões customizados para Java e Node.js

## 🛠️ Compatibilidade

### Java
- **Versões suportadas**: Java 8+
- **Build tools**: Maven 3.6+, Gradle 7.0+
- **Ferramentas**: Semgrep, SpotBugs, OWASP Dependency-Check

### Node.js
- **Versões suportadas**: Node 16+
- **Package managers**: npm 8+, yarn 1.22+, pnpm 7.0+
- **Ferramentas**: Semgrep, ESLint, npm audit

## 📋 Pré-requisitos

### Sistema
- Git
- Bash (Linux/macOS) ou Git Bash (Windows)
- Python 3.7+ (para pre-commit)

### Ferramentas de Segurança
```bash
# Instalação automática via script
bash hooks/install-security-hooks.sh

# Ou instalação manual
pip install pre-commit semgrep trufflehog
brew install gitleaks dependency-check  # macOS
```

## 🚀 Instalação Rápida

### 1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/git-hooks-central.git
cd git-hooks-central
```

### 2. Execute o instalador
```bash
bash hooks/install-security-hooks.sh
```

### 3. Configure o projeto
```bash
# Para projetos Java
cp hooks/java-security-config.yaml ./
# Edite as configurações conforme necessário

# Para projetos Node.js
cp hooks/node-security-config.yaml ./
# Edite as configurações conforme necessário
```

## 📁 Estrutura dos Arquivos

```
hooks/
├── security_pre_push.sh          # Hook principal de segurança
├── install-security-hooks.sh     # Script de instalação
├── java-security-config.yaml     # Configuração para Java
├── node-security-config.yaml     # Configuração para Node.js
├── sast_semantic_fast.sh        # Hook SAST rápido (legado)
├── deps_audit_fast.sh           # Hook de auditoria (legado)
└── branch_ahead_check.sh        # Hook de verificação (legado)
```

## ⚙️ Configuração

### Configuração Básica

O hook é configurado automaticamente via `.pre-commit-config.yaml`:

```yaml
- repo: local
  hooks:
    - id: security-pre-push-hook
      name: Security Pre-Push Hook
      entry: bash hooks/security_pre_push.sh
      language: system
      stages: [pre-push]
      always_run: true
```

### Configurações Específicas

#### Java
```yaml
# hooks/java-security-config.yaml
sast:
  semgrep:
    config: "p/owasp-top-ten"
    timeout: 60

dependency_scanning:
  owasp_dependency_check:
    fail_on_cvss: 7.0
```

#### Node.js
```yaml
# hooks/node-security-config.yaml
dependency_scanning:
  npm_audit:
    audit_level: "high"
    production_only: false
```

## 🔧 Uso

### Execução Automática
Os hooks rodam automaticamente antes de cada `git push`:

```bash
git add .
git commit -m "feat: nova funcionalidade"
git push  # Hooks executam automaticamente
```

### Execução Manual
```bash
# Executar todos os hooks
pre-commit run --all-files --hook-stage pre-push

# Executar apenas o hook de segurança
bash hooks/security_pre_push.sh

# Executar hooks específicos
pre-commit run sast-semantic-fast --all-files
```

## 📊 Logs e Relatórios

### Arquivo de Log
- **Localização**: `.security-hook.log`
- **Formato**: Timestamp + Level + Mensagem
- **Rotação**: Automática (10MB, 5 backups)

### Exemplo de Log
```
[2024-01-15 10:30:15] [INFO] === INICIANDO VERIFICAÇÕES DE SEGURANÇA PRE-PUSH ===
[2024-01-15 10:30:15] [INFO] Tipo de projeto detectado: java
[2024-01-15 10:30:16] [SUCCESS] Semgrep SAST concluído sem problemas críticos
[2024-01-15 10:30:17] [SUCCESS] OWASP Dependency-Check concluído
[2024-01-15 10:30:18] [SUCCESS] GitLeaks não encontrou secrets expostos
```

## 🚨 Tratamento de Erros

### Estratégias de Fallback
1. **Continue on Failure**: Se uma ferramenta falhar, outras continuam
2. **Offline Mode**: Cache local quando serviços estão indisponíveis
3. **Timeout Protection**: Limite de 5 minutos por verificação
4. **Graceful Degradation**: Warnings em vez de falhas para ferramentas opcionais

### Códigos de Saída
- `0`: Todas as verificações passaram
- `1`: Algumas verificações falharam (push bloqueado)
- `2`: Erro crítico no hook

## ⚡ Performance e Otimizações

### Estratégias de Performance
1. **Cache Inteligente**: Resultados são cacheados por 24h
2. **Execução Paralela**: Múltiplas ferramentas rodam simultaneamente
3. **Timeout Configurável**: Evita travamentos
4. **Seleção de Arquivos**: Apenas arquivos modificados são analisados

### Métricas de Performance
- **Tempo médio**: 30-90 segundos
- **Uso de memória**: 1-2GB
- **Overhead no push**: <2 minutos

### Otimizações Recomendadas
```bash
# Configurar cache
export SEMGREP_CACHE_DIR="$HOME/.cache/semgrep"
export GITLEAKS_CACHE_DIR="$HOME/.cache/gitleaks"

# Usar modo rápido para desenvolvimento
export SECURITY_HOOK_FAST_MODE=true
```

## 🔒 Segurança e Conformidade

### Padrões Implementados
- **OWASP Top 10**: Padrões de segurança web
- **CWE**: Common Weakness Enumeration
- **CVSS**: Common Vulnerability Scoring System
- **NIST**: National Institute of Standards and Technology

### Níveis de Severidade
- **Critical (9.0-10.0)**: Bloqueia push
- **High (7.0-8.9)**: Bloqueia push
- **Medium (4.0-6.9)**: Warning
- **Low (0.1-3.9)**: Info

## 🧪 Testes e Validação

### Como Testar
```bash
# 1. Teste básico
bash hooks/security_pre_push.sh

# 2. Teste com pre-commit
pre-commit run --all-files --hook-stage pre-push

# 3. Teste de push
git commit -m "test" --allow-empty
git push

# 4. Verificar logs
tail -f .security-hook.log
```

### Cenários de Teste
1. **Projeto Java limpo**: Todas as verificações passam
2. **Projeto Node.js com vulnerabilidades**: Push bloqueado
3. **Branch desatualizada**: Push bloqueado
4. **Secrets expostos**: Push bloqueado
5. **Ferramentas indisponíveis**: Modo fallback ativado

## 🚀 Exemplos de Uso

### Projeto Java (Spring Boot)
```bash
# 1. Configurar projeto
cp hooks/java-security-config.yaml ./
# Editar configurações específicas

# 2. Instalar hooks
bash hooks/install-security-hooks.sh

# 3. Desenvolver e commitar
git add .
git commit -m "feat: nova API endpoint"
git push  # Hooks executam automaticamente
```

### Projeto Node.js (Express)
```bash
# 1. Configurar projeto
cp hooks/node-security-config.yaml ./
# Editar configurações específicas

# 2. Instalar hooks
bash hooks/install-security-hooks.sh

# 3. Desenvolver e commitar
git add .
git commit -m "feat: middleware de autenticação"
git push  # Hooks executam automaticamente
```

## 🔧 Personalização

### Variáveis de Ambiente
```bash
# Configurações gerais
export DEFAULT_BRANCH="main"
export SECURITY_HOOK_TIMEOUT=300
export SECURITY_HOOK_LOG_LEVEL="INFO"

# Configurações específicas
export SEMGREP_CONFIG="p/owasp-top-ten"
export GITLEAKS_ENABLE=true
export DEPENDENCY_CHECK_ENABLE=true
```

### Configurações Customizadas
```yaml
# hooks/custom-security-config.yaml
sast:
  custom_rules:
    - pattern: "custom_security_pattern"
      message: "Custom security issue detected"
      severity: "high"

dependency_scanning:
  custom_scanners:
    - name: "custom_scanner"
      command: "custom-scan-tool"
      args: ["--scan", "."]
```

## 🐛 Troubleshooting

### Problemas Comuns

#### 1. Hook não executa
```bash
# Verificar instalação
pre-commit --version
pre-commit install --hook-type pre-push

# Verificar permissões
chmod +x hooks/security_pre_push.sh
```

#### 2. Ferramentas não encontradas
```bash
# Instalar ferramentas
bash hooks/install-security-hooks.sh

# Verificar PATH
which semgrep
which gitleaks
```

#### 3. Timeout nas verificações
```bash
# Aumentar timeout
export SECURITY_HOOK_TIMEOUT=600

# Usar modo rápido
export SECURITY_HOOK_FAST_MODE=true
```

#### 4. Falsos positivos
```bash
# Configurar exclusões
# hooks/java-security-config.yaml
secret_detection:
  ignore_files:
    - "**/test-data/**"
    - "**/fixtures/**"
```

### Logs de Debug
```bash
# Habilitar debug
export SECURITY_HOOK_DEBUG=true

# Ver logs detalhados
tail -f .security-hook.log

# Ver logs do pre-commit
pre-commit run --all-files --hook-stage pre-push --verbose
```

## 📚 Recursos Adicionais

### Documentação
- [pre-commit](https://pre-commit.com/)
- [Semgrep](https://semgrep.dev/docs/)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [GitLeaks](https://github.com/zricethezav/gitleaks)

### Ferramentas Relacionadas
- [SonarQube](https://www.sonarqube.org/)
- [Snyk](https://snyk.io/)
- [CodeQL](https://codeql.github.com/)
- [Bandit](https://bandit.readthedocs.io/)

### Comunidade
- [OWASP](https://owasp.org/)
- [Security Headers](https://securityheaders.com/)
- [HackerOne](https://hackerone.com/)

## 🤝 Contribuição

### Como Contribuir
1. Fork o repositório
2. Crie uma branch para sua feature
3. Implemente as mudanças
4. Teste localmente
5. Submeta um Pull Request

### Padrões de Código
- Bash: [ShellCheck](https://www.shellcheck.net/)
- YAML: [yamllint](https://yamllint.readthedocs.io/)
- Documentação: Markdown

### Testes
```bash
# Executar testes
bash hooks/security_pre_push.sh --test

# Validar configurações
yamllint hooks/*.yaml
shellcheck hooks/*.sh
```

## 📄 Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

### Canais de Suporte
- **Issues**: [GitHub Issues](https://github.com/seu-usuario/git-hooks-central/issues)
- **Documentação**: Este README
- **Logs**: `.security-hook.log`

### Informações de Contato
- **Email**: suporte@exemplo.com
- **Slack**: #security-hooks
- **Teams**: Security Hooks Channel

---

**⚠️ Importante**: Este hook é uma camada adicional de segurança. Não substitui outras práticas de segurança como code review, testes automatizados e monitoramento contínuo.
