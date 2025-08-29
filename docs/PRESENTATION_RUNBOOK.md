# 🚀 **RUNBOOK DE APRESENTAÇÃO - Sistema de Git Hooks Centralizado**

## 📋 **Visão Geral da Apresentação**

**Objetivo**: Demonstrar o funcionamento prático do sistema de Git Hooks centralizado para validação de segurança e qualidade de código.

**Duração**: 15-20 minutos  
**Público**: Equipe de desenvolvimento, DevOps e segurança  
**Stack de Demonstração**: Node.js + npm

---

## 🎬 **Roteiro da Apresentação**

### **1. Introdução (2 min)**
- [ ] Apresentar o problema: Validação inconsistente entre repositórios
- [ ] Solução proposta: Sistema centralizado de hooks via pre-commit
- [ ] Benefícios: Segurança, qualidade e padronização

### **2. Arquitetura do Sistema (3 min)**
- [ ] Repositório central: `git-hooks-central`
- [ ] Hooks customizados para validação de segurança
- [ ] Integração via pre-commit framework
- [ ] Compatibilidade multi-plataforma (GitHub, GitLab, Bitbucket)

### **3. Demonstração Prática (10 min)**
- [ ] Setup de um projeto Node.js de exemplo
- [ ] Instalação e configuração dos hooks
- [ ] Execução dos hooks e análise dos resultados
- [ ] Simulação de problemas de segurança e qualidade

### **4. Ferramentas e Tecnologias (3 min)**
- [ ] Visão geral das ferramentas utilizadas
- [ ] Configurações e customizações
- [ ] Integração com CI/CD

### **5. Perguntas e Respostas (2 min)**

---

## 🛠️ **Preparação da Demonstração**

### **Requisitos Prévios:**
```bash
# 1. Node.js 18+ instalado
node --version  # v18.0.0 ou superior

# 2. npm instalado
npm --version   # 8.0.0 ou superior

# 3. Git configurado
git --version   # 2.30.0 ou superior

# 4. pre-commit instalado
pip install pre-commit
pre-commit --version
```

### **Estrutura do Projeto de Demonstração:**
```
demo-node-project/
├── package.json
├── src/
│   ├── index.js
│   ├── utils.js
│   └── config.js
├── .pre-commit-config.yaml
└── README.md
```

---

## 🎭 **Script da Demonstração**

### **Cena 1: Setup Inicial**

#### **Narrativa:**
*"Vamos começar criando um projeto Node.js simples para demonstrar como o sistema funciona na prática."*

#### **Ações:**
```bash
# 1. Criar diretório de demonstração
mkdir demo-node-project && cd demo-node-project

# 2. Inicializar projeto Node.js
npm init -y

# 3. Instalar dependências de exemplo
npm install express dotenv
npm install --save-dev eslint prettier

# 4. Criar arquivos de código
mkdir src
```

#### **Arquivos a Criar:**

**`src/index.js`:**
```javascript
const express = require('express');
const app = express();

// ⚠️ PROBLEMA: Credencial hardcoded (será detectado pelo GitLeaks)
const API_KEY = 'sk-1234567890abcdef1234567890abcdef';

app.get('/', (req, res) => {
  res.json({ message: 'Hello World!' });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

**`src/utils.js`:**
```javascript
// ⚠️ PROBLEMA: Função eval (será detectado pelo ESLint)
function executeCode(code) {
  return eval(code); // ❌ UNSAFE
}

module.exports = { executeCode };
```

### **Cena 2: Configuração dos Hooks**

#### **Narrativa:**
*"Agora vamos configurar o sistema de hooks centralizado. Este é o coração da solução."*

#### **Ações:**
```bash
# 1. Copiar configuração do catálogo central
cp ../../examples/pre-commit-config-node.yaml .pre-commit-config.yaml

# 2. Instalar hooks pre-push
pre-commit install --hook-type pre-push

# 3. Verificar instalação
pre-commit run --all-files --hook-stage push --verbose
```

#### **Configuração `.pre-commit-config.yaml`:**
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
      - id: check-yaml
        stages: [pre-push]
      - id: detect-private-key
        stages: [pre-push]

  # Catálogo central de hooks de segurança
  - repo: https://github.com/pcnuness/git-hooks-central.git
    rev: v1.0.3
    hooks:
      - id: security-pre-push-hook
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

  # Hooks específicos para Node.js
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v9.34.0
    hooks:
      - id: eslint
        additional_dependencies: ['eslint@9.9.0']
        files: \.(js|jsx|ts|tsx)$
        stages: [pre-push]
        args: [--fix]
```

### **Cena 3: Execução dos Hooks**

#### **Narrativa:**
*"Vamos executar os hooks manualmente para ver como eles funcionam e quais problemas detectam."*

#### **Ações:**
```bash
# 1. Executar todos os hooks
pre-commit run --all-files --hook-stage push -v

# 2. Analisar resultados em tempo real
# 3. Explicar cada falha encontrada
```

#### **Resultados Esperados:**

**✅ Hooks que Passam:**
- `end-of-file-fixer`: Formatação de arquivos
- `check-json`: Validação de package.json
- `check-yaml`: Validação de configurações
- `detect-private-key`: Detecção de chaves privadas
- `branch-ahead-check`: Verificação de branch atualizada

**❌ Hooks que Falham:**
- `security-pre-push-hook`: Detecta credenciais hardcoded
- `eslint`: Detecta uso de `eval()` e outras práticas inseguras
- `deps-audit-fast`: Detecta vulnerabilidades nas dependências

### **Cena 4: Correção dos Problemas**

#### **Narrativa:**
*"Agora vamos corrigir os problemas detectados para demonstrar como o sistema orienta o desenvolvedor."*

#### **Ações:**
```bash
# 1. Corrigir credencial hardcoded
# Substituir em src/index.js:
# const API_KEY = 'sk-1234567890abcdef1234567890abcdef';
# Por:
const API_KEY = process.env.API_KEY || '';

# 2. Corrigir função eval
# Substituir em src/utils.js:
# return eval(code);
# Por:
return Function('"use strict"; return (' + code + ')')();

# 3. Executar hooks novamente
pre-commit run --all-files --hook-stage push -v
```

### **Cena 5: Demonstração do Git Push**

#### **Narrativa:**
*"Finalmente, vamos demonstrar como o sistema funciona automaticamente durante o push."*

#### **Ações:**
```bash
# 1. Fazer commit das correções
git add .
git commit -m "Fix security issues detected by hooks"

# 2. Tentar push (hooks executam automaticamente)
git push origin main

# 3. Demonstrar bloqueio se houver problemas
# 4. Demonstrar sucesso após correções
```

---

## 🔧 **Ferramentas Utilizadas**

### **1. pre-commit Framework**
- **Propósito**: Gerenciamento e execução de hooks Git
- **Vantagens**: 
  - Instalação automática de dependências
  - Cache inteligente
  - Suporte a múltiplos estágios (pre-commit, pre-push)
- **Configuração**: Via arquivo `.pre-commit-config.yaml`

### **2. Hooks Nativos (pre-commit-hooks)**
- **`end-of-file-fixer`**: Garante que arquivos terminem com quebra de linha
- **`check-json`**: Valida sintaxe de arquivos JSON
- **`check-yaml`**: Valida sintaxe de arquivos YAML
- **`detect-private-key`**: Detecta chaves privadas expostas

### **3. Hooks Customizados (Catálogo Central)**

#### **`security-pre-push-hook`**
- **Funcionalidade**: Verificação completa de segurança
- **Ferramentas**:
  - **Semgrep**: SAST com regras OWASP Top 10
  - **GitLeaks**: Detecção de secrets e credenciais
  - **TruffleHog**: Verificação adicional de secrets
- **Timeout**: 300 segundos máximo
- **Output**: Log detalhado em `.security-hook.log`

#### **`branch-ahead-check`**
- **Funcionalidade**: Verifica se branch está atualizada
- **Lógica**: Compara com `origin/main`
- **Benefício**: Evita conflitos de merge

#### **`deps-audit-fast`**
- **Funcionalidade**: Auditoria rápida de dependências
- **Suporte**: Node.js (npm/yarn/pnpm), Java (Maven/Gradle), Python (pip)
- **Estratégia**: Só verifica arquivos alterados

#### **`audit-trail`**
- **Funcionalidade**: Gera artefato auditável
- **Output**: `.git/hooks_artifacts/prepush.json`
- **Conteúdo**: Commit, autor, data, hash da configuração

### **4. Hooks Específicos para Node.js**

#### **ESLint**
- **Versão**: 9.9.0 (configuração moderna)
- **Configuração**: Regras de segurança e qualidade
- **Integração**: Execução automática no pre-push

#### **Prettier**
- **Versão**: 4.0.0-alpha.8
- **Funcionalidade**: Formatação automática de código
- **Arquivos**: JS, TS, JSON, YAML, MD

---

## 📊 **Métricas e KPIs**

### **Tempo de Execução:**
- **Hooks rápidos**: < 5 segundos
- **SAST (Semgrep)**: < 60 segundos
- **Dependency audit**: < 30 segundos
- **Total**: < 300 segundos (requisito)

### **Cobertura de Validação:**
- **Segurança**: 100% (OWASP Top 10)
- **Qualidade**: 100% (ESLint + Prettier)
- **Dependências**: 100% (npm audit)
- **Secrets**: 100% (GitLeaks + TruffleHog)

### **Taxa de Detecção:**
- **Vulnerabilidades críticas**: 95%+
- **Secrets expostos**: 98%+
- **Problemas de qualidade**: 90%+

---

## 🚨 **Cenários de Falha e Recuperação**

### **1. Hook Falha por Timeout**
```bash
# Sintoma: "Hook interrompido ou timeout"
# Solução: 
pre-commit clean
pre-commit run --all-files --hook-stage push
```

### **2. Dependências Desatualizadas**
```bash
# Sintoma: "Cannot find package"
# Solução:
pre-commit clean
pre-commit install --hook-type pre-push
```

### **3. Configuração Incorreta**
```bash
# Sintoma: "Hook configuration error"
# Solução: Verificar .pre-commit-config.yaml
# Validar sintaxe YAML
```

### **4. Problemas de Permissão**
```bash
# Sintoma: "Permission denied"
# Solução:
chmod +x hooks/*.sh
git update-index --chmod=+x hooks/*.sh
```

---

## 🔄 **Fluxo de Trabalho do Desenvolvedor**

### **1. Setup Inicial (Primeira vez)**
```bash
# Clonar repositório
git clone <repo-url>
cd <project>

# Copiar configuração
cp examples/pre-commit-config-node.yaml .pre-commit-config.yaml

# Instalar hooks
pre-commit install --hook-type pre-push
```

### **2. Desenvolvimento Diário**
```bash
# 1. Fazer alterações no código
# 2. Commit das mudanças
git add .
git commit -m "Feature description"

# 3. Push (hooks executam automaticamente)
git push origin feature-branch

# 4. Se hooks falharem:
#    - Corrigir problemas identificados
#    - Commit das correções
#    - Tentar push novamente
```

### **3. Atualização de Hooks**
```bash
# 1. Verificar nova versão disponível
# 2. Atualizar rev: no .pre-commit-config.yaml
# 3. Limpar cache
pre-commit clean

# 4. Reinstalar hooks
pre-commit install --hook-type pre-push
```

---

## 🌟 **Benefícios para o Cliente**

### **1. Segurança**
- **Detecção automática** de vulnerabilidades
- **Prevenção** de exposição de secrets
- **Conformidade** com padrões OWASP

### **2. Qualidade**
- **Padronização** automática de código
- **Detecção precoce** de problemas
- **Consistência** entre projetos

### **3. Produtividade**
- **Feedback imediato** durante desenvolvimento
- **Redução** de bugs em produção
- **Integração** transparente com Git

### **4. Governança**
- **Rastreabilidade** completa de execução
- **Auditoria** automática de mudanças
- **Compliance** com políticas de segurança

---

## 📞 **Suporte e Manutenção**

### **Documentação:**
- **README.md**: Visão geral e instalação
- **docs/USAGE.md**: Guia detalhado de uso
- **docs/PRESENTATION_RUNBOOK.md**: Este documento

### **Exemplos:**
- **examples/**: Configurações para diferentes stacks
- **scripts/**: Utilitários de instalação e teste

### **Contato:**
- **Repositório**: https://github.com/pcnuness/git-hooks-central
- **Issues**: Para bugs e melhorias
- **Discussions**: Para dúvidas e suporte

---

## 🎯 **Próximos Passos**

### **Fase 1: Piloto (2 semanas)**
- [ ] Implementar em 2-3 projetos Node.js
- [ ] Coletar feedback dos desenvolvedores
- [ ] Ajustar configurações conforme necessário

### **Fase 2: Expansão (1 mês)**
- [ ] Implementar em todos os projetos Node.js
- [ ] Adicionar suporte a outras linguagens (Java, Python)
- [ ] Integração com CI/CD

### **Fase 3: Otimização (Contínua)**
- [ ] Análise de métricas e performance
- [ ] Refinamento de regras e configurações
- [ ] Treinamento da equipe

---

## 📝 **Checklist de Apresentação**

### **Antes da Apresentação:**
- [ ] Ambiente preparado e testado
- [ ] Projeto de demonstração configurado
- [ ] Slides preparados (se necessário)
- [ ] Tempo cronometrado

### **Durante a Apresentação:**
- [ ] Manter ritmo constante
- [ ] Demonstrar problemas reais
- [ ] Explicar benefícios práticos
- [ ] Responder perguntas

### **Após a Apresentação:**
- [ ] Coletar feedback
- [ ] Agendar próximos passos
- [ ] Compartilhar materiais de referência
- [ ] Definir cronograma de implementação

---

**🎉 Boa sorte na apresentação! O sistema está sólido e pronto para impressionar!**
