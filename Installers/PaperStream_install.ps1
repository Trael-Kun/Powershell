<#
.SYNOPSIS
PStream Install

.DESCRIPTION
Installs Paper Stream & other dependencies:
    - TWAIN Drivers
    - Software Operation Panel
    - Compression fix
    - .ds files for scanner model ID
    - Removes "unnecessary" shortcuts
Includes tests to only run if fi-scanner is online (PStream will
not add scanners that are not attached during install)

.PARAMETER NoScanner
Installs PStream without dependencies to make fi-scanners operate correctly

.PARAMETER ScannerBypass
Bypasses scanner test to install Pstream & all dependencies (for testing only)

.EXAMPLE
PS> .\install.ps1

.EXAMPLE
PS> .\install.ps1 -NoScanner

.EXAMPLE
PS> .\install.ps1 -ScannerBypass

.NOTES
Author: Bill Wilson
Created: 17/04/2024
#>

param (
    [switch]$NoScanner,
    [switch]$ScannerBypass
)

##Variables
#Paths
$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$MsiExe= "$env:WinDir\System32\msiexec.exe"
$Pstream = "$ScriptPath\PSCapture"
$ChooChoo = "$ScriptPath\TwainDwiver" #Get it? Twain Dwiver? Like with a speech impediment? I'm hilarious
$SoPanel= "$ScriptPath\SOPSetup"
$PSDir = "$Env:ProgramFiles\Fujitsu\PaperStream Capture"
$FjiCube = "$env:WinDir\twain_32\Fjicube"
$DsDir = "$ScriptPath\DS"
$CompFix = "$ScriptPath\CompressionFix"
$StMenu = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$PsLnk = "$StMenu\PaperStream Capture"
$FiLnk = "$StMenu\fi series"
$Log = "$env:WinDir\Logs\PStream.log"

#MSI Arguments
$PstreamArgs = @(
    "`"$Pstream\Data1\setup_en.msi`"",
    "INSTALLDIR=`"$PSDir`"",
    "/NoRestart",
    "/QN",
    "/l*v $Log"
)
$TWAINArgs = @(
    "/i",
    "`"$ChooChoo\PSIP_TWAIN.msi`"",
    "/NoRestart",
    "/QN",
    "/l*v $Log"
)
$SopArgs = @(
    "/i",
    "`"$SoPanel\SOPSetup.msi`"",
    "CHS=1",
    "NO_EXECUTE=0",
    "SUPPORT_ERG=0",
    "ERG_START_UP=0",
    "ERG_START_MENU=0",
    "SOP_START_MENU=0",
    "/NoRestart",
    "/QN",
    "/l*v $Log"
)

function Install-PaperStream {
    Write-Host "Installing PaperStream Capture"
    Start-Process -FilePath "$Pstream\PSCSetup.exe" -ArgumentList $PstreamArgs -Wait -NoNewWindow
}

function Install-ChooChoo {
    Write-Host "Installing TWAIN drivers"
    Start-Process -FilePath $MsiExe -ArgumentList $TWAINArgs -Wait -NoNewWindow
}
function Install-SOP {
    Write-Host 'Installing Software Operation Panel'
    Start-Process -FilePath $MsiExe -ArgumentList $SopArgs -Wait -NoNewWindow
}
function Remove-Shortcuts {
    Write-Host 'Adjusting shortcuts...'
    # Adjust PStream Shortcuts
    Remove-Item -Path "$PsLnk\Tools\Exporter.lnk" -Recurse -Force
    #Remove-Item -Path "$PsLnk\Tools\Importer.lnk" -Recurse -Force
    Remove-Item -Path "$PsLnk\Administrator Tool.lnk" -Recurse -Force
    Remove-Item -Path "$PsLnk\Readme.lnk" -Recurse -Force
    Remove-Item -Path "$PsLnk\Use conditions.lnk" -Recurse -Force
    Remove-Item -Path "$FiLnk" -Recurse -Force
}
function Install-CompressionFix {
    Write-Host 'Installing compression fix'
    Copy-Item -Path "$CompFix\icwReadThreadParam.ini" -Destination $FjiCube -Recurse -Force
}
function Copy-Fixes {
    Write-Host 'Installing Software Operation Panel shortcut'
    Copy-Item -Path "$SoPanel\Software Operation Panel.lnk" -Destination "$PsLnk\Software Operation Panel.lnk" -Force
    Write-Host 'Installing .ds files'
    Copy-Item -Path "$DsDir\*.ds" -Destination $FjiCube -Recurse -Force
}

## Check for scanner connection

if ($ScannerBypass) {
    Install-PaperStream
    Install-ChooChoo
    Install-SOP
    Remove-Shortcuts
    Write-Host "Completing Install..."
    Install-CompressionFix
    Copy-Fixes
    Write-Host "Install Complete" -ForegroundColor Green
}
elseif ($NoScanner) {
    Install-PaperStream
    Write-Host "Completing Install..."
    Install-CompressionFix
    Remove-Shortcuts
    Write-Host "Install Complete" -ForegroundColor Green
}
else {
        if (Get-PnpDevice -FriendlyName "fi-*" -Status OK) {
        # Install PStream
        Install-PaperStream        
        # Install TWAIN and Windows drivers.
        Install-ChooChoo
        # Install the Software Operation Panel for page counting on fi-6770/fi-7700 scanners.
        Install-SOP
        # Adjust Shortcuts
        Remove-Shortcuts
        Write-Host "Completing Install..."
        # Compression Fix, SOP Shortcut, Device IDs (.ds)
        Copy-Fixes
        # Finish Install
        Write-Host "Install Complete" -ForegroundColor Green
    }
    elseif (Get-PnpDevice -FriendlyName "fi-*" -Status UNKNOWN) {
        Write-Warning  -Message "Scanner Not Detected."
        Write-Error -Message "Scanner Not Detected" -Category DeviceError -RecommendedAction "PowerOnScanner"
        Exit 6969
    }
    elseif (Get-PnpDevice -FriendlyName "fi-*" -Status ERROR) {
        Write-Warning  -Message "Scanner Not Detected."
        Write-Error -Message "Scanner Not Detected" -Category DeviceError -RecommendedAction "ReinstallScanner"
        Exit 6969
    }
    elseif (Get-PnpDevice -FriendlyName "fi-*" -Status DEGRADED) {
        Write-Warning  -Message "Scanner Not Detected."
        Write-Error -Message "Scanner Not Detected" -Category DeviceError -RecommendedAction "ReinstallScanner"
        Exit 6969
    }
    else {
        ## No Scanner? No install
        Write-Warning  -Message "No Scanner Detected."
        Write-Error -Message "No Scanner Detected" -Category DeviceError -RecommendedAction "ConnectScanner"
        Exit 6969
    }
}
#EndScript
