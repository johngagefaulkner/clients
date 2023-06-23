# Define Behavior
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

# Define URL and file path
$url = "https://fpdownload.macromedia.com/get/flashplayer/current/support/uninstall_flash_player.exe"
$filepath = "C:\Users\Public\uninstall_flash_player.exe"

# Download the file
Invoke-WebRequest -Uri $url -OutFile $filepath

# Unblock the downloaded file
Unblock-File -Path $filepath

# Change location to C:\Users\Public
Set-Location -Path "C:\Users\Public"

# Launch the downloaded file with the argument "-uninstall" and wait for the process to exit
$process = Start-Process -FilePath $filepath -ArgumentList "-uninstall" -NoNewWindow -Wait -PassThru

# Create a JSON object
$jsonObject = @{
    Hostname  = $env:COMPUTERNAME
    Timestamp = Get-Date -Format "yyyy-MM-dd_HH:mm:ss"
    Status    = if ($process.ExitCode -eq 0) { "Success ($($process.ExitCode))" } else { "Error ($($process.ExitCode))" }
    Message   = "placeholder"
    JobId     = "AdobeFlashPlayer_Uninstall_01"
} | ConvertTo-Json

# Write the JSON object to the output
Write-Output $jsonObject
Write-Host $jsonObject

# Exit the script with the exit code from the process
exit $process.ExitCode
