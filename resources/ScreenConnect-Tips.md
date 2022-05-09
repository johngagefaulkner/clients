# ScreenConnect Tips

**Installing .NET 6 using Command Toolbox:**
```bat
#!ps #timeout=180000 iwr https://raw.githubusercontent.com/johngagefaulkner/clients/main/resources/scripts/Install-DotNet6.ps1 -UseBasicParsing | iex
```

**Install PowerShell 7:**
```bat
#!ps #maxlength=100000 #timeout=180000 msiexec /package "https://github.com/PowerShell/PowerShell/releases/download/v7.2.3/PowerShell-7.2.3-win-x64.msi" /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1
```
