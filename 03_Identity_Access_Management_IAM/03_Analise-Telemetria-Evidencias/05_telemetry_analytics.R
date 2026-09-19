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
  filter(!is.na(UtcTime) & UtcTime != "") %>%
  mutate(
    Timestamp = ymd_hms(UtcTime),
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
# 4. Animação Temporal: Timeline do Ataque em Tempo Real (GIF)
# ------------------------------------------------------------------------------
cat("[+] Renderizando animação temporal (GIF) com gganimate...\n")

animated_plot <- static_plot +
  transition_time(Timestamp) +
  shadow_mark(past = TRUE, future = FALSE) +
  labs(
    title = "Evolução do Ataque em Tempo Real",
    subtitle = "Linha do Tempo de Detecção | Horário do Evento: {frame_time}"
  )

# Renderização do arquivo GIF animado
animate(
  animated_plot, 
  nframes  = 100, 
  fps      = 10, 
  width    = 800, 
  height   = 450, 
  renderer = gifski_renderer("incident_timeline.gif")
)

cat("    └─ [✔] 'incident_timeline.gif' gerado com sucesso!\n")
cat("\n[SUCESSO] Pipeline de Ciência de Dados concluído! Todos os artefatos visuais estão prontos.\n")
