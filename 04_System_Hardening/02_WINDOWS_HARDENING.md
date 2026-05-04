# 🪟 Host Hardening Profile: Windows 10 (Lab Workstation)
**ID:** HSP-WIN-02 | **Role:** Workstation / Pivot Point | **Status:** 🛡️ HARDENED

---

## 🔍 1. Análise de Exposição (Contexto da História)
Conforme detalhado no **[Relatório de Enumeração do Red Team](../03_Enumeration/README.md)**, esta máquina é o alvo de um ataque de **Phishing via Engenharia Social (Fase 04)**. O objetivo do atacante é:
1.  **Execução Inicial:** Convencer o usuário a abrir um payload via e-mail.
2.  **Persistence & C2:** Abrir uma porta dos fundos (*Backdoor*) para comunicação com o Apache (MacBook).
3.  **Lateral Movement:** Usar este host como ponte para atingir o Metasploitable.

---

## 🛡️ 2. Estratégia de Defesa Proativa (ASR & PowerShell)

### 🚫 Anti-Phishing: Attack Surface Reduction (ASR)
Implementamos regras para bloquear o comportamento típico de malwares disparados por e-mail (Office disparando processos, scripts ofuscados).

**Procedimento via PowerShell (Admin):**
```powershell
# Bloqueia o Office de criar processos filhos (Comum em Phishing)
Add-MpPreference -AttackSurfaceReductionRules_Ids D4F940AB-401B-4EFC-AADC-AD5F3C50688A -AttackSurfaceReductionRules_Actions Enabled

# Bloqueia execuções de scripts potencialmente maliciosos
Add-MpPreference -AttackSurfaceReductionRules_Ids 92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B -AttackSurfaceReductionRules_Actions Enabled

```
---
### 🔐 PowerShell Constrained Language Mode
Para impedir que um *Reverse Shell* execute comandos complexos de descoberta de rede, reflexão de .NET ou extração de dados.

```powershell
# Força o PowerShell a rodar em modo restrito para usuários comuns (Nível Sênior de Hardening)
[Environment]::SetEnvironmentVariable('__PSLockdownPolicy', '4', 'Machine')

```
---

## 🧱 3. Network Hardening (Anti-Pivotagem)

### 🛑 Desativação de Protocolos de Descoberta (LLMNR/NetBIOS)
Esses protocolos são legados e frequentemente explorados por ferramentas como o **Responder** no MacBook para capturar e fazer o *Relay* de hashes de senhas.

* **Ação:** Criada chave de registro para desativar o LLMNR globalmente no sistema.

```powershell
# Desativa o Multicast DNS (LLMNR) para evitar envenenamento de rede
New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT" -Name "DNSClient" -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 0 -PropertyType DWORD

```
---

### 🛂 Windows Firewall: Scope Restriction
Restringimos serviços críticos como RDP (3389) e SMB (445) para que não aceitem conexões vindas do IP do MacBook, quebrando a tentativa de pivotagem na camada de rede.

```powershell
# Bloqueia entrada de tráfego SMB vindo especificamente do IP do MacBook (Entry Point)
New-NetFirewallRule -DisplayName "Block_Pivot_MacBook" -Direction Inbound -Action Block -RemoteAddress 192.168.1.50 -Protocol TCP -LocalPort 445

```
---

## ✅ 4. Verificação Blue Team (Métrica de Sucesso)

| Vetor de Ataque | Status Inicial | Medida de Hardening | Resultado Final |
| :--- | :--- | :--- | :--- |
| **Execução de Payload** | 🔓 Sucesso | ASR Rules (Office Child Process) | 🚫 Processo Bloqueado |
| **Reverse Shell (C2)** | 🔓 Ativo | PowerShell Constrained Mode | ❌ Comando Negado |
| **SMB Relay / Responder** | 🔓 Vulnerável | LLMNR/NetBIOS Disabled | 🔒 Sem Vazamento de Hash |
| **Pivotagem Inbound** | 🔓 Aberto | Firewall Scope Restriction | 🚫 Connection Reset |

---

## 📈 Conclusão do Hardening: Win10
Com estas medidas, o Windows 10 deixa de ser o "elo fraco" da infraestrutura. Mesmo que o usuário venha a clicar no link de **Phishing na Fase 04**, as regras de **ASR (Attack Surface Reduction)** e o **PowerShell Restrito** impedirão a criação bem-sucedida do túnel reverso e a execução de comandos pós-exploração.

---

[⬅️ Voltar ao README da Fase 03](./README.md) | [Ir para Hardening: Metasploitable ➡️](./03_METASPLOITABLE_HARDENING.md)
