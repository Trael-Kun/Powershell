<# PaperStream Capture installer
Written by Bill Wilson (https://github.com/Trael-Kun) 30/08/24
Begin by copying contents of PSC41000.iso to PS Script root, then copy .\PSTWAIN\SOP from  PSIPTWAIN-3_3-_0.iso to Script Root.
#>
param (
    [switch] $Manual            #Allows user to interact with first bit of the install
)
#Prep Dialogue Box
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Functions
function Show-ErrorDialog {
    param (
        [string] $Message,
        [string] $Resolve
    )
    # Form box
    $form =                     New-Object Windows.Forms.Form
    $form.Text =                "PaperStream Install Error"
    $form.Size =                New-Object Drawing.Size(300,200)
    $form.StartPosition =       "CenterScreen"
    # Message Labels
    $labelMsg =                 New-Object Windows.Forms.Label
    $labelMsg.Text =            "Error: $Message"
    $labelMsg.Size =            New-Object Drawing.Size(260,20)
    $labelMsg.Location =        New-Object Drawing.Point(10,40)
    $form.Controls.Add($labelMsg)
    # Recommended action
    $labelAdvice =              New-Object Windows.Forms.Label
    $labelAdvice.Text =         "To resolve: $Resolve"
    $labelAdvice.Size =         New-Object Drawing.Size(260,20)
    $labelAdvice.Location =     New-Object Drawing.Point(10,60)
    $form.Controls.Add($labelAdvice)
    # OK Button
    $buttonOK =                 New-Object Windows.Forms.Button
    $buttonOK.Text =            "OK"
    $buttonOK.Size =            New-Object Drawing.Size(75,23)
    $buttonOK.Location =        New-Object Drawing.Point(195,130)
    $buttonOK.DialogResult =    [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($buttonOK)
    $form.AcceptButton =        $buttonOK
}
function Test-Error {
    param (
        [string] $ErrMsg,
        [string] $Action1,
        [string] $Action2
    )
    if (!($FormBox)) {
        Write-Warning  -Message $ErrMsg
        Write-Error -Message $ErrMsg -Category DeviceError -RecommendedAction $Action1
    } else {
        Show-ErrorDialog -Message $ErrMsg -Resolve $Action2
    }
    Exit 6969
}
function New-Shortcut {
    param (
        [string] $LnkPath,                                              # Folder for new shortcut
        [string] $LnkFile,                                              # Filename for new shortcut, ending in .lnk
        [string] $LnkTarget,                                            # What the shortcut takes you to
        [string] $LnkIcon                                               # Icon for the shortcut, if different to the default
    )
    if ($LnkFile -notmatch '.lnk$') {                                   # check FileName for .lnk filetype
        $LnkFile +='.lnk'                                               # if not, add it
    }
    $Path               = Join-Path -Path $LnkPath -ChildPath $LnkFile  # join path & filename for shortcut
    $WshShell           = New-Object -ComObject WScript.Shell           # create shortcut object
    $Lnk                = $WshShell.CreateShortcut("$Path")             # set .lnk path
    $Lnk.TargetPath     = $LnkTarget                                    # set target
    if ($null -ne $LnkIcon -or $LnkIcon -ne 'NoIcon') {                 # if LnkIcon has a value
        $Lnk.IconLocation   = $LnkIcon                                  # set icon
    }
    $Lnk.Save()                                                         # create shortcut
}

#############################################################################################
# Variables
#############################################################################################
$SND        = 'Scanner Not Detected'
# Paths
$MsiExe     = Join-Path -Path $env:WinDir       -ChildPath 'System32\msiexec.exe'
$FjiCube    = Join-Path -Path $env:WinDir       -ChildPath 'twain_32\Fjicube'
$StMenu     = Join-Path -Path $env:ProgramData  -ChildPath 'Microsoft\Windows\Start Menu\Programs'
$PStreamDir = Join-Path -Path $env:ProgramFiles -ChildPath 'Fujitsu\PaperStream Capture'
$PsLnk      = Join-Path -Path $StMenu           -ChildPath 'PaperStream Capture'
$FiLnk      = Join-Path -Path $StMenu           -ChildPath 'fi series'
$Pstream    = Join-Path -Path $PSScriptRoot     -ChildPath 'PSCapture'
$ChooChoo   = Join-Path -Path $PSScriptRoot     -ChildPath 'PSTwain'    #Get it? Twain Dwiver? Like with a speech impediment? I'm hilarious
$CompFix    = Join-Path -Path $PSScriptRoot     -ChildPath 'CompressionFix'
$DsDir      = Join-Path -Path $PSScriptRoot     -ChildPath 'DS'
$Ass        = Join-Path -Path $PSScriptRoot     -ChildPath 'assets'
$Man        = Join-Path -Path $PSScriptRoot     -ChildPath 'zzManuals'
$Panel      = Join-Path -Path $ChooChoo         -ChildPath 'SOP'
## MSI Arguments
# PStream Arguments
$PstreamArgs = @(
    "`"$Pstream\Data1\setup_en.msi`"",
    "INSTALLDIR=`"$PStreamDir`"",
    "CHANGESHOWSTARTUP=0",
    "INDIRECTMSI=1",
    "/QB!"
)
# Software Operation Panel install arguments
$SopArgs = @(
    "/i",
    "`"$Panel\SOPSetup.msi`"",
    "CHS=1",
    "NO_EXECUTE=0",
    "SUPPORT_ERG=0",
    "ERG_START_UP=0",
    "ERG_START_MENU=0",
    "SOP_START_MENU=0",
    "/QB!"
)

#############################################################################################
# INSTALL START
#############################################################################################
Write-Host 'Starting install' -ForegroundColor Green
## check for scanner connection
if (Get-PnpDevice -FriendlyName "fi-*" -Status OK -ErrorAction SilentlyContinue) {
    ## install applications
    # install Paper Stream Capture
    if ($Manual) {
        Write-Output "Installing Paper Stream Capture"
        Start-Process -FilePath "$Pstream\PSCSetup.exe" -Wait -NoNewWindow
        while (!(Test-Path "$PsLnk\Tools\Importer.lnk")) {
            if ($LastExitCode -eq 0 -or $LastExitCode -eq 1707) {
                break
            } else {
            Write-Output 'Waiting for PaperStream install'
            Start-Sleep -Seconds 1
            }
        }
    } else {
        Write-Output "Installing Paper Stream Capture"
        Start-Process -FilePath "$Pstream\PSCSetup.exe" -ArgumentList $PstreamArgs -Wait -NoNewWindow
    }
    # check where PStream has been installed
    if (!(Test-Path $PStreamDir)) {
        $PStreamDir = (Get-ChildItem -Path "$env:SystemDrive\" -Filter 'PFU.PaperStream.Capture.exe' -Recurse -ErrorAction SilentlyContinue).DirectoryName
    }
    Write-Output "PaperStream installed to $PStreamDir"

    # install the Software Operation Panel for page counting on fi-6770/fi-7700 scanners.
    Write-Output "Installing Software Operation Panel"
    Start-Process -FilePath $MsiExe -ArgumentList $SopArgs -Wait -NoNewWindow

    # .lnk files to delete
    $Lnks = @(
        "$PsLnk\Tools\Exporter.lnk",
        #"$PsLnk\Tools\Importer.lnk",
        "$PsLnk\Administrator Tool.lnk",
        "$PsLnk\Readme.lnk",
        "$PsLnk\Use conditions.lnk",
        "$FiLnk"
    )
    # files to copy
    $Copies = @(
        @{Path="$CompFix\icwReadThreadParam.ini";   Dest=$FjiCube               } # Compression Fix
        @{Path="$DsDir\*.ds";                       Dest=$FjiCube               } # Config
        @{Path="$Ass\*.png";                        Dest="$PStreamDir\assets"   } # Logos
        @{Path="$Man\*.PDF";                        Dest="$PStreamDir\Manuals" }
    )

    ## adjust shortcuts
    Write-Output "Adjusting shortcuts..."
    foreach ($Lnk in $Lnks) {
        Write-Output "Removing $Lnk"
        Remove-Item -Path "$Lnk" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Output 'Creating Software Operation Panel shortcut'
    New-Shortcut -LnkPath $PsLnk -LnkFile 'Software Operation Panel.lnk' -LnkTarget "$FjiCube\SOP\FjLaunch.exe" -LnkIcon NoIcon

    ## final steps
    Write-Output "Copying files..."
    foreach ($Copy in $Copies) {
        Copy-Item -Path $Copy.Path -Destination $Copy.Dest -Recurse -Force -Verbose
    }

    # finish install
    Write-Host "Install complete" -ForegroundColor Green
    $ExCode = 3010 
} elseif (Get-PnpDevice -FriendlyName "fi-*" -Status UNKNOWN -ErrorAction SilentlyContinue) {
    Test-Error -ErrMsg $SND -Action1 PowerOnScanner -Action2 'Power on scanner'
    $ExCode = 6969
} elseif ((Get-PnpDevice -FriendlyName "fi-*" -Status ERROR -ErrorAction SilentlyContinue) -or (Get-PnpDevice -FriendlyName "fi-*" -Status DEGRADED -ErrorAction SilentlyContinue)) {
    Test-Error -ErrMsg $SND -Action1 ReinstallScanner -Action2 'Try scanner on a different USB port'
    $ExCode = 6969
} else {
    ## No Scanner? No install
    Test-Error -ErrMsg 'No Scanner Detected' -Action1 ConnectScanner -Action2 'Connect Scanner to PC'
    $ExCode = 1603
}
exit $ExCode
<#EndScript
$SuccessNoReboot    = exit 1707
$SoftReboot         = exit 3010
$HardReboot         = exit 1641
$FastRetry          = exit 1618
$ExitSND            = exit 6969
$ExitNoScanner      = exit 1603
#>
