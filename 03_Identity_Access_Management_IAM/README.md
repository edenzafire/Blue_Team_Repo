# 🛡️ Blue Team Lab: Auditoria de Eventos & Telemetria com Sysmon no Windows 10

## 📌 Visão Geral (Overview)
Este repositório documenta as etapas de hardening, auditoria avançada e implantação do **Sysmon** em um ambiente Windows 10 Enterprise. O objetivo central é prover **visibilidade total** do sistema operacional para detectar, rastrear e mitigar atividades maliciosas.

Este projeto faz parte de um **Exercício Prático de Purple Team**:
* 🔴 **Red Team (Simulação de Ataque):** O vetor de entrada por Phishing e a execução dos payloads foram documentados no repositório de Red Team: [`03_Initial_Access_RedTeam`](https://github.com/SEU-USUARIO/Red_Team_Repo/tree/main/03_Initial_Access).
* 🔵 **Blue Team (Defesa & Análise - Este Repositório):** Focado exclusivamente no estudo comportamental dos logs, engenharia de detecção, mapeamento da telemetria e aplicação de medidas de mitigação.

---

## 🏛️ Frameworks & Conformidade (Standards & Alignment)
Este laboratório foi estruturado orientando-se pelos principais padrões e frameworks do mercado de cibersegurança:

* ⚔️ **MITRE ATT&CK®:** Mapeamento de TTPs (*Tactics, Techniques, and Procedures*) utilizadas pelo Red Team para identificação precisa dos vetores de ataque (ex.: `T1566.001 - Phishing`, `T1059.001 - PowerShell`).
* 🛡️ **MITRE D3FEND™:** Aplicação de contramedidas defensivas e contramedidas técnicas de hardening baseadas na arquitetura de defesa (*Process Lineage Analysis*, *System Call Analysis*, *File Modification Analysis*).
* 📜 **NIST Cybersecurity Framework (CSF 2.0):** Alinhado às funções de **Protect** (Hardening/Políticas), **Detect** (Sysmon/Auditoria Avançada) e **Respond** (Análise e Mitigação).
* ⚖️ **LGPD (Lei Geral de Proteção de Dados - Lei nº 13.709/2018):** Conformidade com o princípio de *Segurança e Prevenção* (Art. 6º, VIII e VIII), garantindo retenção de logs e rastreabilidade para auditoria de incidentes que possam envolver dados sensíveis, respeitando a minimização na coleta de logs de usuários.

---

## 🏗️ Arquitetura do Lab & Ferramentas
* **Target / Victim:** Windows 10 (Build 22H2)
* **Agente de Telemetria:** Microsoft Sysinternals Sysmon v15.x
* **Configuração do Sysmon:** [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config) / Personalizada
* **Auditoria Local:** Advanced Audit Policy Configuration (GPO / Local Policy)
* **Análise de Telemetria:** Windows Event Viewer / PowerShell / Regras SIGMA
---

## 📁 Estrutura do Repositório

```

📁 `03_Identity_Access_Management_IAM/`
├── 📂 `01_Configuracao-Logs-Win10/`
│   ├── `01_enable_advanced_audit.ps1`        *(Script PowerShell p/ automação de auditoria local)*
│   ├── `02_gpo_audit_policy_backup.csv`      *(Export das políticas ativas via auditpol)*
│   └── `README.md`                            *(Guia passo a passo do hardening de auditoria)*
│
├── 📂 `02_Deploy-Sysmon/`
│   ├── `01_sysmon_config.xml`                 *(Arquivo de regras/schema do Sysmon utilizado)*
│   ├── `02_install_sysmon.bat`                *(Script de instalação e atualização silenciosa)*
│   └── `README.md`                            *(Documentação sobre Event IDs e customização de regras)*

├── 📂 `03_Analise-Telemetria-Evidencias/`
│   ├── `01_evidencia_process_creation.xml`    *(Export do Sysmon Event ID 1 em formato XML/JSON)*
│   ├── `02_evidencia_network_connection.xml`  *(Export do Sysmon Event ID 3)*
│   ├── `03_hunting_phishing_analysis.ps1`     *(Script PS p/ extrair indicadores direto do Event Log)*
│   └── `04_chain_execution_tree.png`          *(Print do Event Viewer / Tree View da execução)*
│
└── 📂 `04_Regras-Detecao-Mitigacao/`
    ├── `01_sigma_phishing_office_spawn.yml`   *(Regra SIGMA genérica para detecção)*
    └── `02_asr_mitigation_policies.md`        *(Recomendações técnicas de mitigação/ASR)*
```


