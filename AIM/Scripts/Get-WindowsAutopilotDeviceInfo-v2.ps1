$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'
Clear-Host
Write-Host "Obtaining Windows Autopilot Device Information, please wait... "

# Define Variables
$hwidOutputFilePath = "C:\MyHWID.csv"
$AirBaseTableUrl = "https://api.airtable.com/v0/appMJfQcesj5KWqdk/IntuneDataTable"
$AirbaseApiToken = "pat03ZOsGvwyWNjQ0.7dcbd6e0c421fdd9cefe7148fbfc189d86eddb494adf9178b4669f406011f5d8"

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
$autopilotInfoAsJson = $autopilotInfoForDevice | ConvertTo-Json -Compress

# Define the Headers
$apiRequestHeaders = @{
    "Authorization" = "Bearer $AirbaseApiToken"
    "Content-Type" = "application/json"
}

# Define the body
$body = @{
    fields = @{
         "Serial Number"= "$deviceSN"
         "Windows Product ID"= "$deviceProductId"
         "Device HWID Hash"="$deviceHwHash"
    }
} | ConvertTo-Json

Write-Host "Adding device autopilot HWID to AirTable spreadsheet, please wait... "
$apiResponse = Invoke-RestMethod -Method Post -Uri $AirBaseTableUrl -ContentType "application/json" -Body $body -Headers $apiRequestHeaders -UseBasicParsing
Write-Host "Done!"

Write-Host "Operation completed succesfully!"
