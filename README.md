# Git Hooks Central (Framework pre-commit)

Repositório centralizado para armazenar e versionar hooks Git utilizados nos projetos da organização.

## 🔒 Dependências para Validação do Código

- **SAST**: Semgrep com regras OWASP Top 10
- **Secret Detection**: GitLeaks + TruffleHog (dupla verificação)
- **Dependency Scanning**: OWASP Dependency-Check para Java
- **Code Quality**: Hooks nativos do pre-commit

## 🚀 Funcionalidades Principais
## Hooks disponíveis (pre-push)
### Default (rápidos)
- `end-of-file-fixer`           → garante newline final
- `check-json`, `check-xml`, `check-yaml` → valida sintaxe
- `detect-private-key`          → bloqueia chaves privadas

### Custom
- `branch-ahead-check`          → verifica se a branch está atualizada com a default
- `sast-semantic-fast`          → SAST leve/semântico (ex.: semgrep)
- `deps-audit-fast`             → auditoria de dependências rápida por stack
- `audit-trail`                 → grava artefato local auditável para o CI

#### Referencia
- SAST (Static Application Security Testing) conforme documentação: https://docs.gitlab.com/user/application_security/sast/
- Verificação se a branch do desenvolvedor está à frente da master (Check Ahead)
- Dependency Scanning conforme documentação: https://docs.gitlab.com/user/application_security/dependency_scanning/
- Secret Detection conforme documentação: https://docs.gitlab.com/user/application_security/secret_detection/

## Requisitos
- Mecanismo de prevenção a bypass:
  - A) Artefato assinado/hasheado validado no CI
  - B) Backstop no pipeline (fail se hooks não passarem)
- Resultado auditável salvo para validação do pipeline
- Hooks executados apenas no estágio `pre-push`


## SAST (Static Application Security Testing)

### Ferramentas Sugeridas (CLI para uso local):
Java: 
 * pmd.github.io
 * spotbugs.github.io

Node.js: 
 * eslint.org

## Como usar

### Instalação
```bash
<<<<<<< HEAD
# Instalação automática via script
bash scripts/install-security-hooks.sh

# Ou instalação manual
pip install pre-commit semgrep trufflehog
brew install gitleaks dependency-check
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
├── java-security-config.yaml     # Configuração para Java
├── node-security-config.yaml     # Configuração para Node.js
├── sast_semantic_fast.sh        # Hook SAST rápido (legado)
├── deps_audit_fast.sh           # Hook de auditoria (legado)
└── branch_ahead_check.sh        # Hook de verificação (legado)

examples/
├── demo-security-hook.sh        # Script de demonstração
├── pre-commit-config-example.yaml # Configuração de exemplo
└── env.example                  # Variáveis de ambiente

scripts/
├── install-security-hooks.sh     # Script de instalação

SECURITY_HOOKS_README.md         # Documentação completa
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
# Instalar o hooks/pre-push (framework pre-commit)
pre-commit install --hook-type pre-push

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
=======
pip install pre-commit
>>>>>>> parent of 1740c05 (initial project)
pre-commit install --hook-type pre-push
```

### Validação
```bash
pre-commit run --all-files --hook-stage push -v
```

### Atualizar repositorio central
```bash
pre-commit autoupdate --repo https://github.com/pcnuness/git-hooks-central.git
```
<<<<<<< HEAD

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
- **Documentação**: [SECURITY_HOOKS_README.md](SECURITY_HOOKS_README.md)
- **Logs**: `.security-hook.log`

### Informações de Contato
- **Email**: suporte@exemplo.com
- **Slack**: #security-hooks
- **Teams**: Security Hooks Channel

---

**⚠️ Importante**: Este hook é uma camada adicional de segurança. Não substitui outras práticas de segurança como code review, testes automatizados e monitoramento contínuo.

## 📋 Status dos Hooks Existentes

Os seguintes hooks já estão implementados e funcionando:

- ✅ `end-of-file-fixer` - Corrige final de arquivos
- ✅ `check-xml` - Valida arquivos XML
- ✅ `check-yaml` - Valida arquivos YAML
- ✅ `check-json` - Valida arquivos JSON
- ✅ `detect-private-key` - Detecta chaves privadas
- ✅ `eslint` - Linting para JavaScript/TypeScript
- ✅ `black` - Formatação de código Python
- ✅ `flake8` - Linting para Python
- ✅ `golangci-lint` - Linting para Go

## 🆕 Hooks de Segurança Adicionados

Novos hooks robustos de segurança implementados:

- 🆕 `security-pre-push-hook` - Hook principal de segurança
- 🆕 `branch-ahead-check` - Verificação de branch atualizada
- 🆕 `sast-semantic-fast` - SAST rápido com Semgrep
- 🆕 `deps-audit-fast` - Auditoria rápida de dependências



## Como os times de projeto usam
### Instalar pre-commit e os hooks:
Fluxo para publicar novas versões/tags do repositório central
Commitar mudanças e criar tag semântica:

```bash
git checkout -b release/v1.0.0
git add -A
git commit -m "feat: adiciona security-pre-push-hook e integrações SAST/DS/Secrets"
git tag -a v1.0.0 -m "Primeira release com hooks de segurança"
git push origin release/v1.0.0
git push origin v1.0.0
```

#### Publicar incrementos:
  - Patch (correções): v1.0.1
  - Minor (novos hooks/opcionais): v1.1.0
  - Major (breaking changes): v2.0.0

```
git checkout -b release/v1.1.0
git add -A
git commit -m "feat: expõe id 'deps-audit-fast' no catálogo de hooks"
git tag -a v1.1.0 -m "Release: expõe deps-audit-fast e melhorias"
git push origin release/v1.1.0
git push origin v1.1.0
```

#### Após tag publicada, nos repositórios consumidores:
```
pre-commit autoupdate --repo https://github.com/pcnuness/git-hooks-central.git
git add .pre-commit-config.yaml
git commit -m "chore(pre-commit): atualiza git-hooks-central para v1.1.0"
```
=======
>>>>>>> parent of 1740c05 (initial project)

## 🔐 Detecção de Segredos (GitLab Analyzer)

Este catálogo central inclui um hook de detecção de segredos baseado no GitLab Secrets Analyzer, executado via Docker, para impedir pushes com credenciais acidentalmente commitadas.

- **Imagem**: `registry.gitlab.com/gitlab-org/security-products/analyzers/secrets:latest`
- **Hook**: `secrets-detection-gitlab` (stages: `pre-push`)
- **Execução**: `./analyzer run` dentro do container, com o repositório montado em `/code`

### Como habilitar (exemplo Node.js)
```yaml
- repo: https://github.com/pcnuness/git-hooks-central.git
  rev: v1.0.3
  hooks:
    - id: secrets-detection-gitlab
      stages: [pre-push]
      always_run: true
      pass_filenames: false
```

### O que acontece quando encontra um segredo?
- O push é bloqueado com mensagem de erro
- Você verá instruções para remover/rotacionar o segredo

### Como corrigir
1. Remova o valor sensível do código/configuração
2. Rotacione a credencial no provedor (AWS, GitHub, etc.)
3. Regrave o histórico se necessário (caso tenha sido commitado):
   ```bash
   git reset HEAD~1  # ou git revert <commit>
   ```
4. Use variáveis de ambiente/secret manager (AWS Secrets Manager, SSM, Vault)
5. Refaça o commit e tente o push novamente

### Pré-requisitos
- Docker em execução (Desktop no macOS/Windows; Engine no Linux)
