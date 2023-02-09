<#
    - [Name] Install-AdobeCreativeCloud.ps1
    - [Description] Downloads and installs the Adobe Creative Cloud (Desktop App) for Enterprise users.
    - [Author] Gage Faulkner (johngagefaulkner@gmail.com)
    - [Date] February 9th, 2023
    - [Version] 1.0209.01
    - [Resources and References]
        - Microsoft Docs:
            - Win32 App Management in Intune: https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management
        - Chocolatey Install Docs:
            - https://chocolatey.org/install#individual
            - https://community.chocolatey.org/courses/installation/installing?method=install-using-powershell-from-cmdexe
        - Adobe Enterprise Administration and Deployment Docs:
            - https://helpx.adobe.com/enterprise/kb/querying-client-machines-to-check-if-a-package-is-deployed.html
            - https://helpx.adobe.com/enterprise/using/deploy-packages.html
#>
Clear-Host

# Define Behavior
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

# Define Variables
$DEPLOYMENT_NAME = "Adobe Creative Cloud (Desktop App)"
$DEPLOYMENT_DIR = "C:\ProgramData\AIM\Deployments\"
$DEPLOYMENT_LOGS_DIR = "C:\ProgramData\AIM\Logs"
$DEPLOYMENT_INSTALL_DIR = "C:\ProgramData\AIM\Installers\AdobeCreativeCloud_DesktopApp"
$DEPLOYMENT_CONFIG_URL = "https://raw.githubusercontent.com/johngagefaulkner/clients/main/AIM/Config/DefaultDirectoryCreation.csv"
$ADOBE_CC_DOWNLOAD_URL = "https://aimcloudshell.blob.core.windows.net/intunefile/Adobe_Creative_Cloud_Desktop_App_en-US_Windows_x64.zip"
$AdobeSetupExe = 'C:\ProgramData\AIM\Installers\AdobeCreativeCloud_DesktopApp\Creative Cloud Desktop Application\Build\setup.exe'
$AdobeSetupParams = 'setup.exe --silent --INSTALLLANGUAGE=en-US'
$DEPLOYMENT_EXIT_CODE = 0

# Define Functions

# Retrieves the contents of the string data at the targeted URL and outputs it to the pipeline.
function Request-String {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Url
    )

    $downloader = New-Object System.Net.WebClient
    $downloader.DownloadString($url)
}

# Downloads a file from a given URL to the specified local file path.
function Request-File {
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
        New-LogEntry -Msg "Downloading $Url to $File"
        $downloader = New-Object System.Net.WebClient
        $downloader.DownloadFile($Url, $File)
    }
    else {
        New-LogEntry -Msg "$Name already exists, skipping download."
    }
}

# Accepts the full path to a folder/directory, ensures it doesn't already exists, then creates it.
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

# Generates the current date and time, accepts an optional defined severity (info, warning, etc.), then combines it all into a single string to add to the transcript enabling easier parsing later.
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

# Initialize script, obtain deployment configuration file(s)
Clear-Host
New-LogEntry -Msg "[AIM Application Deployment]"
New-LogEntry -Msg "[Application Name]: $DEPLOYMENT_NAME"
New-LogEntry -Msg "[Package Info]: Creative Cloud Desktop Application, Managed Package, WIN64, en_US"
New-LogEntry -Msg "Initializing..."
New-LogEntry -Msg "Downloading deployment configuration file, please wait... "
$myUriData = (Invoke-WebRequest -Uri "$DEPLOYMENT_CONFIG_URL").Content
$myCsvData = ConvertFrom-Csv -InputObject $myUriData
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

Start-Transcript -OutputDirectory "$DEPLOYMENT_LOGS_DIR" -Force -IncludeInvocationHeader

# Download the file(s) required for installation/deployment
New-LogEntry -Msg "Downloading the application installer, please wait..."
Request-File -Name "Adobe Creative Cloud (Desktop App) Installer" -File "$DEPLOYMENT_DIR\Adobe_Creative_Cloud_Desktop_App_en-US_Windows_x64.zip" -Url $ADOBE_CC_DOWNLOAD_URL

New-LogEntry -Msg "Creating output directory to extract contents of Adobe Creative Cloud installer."
New-DirectoryFolder -NewDirectoryPath $DEPLOYMENT_INSTALL_DIR

New-LogEntry -Msg "Extracting (unzipping) file, please wait... "
Expand-Archive -Path "$DEPLOYMENT_DIR\Adobe_Creative_Cloud_Desktop_App_en-US_Windows_x64.zip" -DestinationPath $DEPLOYMENT_INSTALL_DIR -Force
New-LogEntry -Msg "Successfully extracted files from archive ($DEPLOYMENT_DIR\Adobe_Creative_Cloud_Desktop_App_en-US_Windows_x64.zip) to the deployment folder ($DEPLOYMENT_INSTALL_DIR)!"
New-LogEntry -Msg "Launching installer with required arguments, please wait... "

# Launch the 'setup.exe' process with the parameters supplied from Adobe's help docs.
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

# Disposes any remaining resources and passes through the Exit Code returned from the Adobe 'setup.exe' process!
New-LogEntry -Msg "Stopping transcript and exiting with exit code: $DEPLOYMENT_EXIT_CODE"
Stop-Transcript
Exit $DEPLOYMENT_EXIT_CODE
