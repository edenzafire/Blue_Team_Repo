# 💀 Host Hardening Profile: Metasploitable 2
**ID:** HSP-META-03 | **Role:** Vulnerable Legacy Target | **Status:** ⛓️ ISOLATED / SANDBOXED

---

## 🔍 1. Análise de Exposição (O "Queijo Suíço")
Diferente dos hosts anteriores, o Metasploitable 2 possui vulnerabilidades intencionais em quase todos os serviços (FTP, SSH, Telnet, Samba, Java RMI, etc.). No nosso cenário de ataque, ele é o **Alvo Final** após o pivot no Windows 10.

> **Estratégia Blue Team:** Como o hardening interno é inviável sem descaracterizar o lab, aplicamos **Hardening de Infraestrutura e Rede** para impedir que o comprometimento deste host afete o restante da organização.

---

## 🛡️ 2. Estratégia de Contenção (The Sandbox)

### 👤 Identity & Credential Rotation
O primeiro passo de um atacante (ou worm) é tentar as credenciais padrão. Quebramos o movimento automatizado aqui.
* **Ação:** Alteração das credenciais `msfadmin:msfadmin`.
```bash
# Alterando a senha do usuário principal
echo "msfadmin:NovaSenhaSuperForte2026" | sudo chpasswd
```
---

### 🧱 Network Micro-Segmentation (Zero Trust Egress)
A maior ameaça de um Metasploitable comprometido é ele virar um "zumbi" para atacar a internet ou outros hosts internos da organização.

* **Ação:** Configuração de regras de saída (*Egress*) extremamente restritas diretamente no Firewall do host.

```bash
# Bloqueia TODA saída de tráfego (Impede que Reverse Shells consigam 'ligar para casa')
sudo ufw default deny outgoing

# Bloqueia especificamente qualquer tentativa de conexão lateral para o Windows 10 ou MacBook
sudo ufw deny out to 192.168.1.100
sudo ufw deny out to 192.168.1.50

```
---

## 🕵️ 3. Monitoramento de Intrusão (Tripwire Mindset)
Já que o Metasploitable é um alvo conhecido, configuramos alertas para monitorar o comportamento do atacante "dentro da caixa", tratando o host como um verdadeiro *honeypot*.

* **Log de Conexões:** Ativação do log de todas as tentativas de conexão nas portas que deveriam estar desativadas para identificar a origem do ataque.
* **Kernel Auditing:** Monitoramento de acessos ao sistema de arquivos via `auditd` para capturar qualquer tentativa de exfiltração de dados sensíveis.

---

## ✅ 4. Verificação Blue Team (Métrica de Sucesso)

| Vetor de Ataque | Status Inicial | Medida de Hardening | Resultado Final |
| :--- | :--- | :--- | :--- |
| **Exploração por Brute-force** | 🔓 Credenciais Padrão | Rotação de Senhas Críticas | 🔒 Falha na Autenticação |
| **Reverse Shell (C2)** | 🔓 Sucesso | Zero Trust Egress Policy | ❌ Conexão Bloqueada no Host |
| **Movimentação Lateral** | 🔓 Aberta | Micro-segmentação de Rede | 🚫 Host Isolado na VLAN |

---

## 📈 Conclusão do Hardening: Metasploitable
O hardening do Metasploitable prova que, em segurança, **se você não pode proteger o host, você protege a rede ao redor dele**. Ele permanece vulnerável para fins de estudo e laboratório, mas está tecnicamente "preso" em uma jaula digital, incapaz de servir de base para novos ataques ou comprometer outros ativos da rede.

---

[⬅️ Voltar ao README da Fase 03](./README.md)
