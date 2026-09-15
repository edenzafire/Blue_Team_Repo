<#
.SYNOPSIS
    Ferramenta Avançada de Threat Hunting, Triagem de Telemetria e Inspeção YARA (Blue Team Level).
.DESCRIPTION
    Realiza a extração otimizada do Event ID 1 (Sysmon), executa varredura estática via YARA64 em diretórios
    de risco, calcula o Risk Score correlacionado com base em IOCs e exporta o relatório unificado em CSV.
#>

[CmdletBinding()]
param (
    [string]$LogSource   = "Microsoft-Windows-Sysmon/Operational",
    [string]$OutputPath  = ".\hunting_summary.csv",
    [int]$HoursBack      = 48,
    [int]$MaxEvents      = 5000,
    [string]$YaraBinary  = "..\04_Detection_Mitigation_Rules\yara64.exe",
    [string]$YaraRules   = "..\04_Detection_Mitigation_Rules\03_yara_phishing_payloads.yar",
    [string]$ScanFolder  = "C:\Users\Public\Downloads"
)

# --- FUNÇÕES DE ANÁLISE DE RISCO ---
function Get-RiskScore {
    param (
        [string]$CommandLine,
        [string]$ParentImage,
        [string]$Image,
        [string[]]$YaraMatches
    )
    
    $Score = 0
    $Reasons = @()

    # 1. Checagem de Processo Pai Suspeito (Ex: Office/Navegador abrindo Shell)
    if (\(ParentImage -match "(winword|excel|powerpnt|outlook|chrome|msedge|firefox)\.exe\)") {
        $Score += 40
        $Reasons += "Processo pai de produtividade/web"
    }

    # 2. Checagem de Flags e Comandos Suspeitos
    if ($CommandLine -match "(-enc|-encodedcommand|bypass|-w hidden|downloadstring|iex)") {
        $Score += 30
        $Reasons += "Argumentos evasivos detectados"
    }

    # 3. Checagem de Execução em Pastas Temporárias
    if ($Image -match "(\\AppData\\Local\\Temp\\|\\Windows\\Temp\\)") {
        $Score += 20
        $Reasons += "Execução a partir de pasta temporária"
    }

    # 4. Executáveis de Alto Risco (LOLBins)
    if (\(Image -match "(certutil|mshta|bitsadmin|regsvr32|rundll32)\.exe\)") {
        $Score += 25
        $Reasons += "Uso de LOLBin detectado"
    }

    # 5. Correlação com Detecções do YARA
    if (\(YaraMatches -and\)YaraMatches.Count -gt 0) {
        $Score += 50
        \(Reasons += "Match de Assinatura YARA (\)($YaraMatches -join ', '))"
    }

    # Classificação Final de Severidade
    $Severity = "LOW"
    if (\(Score -ge 70) {\)Severity = "CRITICAL" }
    elseif (\(Score -ge 40) {\)Severity = "HIGH" }
    elseif (\(Score -ge 20) {\)Severity = "MEDIUM" }

    return [PSCustomObject]@{
        Score    = $Score
        Severity = $Severity
        Reasons  = ($Reasons -join " | ")
    }
}

# --- INÍCIO DO PROCESSAMENTO ---
Write-Host "[+] Iniciando varredura de Threat Hunting e Telemetria Integrada..." -ForegroundColor Cyan

# --- ETAPA 1: VARREDURA ESTÁTICA YARA ---
$YaraDetections = @{}

if ((Test-Path \(YaraBinary) -and (Test-Path\)YaraRules) -and (Test-Path $ScanFolder)) {
    Write-Host "[+] Executando engine YARA na pasta: $ScanFolder" -ForegroundColor Yellow
    try {
        \(YaraOutput = &\)YaraBinary -r \(YaraRules\)ScanFolder 2>$null
        foreach (\(Line in\)YaraOutput) {
            if ($Line) {
                \(Parts =\)Line -split "\s+", 2
                \(RuleName =\)Parts[0]
                \(FilePath =\)Parts[1]

                if (-not \(YaraDetections.ContainsKey(\)FilePath)) {
                    \(YaraDetections[\)FilePath] = @()
                }
                \(YaraDetections[\)FilePath] += $RuleName
            }
        }
        Write-Host "    └─ Ameaças identificadas via YARA: \((\)YaraDetections.Count) arquivos" -ForegroundColor Green
    } catch {
        Write-Warning "Falha na execução do scanner YARA: $_"
    }
} else {
    Write-Host "[!] YARA64 ou regras não encontradas nos caminhos especificados. Pulasndo varredura de arquivo estático." -ForegroundColor DarkGray
}

# --- ETAPA 2: EXTRAÇÃO E CORRELAÇÃO DE LOGS SYSMON ---
Write-Host "[+] Coletando Event ID 1 (Sysmon) dos últimos $HoursBackh..." -ForegroundColor Cyan

\(StartTime = (Get-Date).AddHours(-\)HoursBack)
$FilterHashtable = @{
    LogName   = $LogSource
    Id        = 1
    StartTime = $StartTime
}

try {
    \(RawEvents = Get-WinEvent -FilterHashtable\)FilterHashtable -MaxEvents $MaxEvents -ErrorAction Stop
    Write-Host "[+] Eventos Sysmon recuperados: \((\)RawEvents.Count). Processando pipeline..." -ForegroundColor Green

    \(AnalyzedResults = foreach (\)Event in $RawEvents) {
        \(Xml = [xml]\)Event.ToXml()
        $DataHashtable = @{}
        
        foreach (\(Item in\)Xml.Event.EventData.Data) {
            \(DataHashtable[\)Item.Name] = $Item.'#text'
        }

        # Verificar se a imagem em execução bate com algum arquivo pego no YARA
        \(ImagePath =\)DataHashtable['Image']
        \(MatchedYara =\)null
        if (\(ImagePath -and\)YaraDetections.ContainsKey($ImagePath)) {
            \(MatchedYara =\)YaraDetections[$ImagePath]
        }

        # Análise de Risco Correlacionada (Sysmon + YARA)
        \(Risk = Get-RiskScore -CommandLine\)DataHashtable['CommandLine'] `
                             -ParentImage $DataHashtable['ParentImage'] `
                             -Image $DataHashtable['Image'] `
                             -YaraMatches $MatchedYara

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

    # Ordenação por Risk Score (Maior Risco no topo)
    \(SortedResults =\)AnalyzedResults | Sort-Object RiskScore -Descending

    # Exportação UTF-8 para consumo no R
    \(SortedResults | Export-Csv -Path\)OutputPath -NoTypeInformation -Encoding utf8
    
    # Resumo no Console
    \(CriticalCount = (\)SortedResults | Where-Object Severity -eq "CRITICAL").Count
    \(HighCount     = (\)SortedResults | Where-Object Severity -eq "HIGH").Count

    Write-Host "`n[✔] Pipeline de Threat Hunting concluído com sucesso!" -ForegroundColor Green
    Write-Host "    ├─ CSV Consolidado: $OutputPath" -ForegroundColor Yellow
    Write-Host "    ├─ Alertas CRÍTICOS: $CriticalCount" -ForegroundColor Red
    Write-Host "    └─ Alertas ALTOS: $HighCount" -ForegroundColor Yellow

} catch {
    Write-Warning "Nenhum evento localizado na janela de tempo informada ou erro de permissão: $_"
}
