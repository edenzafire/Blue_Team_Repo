# ==============================================================================
# BLUE TEAM TELEMETRY ANALYTICS - ANIMATED & ADVANCED VISUALS
# Ambiente: ThinkPad (R Environment)
# Descrição: Processa logs unificados Sysmon + YARA, gera dashboard de picos de
#            incidentes e compila animação temporal do ataque.
# ==============================================================================


# 1. Carregamento Seguro das Bibliotecas
suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(scales)
  library(hrbrthemes) # Estética profissional de dashboards
  library(gganimate)   # Engine de animação temporal
  library(gifski)      # Renderizador de GIF
})

# 2. Definição do Caminho e Leitura da Telemetria
csv_path <- "hunting_summary.csv"

if (!file.exists(csv_path)) {
  stop("[ERRO FATAL] O arquivo 'hunting_summary.csv' não foi encontrado no diretório atual!")
}

cat("[+] Lendo e higienizando dados de telemetria unificada (Sysmon + YARA)...\n")

clean_data <- read.csv(csv_path, stringsAsFactors = FALSE, encoding = "UTF-8") %>%
  filter(!is.na(Timestamp) & Timestamp != "") %>%
  mutate(
    Timestamp = ymd_hms(Timestamp),
    Severity  = factor(Severity, levels = c("CRITICAL", "HIGH", "MEDIUM", "LOW"))
  )


# ------------------------------------------------------------------------------
# 3. Gráfico Estático: Incident Spike Dashboard (PNG HD)
# ------------------------------------------------------------------------------
cat("[+] Gerando visualização estática de picos de incidentes...\n")

static_plot <- ggplot(clean_data, aes(x = floor_date(Timestamp, "5 mins"), fill = Severity)) +
  geom_bar(position = "stack", width = 250) +
  scale_fill_manual(values = c(
    "CRITICAL" = "#D9534F",
    "HIGH"     = "#F0AD4E",
    "MEDIUM"   = "#5BC0DE",
    "LOW"      = "#5CB85C"
  )) +
  scale_x_datetime(date_labels = "%H:%M\n%d/%m", date_breaks = "1 hour") +
  labs(
    title = "Análise Temporal de Telemetria e Detecção de Anomalias",
    subtitle = "Eventos Sysmon & Assinaturas YARA agrupados em janelas de 5 minutos",
    x = "Janela de Tempo (UTC)",
    y = "Quantidade de Logs",
    fill = "Severidade"
  ) +
  theme_ipsum_rc(grid = "Y") +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 10, color = "gray30")
  )

# Salvar gráfico estático em alta resolução
ggsave("timeline_incident_spike.png", plot = static_plot, width = 10, height = 5, dpi = 300)
cat("    └─ [✔] 'timeline_incident_spike.png' gerado com sucesso!\n")

# ------------------------------------------------------------------------------
# 4. Painel Temporal de Telemetria (Timeline Estática em Alta Resolução)
# ------------------------------------------------------------------------------
cat("[+] Gerando gráfico de distribuição temporal das detecções...\n")

# Construção do gráfico de facetas temporais por Severidade
timeline_plot <- ggplot(clean_data, aes(x = Timestamp, fill = Severity)) +
  geom_histogram(binwidth = 300, color = "black", alpha = 0.85, show.legend = FALSE) +
  facet_wrap(~ Severity, ncol = 1, scales = "free_y") +
  scale_fill_manual(values = c(
    "CRITICAL" = "#d9534f",
    "HIGH"     = "#f0ad4e",
    "MEDIUM"   = "#5bc0de",
    "LOW"      = "#5cb85c"
  )) +
  theme_minimal() +
  labs(
    title = "Linha do Tempo dos Eventos de Telemetria (Sysmon + YARA)",
    subtitle = "Distribuição de Incidentes Detectados ao Longo do Tempo",
    x = "Horário do Evento",
    y = "Volume de Detecções"
  )

# Salvar arquivo PNG no diretório atual
output_png <- file.path(getwd(), "incident_timeline.png")
ggsave(output_png, plot = timeline_plot, width = 10, height = 7, dpi = 300)

cat("    └─ [✔] 'incident_timeline.png' gerado e salvo com sucesso!\n")
cat("\n[SUCESSO] Pipeline de Ciência de Dados concluído! Todos os artefatos visuais estão prontos.\n")