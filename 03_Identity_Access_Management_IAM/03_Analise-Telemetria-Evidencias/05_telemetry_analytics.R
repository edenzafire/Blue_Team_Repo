# ==============================================================================
# BLUE TEAM TELEMETRY ANALYTICS & THREAT HUNTING ENGINE
# Ambiente: ThinkPad (R Environment)
# Descricao: Processamento estatistico de telemetria, deteccao de picos temporais
#            e correlacao de severidade de eventos do Sysmon.
# ==============================================================================

# 1. Carregamento de Bibliotecas de Producao
suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(scales)
})

# 2. Parametros e Importacao de Dados
csv_path <- "hunting_summary.csv"

if (!file.exists(csv_path)) {
  stop("[ERRO] Arquivo 'hunting_summary.csv' nao encontrado. Execute o script em PowerShell primeiro.")
}

cat("[+] Lendo artefatos de telemetria extraidos...\n")
raw_data <- read.csv(csv_path, stringsAsFactors = FALSE, encoding = "UTF-8")

# 3. Tratamento e Normalizacao de Dados
cat("[+] Processando e estruturando os timestamps...\n")
clean_data <- raw_data %>%
  filter(!is.na(UtcTime) & UtcTime != "") %>%
  mutate(
    # Converter UtcTime para objeto POSIXct de data/hora
    Timestamp = ymd_hms(UtcTime),
    # Forcar ordem logica dos niveis de severidade para os graficos
    Severity = factor(Severity, levels = c("CRITICAL", "HIGH", "MEDIUM", "LOW"))
  )

# 4. Resumo Estatistico para o Terminal
cat("\n=================================================================\n")
cat("                RESUMO ESTATISTICO DA TRIAGEM                    \n")
cat("=================================================================\n")

severity_summary <- clean_data %>%
  group_by(Severity) %>%
  summarise(Total_Eventos = n())

print(severity_summary)

# 5. Visualizacao 1: Deteccao de Picos Temporais (Incident Spike Detection)
cat("\n[+] Gerando grafico de distribuicao temporal de eventos...\n")

timeline_plot <- ggplot(clean_data, aes(x = floor_date(Timestamp, "5 mins"), fill = Severity)) +
  geom_bar(position = "stack", width = 250) +
  scale_fill_manual(values = c(
    "CRITICAL" = "#d9534f",
    "HIGH"     = "#f0ad4e",
    "MEDIUM"   = "#5bc0de",
    "LOW"      = "#5cb85c"
  )) +
  scale_x_datetime(date_labels = "%H:%M\n%d/%m", date_breaks = "1 hour") +
  labs(
    title = "Análise Temporal de Telemetria e Detecção de Anomalias",
    subtitle = "Agrupamento de eventos por janela de 5 minutos e nível de severidade",
    x = "Janela de Tempo (UTC)",
    y = "Quantidade de Logs Capturados",
    fill = "Nível de Risco"
  ) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# Salvar o gráfico da linha do tempo
ggsave("timeline_incident_spike.png", plot = timeline_plot, width = 10, height = 5, dpi = 300)
cat("[✔] Grafico salvo: timeline_incident_spike.png\n")

# 6. Visualizacao 2: Top Executaveis com Maior Score de Risco
cat("[+] Gerando grafico dos executaveis de maior risco...\n")

top_risk_plot <- clean_data %>%
  filter(RiskScore > 0) %>%
  group_by(Image, Severity) %>%
  summarise(Max_Score = max(RiskScore), Total = n(), .groups = 'drop') %>%
  top_n(10, Max_Score) %>%
  ggplot(aes(x = reorder(Image, Max_Score), y = Max_Score, fill = Severity)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("CRITICAL" = "#d9534f", "HIGH" = "#f0ad4e", "MEDIUM" = "#5bc0de")) +
  labs(
    title = "Top Executáveis Identificados por Score de Risco",
    subtitle = "Triagem heurística baseada em argumentos evasivos e diretórios temporários",
    x = "Caminho do Processo (Image)",
    y = "Pontuação Máxima de Risco (Risk Score)",
    fill = "Severidade"
  ) +
  theme_minimal()

# Salvar o gráfico de executáveis
ggsave("top_risk_executables.png", plot = top_risk_plot, width = 10, height = 5, dpi = 300)
cat("[✔] Grafico salvo: top_risk_executables.png\n")

cat("\n[✔] ANALISE CONCLUIDA COM SUCESSO! Relatorios visuais prontos para a documentacao.\n")
