Start-Transcript -Path "C:\Users\Public\transcript0.txt" -Append -Force

# Test
Write-Host "LOGGED USING WRITE-HOST"
Write-Output "LOGGED USING WRITE-OUTPUT"

# Define Behavior(s)
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

# Define Variables
$AIM_DIR = "C:\AIM"

if (!(Test-Path $AIM_DIR)) {
    Write-Host "[$AIM_DIR] Directory not found!"
    Write-Output "[$AIM_DIR] Directory not found!"
    New-Item -Path $AIM_DIR -ItemType Directory -Force
    Write-Host "[$AIM_DIR] Created successfully!"
    Write-Output "[$AIM_DIR] Created successfully!"
} else {
    Write-Host "[$AIM_DIR] Directory found!"
    Write-Output "[$AIM_DIR] Directory found!"
}

# Define URL and file path
$url = "https://fpdownload.macromedia.com/get/flashplayer/current/support/uninstall_flash_player.exe"
$filepath = "C:\AIM\uninstall_flash_player.exe"

# Download the file
Invoke-WebRequest -Uri $url -OutFile $filepath -UseBasicParsing

# Unblock the downloaded file
Unblock-File -Path $filepath -Force

# Change location to C:\Users\Public
Set-Location -Path $AIM_DIR

# Launch the downloaded file with the argument "-uninstall" and wait for the process to exit
$process = Start-Process -FilePath $filepath -ArgumentList "-uninstall" -NoNewWindow -Wait -PassThru

# Create a JSON object
$jsonObject = @{
    Hostname  = $env:COMPUTERNAME
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Status    = if ($process.ExitCode -eq 0) { "Success ($($process.ExitCode))" } else { "Error ($($process.ExitCode))" }
    Message   = "Completed job Adobe Flash Player Uninstall (Silent) on $env:COMPUTERNAME."
    JobId     = "AdobeFlashPlayer_Uninstall_01"
} | ConvertTo-Json

# Write the JSON object to the output
Write-Host $jsonObject
$jsonObject | Out-File -FilePath "C:\AIM\AdobeFlashPlayer_Uninstall_Results.json"

# Exit the script with the exit code from the process
exit $process.ExitCode
