<#
.SYNOPSIS
    Ferramenta Avançada de Threat Hunting e Triagem de Telemetria (Blue Team Level).
.DESCRIPTION
    Realiza a extração otimizada do Event ID 1 (Sysmon), mapeando a árvore de execução,
    calculando nível de risco (Score) com base em IOCs e gerando relatórios detalhados.
#>

[CmdletBinding()]
param (
    [string]$LogSource = "Microsoft-Windows-Sysmon/Operational",
    [string]$OutputPath = ".\hunting_summary.csv",
    [int]$HoursBack = 48,
    [int]$MaxEvents = 5000
)

# --- FUNÇÕES DE ANÁLISE DE RISCO ---
function Get-RiskScore {
    param (
        [string]$CommandLine,
        [string]$ParentImage,
        [string]$Image
    )
    
    $Score = 0
    $Reasons = @()

    # Checagem de Processo Pai Suspeito (Ex: Office/Navegador abrindo Shell)
    if ($ParentImage -match "(winword|excel|powerpnt|outlook|chrome|msedge|firefox)\.exe$") {
        $Score += 40
        $Reasons += "Processo pai de produtividade/web"
    }

    # Checagem de Flags e Comandos Suspeitos
    if ($CommandLine -match "(-enc|-encodedcommand|bypass|-w hidden|downloadstring|iex)") {
        $Score += 30
        $Reasons += "Argumentos evasivos detectados"
    }

    # Checagem de Execução em Pastas Temporárias
    if ($Image -match "(\\AppData\\Local\\Temp\\|\\Windows\\Temp\\)") {
        $Score += 20
        $Reasons += "Execução a partir de pasta temporária"
    }

    # Executáveis de Alto Risco (LOLBins)
    if ($Image -match "(certutil|mshta|bitsadmin|regsvr32|rundll32)\.exe$") {
        $Score += 25
        $Reasons += "Uso de LOLBin detectado"
    }

    # Classificação Final
    $Severity = "LOW"
    if ($Score -ge 70) { $Severity = "CRITICAL" }
    elseif ($Score -ge 40) { $Severity = "HIGH" }
    elseif ($Score -ge 20) { $Severity = "MEDIUM" }

    return [PSCustomObject]@{
        Score    = $Score
        Severity = $Severity
        Reasons  = ($Reasons -join " | ")
    }
}

# --- INÍCIO DO PROCESSAMENTO ---
Write-Host "[+] Iniciando varredura de Threat Hunting (Sysmon Event ID 1)..." -ForegroundColor Cyan

$StartTime = (Get-Date).AddHours(-$HoursBack)
$FilterHashtable = @{
    LogName   = $LogSource
    Id        = 1
    StartTime = $StartTime
}

try {
    # Coleta Otimizada no Kernel dos Logs
    $RawEvents = Get-WinEvent -FilterHashtable $FilterHashtable -MaxEvents $MaxEvents -ErrorAction Stop
    Write-Host "[+] Eventos recuperados: $($RawEvents.Count). Processando telemetria..." -ForegroundColor Green

    $AnalyzedResults = foreach ($Event in $RawEvents) {
        $Xml = [xml]$Event.ToXml()
        $DataHashtable = @{}
        
        # Mapeamento rápido do XML sem repetição de busca
        foreach ($Item in $Xml.Event.EventData.Data) {
            $DataHashtable[$Item.Name] = $Item.'#text'
        }

        # Análise de Risco Automatizada
        $Risk = Get-RiskScore -CommandLine $DataHashtable['CommandLine'] `
                             -ParentImage $DataHashtable['ParentImage'] `
                             -Image $DataHashtable['Image']

        [PSCustomObject]@{
            UtcTime         = $DataHashtable['UtcTime']
            Severity        = $Risk.Severity
            RiskScore       = $Risk.Score
            DetectionReason = $Risk.Reasons
            ProcessId       = $DataHashtable['ProcessId']
            Image           = $DataHashtable['Image']
            CommandLine     = $DataHashtable['CommandLine']
            ParentImage     = $DataHashtable['ParentImage']
            ParentCmdLine   = $DataHashtable['ParentCommandLine']
            Hashes          = $DataHashtable['Hashes']
            User            = $DataHashtable['User']
        }
    }

    # Ordenar pelos eventos de maior risco no topo
    $SortedResults = $AnalyzedResults | Sort-Object RiskScore -Descending

    # Exportação em CSV UTF-8
    $SortedResults | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding utf8
    
    # Exibir resumo no console
    $CriticalCount = ($SortedResults | Where-Object Severity -eq "CRITICAL").Count
    $HighCount     = ($SortedResults | Where-Object Severity -eq "HIGH").Count

    Write-Host "`n[✔] Auditoria concluída com sucesso!" -ForegroundColor Green
    Write-Host "    ├─ Relatório salvo em: $OutputPath" -ForegroundColor Yellow
    Write-Host "    ├─ Alertas CRÍTICOS: $CriticalCount" -ForegroundColor Red
    Write-Host "    └─ Alertas ALTOS: $HighCount" -ForegroundColor Yellow

} catch {
    Write-Warning "Nenhum evento localizado na janela de tempo informada ou erro de permissão: $_"
}
