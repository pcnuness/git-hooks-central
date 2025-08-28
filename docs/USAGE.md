# Git Hooks Central - Guia de Uso

## 📋 Visão Geral

Este sistema centraliza Git hooks de segurança e conformidade via pre-commit, executando no estágio `pre-push` para validações rápidas (<300s) antes do push. Os hooks são versionados por tags e consumidos por repositórios remotos.

## 🏗️ Arquitetura

### Catálogo Central (Este Repositório)
- **Localização**: https://github.com/pcnuness/git-hooks-central.git
- **Versionamento**: Sempre via tags (ex: `v1.0.0`, `v1.1.0`)
- **Stages**: Apenas `pre-push` para execução local rápida
- **Hooks Custom**: Segurança, auditoria, verificação de branch

### Repositórios Consumidores
- **Configuração**: `.pre-commit-config.yaml` com `rev: vX.Y.Z`
- **Hooks Default**: Validações rápidas (end-of-file, JSON, XML, YAML)
- **Hooks Custom**: Do catálogo central + específicos por stack

## 🚀 Instalação e Configuração

### 1. No Repositório Consumidor

```bash
# Instalar pre-commit
pip install pre-commit

# Instalar hooks pre-push
pre-commit install --hook-type pre-push

# Verificar instalação
pre-commit run --all-files --hook-stage push -v
```

### 2. Configuração do .pre-commit-config.yaml

```yaml
repos:
  # Hooks nativos e rápidos
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: end-of-file-fixer
        stages: [pre-push]
      - id: check-json
        stages: [pre-push]
      - id: check-xml
        stages: [pre-push]
      - id: check-yaml
        stages: [pre-push]
      - id: detect-private-key
        stages: [pre-push]
      - id: detect-secrets
        stages: [pre-push]

  # Catálogo central (SEMPRE usar tag específica)
  - repo: https://github.com/pcnuness/git-hooks-central.git
    rev: v1.0.0  # ⚠️ NUNCA usar main ou latest
    hooks:
      - id: audit-trail
        stages: [pre-push]
        pass_filenames: false
      - id: branch-ahead-check
        stages: [pre-push]
        pass_filenames: false
      - id: deps-audit-fast
        stages: [pre-push]
        pass_filenames: false
      - id: sast-semantic-fast
        stages: [pre-push]
        pass_filenames: false

  # Hooks específicos por stack (opcional)
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v9.34.0
    hooks:
      - id: eslint
        additional_dependencies: ['eslint@9.9.0']
        files: \.(js|jsx|ts|tsx)$
        stages: [pre-push]
```

## 🔧 Hooks Disponíveis

### Hooks Custom do Catálogo

| Hook ID | Descrição | Tempo Estimado |
|----------|-----------|----------------|
| `audit-trail` | Gera artefato auditável | <5s |
| `branch-ahead-check` | Verifica branch atualizada | <2s |
| `deps-audit-fast` | Auditoria rápida de dependências | <30s |
| `sast-semantic-fast` | SAST leve com semgrep | <60s |

### Hooks Default (pre-commit-hooks)

| Hook ID | Descrição | Tempo Estimado |
|----------|-----------|----------------|
| `end-of-file-fixer` | Corrige final de arquivos | <1s |
| `check-json` | Valida JSON | <1s |
| `check-xml` | Valida XML | <1s |
| `check-yaml` | Valida YAML | <1s |
| `detect-private-key` | Detecta chaves privadas | <5s |
| `detect-secrets` | Detecta secrets | <10s |

## 📊 Artefato de Auditoria

O hook `audit-trail` gera um arquivo JSON em `.git/hooks_artifacts/prepush.json`:

```json
{
  "commit": "abc123...",
  "author": "Dev Name <dev@company.com>",
  "date": "2024-01-15T10:30:00Z",
  "precommit_config_sha1": "def456...",
  "status": "passed-local"
}
```

### Validação no CI (Opcional)

```yaml
# .gitlab-ci.yml ou similar
validate_prepush_artifact:
  script:
    - test -f .git/hooks_artifacts/prepush.json
    - jq -e '.status == "passed-local"' .git/hooks_artifacts/prepush.json
```

## 🧪 Testes e Validação

### Comandos de Teste

```bash
# Limpar cache e reinstalar
pre-commit clean
pre-commit install --hook-type pre-push

# Executar todos os hooks pre-push
pre-commit run --all-files --hook-stage push -v

# Executar hook específico
pre-commit run audit-trail --all-files --hook-stage push -v

# Verificar status
pre-commit run --all-files --hook-stage push --show-diff-on-failure
```

### Pipeline de Validação (Backstop)

```yaml
# .gitlab-ci.yml
pre-commit-validation:
  stage: test
  script:
    - pip install pre-commit
    - pre-commit run --all-files --hook-stage push
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

## 🔄 Atualização de Versão

### 1. Atualizar Tag no Catálogo

```bash
# No repositório central
git tag v1.1.0
git push origin v1.1.0
```

### 2. Atualizar no Repositório Consumidor

```yaml
# .pre-commit-config.yaml
- repo: https://github.com/pcnuness/git-hooks-central.git
  rev: v1.1.0  # Atualizar tag
```

### 3. Limpar e Reinstalar

```bash
pre-commit clean
pre-commit install --hook-type pre-push
pre-commit run --all-files --hook-stage push -v
```

## 🚨 Troubleshooting

### Problemas Comuns

#### Hook Falha com Permissão
```bash
# Corrigir permissões
git update-index --chmod=+x hooks/*.sh
# Ou
chmod +x hooks/*.sh
```

#### Cache Corrompido
```bash
# Limpar cache
pre-commit clean
# Reinstalar
pre-commit install --hook-type pre-push
```

#### Hook Muito Lento
```bash
# Verificar tempo de execução
time pre-commit run --all-files --hook-stage push -v

# Se >300s, mover para CI ou otimizar
```

#### Falha no Branch Check
```bash
# Atualizar branch
git fetch origin main
git pull --rebase origin main
```

### Logs e Debug

```bash
# Executar com verbose
pre-commit run --all-files --hook-stage push -v

# Ver logs detalhados
pre-commit run --all-files --hook-stage push --verbose
```

## 📋 Checklist de Implementação

### Para Repositório Consumidor

- [ ] Instalar pre-commit: `pip install pre-commit`
- [ ] Criar `.pre-commit-config.yaml` com hooks necessários
- [ ] Configurar `rev: vX.Y.Z` (tag específica)
- [ ] Instalar hooks: `pre-commit install --hook-type pre-push`
- [ ] Testar: `pre-commit run --all-files --hook-stage push -v`
- [ ] Configurar CI para validação (opcional)
- [ ] Documentar processo para desenvolvedores

### Para CI/CD

- [ ] Adicionar step de validação pre-commit
- [ ] Configurar validação do artefato `prepush.json` (opcional)
- [ ] Definir timeout adequado (<300s)
- [ ] Configurar falha em caso de erro

## 🔒 Segurança e Boas Práticas

### Regras Obrigatórias

1. **NUNCA usar referências mutáveis** (`main`, `latest`) em `rev:`
2. **SEMPRE usar tags específicas** (`v1.0.0`, `v1.1.0`)
3. **Manter pre-push <300s** para não impactar produtividade
4. **Não editar arquivos** do repositório durante pre-push
5. **Usar scripts POSIX** para compatibilidade multi-OS

### Recomendações

1. **Validação no CI** como backstop para hooks locais
2. **Artefato de auditoria** para compliance e auditoria
3. **Hooks específicos por stack** apenas quando necessário
4. **Documentação clara** para desenvolvedores
5. **Processo de rollback** para problemas críticos

## 📞 Suporte

### Recursos Adicionais

- [Documentação pre-commit](https://pre-commit.com/)
- [Hooks disponíveis](https://pre-commit.com/hooks.html)
- [Configuração avançada](https://pre-commit.com/#advanced)

### Contato

Para suporte técnico ou sugestões de melhoria, abra uma issue no repositório central.
