@echo off
REM =============================================================================
REM SECRETS DETECTION WRAPPER - GitLab Analyzer (Windows)
REM =============================================================================
REM Executa o GitLab Secrets Analyzer e força falha se detectar segredos
REM Compatível com: Windows (CMD/PowerShell)
REM =============================================================================

setlocal enabledelayedexpansion

set IMAGE=registry.gitlab.com/gitlab-org/security-products/analyzers/secrets:latest
set REPORT_FILE=gl-secret-detection-report.json

REM Detectar diretório do projeto
for /f "tokens=*" %%i in ('git rev-parse --show-toplevel 2^>nul') do set PROJECT_ROOT=%%i
if "%PROJECT_ROOT%"=="" set PROJECT_ROOT=%CD%

echo [INFO] Executando GitLab Secrets Analyzer...

REM Verificar se Docker está disponível
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker não encontrado. Instale Docker Desktop.
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker não está em execução. Inicie o Docker Desktop.
    exit /b 1
)

REM Baixar imagem se necessário
docker image inspect %IMAGE% >nul 2>&1
if errorlevel 1 (
    echo [INFO] Baixando imagem do GitLab Secrets Analyzer...
    docker pull %IMAGE% >nul
)

REM Executar analisador
docker run --rm -v "%PROJECT_ROOT%:/code" -w /code %IMAGE% /analyzer run --full-scan --excluded-paths=node_modules,dist,build,.git --artifact-dir=/code

REM Verificar se relatório foi gerado
if not exist "%PROJECT_ROOT%\%REPORT_FILE%" (
    echo [WARNING] Relatório não encontrado: %REPORT_FILE%
    exit /b 0
)

REM Verificar se há vulnerabilidades (usando findstr)
findstr /c:"\"vulnerabilities\"" "%PROJECT_ROOT%\%REPORT_FILE%" >nul
if errorlevel 1 (
    echo [SUCCESS] Nenhum segredo sensível detectado
    exit /b 0
)

REM Contar vulnerabilidades
set /a vuln_count=0
for /f %%i in ('findstr /c:"\"id\":" "%PROJECT_ROOT%\%REPORT_FILE%" ^| find /c /v ""') do set vuln_count=%%i

if %vuln_count% gtr 0 (
    echo [ERROR] Secrets detectados: %vuln_count% vulnerabilidade^(s^)
    echo [ERROR] Arquivo: %REPORT_FILE%
    
    REM Mostrar arquivos com problemas
    echo [ERROR] Arquivos com segredos:
    findstr /o "\"file\":" "%PROJECT_ROOT%\%REPORT_FILE%" | findstr /v "node_modules" | findstr /v "dist" | findstr /v "build"
    
    echo [ERROR] Revise e remova credenciais antes do push
    echo [INFO] Dicas: rotacione chaves, use variáveis de ambiente, adicione ao .gitignore
    exit /b 1
) else (
    echo [SUCCESS] Nenhum segredo sensível detectado
    exit /b 0
)
