#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# DEMONSTRAÇÃO DOS HOOKS DE SEGURANÇA
# =============================================================================
# Script para demonstrar o funcionamento dos hooks de segurança
# =============================================================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função de logging
log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# Função para criar projeto de exemplo
create_java_project() {
    log "INFO" "Criando projeto Java de exemplo..."
    
    mkdir -p demo-java/src/main/java/com/example
    mkdir -p demo-java/src/main/resources
    
    # Criar pom.xml
    cat > demo-java/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>demo-security</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    
    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <version>2.7.0</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
            <version>2.7.0</version>
        </dependency>
    </dependencies>
</project>
EOF

    # Criar classe Java com vulnerabilidade de exemplo
    cat > demo-java/src/main/java/com/example/SecurityDemo.java << 'EOF'
package com.example;

import org.springframework.web.bind.annotation.*;
import java.sql.*;

@RestController
@RequestMapping("/api")
public class SecurityDemo {
    
    // VULNERABILIDADE: SQL Injection
    @GetMapping("/users")
    public String getUsers(@RequestParam String id) {
        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/db");
            Statement stmt = conn.createStatement();
            // VULNERABILIDADE: Concatenção direta de string
            ResultSet rs = stmt.executeQuery("SELECT * FROM users WHERE id = " + id);
            return "Users found";
        } catch (SQLException e) {
            return "Error: " + e.getMessage();
        }
    }
    
    // VULNERABILIDADE: Hardcoded credentials
    private static final String DB_PASSWORD = "admin123";
    private static final String API_KEY = "sk-1234567890abcdef";
    
    @PostMapping("/login")
    public String login(@RequestParam String username, @RequestParam String password) {
        if ("admin".equals(username) && DB_PASSWORD.equals(password)) {
            return "Login successful";
        }
        return "Login failed";
    }
}
EOF

    log "SUCCESS" "Projeto Java criado em demo-java/"
}

# Função para criar projeto Node.js de exemplo
create_node_project() {
    log "INFO" "Criando projeto Node.js de exemplo..."
    
    mkdir -p demo-node/src
    mkdir -p demo-node/config
    
    # Criar package.json
    cat > demo-node/package.json << 'EOF'
{
  "name": "demo-security-node",
  "version": "1.0.0",
  "description": "Demo project for security hooks",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "express": "^4.18.0",
    "sqlite3": "^5.0.0",
    "bcrypt": "^5.0.0"
  },
  "devDependencies": {
    "eslint": "^8.0.0",
    "eslint-plugin-security": "^1.7.0"
  }
}
EOF

    # Criar arquivo principal com vulnerabilidades
    cat > demo-node/src/index.js << 'EOF'
const express = require('express');
const sqlite3 = require('sqlite3');
const bcrypt = require('bcrypt');

const app = express();
app.use(express.json());

// VULNERABILIDADE: Hardcoded secrets
const API_SECRET = 'sk-1234567890abcdef';
const DB_PASSWORD = 'admin123';
const JWT_SECRET = 'my-super-secret-jwt-key';

// VULNERABILIDADE: SQL Injection
app.get('/users/:id', (req, res) => {
    const userId = req.params.id;
    const db = new sqlite3.Database('./database.db');
    
    // VULNERABILIDADE: Concatenção direta de string
    const query = `SELECT * FROM users WHERE id = ${userId}`;
    
    db.get(query, (err, row) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(row);
        }
    });
});

// VULNERABILIDADE: Weak password hashing
app.post('/register', async (req, res) => {
    const { username, password } = req.body;
    
    // VULNERABILIDADE: Salt fixo e poucas iterações
    const saltRounds = 1;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    res.json({ message: 'User registered', hash: hashedPassword });
});

// VULNERABILIDADE: Exposed environment variables
app.get('/config', (req, res) => {
    res.json({
        nodeEnv: process.env.NODE_ENV,
        port: process.env.PORT,
        database: process.env.DATABASE_URL
    });
});

app.listen(3000, () => {
    console.log('Server running on port 3000');
});
EOF

    # Criar .eslintrc
    cat > demo-node/.eslintrc << 'EOF'
{
  "env": {
    "node": true,
    "es2021": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:security/recommended"
  ],
  "plugins": ["security"],
  "parserOptions": {
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "rules": {
    "security/detect-object-injection": "error",
    "security/detect-non-literal-regexp": "error"
  }
}
EOF

    log "SUCCESS" "Projeto Node.js criado em demo-node/"
}

# Função para demonstrar hooks de segurança
demonstrate_security_hooks() {
    local project_dir="$1"
    local project_type="$2"
    
    log "INFO" "Demonstrando hooks de segurança para $project_type em $project_dir..."
    
    cd "$project_dir" || exit 1
    
    # Inicializar git
    if [[ ! -d ".git" ]]; then
        git init
        git config user.name "Demo User"
        git config user.email "demo@example.com"
    fi
    
    # Adicionar arquivos
    git add .
    git commit -m "Initial commit with security vulnerabilities" || true
    
    # Executar hook de segurança
    log "INFO" "Executando hook de segurança..."
    if [[ -f "../hooks/security_pre_push.sh" ]]; then
        bash ../hooks/security_pre_push.sh
    else
        log "WARNING" "Hook de segurança não encontrado. Execute o instalador primeiro."
    fi
    
    cd ..
}

# Função para mostrar resultados
show_results() {
    log "INFO" "=== RESULTADOS DA DEMONSTRAÇÃO ==="
    echo
    
    log "INFO" "Projetos criados:"
    log "INFO" "  - demo-java/: Projeto Java com vulnerabilidades"
    log "INFO" "  - demo-node/: Projeto Node.js com vulnerabilidades"
    echo
    
    log "INFO" "Vulnerabilidades incluídas para demonstração:"
    log "INFO" "  - SQL Injection"
    log "INFO" "  - Hardcoded credentials"
    log "INFO" "  - Weak password hashing"
    log "INFO" "  - Exposed secrets"
    echo
    
    log "INFO" "Para testar os hooks:"
    log "INFO" "  1. cd demo-java ou demo-node"
    log "INFO" "  2. bash ../hooks/security_pre_push.sh"
    log "INFO" "  3. Ver logs em .security-hook.log"
    echo
    
    log "INFO" "Para instalar hooks em um projeto real:"
    log "INFO" "  bash hooks/install-security-hooks.sh"
}

# Função principal
main() {
    log "INFO" "=== DEMONSTRAÇÃO DOS HOOKS DE SEGURANÇA ==="
    echo
    
    # Criar diretório de exemplos
    mkdir -p examples
    cd examples
    
    # Criar projetos de exemplo
    create_java_project
    create_node_project
    
    # Demonstrar hooks (se disponíveis)
    if [[ -f "../hooks/security_pre_push.sh" ]]; then
        demonstrate_security_hooks "demo-java" "Java"
        demonstrate_security_hooks "demo-node" "Node.js"
    fi
    
    # Mostrar resultados
    show_results
    
    log "SUCCESS" "Demonstração concluída!"
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
