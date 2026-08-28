@echo off
:: ============================================================================
:: SYSMON AUTOMATED DEPLOYMENT SCRIPT (PRODUCTION GRADE)
:: Autor: Éden Zafire
:: Descricao: Valida permissoes, baixa a versao oficial do Sysmon se necessario
::            e instala/atualiza o servico utilizando as regras do XML local.
:: ============================================================================

setlocal EnableDelayedExpansion

:: Configuração de Cores do Terminal
color 0A
title Deploy do Microsoft Sysmon - Blue Team Lab

echo ============================================================================
echo                    IMPLANTATION E CONFIGURACAO DO SYSMON
echo ============================================================================
echo.

:: 1. Validar Privilegios de Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    color 0C
    echo [ERRO] Este script precisa ser executado como ADMINISTRADOR!
    echo.
    echo Clique com o boto direito no arquivo e selecione "Executar como administrador".
    echo.
    pause
    exit /b 1
)

:: 2. Definir Caminhos e Arquivos
set "WORK_DIR=%~dp0"
set "SYSMON_EXE=%WORK_DIR%Sysmon.exe"
set "SYSMON_CONFIG=%WORK_DIR%01_sysmon_config.xml"
set "SYSMON_URL=https://live.sysinternals.com/Sysmon.exe"

cd /d "%WORK_DIR%"

:: 3. Verificar Arquivo de Configuracao XML
echo [+] [1/4] Verificando arquivo de configuracao XML...
if not exist "%SYSMON_CONFIG%" (
    color 0C
    echo [ERRO] O arquivo '01_sysmon_config.xml' nao foi encontrado no diretorio:
    echo        %WORK_DIR%
    echo.
    pause
    exit /b 1
)
echo [OK] Arquivo de configuracao localizado.

:: 4. Verificar ou Baixar o Executavel do Sysmon
echo [+] [2/4] Verificando o binario do Sysmon...
if not exist "%SYSMON_EXE%" (
    echo [INFO] Sysmon.exe nao encontrado localmente. Efetuando download oficial...
    powershell -Command "Invoke-WebRequest -Uri '%SYSMON_URL%' -OutFile '%SYSMON_EXE%'"
    
    if not exist "%SYSMON_EXE%" (
        color 0C
        echo [ERRO] Falha ao baixar o Sysmon.exe. Verifique a conexao com a internet.
        pause
        exit /b 1
    )
    echo [OK] Download concluido com sucesso.
) else (
    echo [OK] Executavel Sysmon.exe encontrado localmente.
)

:: 5. Verificar se o Servico ja existe (Instalar ou Atualizar)
echo [+] [3/4] Verificando status do servico no sistema...
sc query Sysmon >nul 2>&1
if %errorLevel% equ 0 (
    echo [INFO] Servico Sysmon detectado. Atualizando configuracao existente...
    "%SYSMON_EXE%" -c "%SYSMON_CONFIG%"
) else (
    echo [INFO] Servico Sysmon nao encontrado. Realizando nova instalacao...
    "%SYSMON_EXE%" -i "%SYSMON_CONFIG%" -accepteula
)

if %errorLevel% neq 0 (
    color 0C
    echo [ERRO] Falha na instalacao/atualizacao do Sysmon. Codigo de erro: %errorLevel%
    pause
    exit /b 1
)

:: 6. Validacao Final do Servico
echo [+] [4/4] Validando execucao do servico...
sc query Sysmon | findstr /i "RUNNING" >nul 2>&1
if %errorLevel% equ 0 (
    color 0A
    echo.
    echo ============================================================================
    echo [SUCESSO] Sysmon instalado, configurado e EM EXECUCAO com exito!
    echo [INFO] Os logs estao sendo enviados para o Event Viewer em:
    echo        Applications and Services Logs -> Microsoft -> Windows -> Sysmon
    echo ============================================================================
) else (
    color 0E
    echo.
    echo [AVISO] O Sysmon foi instalado, mas o servico nao consta no estado 'RUNNING'.
    echo         Verifique o Event Viewer para detalhes.
)

echo.
pause
exit /b 0
