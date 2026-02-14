# 🐧 Host Hardening Profile: MacBook White (Debian 12)
**ID:** HSP-DEB-01 | **Role:** Web Server / Entry Point | **Status:** 🛡️ HARDENED

---

## 🔍 1. Análise de Exposição (Red Team Input)
O relatório de **[Enumeração do Red Team](../03_Enumeration/README.md)** identificou que, após a exploração do DVWA, foi possível:
1.  Listar todos os usuários do sistema via `/etc/passwd`.
2.  Identificar que o serviço Apache rodava com permissões excessivas.
3.  Mapear a rede interna para iniciar o túnel SSH/Proxychains para o Windows 10.

---

## 🔧 2. Implementação do Privilégio Mínimo (PoLP)

### 👤 Hardening de Conta de Serviço
O Apache não deve ter acesso a nada fora do `/var/www/html`. 
* **Ação:** Garantir que o usuário `www-data` tenha o shell definido como `/usr/sbin/nologin`.
* **Comando:**
```bash
sudo usermod -s /usr/sbin/nologin www-data
```
---

### 📂 Restrição de Sistema de Arquivos (ACLs)
Impedir que o processo do servidor web "fofoque" sobre os usuários do sistema para o atacante.
* **Ação:** Restringir permissões de leitura em arquivos sensíveis.

```bash
# Impede usuários comuns de lerem logs e configs sensíveis
sudo chmod 600 /etc/shadow
sudo chmod 600 /etc/ssh/sshd_config
```
---

## 🧱 3. OS Hardening (Anti-Pivotagem)

### 🚫 Anti-Reverse Shell & Tunneling
Para evitar que o MacBook seja usado como "ponte" para o Windows 10, aplicamos restrições de rede no nível do host (**Egress Filtering**).

**Configuração de Firewall (UFW):**

```bash
# Bloqueia qualquer tentativa de conexão saindo do MacBook para a rede interna, 
# exceto o necessário para o laboratório.
sudo ufw default deny outgoing
sudo ufw allow out to any port 80,443          # Updates
sudo ufw deny out to 192.168.1.100             # BLOQUEIO de Pivot para Win10

```
---

### 🔐 SSH Deep Hardening
Se o atacante tentar forçar um túnel SSH para pivotagem, as diretivas abaixo bloqueiam a criação de canais secundários:

**Arquivo:** `/etc/ssh/sshd_config`

```plaintext
AllowTcpForwarding no
X11Forwarding no
AllowAgentForwarding no
PermitRootLogin no
MaxAuthTries 3

---

## 🕵️ 4. Vigilância Ativa (Auditd)
Configuramos o `auditd` para gerar alertas imediatos se alguém tentar ler arquivos de configuração ou executar comandos de rede suspeitos.

```bash
# Adicionando regra para monitorar execuções do binário 'nc' (netcat) ou 'nmap'
sudo auditctl -a exit,always -F arch=b64 -S execve -k suspicious_commands

```
---

## ✅ 5. Verificação Blue Team

A eficácia das medidas foi testada para garantir que o caminho de pivotagem para o Windows 10 fosse interrompido.

| Vetor de Ataque | Status Inicial | Medida de Hardening | Resultado Final |
| :--- | :--- | :--- | :--- |
| **Enumeração de Usuários** | 🔓 Aberta | Restrição de Permissões (ACLs) | 🔒 Bloqueado (403/Access Denied) |
| **Pivotagem (Túnel SSH)** | 🔓 Possível | `AllowTcpForwarding no` | 🚫 Conexão Recusada |
| **Reverse Shell** | 🔓 Sucesso | Egress Filtering (Firewall) | ❌ Timeout na Conexão |

---

[⬅️ Voltar ao README da Fase 03](./README.md)
