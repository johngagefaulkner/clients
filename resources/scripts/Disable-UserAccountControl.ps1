<#
  - [Name] Disable-UserAccountControl.ps1
  - [Description] Disables User Account Control by setting a value of '0' for the following Registry Key: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA
#>
Clear-Host
Write-Host "[ Disable-UserAccountControl ]"
Write-Host

# Define Variables
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# Init
Write-Host "Disabling User Account Control (UAC), please wait..."
Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "/k %windir%\System32\reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f"
Write-Host "Done!"
