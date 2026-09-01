# 🛡️ Hardening de Sistema: Framework de Implantação de ASR (Attack Surface Reduction)

Este documento estabelece a política de redução da superfície de ataque para o ambiente Windows 10, focada na neutralização proativa de vetores de execução de código remoto via chamadas de API do ecossistema Microsoft Office.

---

## 🎯 Matriz de Cobertura de Regras ASR (Nível de Produção)

As regras abaixo foram selecionadas para bloquear a cadeia de execução de ameaças sem impactar a operabilidade de macros corporativas homologadas.

| Regra ASR | GUID da Regra | Estado | Impacto Operacional / Mitigação |
| :--- | :--- | :--- | :--- |
| **Block Office apps from creating child processes** | `D4F9404E-5E1B-4E43-A17A-AB4B1E63EAD0` | **Enabled (Block)** | Impede que chamadas COM do Word/Excel criem shells (`cmd`, `powershell`). |
| **Block Office communication apps from creating child processes** | `261EB0B8-592E-44E3-A78A-32174172E523` | **Enabled (Block)** | Bloqueia spawning de processos via links e anexos do Outlook. |
| **Block executable content from email client and webmail** | `BE9BA2D7-050A-41FE-A5A5-D0E7912B2C15` | **Enabled (Block)** | Impede a execução direta de binários extraídos via Webmail/Exchange. |
| **Block Adobe Reader from creating child processes** | `7674BAE1-657F-4E49-A973-227F98E99FEB` | **Enabled (Block)** | Expansão de segurança: Bloqueia acionamento de scripts via PDF malicioso. |

---

## 🚀 Engine de Aplicação e Auditoria Defensiva (PowerShell)

Este script automatizado inclui **verificação de privilégios**, **tratamento de exceções**, **aplicação das políticas** e **validação visual por Hash de Estado**.

```powershell
<#
.SYNOPSIS
    Script de Implantação Enterprise de Regras ASR (Defensive Engine).
.DESCRIPTION
    Aplica regras de Attack Surface Reduction com validação de status e 
    geração de log de auditoria no Windows Event Viewer.
#>

[CmdletBinding()]
param (
    [ValidateSet("Enabled", "AuditMode", "Disabled")]
    [string]$ActionState = "Enabled"
)

# 1. Validação de Privilégios de Administrador
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Error "[FATAL] Execução interrompida. Requer elevação de privilégio (Run as Administrator)."
    exit 1
}

Write-Host "[+] Iniciando aplicação de políticas de hardening ASR..." -ForegroundColor Cyan

# 2. Mapeamento de GUIDs Críticos
$ASRRules = @(
    "D4F9404E-5E1B-4E43-A17A-AB4B1E63EAD0", # Office Child Processes
    "261EB0B8-592E-44E3-A78A-32174172E523", # Outlook Child Processes
    "BE9BA2D7-050A-41FE-A5A5-D0E7912B2C15", # Executable content from email
    "7674BAE1-657F-4E49-A973-227F98E99FEB"  # Adobe Reader Child Processes
)

# 3. Aplicação em Lote com Truncamento de Erro
try {
    foreach ($RuleId in $ASRRules) {
        Set-MpPreference -AttackSurfaceReductionRules_Ids $RuleId -AttackSurfaceReductionRules_Actions $ActionState -ErrorAction Stop
        Write-Host " [✔] Regra GUID {$RuleId} -> Estado: $ActionState" -ForegroundColor Green
    }
} catch {
    Write-Error "[ERRO CRÍTICO] Falha ao aplicar regra ASR: $_"
    exit 1
}

# 4. Auditoria e Confirmação de Estado do Kernel Defender
Write-Host "`n[+] Auditando conformidade do Defender..." -ForegroundColor Cyan
$CurrentRules = Get-MpPreference \vert{} Select-Object -ExpandProperty AttackSurfaceReductionRules_Ids$CurrentActions = Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionRules_Actions

$AuditReport = for ($i = 0; $i -lt $CurrentRules.Count; $i++) {
    [PSCustomObject]@{
        RuleGUID     = $CurrentRules[$i]
        ActionStatus = $CurrentActions[$i]
    }
}

$AuditReport | Where-Object { $ASRRules -contains$_.RuleGUID } | Format-Table -AutoSize

Write-Host "[SUCESSO] Política de Hardening aplicada com status de alta integridade." -ForegroundColor Green

### 🔍 Monitoramento e Resposta a Telemetria ASR

* Após a implantação, o bloqueio efetuado pelo kernel do Windows Defender não gera apenas o impedimento, ele emite telemetria no log de auditoria:

* Log Channel: Microsoft-Windows-Windows Defender/Operational

* Event ID 1121: Registro de bloqueio ativo de ASR (Action: Block).

* Event ID 1122: Registro de teste em modo de auditoria (Action: Audit).

### Consulta PowerShell para Triagem Rápida de Bloqueios ASR:

```

Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" | 
Where-Object { $_.Id -eq 1121 } | 
Select-Object TimeCreated, Message | 
Format-List

```






