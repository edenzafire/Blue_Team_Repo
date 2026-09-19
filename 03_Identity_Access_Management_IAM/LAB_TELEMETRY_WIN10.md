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

** Etapa 1: Obtenção do Repositório

O projeto foi clonado diretamente do repositório remoto para a máquina local de testes.

*  Ação: Baixado a estrutura do projeto em .zip e extraído na Área de Trabalho (Desktop).

![Baixar Zip](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/01.png)

*  Estrutura: Pasta 03_Identity_Access_Management_IAM posicionada no Desktop.

![Extrair & acessar a pasta](https://github.com/edenzafire/Blue_Team_Repo/blob/main/03_Identity_Access_Management_IAM/Evidencias/03.png)


## Etapa 2: Preparação do Ambiente e Execução do Script de Auditoria




