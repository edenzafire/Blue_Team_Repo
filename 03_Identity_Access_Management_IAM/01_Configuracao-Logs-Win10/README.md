## 🚀 Como Executar o Script de Auditoria Avançada

Este script em PowerShell automatiza a configuração das políticas de auditoria local no Windows 10 e exporta o estado das regras aplicadas para validação.

### Pré-requisitos
* Sistema Operacional: Windows 10
* Permissões: Privilégios de Administrador

### Passo a Passo

1. Abra o **PowerShell** como Administrador:
   * Pressione a tecla `Win`, digite **PowerShell**, clique com o botão direito e selecione **Executar como Administrador**.

2. Navegue até o diretório do projeto:
   ```powershell
   cd path\to\Blue_Team_Repo\03_Identity_Access_Management_IAM\01_Configuracao-Logs-Win10
   ```
### Caso a execução de scripts esteja bloqueada no seu sistema, libere temporariamente para a sessão atual:

  ```
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

  ```

### Execute o script de configuração:

  ```
.\01_enable_advanced_audit.ps1

  ```



