<#
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

Clear-Host
New-LogEntry -Msg "Changing current directory to: C:\Users\$ENV:USERNAME\Downloads\"
cd "C:\Users\$ENV:USERNAME\Downloads\"
New-LogEntry -Msg "Launching the Adobe Creative Cloud installer, please wait..."
.\Creative_Cloud_Set-Up.exe --silent

Stop-Process -Name "Creative Cloud" -Force -ErrorAction SilentlyContinue | out-null
Wait-Process -Name "Creative Cloud"
#>

<#
    - To run this command:
        - $pwsh_arguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -Command $command"
        - Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
#>

# Define Behavior
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

# Define Variables
$DEPLOYMENT_NAME = "Adobe Creative Cloud (Desktop App)"
$DEPLOYMENT_DIR = "C:\ProgramData\AIM\Deployments\"
$DEPLOYMENT_CONFIG_URL = "https://raw.githubusercontent.com/johngagefaulkner/clients/main/AIM/Config/DefaultDirectoryCreation.csv"
$ADOBE_CC_DOWNLOAD_URL = "https://aimcloudshell.blob.core.windows.net/intunefile/Adobe_Creative_Cloud_Desktop_App_en-US_Windows_x64.zip"
$7ZIP_DOWNLOAD_URL = "https://community.chocolatey.org/7za.exe"
$DEPLOYMENT_EXIT_CODE = 0

<#
## Defining the command to be passed through to the PowerShell instance.
$ADOBE_CC_INSTALL_COMMAND = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))";

## Defining the arguments to launch the PowerShell instance with.
$pwsh_arguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -Command $ADOBE_CC_INSTALL_COMMAND"
## Launch the PowerShell instance using the pre-defined arguments and command above.
$process = Start-Process "PowerShell" -ArgumentList $pwsh_arguments -PassThru
#>

# Define Functions

function Request-String {
    <#
    .SYNOPSIS
    Downloads content from a remote server as a string.

    .DESCRIPTION
    Downloads target string content from a URL and outputs the resulting string.
    Any existing proxy that may be in use will be utilised.

    .PARAMETER Url
    URL to download string data from.

    .EXAMPLE
    Request-String https://community.chocolatey.org/install.ps1

    Retrieves the contents of the string data at the targeted URL and outputs
    it to the pipeline.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Url
    )

    $downloader = New-Object System.Net.WebClient
    $downloader.DownloadString($url)
}

function Request-File {
    <#
    .SYNOPSIS
    Downloads a file from a given URL.

    .DESCRIPTION
    Downloads a target file from a URL to the specified local path.
    Any existing proxy that may be in use will be utilised.

    .PARAMETER Name
    Friendly name of the file to be downloaded.

    .PARAMETER File
    Local path for the file to be downloaded to.

    .PARAMETER Url
    URL of the file to download from the remote host.

    .EXAMPLE
    Request-File -Name "7zip" -File "C:\ProgramData\AIM\Tools\7za.exe" -Url "https://community.chocolatey.org/7za.exe"

    Downloads the install.ps1 script to the path specified in $targetFile.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [string]
        $File,

        [Parameter(Mandatory = $true)]
        [string]
        $Url
    )

    if (-not (Test-Path ($File))) {
        New-LogEntry -Msg "Initiating download for $Name, please wait..."
        New-LogEntry -Msg "Downloading $Url to $File"
        $downloader = New-Object System.Net.WebClient
        $downloader.DownloadFile($Url, $File)
    }
    else {
        New-LogEntry -Msg "$Name already exists, skipping download."
    }
}

function Get-7ZippedFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [string]
        $OutputFolder
    )

    $7zipPath = "C:\ProgramData\AIM\Tools\7za.exe"
    $path = $FilePath.Substring(0, $FilePath.lastIndexOf('\'))
    #$command = "7z x '$filePath' -o'$path\$folder'"
    #$command = "7z x '$filePath' -o'$path\$folder'"
    #Invoke-Expression $command
    #Remove-Item -Path $filePath -Confirm:$false -Force | Out-Null

    $params = 'x -o"{0}" -y "{1}"' -f $tempDir, $file

    # use more robust Process as compared to Start-Process -Wait (which doesn't
    # wait for the process to finish in PowerShell v3)
    $process = New-Object System.Diagnostics.Process

    try {
        $process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo -ArgumentList $7zaExe, $params
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

        $null = $process.Start()
        $process.BeginOutputReadLine()
        $process.WaitForExit()

        $exitCode = $process.ExitCode
    }
    finally {
        $process.Dispose()
    }

    $errorMessage = "Unable to unzip package using 7zip. Perhaps try setting `$env:chocolateyUseWindowsCompression = 'true' and call install again. Error:"
    if ($exitCode -ne 0) {
        $errorDetails = switch ($exitCode) {
            1 { "Some files could not be extracted" }
            2 { "7-Zip encountered a fatal error while extracting the files" }
            7 { "7-Zip command line error" }
            8 { "7-Zip out of memory" }
            255 { "Extraction cancelled by the user" }
            default { "7-Zip signalled an unknown error (code $exitCode)" }
        }

        throw ($errorMessage, $errorDetails -join [Environment]::NewLine)
    }
}

function New-DirectoryFolder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $NewDirectoryPath
    )

    if (Test-Path -Path $NewDirectoryPath) {
        New-LogEntry -Msg "[$NewDirectoryPath] Already exists!"
    }
    else {
        $null = New-Item -ItemType Directory -Path $NewDirectoryPath -Force
        New-LogEntry -Msg "[$NewDirectoryPath] Created successfully!"
    }
}

function New-LogEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Msg,
        [Parameter(Mandatory = $false)]
        [string]
        $Severity
    )

    if (-not ($Severity)) {
        $Severity = "INFO"
    }

    $logDate = Get-Date -Format "MMM dd yyyy"
    $logTime = Get-Date -Format "hh:mm:ss"
    $FULL_LOG_MESSAGE = "[$logDate] [$logTime] [$Severity] $Msg"
    Write-Host $FULL_LOG_MESSAGE
}

# Init
Clear-Host
New-LogEntry -Msg "[AIM Application Deployment]"
New-LogEntry -Msg "Initializing..."
New-LogEntry -Msg "Downloading deployment configuration file, please wait... "
$myUriData = (Invoke-WebRequest -Uri "$DEPLOYMENT_CONFIG_URL").Content
$myCsvData = ConvertFrom-Csv -InputObject $myUriData
New-LogEntry -Msg "Done!"
Write-Host
New-LogEntry -Msg "[Prerequisite Check]"
New-LogEntry -Msg "Checking required directories, please wait... "

ForEach ($tmpDir in $myCsvData.Directories) {
    if (Test-Path -Path $tmpDir) {
        New-LogEntry -Msg "[$tmpDir] Already exists!" -Severity "WARN"
    }
    else {
        New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
        New-LogEntry -Msg "[$tmpDir] Created successfully!"
    }
}

New-LogEntry -Msg "Creating deployment directory, please wait..."
if (Test-Path -Path $tmpDir) {
    New-LogEntry -Msg "[$tmpDir] Already exists!" -Severity "WARN"
}
else {
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
    New-LogEntry -Msg "[$tmpDir] Created successfully!"
}

New-LogEntry -Msg "Done!"
New-LogEntry -Msg "Starting transcript, please wait..."
Start-Transcript -OutputDirectory "C:\ProgramData\AIM\Logs" -Force -IncludeInvocationHeader
Write-Host
New-LogEntry -Msg "[AIM Application Deployment]"
New-LogEntry -Msg "Application Name: $DEPLOYMENT_NAME"
New-LogEntry -Msg "Package Name: Creative Cloud Desktop Application"
New-LogEntry -Msg "Package Type: Managed Package"
New-LogEntry -Msg "Platform: WIN64"
New-LogEntry -Msg "Locale: en_US"
New-LogEntry -Msg "Use OS Locale: Enabled"
Write-Host

New-LogEntry -Msg "Downloading 7-Zip to handle extracting the archive, please wait..."
Request-File -Name "7zip" -File "C:\ProgramData\AIM\Tools\7za.exe" -Url $7ZIP_DOWNLOAD_URL
New-LogEntry -Msg "Done!" -Severity "SUCCESS"
New-LogEntry -Msg "Downloading the application installer, please wait..."
Request-File -Name "Adobe Creative Cloud (Desktop App) Installer" -File "$DEPLOYMENT_DIR\Adobe_Creative_Cloud_Desktop_App_en-US_Windows_x64.zip" -Url $ADOBE_CC_DOWNLOAD_URL
New-LogEntry -Msg "Done!" -Severity "SUCCESS"

#Microsoft.PowerShell.Archive\Expand-Archive -Path "$DEPLOYMENT_DIR\Adobe_Creative_Cloud_Desktop_App_en-US_Windows_x64.zip" -DestinationPath $tempDir -Force

New-LogEntry -Msg "Creating output directory to extract contents of Adobe Creative Cloud installer."
$NewDirPath = "C:\ProgramData\AIM\Installers\AdobeCreativeCloud_DesktopApp"
New-DirectoryFolder -NewDirectoryPath $NewDirPath
New-LogEntry -Msg "Extracting (unzipping) file, please wait... "
Expand-Archive -Path "$DEPLOYMENT_DIR\Adobe_Creative_Cloud_Desktop_App_en-US_Windows_x64.zip" -DestinationPath $NewDirPath -Force
New-LogEntry -Msg "File successfully extracted (unzipped)!" -Severity "SUCCESS"

# use more robust Process as compared to Start-Process -Wait (which doesn't wait for the process to finish in PowerShell v3)
# "C:\ProgramData\AIM\Installers\AdobeCreativeCloud_DesktopApp\Creative Cloud Desktop Application\Build\setup.exe"

New-LogEntry -Msg "Creating directory to hold the Adobe Creative Cloud installation, please wait..."

$AdobeSetupExe = 'C:\ProgramData\AIM\Installers\AdobeCreativeCloud_DesktopApp\Creative Cloud Desktop Application\Build\setup.exe'
#$AdobeSetupParams = '--silent --ADOBEINSTALLDIR="$NewDirPath" --INSTALLLANGUAGE=en-US'
$AdobeSetupParams = 'setup.exe --silent --INSTALLLANGUAGE=en-US'

New-LogEntry -Msg "Launching installer with required arguments, please wait... "
$process = New-Object System.Diagnostics.Process

try {
    $process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo -ArgumentList $AdobeSetupExe, $AdobeSetupParams
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

    $null = $process.Start()
    $process.BeginOutputReadLine()
    $process.WaitForExit()

    $DEPLOYMENT_EXIT_CODE = $process.ExitCode
}
finally {
    $process.Dispose()
}

# Disposes any remaining resources and exits with a "Success" exit code (0).
New-LogEntry -Msg "Stopping transcript and exiting with exit code: $DEPLOYMENT_EXIT_CODE"
Stop-Transcript
Exit $DEPLOYMENT_EXIT_CODE
