# 🛡️ System Hardening & Least Privilege
## Blue Team Phase 03 | Fortalecimento de Sistemas e Controle de Privilégios

![Status](https://img.shields.io/badge/Status-Phase%2003%20Design-blue?style=for-the-badge&logo=gitbook)
![Security](https://img.shields.io/badge/Security-Least%20Privilege-green?style=for-the-badge&logo=dependabot)
![Compliance](https://img.shields.io/badge/Compliance-CIS%20Benchmarks-gold?style=for-the-badge&logo=checkmarx)
![Focus](https://img.shields.io/badge/Focus-ASR%20Tactics-red?style=for-the-badge&logo=target)

---

### 📖 Visão Geral
Esta fase é o contra-ataque direto à **Enumeração do Red Team**. Enquanto o atacante busca por permissões mal configuradas, serviços rodando como *root* e credenciais fracas, nosso foco é a **Redução da Superfície de Ataque (ASR)** através do endurecimento (*Hardening*) rigoroso do Sistema Operacional e Aplicativos.

> **Missão:** Garantir que, mesmo que um atacante consiga acesso inicial, ele encontre um ambiente hostil, restrito e incapaz de permitir movimentação lateral ou escalada de privilégios.

---

### 🎯 Inteligência de Ameaças (Purple Team Link)
> [!IMPORTANT]
> **Defesa Baseada em Evidências:** As configurações de Hardening e Privilégio Mínimo aplicadas aqui são uma resposta direta às vulnerabilidades de configuração exploradas no relatório: 
> 👉 **[03_Enumeration: Post-Exploitation & Network Discovery](https://github.com/edenzafire/Red_Team_Repo/blob/main/03_Enumeration/README.md)**.
>
> *O foco é bloquear a visão do atacante sobre usuários, grupos e serviços que foram expostos durante a enumeração.*

---

### 🎯 Contexto da Operação (Cenário de Pivotagem)
Esta fase foca em quebrar a corrente de ataque identificada no cenário de invasão:
* **Entrada:** MacBook White (Debian 12 + DVWA).
* **Movimentação:** Pivotagem via túnel para Windows 10.
* **Alvo Final:** Infraestrutura crítica (Metasploitable).

**Nossa missão nesta fase:** Impedir o movimento lateral através de Hardening de Kernel, restrição de portas de pivotagem e políticas de execução restritas.

---

### ⚖️ 1. Principle of Least Privilege (PoLP)
O objetivo é garantir que cada processo, usuário ou sistema tenha apenas o acesso estritamente necessário para realizar sua função.

* **Service Account Hardening:** Migração de serviços (Apache/MySQL) para contas dedicadas sem privilégios de Shell (`nologin`).
* **Privileged Access Management (PAM):** Restrição severa do uso de `sudo` e `Administrator`.
* **File System Permissions:** Correção de ACLs em arquivos sensíveis (ex: `/etc/shadow`, `C:\Windows\System32\config`) para impedir leitura não autorizada.

---

### 🏗️ 2. OS Hardening (Baseline CIS Benchmarks)
Implementação de políticas baseadas nos padrões globais de segurança para Linux e Windows.

#### 🐧 Linux Hardening (Debian/Ubuntu)
* **SSH Security:** Desativação de login de *root*, mudança da porta padrão e uso obrigatório de chaves **Ed25519**.
* **Unused Services:** Desativação de daemons desnecessários (ex: `avahi-daemon`, `cups`) identificados na enumeração.
* **Kernel Hardening:** Ajustes via `sysctl` para prevenir ataques de rede (ex: IP Spoofing e ICMP Redirects).

#### 🪟 Windows Hardening
* **UAC Optimization:** Configuração do Controle de Conta de Usuário no nível máximo (Always Notify).
* **Network ASR:** Desativação de protocolos legados (LLMNR, NetBIOS) para neutralizar ataques de **Relay (Responder)**.
* **Local Admin Restraint:** Remoção de contas de usuários comuns do grupo de Administradores Locais.

---

### 🕵️ 3. Auditing & Logging (Vigilância Ativa)
Um sistema forte deve ser capaz de "gritar" quando for atacado.

* **Configuração de Auditoria:** Ativação de logs granulares para sucessos e falhas de login.
* **Command Logging:** Registro detalhado de comandos executados com privilégios elevados.
* **Centralização:** Preparação da telemetria para envio a um futuro **SIEM (Security Information and Event Management)**.

---

### 🛠️ Frameworks de Referência
* **CIS Benchmarks:** O padrão ouro para configuração segura de sistemas.
* **NIST SP 800-123:** *Guide to General Server Security*.
* **Microsoft Security Baselines:** Melhores práticas de endurecimento para ambientes Active Directory.

---

> [!NEXT]
> **Próxima Fase:** [**04. Identity & Access Management (IAM)**](../04_IAM_Social_Eng/README.md)

---
[⬅️ Voltar ao Dashboard Principal](../README.md)
