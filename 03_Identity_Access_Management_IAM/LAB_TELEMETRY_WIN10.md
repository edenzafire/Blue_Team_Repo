## 🛡️ Laboratório de Coleta de Telemetria e Caça a Ameaças (Blue Team)

Este repositório documenta a implantação, auditoria de segurança, depuração de erros de ambiente e extração de telemetria avançada em uma VM Windows 10, preparando o dataset (hunting_summary.csv) para análise estatística de dados via R (RStudio) em um estojo físico de análise (ThinkPad).

## 📐 1. Arquitetura do Ambiente

*  SO de Telemetria: Windows 10 Pro (Phisical, Acer)
*  Sensores de Segurança: Windows Event Logs (Nativo) + Sysmon v15.22
*  Mecanismos de Rastreamento:
   *  Event ID 4688: Process Creation com Habilitação de Command Line Tracking.   
   *  Event ID 4104: PowerShell Script Block Logging.   
   *  Sysmon Event ID 1: Process Creation e detalhamento de chamadas de Kernel.   
*  Linguagens e Ferramentas: PowerShell, Git, Sysinternals e R/RStudio.

## 🚀 2. Implantação e Execução Passo a Passo

**Etapa 1: Obtenção do Repositório

O projeto foi clonado diretamente do repositório remoto para a máquina local de testes.

*  Ação: Baixado a estrutura do projeto em .zip e extraído na Área de Trabalho (Desktop).

![Baixar Zip](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/01.png)

*  Estrutura: Pasta 03_Identity_Access_Management_IAM posicionada no Desktop.

![Extrair & acessar a pasta](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/03.png)


## Etapa 2: Preparação do Ambiente e Execução do Script de Auditoria

*  Verificação de Arquivos: Navegação até o diretório 01_Configuracao-Logs-Win10 e listagem dos scripts nativos (01_enable_advanced_audit.ps1).


## 🛠️ 3. Seção de Troubleshooting (Erros e Soluções)

Durante a execução do projeto, diversos bloqueios e exceções de ambiente foram identificados e corrigidos:

## ⚠️ Erro 1: Bloqueio de Política de Execução de Scripts (PSSecurityException)

*  Sintoma: Bloqueio de segurança ao tentar executar o script .\01_enable_advanced_audit.ps1:

```
...\01_enable_advanced_audit.ps1 não pode ser carregado porque a execução de scripts foi desabilitada neste sistema.

```

*  Causa: Política de execução do PowerShell configurada no modo restrito por padrão.

*  Solução: Alteração temporária do escopo do processo com o comando:

```
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

```

![Erro na Execussão](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/04.png)


## ⚠️ Erro 2: Script Não Assinado Digitalmente (UnauthorizedAccess)

*  Sintoma: Mesmo após mudar a política para RemoteSigned, o script foi bloqueado por ausência de assinatura digital.

*  Solução: Aplicação do bypass total para a sessão atual do PowerShell:

```
Set-ExecutionPolicy Bypass -Scope Process -Force

```

![Script não Assinado](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/05.png)


## ⚠️ Erro 3: Incompatibilidade de Idioma na Ferramenta auditpol (0x00000057)

*  Sintoma: Ao executar 01_enable_advanced_audit.ps1, o utilitário auditpol retornou o erro Erro 0x00000057: Parâmetro incorreto em subcategorias como Process Creation e Account Lockout

*  Causa: O sistema operacional Windows está instalado em Português (Pt-BR). O utilitário auditpol exige que os nomes das subcategorias sejam digitados no idioma nativo do sistema operacional (ex: "Criação de processo" em vez de "Process Creation")

*  Observação Importante: As alterações nas Chaves de Registro (Event 4688 e Script Block Logging 4104) foram aplicadas com sucesso.

*  Solução Manual/Direta: Execução do comando do auditpol adaptado para o idioma do SO

```
auditpol /set /subcategory:"Criação de processo" /success:enable /failure:enable

```
![Evidencia Auditpol](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/06.png)

![Correção](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/07.png)

## ⚠️ Erro 4: Ausência do Executável do Sysmon no Diretório do Projeto

*  Sintoma: O utilitário Sysmon64.exe não se encontrava na pasta clonada.
*  Solução: Download automatizado direto do Sysinternals da Microsoft e aplicação da configuração do repositório SwiftOnSecurity:


# Criar diretório dedicado e baixar Sysmon + Configuração
```
New-Item -ItemType Directory -Path "C:\Users\WinLab\Desktop\Sysmon" -Force | Out-Null
cd C:\Users\WinLab\Desktop\Sysmon

Invoke-WebRequest -Uri "https://live.sysinternals.com/files/Sysmon.zip" -OutFile ".\Sysmon.zip"
Expand-Archive -Path ".\Sysmon.zip" -DestinationPath "." -Force

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile ".\sysmon_config.xml"

```

# Instalação do Serviço

```
.\Sysmon64.exe -accepteula -i .\sysmon_config.xml

```
![Instalação Sysmon](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/08.png)

### ⚠️ Erro 5: Nome do Serviço Divergente (`GetServiceCommandException`)


* Sintoma: O comando `Get-Service Sysmon` retornava a mensagem: `Não é possível localizar qualquer serviço com o nome de serviço 'Sysmon'.
* Causa: Em arquiteturas de 64 bits, quando instalado via `Sysmon64.exe`, o nome do serviço é registrado no Windows com o sufixo `64`.
* Solução: Consultar o nome exato registrado do serviço:

  ```
  Get-Service Sysmon64
 
  ```
![Error Name](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/09.png)

### ⚠️ Erro 6: Erro de Sintaxe e Parser no Script de Hunting (ParseException)

*  Sintoma: Falha ao executar .\03_hunting_phishing_analysis.ps1 com múltiplos erros de sintaxe (ex: ')' de fechamento ausente e caracteres de barra invertida escapando parênteses
*  Causa: Corrupção de caracteres especiais e formatação durante a cópia/transferência do arquivo
*  Solução: Reescrever o arquivo de análise diretamente via PowerShell com bloco here-string limpo e codificação UTF-8:

![erro](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/10.png)

**A mudança realizada através do scrip**

[triagem.ps1](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/triagem.ps1)

### 📊 4. Resultado da Caça a Ameaças (Threat Hunting)

Após a reescrita e correção do script, a análise varreu os eventos do Sysmon/Segurança e consolidou as evidências:

*  Execução com Sucesso: O script processou os logs operacionais e identificou 9 detecções de ameaças/anomalias no ambiente.

![Sucesso](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/11.png)

*  Arquivo Gerado: O artefato de telemetria hunting_summary.csv foi criado com sucesso no diretório de trabalho com tamanho total de 7.28 KB (7280 bytes).

![Arquovo gerado](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/12.png)

### 📈 5. Análise Estatística e Visualização de Dados em R

Após a extração e validação do dataset `hunting_summary.csv` no ambiente Windows, os dados foram transferidos para a estação de análise Blue Team (ThinkPad E470 - Ubuntu 24.04 Noble) para processamento estatístico e geração de visuais com RStudio e `tidyverse`.

#### 🛠️ Seção de Troubleshooting (Ambiente R e Renderização)

* **Resolução de Chaves GPG / Repositório CRAN:** Repositórios do R no Ubuntu Noble foram ajustados e as dependências nativas (`libcurl4-openssl-dev`, `libssl-dev`, `cargo`) foram consolidadas via `apt`.
* **Tratamento de Esquema de Dados:** O parser do script `05_telemetry_analytics.R` foi atualizado para alinhar o mapeamento da coluna temporal com o cabeçalho real do CSV (`Timestamp`).
* **Estabilidade de Renderização:** Para evitar exceções de buffer e pastas temporárias (`/tmp`) em instâncias Linux, a exportação do pipeline gráfico foi padronizada em imagens estáticas de alta resolução via `ggplot2::ggsave`.

#### 📊 6. Resultados da Análise de Telemetria
A execução do pipeline em R consumiu os eventos higienizados e gerou os artefatos visuais de análise temporal e volumetria do incidente:

1. Análise Temporal de Anomalias 

![timeline_incident_spike.png](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/timeline_incident_spike.png)

   *  Agrupamento de logs em janelas fixas de 5 minutos.

   *  Identificação clara de pico de atividade suspeita concentrado entre 21:50 e 22:00.

2. Distribuição Contínua por Severidade

 ![incident_timeline.png](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/timeline_incident_spike.png)

   *   Histograma de eventos classificados por criticidade.

   *   Todas as 9 detecções capturadas enquadraram-se na severidade HIGH, referentes a comportamento de descompactação e execução encadeada via navegadores/processos utilitários (msedge.exe).

#### 🏆 7. Conclusão e Lições Aprendidas

*  Eficácia da Telemetria Integrada: A combinação do Sysmon (Event ID 1) com o acompanhamento de linha de comando permitiu reconstruir a árvore de execução dos processos sem lacunas visuais.

* Resiliência na Resposta a Incidentes: O ajuste dinâmico de scripts PowerShell em ambientes heterogêneos (Win10 Pt-BR vs Linux RStudio) comprovou a importância de pipelines de dados robustos para Triagem e Threat Hunting.

* Escalabilidade: O ambiente de análise em R está homologado para processar datasets de maior escala gerados por frameworks de Command and Control (C2) e simulações de adversários em fases avançadas de laboratório.


