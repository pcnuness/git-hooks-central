#!/usr/bin/env python3
"""
=============================================================================
SECRETS DETECTION WRAPPER - GitLab Analyzer (Python Multi-OS)
=============================================================================
Executa o GitLab Secrets Analyzer e força falha se detectar segredos
Compatível com: Windows, Linux, macOS
Inclui gerenciamento automático de virtual environment
=============================================================================
"""

import json
import os
import subprocess
import sys
import platform
import venv
from pathlib import Path
from typing import Dict, List, Optional, Tuple


class Colors:
    """Cores para output (compatível com todos os SOs)"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'
    
    @classmethod
    def disable_colors(cls):
        """Desabilita cores para terminais que não suportam"""
        cls.RED = ''
        cls.GREEN = ''
        cls.YELLOW = ''
        cls.BLUE = ''
        cls.NC = ''


class VirtualEnvironmentManager:
    """Gerenciador de Virtual Environment"""
    
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.venv_path = project_root / ".venv"
        self.venv_python = self._get_venv_python()
        self.requirements_file = project_root / "requirements.txt"
    
    def _get_venv_python(self) -> Path:
        """Obtém o caminho do Python no virtual environment"""
        if platform.system().lower() == "windows":
            return self.venv_path / "Scripts" / "python.exe"
        else:
            return self.venv_path / "bin" / "python"
    
    def create_venv(self) -> bool:
        """Cria o virtual environment se não existir"""
        if self.venv_path.exists():
            return True
        
        try:
            venv.create(self.venv_path, with_pip=True)
            return True
        except Exception as e:
            print(f"[ERROR] Falha ao criar virtual environment: {e}")
            return False
    
    def install_requirements(self) -> bool:
        """Instala as dependências do requirements.txt"""
        if not self.requirements_file.exists():
            self._create_default_requirements()
        
        try:
            cmd = [str(self.venv_python), "-m", "pip", "install", "-r", str(self.requirements_file)]
            subprocess.run(cmd, check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] Falha ao instalar dependências: {e}")
            return False
    
    def _create_default_requirements(self):
        """Cria um requirements.txt padrão se não existir"""
        requirements_content = """# Dependências para Secrets Detection Wrapper
# Python 3.6+ é necessário

# Para parsing JSON (já incluído no Python 3.6+)
# json

# Para subprocess (já incluído no Python 3.6+)
# subprocess

# Para pathlib (já incluído no Python 3.6+)
# pathlib

# Para venv (já incluído no Python 3.6+)
# venv

# Para platform (já incluído no Python 3.6+)
# platform

# Para typing (já incluído no Python 3.6+)
# typing

# Dependências opcionais para melhor performance
# docker>=6.0.0  # Para interação com Docker API (opcional)
# requests>=2.25.0  # Para requisições HTTP (opcional)
"""
        with open(self.requirements_file, 'w', encoding='utf-8') as f:
            f.write(requirements_content)


class SecretsDetector:
    """Detector de segredos usando GitLab Analyzer"""
    
    def __init__(self):
        self.image = "registry.gitlab.com/gitlab-org/security-products/analyzers/secrets:latest"
        self.report_file = "gl-secret-detection-report.json"
        self.project_root = self._get_project_root()
        self.venv_manager = VirtualEnvironmentManager(self.project_root)
        self._setup_colors()
    
    def _get_project_root(self) -> Path:
        """Obtém o diretório raiz do projeto Git"""
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--show-toplevel"],
                capture_output=True,
                text=True,
                check=True
            )
            return Path(result.stdout.strip())
        except (subprocess.CalledProcessError, FileNotFoundError):
            return Path.cwd()
    
    def _setup_colors(self):
        """Configura cores baseado no SO e terminal"""
        system = platform.system().lower()
        
        # Desabilitar cores em Windows CMD (não PowerShell)
        if system == "windows" and os.environ.get("TERM") != "xterm-256color":
            Colors.disable_colors()
        # Desabilitar cores se não suportado
        elif not sys.stdout.isatty():
            Colors.disable_colors()
    
    def log(self, level: str, message: str):
        """Log com cores compatíveis"""
        color_map = {
            "INFO": Colors.BLUE,
            "SUCCESS": Colors.GREEN,
            "WARNING": Colors.YELLOW,
            "ERROR": Colors.RED
        }
        color = color_map.get(level, "")
        print(f"{color}[{level}]{Colors.NC} {message}")
    
    def check_docker(self) -> bool:
        """Verifica se Docker está disponível e rodando"""
        try:
            # Verificar se docker está instalado
            subprocess.run(["docker", "--version"], capture_output=True, check=True)
            
            # Verificar se docker está rodando
            subprocess.run(["docker", "info"], capture_output=True, check=True)
            
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            self.log("ERROR", "Docker não encontrado ou não está em execução.")
            self.log("INFO", "Instale Docker Desktop/Engine e inicie o serviço.")
            return False
    
    def pull_image_if_needed(self) -> bool:
        """Baixa a imagem Docker se necessário"""
        try:
            # Verificar se imagem existe localmente
            result = subprocess.run(
                ["docker", "image", "inspect", self.image],
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                self.log("INFO", "Baixando imagem do GitLab Secrets Analyzer...")
                subprocess.run(
                    ["docker", "pull", self.image],
                    check=True,
                    capture_output=True
                )
            
            return True
        except subprocess.CalledProcessError as e:
            self.log("ERROR", f"Falha ao baixar imagem: {e}")
            return False
    
    def run_analyzer(self) -> bool:
        """Executa o GitLab Secrets Analyzer"""
        self.log("INFO", "Executando GitLab Secrets Analyzer...")
        
        try:
            # Comando Docker
            cmd = [
                "docker", "run", "--rm",
                "-v", f"{self.project_root}:/code",
                "-w", "/code",
                self.image,
                "/analyzer", "run",
                "--full-scan",
                "--excluded-paths=node_modules,dist,build,.git",
                "--artifact-dir=/code"
            ]
            
            # Executar analisador
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            # Verificar se relatório foi gerado
            report_path = self.project_root / self.report_file
            if not report_path.exists():
                self.log("WARNING", f"Relatório não encontrado: {self.report_file}")
                return True
            
            # Analisar relatório
            return self._analyze_report(report_path)
            
        except subprocess.CalledProcessError as e:
            self.log("ERROR", f"Falha ao executar analisador: {e}")
            return False
    
    def _analyze_report(self, report_path: Path) -> bool:
        """Analisa o relatório JSON e verifica vulnerabilidades"""
        try:
            with open(report_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            vulnerabilities = data.get('vulnerabilities', [])
            vuln_count = len(vulnerabilities)
            
            if vuln_count > 0:
                self.log("ERROR", f"Secrets detectados: {vuln_count} vulnerabilidade(s)")
                self.log("ERROR", f"Arquivo: {self.report_file}")
                
                # Mostrar resumo das vulnerabilidades
                for vuln in vulnerabilities:
                    name = vuln.get('name', 'Unknown')
                    file_path = vuln.get('location', {}).get('file', 'Unknown')
                    line = vuln.get('location', {}).get('start_line', 'Unknown')
                    severity = vuln.get('severity', 'Unknown')
                    
                    print(f"• {name} em {file_path}:{line} (Severidade: {severity})")
                
                self.log("ERROR", "Revise e remova credenciais antes do push")
                self.log("INFO", "Dicas: rotacione chaves, use variáveis de ambiente, adicione ao .gitignore")
                return False
            else:
                self.log("SUCCESS", "Nenhum segredo sensível detectado")
                return True
                
        except (json.JSONDecodeError, KeyError, IOError) as e:
            self.log("ERROR", f"Erro ao analisar relatório: {e}")
            return False
    
    def setup_environment(self) -> bool:
        """Configura o ambiente (virtual environment e dependências)"""
        self.log("INFO", "Configurando ambiente Python...")
        
        # Criar virtual environment
        if not self.venv_manager.create_venv():
            return False
        
        # Instalar dependências
        if not self.venv_manager.install_requirements():
            return False
        
        self.log("SUCCESS", "Ambiente Python configurado com sucesso")
        return True
    
    def run(self) -> int:
        """Executa o detector de segredos"""
        # Configurar ambiente primeiro
        if not self.setup_environment():
            return 1
        
        if not self.check_docker():
            return 1
        
        if not self.pull_image_if_needed():
            return 1
        
        if not self.run_analyzer():
            return 1
        
        return 0


def main():
    """Função principal"""
    detector = SecretsDetector()
    exit_code = detector.run()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
