# Git Hooks Central

Repositório centralizado para armazenar e versionar hooks Git utilizados nos projetos da organização.

## Hooks disponíveis (pre-push)
### Default (rápidos)
- `end-of-file-fixer`           → garante newline final
- `check-json`, `check-xml`, `check-yaml` → valida sintaxe
- `detect-private-key`          → bloqueia chaves privadas
- `detect-secrets`              → detecção leve de segredos (com baseline)

### Custom
- `branch-ahead-check`          → verifica se a branch está atualizada com a default
- `sast-semantic-fast`          → SAST leve/semântico (ex.: semgrep)
- `deps-audit-fast`             → auditoria de dependências rápida por stack
- `audit-trail`                 → grava artefato local auditável para o CI

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
```bash
pip install pre-commit
pre-commit install --hook-type pre-push
```

### Atualizar repositorio central
```bash
pre-commit autoupdate --repo https://github.com/pcnuness/git-hooks-central.git
```
