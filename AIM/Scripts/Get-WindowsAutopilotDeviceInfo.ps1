$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
Clear-Host
Write-Host "Obtaining Windows Autopilot Device Information, please wait... "

# Define Variables
$hwidOutputFilePath = "C:\Deploy\MyHWID.csv"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Install-Script -Name Get-WindowsAutopilotInfo -Force
Get-WindowsAutopilotInfo -OutputFile $hwidOutputFilePath

Write-Host "Parsing Autopilot Enrollment data from output, please wait... "

$rawData = Get-Content -Path $hwidOutputFilePath -Raw
$csvData = $rawData | ConvertFrom-Csv -Delimiter ','

$deviceSN = $csvData.'Device Serial Number'.Trim()
$deviceProductId = $csvData.'Windows Product ID'.Trim()
$deviceHwHash = $csvData.'Hardware Hash'.Trim()
$autopilotInfoForDevice = "$deviceSN,$deviceProductId,$deviceHwHash"

Write-Host
Write-Host "[ Autopilot Enrollment Information for Device ]" -ForegroundColor Magenta
Write-Host $autopilotInfoForDevice