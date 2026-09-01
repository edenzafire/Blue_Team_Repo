## 🎯 Como Executar o Script de Threat Hunting (`03_hunting_phishing_analysis.ps1`)

Este script realiza a varredura automatizada nos logs do Sysmon (`Event ID 1`), aplicando regras de triagem e cálculo de pontuação de risco (*Risk Score*) para identificar anomalias e comportamentos suspeitos de execução.

### 📋 Principais Funcionalidades
* **Filtragem de Alta Performance:** Utiliza *hashtables* no engine do Windows para rápida extração de eventos.
* **Cálculo de Risco Automático:** Atribui pontuações (*LOW*, *MEDIUM*, *HIGH*, *CRITICAL*) com base em indicadores como executáveis temporários, argumentos evasivos (`-enc`, `bypass`) e uso de *LOLBins*.
* **Mapeamento de Processo Pai:** Sinaliza quando interpretadores de comandos são iniciados por softwares de produtividade ou navegadores.
* **Saída Estruturada:** Gera o arquivo `hunting_summary.csv` ordenado pelos eventos de maior prioridade.

---

### 🚀 Passo a Passo de Execução

#### Pré-requisitos
* Sistema Operacional: Windows 10
* Permissões: Privilégios de Administrador
* Dependência: Logs do Sysmon ativos (`Microsoft-Windows-Sysmon/Operational`)

#### Instruções

1. Abra o **PowerShell** como **Administrador**.

2. Navegue até o diretório do módulo:
   ```powershell
   cd path\to\Blue_Team_Repo\03_Identity_Access_Management_IAM

   ```
### Execute o script utilizando os parâmetros padrão (analisa as últimas 48 horas):

```
 .\03_hunting_phishing_analysis.ps1

```

### (Opcional) Para personalizar a janela de tempo (ex: últimas 12 horas) ou o nome do relatório de saída:
 
```
.\03_hunting_phishing_analysis.ps1 -HoursBack 12 -OutputPath ".\relatorio_triagem.csv"

```

### 📊 Saída Esperada no Terminal

```
[+] Iniciando varredura de Threat Hunting (Sysmon Event ID 1)...
[+] Eventos recuperados: 124. Processando telemetria...

[✔] Auditoria concluída com sucesso!
    ├─ Relatório salvo em: .\hunting_summary.csv
    ├─ Alertas CRÍTICOS: 1
    └─ Alertas ALTOS: 2
```



---

## 📊 Análise de Telemetria e Visualização em R (`04_telemetry_analytics.R`)

O script em R é executado no ambiente de análise (**ThinkPad**) para processar os dados exportados pelo PowerShell (`hunting_summary.csv`). Ele realiza o tratamento estatístico da telemetria, identifica anomalias temporais e gera gráficos de alta resolução para o relatório de investigação.

### 📋 Principais Funcionalidades
* **Tratamento de Dados:** Normalização de datas/timestamps (`POSIXct`) e ordenação lógica por níveis de severidade.
* **Detecção de Picos Temporais:** Agrupamento de logs em janelas de 5 minutos para evidenciar o momento exato de disparos anômalos.
* **Mapeamento de Executáveis de Risco:** Identificação e plotagem dos processos com maior pontuação heurística (*Risk Score*).
* **Exportação Automática:** Geração direta de imagens `.png` (300 DPI) para compor a documentação executiva.

---

### 🚀 Instruções de Execução

#### Pré-requisitos
* R instalado no ambiente ThinkPad
* Pacotes R necessários: `tidyverse`, `lubridate`, `scales`

#### Passo a Passo

1. Garanta que o arquivo `hunting_summary.csv` gerado na etapa anterior esteja no mesmo diretório do script R.

2. Abra o terminal ou o **RStudio** e navegue até a pasta:
   ```bash
   cd path/to/Blue_Team_Repo/03_Identity_Access_Management_IAM
  
   ```

## Execute o script via linha de comando:

```
Rscript 04_telemetry_analytics.R

```

###📈 Artefatos Gerados
Após a execução, o script disponibilizará dois relatórios visuais na raiz da pasta:

* timeline_incident_spike.png: Gráfico de barras empilhadas mostrando o volume de logs ao longo do tempo categorizados por nível de risco (CRITICAL, HIGH, MEDIUM, LOW).

* top_risk_executables.png: Gráfico de barras horizontais destacando os executáveis que atingiram as maiores pontuações de risco na triagem.

