<#
    .DESCRIPTION
     Configure Dell BIOS settings using WMI
     Will only affect post-2018 machines
     
    .NOTES
     Author:    Bill Wilson (https://github.com/Trael-Kun)
     Date: 29/04/2025

     References;
        https://dl.dell.com/manuals/common/dell-agentless-client-manageability.pdf
        https://www.powershellgallery.com/packages/DellBIOSProvider/2.9.0
#>

$BiosSettings = @(
   #Disable ALL Audio
    [pscustomobject]@{Attribute='IntegratedAudio'; Value='Disabled'}
    [pscustomobject]@{Attribute='OnboardSoundDevice'; Value='Disabled'}
    [pscustomobject]@{Attribute='Microphone'; Value='Disabled'}
    [pscustomobject]@{Attribute='InternalSpeaker'; Value='Disabled'}
   #Disable Camera
    [pscustomobject]@{Attribute='Camera'; Value='Disabled'}
   #Disable ALL Wireless
    [pscustomobject]@{Attribute='WirelessLan'; Value='Disabled'}
    [pscustomobject]@{Attribute='BluetoothDevice'; Value='Disabled'}
   #Num Lock ON
    [pscustomobject]@{Attribute='NumLock'; Value='Enabled'}
   #Auto-On @ 9am
    [pscustomobject]@{Attribute='AutoOnHr'; Value=9}
   #TpmClear disable
    [pscustomobject]@{Attribute='TpmClear'; Value='Disabled'}
   #Secure boot = Deployed Mode
    [pscustomobject]@{Attribute='SecureBootMode'; Value='DeployedMode'}
)

param(
    [string]$Pwd,    #Password to use for BIOS changes
    [switch]$NewPwd, #Change BIOS password
    [string]$OldPwd  #Previous password used by BIOS
)

function Write-Log { #simple logging
    param (
      [string]$Message
    )
    $Time = Get-Date -Format G
    "$Time - $Message" | Out-File $LogPath -Append
}

function Write-EndScript {
    Write-Log ''
    Write-Log '----------------------'
    Write-Log 'SCRIPT ENDED'
    Write-Log '----------------------'
}

#VARIABLES
$LogDir  = "$env:TEMP\Logs"
$LogFile = "Modify_Dell_BIOS_Settings_$(Get-Date -Format yymmddhhss).log"
$LogPath = Join-Path $LogDir -ChildPath $LogFile

# INITIATE LOG FILE
"" | Out-File $LogPath
Write-Log '----------------------'
Write-Log 'SCRIPT STARTED'
Write-Log '----------------------'
Write-Log 'Applying Dell BIOS Settings'
Write-Log ''

#Test if script will run
if ((Get-WmiObject -Class Win32_BIOS).Manufacturer -notlike "*Dell*") {
    Write-Log 'Computer is not a Dell. Ending script'
    Write-EndScript
    exit 0
} elseif (!(Get-WmiObject -Namespace root/dcim/sysman/wmisecurity -Class PasswordObject)) {
    Write-Log 'WMI Bios management is not applicable.'
    Write-Log 'For futher info please visit https://dl.dell.com/manuals/common/dell-agentless-client-manageability.pdf or install "Dell Command | Monitor"'
    Write-EndScript
    exit 0
}

if ($null -ne $Pwd) {
    #Encode Password
    $Encoder = New-Object System.Text.UTF8Encoding
    $Bytes   = $Encoder.GetBytes($Pwd)
}

if ($NewPwd) {
    #Set new Password
    $SI = Get-WmiObject -Namespace root/dcim/sysman/wmisecurity -Class SecurityInterface
    if ((Get-WmiObject -Namespace root/dcim/sysman/wmisecurity -Class PasswordObject).IsPasswordSet -eq 0) {
        #if no Password currently set
        Write-Log "Setting new BIOS password"
        $SI.SetnewPassword(0,0,0,"Admin",$OldPwd, $Pwd)
    } else {
        #if password currently set
        Write-Log "Resetting BIOS password"
        $OldEncoder = New-Object System.Text.UTF8Encoding
        $OldBytes   = $OldEncoder.GetBytes($OldPwd)
        $SI.SetnewPassword(1,$OldBytes.Length,$OldBytes,"Admin",$OldPwd,$Pwd)
    }
}

#Set Attributes
if ($null -eq $Pwd -or $Pwd -eq '') {
    foreach ($BiosSetting in $BiosSettings) {
        Write-Log "Setting $($BiosSetting.Attribute) to $($BiosSetting.Value)"
        $BAI.SetAttribute(0,0,0,$BiosSetting.Attribute,$BiosSetting.Value)
  } else {
    foreach ($BiosSetting in $BiosSettings) {
        Write-Log "Setting $($BiosSetting.Attribute) to $($BiosSetting.Value)"
        $BAI.SetAttribute(1,$bytes.Length,$bytes,$BiosSetting.Attribute,$BiosSetting.Value)
    }
}

Write-EndScript

##END##
