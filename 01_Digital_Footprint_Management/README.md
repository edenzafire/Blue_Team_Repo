# 🛡️ Digital Footprint Management & Identity Hardening
## Blue Team Phase 01 | Mapeamento, Mitigação e Redução de Superfície de Ataque

![Status](https://img.shields.io/badge/Status-Phase%2001%20Complete-green?style=for-the-badge&logo=checkmarx)
![Security](https://img.shields.io/badge/Security-Blue%20Team-blue?style=for-the-badge&logo=shield)
![Framework](https://img.shields.io/badge/Framework-MITRE%20D3FEND-orange?style=for-the-badge&logo=mitre)
![Privacy](https://img.shields.io/badge/Compliance-LGPD-red?style=for-the-badge&logo=gdpr)

### 📋 Visão Geral
Esta fase foca na **Remediação de Ativos** identificados durante a etapa de **[OSINT - Red Team Operation](https://github.com/edenzafire/Red_Team_Repo)**. 

O objetivo principal é a aplicação de controles de segurança rigorosos para neutralizar vetores de ataque baseados em pegada digital, vazamento de dados históricos e identidades legadas que foram mapeadas e exploradas na fase ofensiva deste projeto. Através da união entre as frentes ofensiva e defensiva, este repositório consolida uma abordagem de **Purple Teaming**.

---

## 📑 Índice de Documentação Técnica (Fase 01)
A estrutura abaixo centraliza todos os artefatos gerados durante o processo de remediação e proteção.

| Documento | Descrição | Referência |
| :--- | :--- | :--- |
| [🧪 Lab Report](./fase-01-osint-remediation/LAB-REPORT-01.md) | Evidências de Decommissioning e Sanitização | MITRE D3FEND |
| [🛡️ Hardening](./fase-01-osint-remediation/HARDENING-MONITORING.md) | Controles de MFA e Monitoramento de Dark Web | NIST PR.IP-6 |
| [🏁 Post-Mortem](./fase-01-osint-remediation/POST-MORTEM.md) | Lições aprendidas e Melhoria Contínua | NIST SP 800-61 |
| [📸 Evidences Folder](./fase-01-osint-remediation/evidences/) | Repositório de logs, prints e artefatos brutos | Auditoria Técnica |

---
### 🏛️ The "Master" Layer: MITRE D3FEND™ Integration
Diferente de uma higienização comum, este projeto utiliza o framework **MITRE D3FEND** como camada mestre para orquestrar contramedidas específicas contra as táticas de reconhecimento e exploração.

* **Modelagem de Defesa:**
    * **D3-DA (Decoy Any):** Ofuscação de dados reais para confundir a coleta de informações (Data Poisoning).
    * **D3-EAL (Evict Adversary):** Desacoplamento de sessões e revogação de identidades legadas para expulsar persistência latente.
    * **D3-OTAD (OTP-based Authentication):** Endurecimento de acesso via métodos de autenticação de fator múltiplo.

---

### 🎯 Objetivos Estratégicos
* **Attack Surface Reduction (ASR):** Eliminação cirúrgica de pontos de entrada desnecessários e obsoletos.
* **Data Minimization (LGPD):** Higienização de dados pessoais em conformidade com o **Art. 18 da LGPD** (Direito à Eliminação).
* **Identity Lifecycle Management:** Governança técnica sobre o encerramento de identidades (Decommissioning).

---

### 🛠️ Controles de Segurança & Técnicas D3FEND

#### 1. Decommissioning de Ativos Legados (Contas 2011)
* **Cenário:** Redes sociais (Meta, TikTok, etc.) vinculadas a credenciais obsoletas (e-mails/telefones de 2011).
* **Ação:** Execução de **Data Poisoning** (sanitização de metadados antes da exclusão) e desacoplamento de identidades federadas no Meta Accounts Center.
* **Técnica D3FEND:** *Credential Disruption* (Interrupção de Credenciais).
* **Resultado:** Neutralização de ataques de **Account Takeover (ATO)** e engenharia social baseada em histórico.

#### 2. Análise de Exposição & Credential Hardening
* **Cenário:** Auditoria cruzada em bases de vazamentos históricos (Have I Been Pwned, IntelX).
* **Controle:** Implementação de políticas de rotação de senhas e **MFA Enforcement** (FIDO2/TOTP).
* **Técnica D3FEND:** *Multi-factor Authentication*.
* **Resultado:** Mitigação de vetores de *Credential Stuffing* e *Password Spraying*.

#### 3. Sanitização de Metadados (Privacy by Default)
* **Cenário:** Presença de informações sensíveis (GPS, Device ID, Timestamps) em mídias públicas.
* **Ferramenta:** ExifTool.
* **Técnica D3FEND:** *File Content Analysis & Metadata Removal*.
* **Conceito:** Aplicação de Privacy by Design para eliminar inteligência de reconhecimento (Recon).

---

### 📊 Matriz de Correlação (Red ➔ Blue ➔ D3FEND)

| Ativo Identificado (Red Team) | Risco Associado | Mitigação Aplicada (Blue Team) | D3FEND Mapping |
| :--- | :--- | :--- | :--- |
| **Legacy Phone (2011)** | Recuperação de conta (ATO) | Account Decommissioning | **D3-ICA** (Ident. Cache Analysis) |
| **Unique Usernames** | Pivotagem e Impostorismo | Brand Protection Monitoring | **D3-DTL** (Decoy Territory Logging) |
| **EXIF Data** | Localização e Recon | Metadata Stripping | **D3-FCA** (File Content Analysis) |

---

### 🛡️ Hardening & Continuous Monitoring
Para garantir a integridade da identidade digital a longo prazo, foram estabelecidos os seguintes controles de persistência:

* **Exposure Alerts:** Configuração de webhooks para monitoramento de vazamentos de credenciais em tempo real.
* **Quarterly OSINT Audit:** Agendamento trimestral de varreduras para detectar novos rastros ou *shadow accounts*.

---

### 📜 Frameworks & Conceitos Aplicados
* **NIST PR.IP-6:** Gestão do ciclo de vida de identidades e credenciais.
* **MITRE ATT&CK [T1589]:** Mitigação contra coleta de informações de identidade.
* **MITRE D3FEND:** Arquitetura de contramedidas e engenharia defensiva.

**Próxima Fase:** *02. Asset Inventory & Shielding (Recon Equivalent)*
