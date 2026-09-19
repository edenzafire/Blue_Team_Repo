
# --- SCRIPT DE HUNTING E TRIAGEM DE PHISHING / C2 ---
$CsvPath = ".\hunting_summary.csv"
$Results = @()

Write-Host "[*] Iniciando varredura nos logs de telemetria..." -ForegroundColor Cyan

# 1. Coleta de Eventos do Sysmon (ID 1 - Process Creation) e Audit (ID 4688)
$Events = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; Id=1} -ErrorAction SilentlyContinue

if (-not $Events) {
    Write-Host "[!] Buscando logs de auditoria nativos (Event ID 4688)..." -ForegroundColor Yellow
    $Events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4688} -ErrorAction SilentlyContinue
}

foreach ($Event in $Events) {
    $Xml = [xml]$Event.ToXml()
    $Data = @{}
    foreach ($Item in $Xml.Event.EventData.Data) {
        $Data[$Item.Name] = $Item.'#text'
    }

    $CommandLine = $Data['CommandLine']
    $Image = $Data['Image']
    $ParentImage = $Data['ParentImage']
    $User = $Data['User']
    $UtcTime = $Data['UtcTime']
    
    if (-not $UtcTime) { $UtcTime = $Event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss") }

    $Score = 0
    $Reasons = @()

    # Regra 1: Argumentos Suspeitos em Linha de Comando
    if ($CommandLine -match "(-enc|-encodedcommand|bypass|-w hidden|downloadstring|iex)") {
        $Score += 40
        $Reasons += "Comando PowerShell/CMD Suspeito (Obfuscation/Download)"
    }

    # Regra 2: Processo Pai Suspeito (Office / Navegador)
    if ($ParentImage -match "(WINWORD|EXCEL|POWERPNT|chrome|msedge)\.exe") {
        $Score += 50
        $Reasons += "Processo pai suspeito (Execução via Office/Navegador)"
    }

    # Regra 3: Execução em Diretórios Temporários
    if ($Image -match "(AppData\\Local\\Temp|Users\\Public)") {
        $Score += 20
        $Reasons += "Execução a partir de diretório temporário/público"
    }

    # Escala de Severidade
    $Severity = "LOW"
    if ($Score -ge 70) { $Severity = "CRITICAL" }
    elseif ($Score -ge 40) { $Severity = "HIGH" }
    elseif ($Score -ge 20) { $Severity = "MEDIUM" }

    if ($Score -gt 0) {
        $Results += [PSCustomObject]@{
            Timestamp    = $UtcTime
            Severity     = $Severity
            Score        = $Score
            Process      = $Image
            ParentProcess= $ParentImage
            CommandLine  = $CommandLine
            User         = $User
            Detection    = ($Reasons -join ' | ')
        }
    }
}

# Exportação do Dataset
if ($Results.Count -gt 0) {
    $Results | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding utf8
    Write-Host "[+] Telemetria extraída com sucesso! CSV gerado em: $CsvPath" -ForegroundColor Green
    Write-Host "[+] Total de detecções registradas: $($Results.Count)" -ForegroundColor Green



| Out-File -FilePath ".\03_hunting_phishing_analysis.ps1" -Encoding utf8
