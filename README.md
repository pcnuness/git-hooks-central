# Git Hooks Central (Framework pre-commit)

Repositório centralizado para armazenar e versionar hooks Git utilizados nos projetos da organização.

## 🔒 Dependências para Validação do Código

- **SAST**: A definir
- **Secret Detection**: GitLeaks (Gitlab Analizer)
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
- `audit-trail`                 → grava artefato local remoto (a definir) auditável para o CI

#### Referencia
- Verificação se a branch do desenvolvedor está à frente da master (Check Ahead)
- Secret Detection conforme documentação: https://docs.gitlab.com/user/application_security/secret_detection/
- Dependency Scanning conforme documentação: https://docs.gitlab.com/user/application_security/dependency_scanning/
- SAST (Static Application Security Testing) conforme documentação: https://docs.gitlab.com/user/application_security/sast/

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
# Instalação framework pre-commit
pip install pre-commit
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
cp examples/pre-commit-config-java.yaml .pre-commit-config.yaml

# Para projetos Node.js
cp examples/pre-commit-config-node.yaml .pre-commit-config.yaml

# Edite as configurações conforme necessário
```

## 📁 Estrutura dos Arquivos

```
hooks/
├── secrets_detection_wrapper.py # Hook de segurança na detecção de credencias
├── dependency_scanning.py       # Hook de Dependencia na validação de biblioteca de dependencia. 
├── deps_audit_fast.sh           # Hook de auditoria
└── branch_ahead_check.sh        # Hook de verificação

examples/
├── pre-commit-config-java.yaml # Configuração de Java
├── pre-commit-config-node.yaml # Configuração de Node
└── eslint.config.js            # ESLint analisa estaticamente seu código para encontrar problemas

scripts/
├── validation.py     # Script de validação de dependencias

docs/
├── ADMIN_GUIDE.md           # Documento de Gestão do repositorio central
├── DEVELOPER_QUICK_START.md # Documento passo a passo para o desenvolvedor trabalhar
└── TROUBLESHOOTING_GUIDE.md # Documento de ajudar para encontrar problemas mapeados
```


## 🔧 Uso

### Execução Automática
Os hooks rodam automaticamente antes de cada `git push`:

```bash
git add .
git commit -m "feat: nova funcionalidade"
git push  # Hooks executam automaticamente
```

### Execução Manual (Desenvolvedor)
```bash
# Instalar o hooks/pre-push (framework pre-commit)
pre-commit install --hook-type pre-push

# Executar todos os hooks de validação (Recomendado antes do Commit/Push)
pre-commit run --all-files --hook-stage pre-push

# Executar hooks específicos
pre-commit run secrets-detection-gitlab --all-files
```

## 📊 Logs e Relatórios

### Arquivo de Log Detalhado (git hooks secrets-detection-gitlab)
- **Localização**: `gl-secret-detection-report.json`
- **Formato**: Json

### Exemplo de Log Secrets Detection
```
[INFO] Configurando ambiente Python...
[SUCCESS] Ambiente Python configurado com sucesso
[INFO] Executando GitLab Secrets Analyzer...
[ERROR] Secrets detectados: 2 vulnerabilidade(s)
[ERROR] Arquivo: gl-secret-detection-report.json
• RSA private key em src/index.js:14 (Severidade: Critical)
• AWS access token em src/index.js:11 (Severidade: Critical)
[ERROR] Revise e remova credenciais antes do push
[INFO] Dicas: rotacione chaves, use variáveis de ambiente, adicione ao .gitignore
```


## 🐛 Troubleshooting

### Problemas Comuns

#### Hook não executa
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

### Logs de Debug
```bash
# Habilitar debug
export SECURITY_HOOK_DEBUG=true

# Ver logs detalhados
tail -f .security-hook.log

# Ver logs do pre-commit
pre-commit run --all-files --hook-stage pre-push --verbose
```

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
git tag -a latest -m "Release: expõe deps-audit-fast e melhorias"
git push origin main
git push origin latest
```

#### Após tag publicada, nos repositórios consumidores:
```
pre-commit clean
pre-commit run --all-files --hook-stage pre-push
```
=======
## 🔐 Detecção de Segredos (GitLab Analyzer)

Este catálogo central inclui um hook de detecção de segredos baseado no GitLab Secrets Analyzer, executado via Docker, para impedir pushes com credenciais acidentalmente commitadas.

- **Imagem**: `registry.gitlab.com/gitlab-org/security-products/analyzers/secrets:latest`
- **Hook**: `secrets-detection-gitlab` (stages: `pre-push`)
- **Execução**: `/analyzer run` dentro do container, com o repositório montado em `/code`

### Como habilitar (exemplo Node.js)
```yaml
- repo: <repositorio-central>.git
  rev: latest
  hooks:
    - id: secrets-detection-gitlab
      stages: [pre-push]
      always_run: true
      pass_filenames: false
```

### O que acontece quando encontra um segredo?
- O push é bloqueado com mensagem de erro
- Você verá instruções onde foi detectado o segredo

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
