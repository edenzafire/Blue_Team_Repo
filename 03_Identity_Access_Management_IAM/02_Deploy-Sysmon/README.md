## 🛡️ Deploy e Configuração Avançada do Sysmon

Esta etapa realiza a implantação do **System Monitor (Sysmon)** da suíte Microsoft Sysinternals, utilizando um arquivo de configuração XML mapeado com base nas técnicas do framework **MITRE ATT&CK**.

---

### 📋 Mapeamento de Regras e Coleta

A configuração `01_sysmon_config.xml` foi projetada para alta fidelidade e baixo consumo de recursos, cobrindo os seguintes eventos estratégicos:

* **Event ID 1 (Process Creation):** Monitoramento de executáveis do sistema comumente abusados (LOLBins como `powershell.exe`, `cmd.exe`, `certutil.exe`) e cálculo de hashes (`MD5`, `SHA256`, `IMPHASH`).
* **Event ID 3 (Network Connection):** Rastreamento de conexões de rede originadas por binários e scripts de administração.
* **Event ID 7 (Image Loaded):** Detecção de carregamento de DLLs sensíveis em locais incomuns.
* **Event ID 11 (File Create):** Coleta de criação de arquivos executáveis e scripts (`.ps1`, `.bat`, `.vbs`) em diretórios temporários (`AppData\Local\Temp`).
* **Event ID 12/13/14 (Registry Events):** Monitoramento de alterações em chaves de persistência do Registro do Windows (`Run`, `RunOnce`).

---

### 🚀 Passo a Passo de Instalação

#### Pré-requisitos
* Sistema Operacional: Windows 10
* Permissões: Elevação de Administrador

#### Instruções de Execução

1. Abra o **Prompt de Comando (cmd)** ou o **PowerShell** como **Administrador**.

2. Navegue até o diretório desta etapa:
   ```powershell
   cd path\to\Blue_Team_Repo\03_Identity_Access_Management_IAM\02_Deploy-Sysmon

   ```
### Execute o script em lote de instalação:

 ```
02_install_sysmon.bat

```


################################################################################################

---

## ⚙️ Como Executar o Script de Deploy (`02_install_sysmon.bat`)

O script `02_install_sysmon.bat` realiza o deploy automatizado do Sysmon de forma resiliente, verificando permissões, gerenciando arquivos e validando a execução do serviço.

### 📑 Funcionalidades do Script
* **Validação de Elevação:** Confirma se a sessão possui privilégios de Administrador.
* **Download Automático:** Baixa a versão oficial do `Sysmon.exe` caso o binário não esteja presente na pasta.
* **Gestão Inteligente de Serviço:** Detecta se o serviço já está instalado e opta por instalar (`-i`) ou apenas atualizar as regras (`-c`).
* **Validação Pós-Deploy:** Consulta o estado do serviço (`sc query`) para garantir a transição para o estado `RUNNING`.

---

### 🚀 Instruções de Execução

1. Abra o **Prompt de Comando (CMD)** ou o **Windows PowerShell** como **Administrador**.

2. Navegue até o diretório da etapa:
   ```cmd
   cd path\to\Blue_Team_Repo\03_Identity_Access_Management_IAM\02_Deploy-Sysmon

  ```
### Execute o script em lote:

  ```
 02_install_sysmon.bat
 
 ```

## 🟢 Saída Esperada no Terminal

============================================================================
                    IMPLANTATION E CONFIGURACAO DO SYSMON
============================================================================

[+] [1/4] Verificando arquivo de configuracao XML...
[OK] Arquivo de configuracao localizado.
[+] [2/4] Verificando o binario do Sysmon...
[OK] Executavel Sysmon.exe encontrado localmente.
[+] [3/4] Verificando status do servico no sistema...
[INFO] Servico Sysmon nao encontrado. Realizando nova instalacao...
[+] [4/4] Validando execucao do servico...

============================================================================
[SUCESSO] Sysmon instalado, configurado e EM EXECUCAO com exito!
============================================================================



