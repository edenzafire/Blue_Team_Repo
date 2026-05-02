# 🛡️ Blue Team Operations & Defesa Cibernética
> **Foco:** Monitoramento, Hardening e Mitigação de Riscos.

Nota: Este portfólio é a camada de proteção que consolida meus estudos em **[Red Team](https://github.com/edenzafire/Red_Team_Repo)** e **[Low-Level Security](https://github.com/edenzafire/Low_Level_Repo)**. Juntos, eles formam minha base de **Purple Teaming**, onde o conhecimento ofensivo é utilizado para construir infraestruturas resilientes e detecções precisas.

---

## 📊 Operações de Defesa
![BlueTeam](https://img.shields.io/badge/Focus-Active--Defense-blue?style=for-the-badge&logo=fortinet&logoColor=white)
![Detection](https://img.shields.io/badge/Tools-SIEM%20%7C%20EDR%20%7C%20WAF-brightgreen?style=for-the-badge&logo=elasticstack&logoColor=white)
![Framework](https://img.shields.io/badge/Framework-NIST%20%7C%20MITRE%20D3FEND-lightgrey?style=for-the-badge&logo=googlecloud&logoColor=white)

---

## 📌 Sobre este Repositório
Este é o meu Centro de Operações de Segurança (SOC) pessoal. Aqui documento a implementação de controles de segurança, análise de logs e o endurecimento (*hardening*) de sistemas. Minha filosofia de defesa é baseada em dados: "Não basta bloquear, é preciso entender o comportamento".

### 🛡️ O Elo do Purple Teaming
Neste repositório, transformamos a exploração em proteção:
* [**Red Team**](https://github.com/edenzafire/Red_Team_Repo) Recebemos o comportamento de payloads.
* [**Low Level:**](https://github.com/edenzafire/Low-Level-Security) técnicas de evasão e cadeias de ataque.
* [**No Blue Team:**] Implementamos regras de detecção (YARA, Sigma), configuramos Firewalls/IDPs e aplicamos políticas de Hardening.
* **Resultado:** Um ciclo contínuo de melhoria onde cada ataque bem-sucedido no lab gera uma nova barreira defensiva.

---

## 👨‍💻 Sobre Mim

Olá! Sou **Éden Zafire**, um entusiasta de cibersegurança focado em transformar vulnerabilidades em perímetros fortificados.


---

## 🛠️ Competências Core & Frameworks

* 🛡️ **Defesa Estratégica (MITRE ATT&CK & D3FEND):** Especialista em converter táticas do **MITRE ATT&CK** em controles de detecção e resposta. Utilizo o framework **D3FEND** para projetar arquiteturas de defesa resilientes baseadas em engenharia de detecção.
* 🔍 **Threat Intelligence:** Monitoramento ativo de indicadores de comprometimento (IoCs) e análise de pegada digital (OSINT) para antecipar movimentos de adversários.
* ⚙️ **Hardening & NIST CSF:** Experiência em blindagem de sistemas Linux/Windows e gestão de identidades (IAM), seguindo as diretrizes do **NIST Cybersecurity Framework** para Identificar, Proteger e Detectar.
* 📋 **Compliance e Governança:** Aplicação de controles baseados na **ISO 27001**, garantindo que a segurança técnica esteja alinhada aos objetivos de negócio e conformidade.
* 🎓 **Evolução Contínua:** Pesquisa constante em metodologias de *Incident Response* e estudos voltados para certificações de defesa cibernética de alto nível.

<p align="center">
  <a href="https://github.com/edenzafire/Blue_Team_Repo">
    <img src="images/capa.png" alt="Capa do Portfólio Blue" style="border-radius:50px; border:3px solid red;" />
  </a>
</p>


## 🛡️ Projetos de Resiliência (Do Red ao Blue)

Abaixo, apresento como utilizo a mentalidade ofensiva para implementar contramedidas técnicas:

### 01. Gestão de Pegada Digital (OSINT → Blue)
* **Ação:** Mapeamento de exposição externa e limpeza de metadados.
* **Implementação:** Aplicação de "Direito ao Esquecimento" e monitoramento de *leaks* (Have I Been Pwned/BreachDirectory).
* **Foco:** Privacidade e Redução de Superfície.

### 02. Inventário e Blindagem de Ativos (Recon → Blue)
* **Ação:** Varredura de serviços críticos e fechamento de portas desnecessárias.
* **Implementação:** Configuração de **Host-based Firewalls** para bloquear acessos não autorizados.
* **Foco:** Asset Inventory & Shielding.

### 03. System Hardening (Enumeration → Blue)
* **Ação:** Identificação de protocolos legados e permissões excessivas.
* **Implementação:** Desativação de SMBv1, hardening de kernel e políticas de senhas complexas.
* **Foco:** Princípio do Privilégio Mínimo.

### 04. Segurança de Identidade - IAM (Social Engineering → Blue)
* **Ação:** Prevenção contra roubo de credenciais e acessos indevidos.
* **Implementação:** Deploy de **MFA (2FA)** e processos de *Decommissioning* de contas inativas.
* **Foco:** Identity & Access Management.

### 05. Proteção de Endpoint e Detecção (Exploitation → Blue)
* **Ação:** Bloqueio de execução de payloads e scripts maliciosos.
* **Implementação:** Configuração de defesas de memória (ASLR/DEP) e monitoramento de processos.
* **Foco:** Endpoint Security & EDR.

### 06. Monitoramento de Logs e Forense (Post-Exploitation → Blue)
* **Ação:** Prevenção contra limpeza de rastros e movimentação lateral.
* **Implementação:** Centralização de Logs e uso de **Honeytokens** para detecção precoce.
* **Foco:** SIEM & Incident Response.

---

## 📬 Contato

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/seu-perfil)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/edenzafire)

---
<p align="center">
  <em>"A melhor defesa é uma defesa que conhece profundamente o ataque."</em>
</p>
