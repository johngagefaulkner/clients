<#
    - [Name] Install-PowerShell7.ps1
    - [Description] Installs PowerShell v7.2.3
    - [Resources and References]
        - https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2
#>
Clear-Host
Write-Host "[ Install-PowerShell7.ps1 ]"
Write-Host

# Define Variables
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# Download the Installer
Write-Host "Download and installing PowerShell v7.2.3, please wait..."

function Install-PowerShell7 {
    Start-Process -FilePath msiexec.exe -ArgumentList '/package "https://github.com/PowerShell/PowerShell/releases/download/v7.2.3/PowerShell-7.2.3-win-x64.msi" /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1' -Wait
}

# Install the application silently
Install-PowerShell7
Write-Host "Done!"
