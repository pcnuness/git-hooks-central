# Git Hooks Central

Repositório centralizado para armazenar e versionar hooks Git utilizados nos projetos da organização.

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
pip install pre-commit
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
