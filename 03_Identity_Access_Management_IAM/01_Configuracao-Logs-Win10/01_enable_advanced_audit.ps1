<#
.SYNOPSIS
    Habilita Telemetria Avançada e Auditoria no Windows 10 .
.DESCRIPTION
    Aplica políticas de auditoria local, ativa o rastreamento de linha de comando (Event ID 4688),
    abilita o PowerShell Script Block Logging (Event ID 4104) com tratamento de erros, 
    validação pós-execução e geração de logs de auditoria.
.AUTHOR
   Éden Zafire / Blue Team
#>

[CmdletBinding()]
param (
    [string]$LogPath = ".\audit_execution.log",
    [string]$BackupPath = ".\02_gpo_audit_policy_backup.csv"
)

# --- FUNÇÕES AUXILIARES ---

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")][string]$Level = "INFO"
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$TimeStamp] [$Level] $Message"
    
    # Escrever no terminal com cor
    switch ($Level) {
        "SUCCESS" { Write-Host $LogEntry -ForegroundColor Green }
        "WARNING" { Write-Host $LogEntry -ForegroundColor Yellow }
        "ERROR"   { Write-Host $LogEntry -ForegroundColor Red }
        Default   { Write-Host $LogEntry -ForegroundColor Cyan }
    }
    
    # Registrar em arquivo de log
    $LogEntry | Out-File -FilePath $LogPath -Append -Encoding utf8
}

function Test-AdminPrivileges {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
    return $Principal.IsInRole([Security.Principal.WindowsRole]::Administrator)
}

# --- INÍCIO DA EXECUÇÃO ---

Clear-Host
Write-Log "Iniciando implantação de políticas de telemetria..." "INFO"

# 1. Validação de Privilégios
if (-not (Test-AdminPrivileges)) {
    Write-Log "Permissão negada. O script precisa ser executado como Administrador." "ERROR"
    exit 1
}

try {
    # 2. Configuração de Auditoria Avançada via auditpol
    Write-Log "[1/3] Aplicando subcategorias de auditoria nativas..." "INFO"
    
    $AuditSubcategories = @(
        @{ Name = "Logon"; Success = "enable"; Failure = "enable" },
        @{ Name = "Logoff"; Success = "enable"; Failure = "disable" },
        @{ Name = "Account Lockout"; Success = "enable"; Failure = "enable" },
        @{ Name = "Process Creation"; Success = "enable"; Failure = "disable" },
        @{ Name = "Process Termination"; Success = "enable"; Failure = "disable" },
        @{ Name = "Security State Change"; Success = "enable"; Failure = "enable" },
        @{ Name = "Security Group Management"; Success = "enable"; Failure = "enable" },
        @{ Name = "User Account Management"; Success = "enable"; Failure = "enable" },
        @{ Name = "File System"; Success = "enable"; Failure = "enable" },
        @{ Name = "Registry"; Success = "enable"; Failure = "enable" }
    )

    foreach ($Item in $AuditSubcategories) {
        $result = auditpol /set /subcategory:"$($Item.Name)" /success:$($Item.Success) /failure:$($Item.Failure)
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Falha ao aplicar auditoria na subcategoria: $($Item.Name)" "WARNING"
        }
    }
    Write-Log "Políticas de auditoria aplicadas com sucesso." "SUCCESS"

    # 3. Alterações de Registro (Linha de Comando e PowerShell Logging)
    Write-Log "[2/3] Configurando chaves de registro de telemetria..." "INFO"

    $RegistryConfigs = @(
        @{
            Path  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
            Name  = "ProcessCreationIncludeCmdLine_Enabled"
            Value = 1
            Type  = "DWord"
            Desc  = "CmdLine Process Tracking (Event 4688)"
        },
        @{
            Path  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
            Name  = "EnableScriptBlockLogging"
            Value = 1
            Type  = "DWord"
            Desc  = "PowerShell Script Block Logging (Event 4104)"
        }
    )

    foreach ($Reg in $RegistryConfigs) {
        if (-not (Test-Path $Reg.Path)) {
            New-Item -Path $Reg.Path -Force | Out-Null
            Write-Log "Caminho de registro criado: $($Reg.Path)" "INFO"
        }
        Set-ItemProperty -Path $Reg.Path -Name $Reg.Name -Value $Reg.Value -Type $Reg.Type -ErrorAction Stop
        Write-Log "Habilitado: $($Reg.Desc)" "SUCCESS"
    }

    # 4. Validação Pós-Execução
    Write-Log "[3/3] Validando integridade das configurações..." "INFO"
    
    $CmdLineCheck = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Name "ProcessCreationIncludeCmdLine_Enabled" -ErrorAction SilentlyContinue).ProcessCreationIncludeCmdLine_Enabled
    $PSLogCheck   = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue).EnableScriptBlockLogging

    if ($CmdLineCheck -eq 1 -and $PSLogCheck -eq 1) {
        Write-Log "Validação do Registro: SUCESSO (Todas as chaves ativas)" "SUCCESS"
    } else {
        Write-Log "Validação do Registro: FALHA (Alguma chave não foi gravada corretamente)" "WARNING"
    }

    # 5. Exportação do Relatório Final
    auditpol /get /category:* /r | Out-File -FilePath $BackupPath -Encoding utf8
    Write-Log "Relatório de auditoria exportado para: $BackupPath" "SUCCESS"
    Write-Log "Processo concluído com êxito." "SUCCESS"

} catch {
    Write-Log "Erro crítico durante a execução do script: $_" "ERROR"
    exit 1
}
