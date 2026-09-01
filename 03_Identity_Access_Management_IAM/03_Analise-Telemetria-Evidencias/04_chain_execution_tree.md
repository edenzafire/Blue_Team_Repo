# 🛡️ Relatório de Análise Defensiva e Mapeamento de Incidentes

Este documento descreve a metodologia de análise de telemetria aplicada para identificar comportamentos anômalos e estabelecer medidas preventivas no ambiente Windows 10.

---

## 🔍 Mapeamento da Cadeia de Execução (Execution Chain)

A correlação entre o `Event ID 1` (Criação de Processos) e o `Event ID 3` (Conexão de Rede) permite visualizar o fluxo de eventos durante uma auditoria:

```text
[ Processo Pai Legítimo ] (ex: Navegador / Leitor de E-mail)
       │
       └──> [ Interpretador de Comandos ] (Event ID 1 - Sinalizado para Análise)
               │   ├── Linha de Comando: Parâmetros de Execução
               │   └── Hash SHA256: Assinatura do Arquivo
               │
               └──> [ Conexão Externa ] (Event ID 3 - Validação de Destino)

```

### 🛠️ Recomendações de Hardening e Mitigação

* Regras de Redução da Superfície de Ataque (ASR): Configurar políticas no sistema para impedir que aplicativos de produtividade criem processos filhos em formato de script.

* Políticas de Restrição de Software (AppLocker / WDAC): Restringir a execução de executáveis e scripts a diretórios protegidos contra gravação por usuários comuns.

* Reforço de Monitoramento: Manter os filtros do Sysmon atualizados para registrar a execução de binários administrativos (LOLBins).
