# 🚀 **Guia Rápido para Desenvolvedores**

## ⚡ **Setup em 5 Minutos**

### **1. Instalar Dependências**
```bash
# Python 3.6+ (obrigatório)
python3 --version

# Docker (obrigatório)
docker --version
docker info  # Deve estar rodando

# Git (obrigatório)
git --version
```

### **2. Configurar Projeto**
```bash
# No seu repositório
cat > .pre-commit-config.yaml << 'EOF'
repos:
  # Hooks básicos
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: end-of-file-fixer
        stages: [pre-push]
      - id: check-json
        stages: [pre-push]
      - id: detect-private-key
        stages: [pre-push]

  # Catálogo central
  - repo: https://github.com/pcnuness/git-hooks-central.git
    rev: v1.0.3
    hooks:
      - id: branch-ahead-check
        stages: [pre-push]
        pass_filenames: false
      
      - id: audit-trail
        stages: [pre-push]
        pass_filenames: false
      
      - id: secrets-detection-gitlab
        stages: [pre-push]
        always_run: true
        pass_filenames: false
EOF
```

### **3. Instalar Hooks**
```bash
# Instalar pre-commit
pip install pre-commit

# Instalar hooks
pre-commit install --hook-type pre-push

# Testar
pre-commit run --all-files --hook-stage push
```

## 🎯 **Uso Diário**

### **Fluxo Normal**
```bash
# 1. Desenvolver
git add .
git commit -m "feat: nova funcionalidade"

# 2. Push (hooks executam automaticamente)
git push origin feature-branch

# ✅ Se passar: push liberado
# ❌ Se falhar: push bloqueado + instruções
```

### **Comandos Úteis**
```bash
# Executar todos os hooks
pre-commit run --all-files --hook-stage push

# Executar hook específico
pre-commit run secrets-detection-gitlab --all-files --hook-stage push

# Limpar cache
pre-commit clean

# Verificar hooks instalados
ls -la .git/hooks/
```

## 🔧 **Problemas Comuns**

### **Push Bloqueado por Segredos**
```bash
# ❌ Erro:
[ERROR] Secrets detectados: 1 vulnerabilidade(s)
• AWS access token em src/index.js:11 (Severidade: Critical)

# ✅ Solução:
# 1. Remover o segredo do código
# 2. Usar variável de ambiente
const apiKey = process.env.AWS_ACCESS_KEY_ID;
# 3. Adicionar ao .gitignore
echo ".env" >> .gitignore
```

### **Branch Desatualizada**
```bash
# ❌ Erro:
❌ Branch não está atualizada em relação a origin/main.

# ✅ Solução:
git pull origin main
git push origin feature-branch
```

### **Docker não Encontrado**
```bash
# ❌ Erro:
[ERROR] Docker não encontrado ou não está em execução.

# ✅ Solução:
# Windows: Instalar Docker Desktop
# Linux: sudo apt-get install docker.io
# macOS: brew install --cask docker
```

## 📋 **Checklist de Segurança**

### **Antes do Push**
- [ ] Nenhum segredo hardcoded no código
- [ ] Variáveis de ambiente configuradas
- [ ] .gitignore atualizado
- [ ] Branch atualizada com main
- [ ] Testes passando localmente

### **Secrets Detectados**
- [ ] Rotacionar credenciais imediatamente
- [ ] Remover do código
- [ ] Usar variáveis de ambiente
- [ ] Atualizar documentação
- [ ] Notificar equipe se necessário

## 🆘 **Emergência**

### **Bypass Temporário (APENAS EMERGÊNCIA)**
```bash
# ⚠️ CUIDADO: Use apenas em emergências
git push --no-verify

# Ou comentar hook no .pre-commit-config.yaml
# - id: secrets-detection-gitlab
#   stages: [pre-push]
```

### **Contato de Suporte**
- **Issues**: [GitHub Issues](https://github.com/pcnuness/git-hooks-central/issues)
- **Documentação**: [docs/COMPLETE_USAGE_GUIDE.md](docs/COMPLETE_USAGE_GUIDE.md)

## 🎉 **Pronto!**

Agora você está configurado para desenvolver com segurança! Os hooks vão proteger seu código automaticamente.

**Lembre-se**: Os hooks são seus amigos, não inimigos. Eles protegem você e sua equipe de problemas de segurança! 🛡️
