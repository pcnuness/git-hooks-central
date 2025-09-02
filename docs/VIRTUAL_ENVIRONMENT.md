# 🐍 **Virtual Environment - Secrets Detection Wrapper**

## 🎯 **Visão Geral**

O script `secrets_detection_wrapper.py` agora inclui gerenciamento automático de virtual environment, garantindo que todas as dependências estejam disponíveis e isoladas do sistema.

## 🔧 **Funcionalidades Implementadas**

### **1. Criação Automática de Virtual Environment**
```python
# O script cria automaticamente um .venv/ no diretório do projeto
.venv/
├── bin/           # Executáveis (Linux/macOS)
├── Scripts/       # Executáveis (Windows)
├── lib/           # Bibliotecas Python
├── include/       # Headers C
└── pyvenv.cfg     # Configuração do venv
```

### **2. Gerenciamento de Dependências**
```python
# Cria requirements.txt automaticamente se não existir
requirements.txt
```

### **3. Compatibilidade Multi-OS**
```python
# Detecta automaticamente o SO e usa o caminho correto
if platform.system().lower() == "windows":
    python_path = venv_path / "Scripts" / "python.exe"
else:
    python_path = venv_path / "bin" / "python"
```

## 🚀 **Como Funciona**

### **1. Primeira Execução**
```bash
python3 hooks/secrets_detection_wrapper.py
```

**O que acontece:**
1. ✅ **Detecta** se `.venv/` existe
2. ✅ **Cria** virtual environment se necessário
3. ✅ **Cria** `requirements.txt` se não existir
4. ✅ **Instala** dependências via pip
5. ✅ **Executa** o detector de segredos

### **2. Execuções Subsequentes**
```bash
python3 hooks/secrets_detection_wrapper.py
```

**O que acontece:**
1. ✅ **Reutiliza** `.venv/` existente
2. ✅ **Verifica** dependências
3. ✅ **Executa** o detector de segredos

## 📁 **Estrutura de Arquivos**

```
projeto/
├── .venv/                    # Virtual environment (criado automaticamente)
│   ├── bin/                  # Executáveis (Linux/macOS)
│   ├── Scripts/              # Executáveis (Windows)
│   ├── lib/                  # Bibliotecas Python
│   └── pyvenv.cfg           # Configuração
├── requirements.txt          # Dependências (criado automaticamente)
├── hooks/
│   └── secrets_detection_wrapper.py
└── gl-secret-detection-report.json  # Relatório (gerado)
```

## 🔧 **Configuração Manual (Opcional)**

### **1. Criar Virtual Environment Manualmente**
```bash
# Linux/macOS
python3 -m venv .venv
source .venv/bin/activate

# Windows
python -m venv .venv
.venv\Scripts\activate
```

### **2. Instalar Dependências Manualmente**
```bash
# Ativar virtual environment
source .venv/bin/activate  # Linux/macOS
# ou
.venv\Scripts\activate     # Windows

# Instalar dependências
pip install -r requirements.txt
```

### **3. Executar Script**
```bash
# Com virtual environment ativado
python hooks/secrets_detection_wrapper.py

# Ou sem ativar (script gerencia automaticamente)
python3 hooks/secrets_detection_wrapper.py
```

## 🎯 **Vantagens do Virtual Environment**

### **✅ Isolamento**
- **Dependências isoladas** do sistema
- **Sem conflitos** com outros projetos
- **Versões específicas** de bibliotecas

### **✅ Portabilidade**
- **Funciona em qualquer SO** com Python 3.6+
- **Dependências versionadas** no requirements.txt
- **Ambiente reproduzível**

### **✅ Manutenção**
- **Fácil limpeza** (apenas deletar .venv/)
- **Atualizações controladas** via pip
- **Backup simples** (requirements.txt)

## 🧪 **Testando o Virtual Environment**

### **1. Verificar Criação**
```bash
ls -la .venv/
# Deve mostrar: bin/, lib/, include/, pyvenv.cfg
```

### **2. Verificar Python**
```bash
# Linux/macOS
.venv/bin/python --version

# Windows
.venv\Scripts\python --version
```

### **3. Verificar Dependências**
```bash
# Ativar virtual environment
source .venv/bin/activate  # Linux/macOS
# ou
.venv\Scripts\activate     # Windows

# Listar pacotes instalados
pip list
```

## 🔍 **Troubleshooting**

### **Problema: Virtual Environment não é criado**
```bash
# Solução: Verificar permissões
chmod +x hooks/secrets_detection_wrapper.py
python3 hooks/secrets_detection_wrapper.py
```

### **Problema: Dependências não são instaladas**
```bash
# Solução: Verificar pip
python3 -m pip --version
python3 -m pip install --upgrade pip
```

### **Problema: Python não encontrado**
```bash
# Solução: Verificar Python 3.6+
python3 --version
# Deve ser 3.6.0 ou superior
```

## 📊 **Performance**

| Aspecto | Sem Virtual Environment | Com Virtual Environment |
|---------|------------------------|-------------------------|
| **Primeira execução** | 2-3s | 5-8s (criação) |
| **Execuções subsequentes** | 2-3s | 2-3s |
| **Isolamento** | ❌ Não | ✅ Sim |
| **Portabilidade** | ⚠️ Limitada | ✅ Completa |
| **Manutenção** | ❌ Difícil | ✅ Fácil |

## 🎉 **Resultado**

**O script agora é verdadeiramente multi-OS e auto-suficiente!**

- ✅ **Cria** virtual environment automaticamente
- ✅ **Instala** dependências automaticamente
- ✅ **Funciona** em Windows, Linux, macOS
- ✅ **Isola** dependências do sistema
- ✅ **Reproduzível** em qualquer ambiente

---

**🚀 Pronto para produção em qualquer SO!**
