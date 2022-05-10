# ScreenConnect Tips

Downloads and installs the Windows Desktop Runtime v6.0.4 (x64)

**Install the Windows Desktop .NET 6.0.4 Runtime (x64)**
```bat
#!ps
#maxlength=100000
#timeout=180000
powershell -ExecutionPolicy Bypass -NoProfile -Command "iex(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/johngagefaulkner/clients/main/resources/scripts/Install-DotNet6.ps1')"
```

**Install PowerShell 7:**
```bat
#maxlength=100000 #timeout=180000 msiexec /package "https://github.com/PowerShell/PowerShell/releases/download/v7.2.3/PowerShell-7.2.3-win-x64.msi" /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1
```
