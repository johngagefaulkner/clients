$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
Clear-Host
Write-Host "Initializing App Deployment Script, please wait..."
Write-Host "[App] MinuteTraq"
Write-Host "[Version] v8.10.88"
Write-Host "[Date] $(Get-Date -Format g)"
Write-Host "[Device Name] $env:COMPUTERNAME"
Write-Host "[User] $(whoami)"
Write-Host "[Directory] $PSScriptRoot"
Write-Host "[WorkingDirectory] $pwd"
Write-Host "[PID] $PID"


# Define Functions
Function New-LogEntry([string]$LogMessage) {

    # Display log message to console (for debugging purposes)
    Write-Host $LogMessage

    # Define the URL and Headers
    $url = "https://logs.collector.solarwinds.com/v1/log"
    $headers = @{
        "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":x3mwoHmpLLfTI9rwWmY7FjvRAShs"))
        "Content-Type"  = "application/json"
    }

    # Define the Body
    $body = @{
        hostname  = "$env:COMPUTERNAME"
        message   = "$LogMessage"
        username  = "$(whoami)"
        timestamp = "$(Get-Date -Format g)"
    } | ConvertTo-Json

    # Make the Request
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body

    # Optionally, display the response
    $response
}



# Init
New-LogEntry -LogMessage "Executing MinuteTraq v8.10.88 Installation, please wait..."

$msiUrl = "https://aimcloudshell.blob.core.windows.net/intunefile/packages/Granicus/IQM2/MinuteTraq/8.10.88/MinuteTraqInstaller.msi"
$logPath = "$env:WINDIR\Temp\MinuteTraq-Install.log"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiUrl`" /L*v `"$logPath`" /qn" -Wait -NoNewWindow

New-LogEntry -LogMessage "Application Installation Complete!"
