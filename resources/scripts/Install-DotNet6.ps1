<#
    - [Name] Install-DotNet6.ps1
    - [Description] Downloads and installs the Windows Desktop Runtime v6.0.4 (x64)
    - [Resources and References]
        -
#>
Clear-Host
Write-Host "[ Install-DotNet6.ps1 ]"
Write-Host

# Define Variables
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$backup_dotnetUrl = "https://download.visualstudio.microsoft.com/download/pr/f13d7b5c-608f-432b-b7ec-8fe84f4030a1/5e06998f9ce23c620b9d6bac2dae6c1d/windowsdesktop-runtime-6.0.4-win-x64.exe"
$dotnetUrl = "https://datacdn.b-cdn.net/dl/windowsdesktop-runtime-6.0.4-win-x64.exe"
$localDir = "C:\ProgramData\"
$localPath = "C:\ProgramData\windowsdesktop-runtime-6.0.4-win-x64.exe"

# Download the Installer
Write-Host "Downloading .NET 6.0.4, please wait..."
Invoke-WebRequest -Uri $dotnetUrl -OutFile $localPath
Write-Host "Done!"

function Install-DotNet6 {
    Start-Process -FilePath $localPath -ArgumentList "/install /quiet /norestart" -Wait
}

# Install the application silently
Write-Host "Installing .NET 6.0.4, please wait..."
Install-DotNet6
Write-Host "Done!"
