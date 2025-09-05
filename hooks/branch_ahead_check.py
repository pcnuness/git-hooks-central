#!/usr/bin/env python3
"""
=============================================================================
BRANCH AHEAD CHECK - Python Multi-OS
=============================================================================
Verifica se a branch atual está atualizada em relação à branch principal
Compatível com: Windows, Linux, macOS
=============================================================================
"""

import subprocess
import sys
import os
from pathlib import Path


class Colors:
    """Cores para output (compatível com todos os SOs)"""
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    
    @classmethod
    def disable_colors(cls):
        """Desabilita cores para terminais que não suportam"""
        cls.RED = ''
        cls.GREEN = ''
        cls.YELLOW = ''
        cls.BLUE = ''
        cls.RESET = ''


def setup_colors():
    """Configura cores baseado no SO e terminal"""
    import platform
    
    system = platform.system().lower()
    
    # Desabilitar cores em Windows CMD (não PowerShell)
    if system == "windows" and os.environ.get("TERM") != "xterm-256color":
        Colors.disable_colors()
    # Desabilitar cores se não suportado
    elif not sys.stdout.isatty():
        Colors.disable_colors()


def run_command(command):
    """Executa um comando no shell e retorna o resultado."""
    try:
        result = subprocess.run(
            command,
            check=True,       # Lança exceção se o comando falhar
            capture_output=True, # Captura stdout e stderr
            text=True         # Decodifica a saída como texto
        )
        return result.stdout.strip()
    except FileNotFoundError:
        print(f"{Colors.RED}Erro: O comando '{command[0]}' não foi encontrado. O Git está instalado e no PATH do sistema?{Colors.RESET}")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"{Colors.RED}Erro ao executar o comando: {' '.join(command)}{Colors.RESET}")
        if e.stderr.strip():
            print(f"Stderr: {e.stderr.strip()}")
        sys.exit(1)


def get_default_branch():
    """Obtém a branch padrão do repositório"""
    try:
        # Tentar obter a branch padrão do repositório
        result = subprocess.run(
            ["git", "symbolic-ref", "refs/remotes/origin/HEAD"],
            capture_output=True,
            text=True,
            check=True
        )
        # Extrair nome da branch (ex: refs/remotes/origin/main -> main)
        return result.stdout.strip().split('/')[-1]
    except subprocess.CalledProcessError:
        # Fallback: usar variável de ambiente ou padrão
        return os.environ.get("DEFAULT_BRANCH", "main")


def main():
    """Função principal que executa a verificação de sincronia."""
    # Configurar cores
    setup_colors()
    
    # Obter branch padrão
    main_branch = get_default_branch()
    
    # 1. Obter o nome da branch atual
    current_branch = run_command(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    
    # Se estiver na branch principal, não há necessidade de verificar
    if current_branch == main_branch:
        print(f"{Colors.YELLOW}Check pulado: Você já está na branch '{main_branch}'.{Colors.RESET}")
        sys.exit(0)
    
    print(f"Verificando se a branch '{current_branch}' está sincronizada com '{main_branch}'...")
    
    # 2. Buscar as atualizações mais recentes do repositório remoto (sem fazer merge)
    print("Buscando atualizações do repositório remoto (git fetch)...")
    run_command(["git", "fetch", "origin", main_branch, "--quiet"])
    
    # 3. Verificar se a branch atual está à frente da origin/main
    # Usar merge-base para verificar se origin/main é ancestral de HEAD
    try:
        run_command(["git", "merge-base", "--is-ancestor", f"origin/{main_branch}", "HEAD"])
        # Se chegou aqui, origin/main é ancestral de HEAD, então está atualizada
        print(f"{Colors.GREEN}✅ Branch atualizada em relação a origin/{main_branch}.{Colors.RESET}")
        sys.exit(0)
    except subprocess.CalledProcessError:
        # origin/main não é ancestral de HEAD, então a branch está desatualizada
        print(f"\n{Colors.RED}❌ Sua branch não está atualizada com origin/{main_branch}.{Colors.RESET}")
        print("   Atualize antes de dar push: git pull --rebase origin", main_branch)
        print(f"{Colors.YELLOW}   (ou 'git merge origin/{main_branch}' se preferir){Colors.RESET}")
        sys.exit(1)


if __name__ == "__main__":
    main()
