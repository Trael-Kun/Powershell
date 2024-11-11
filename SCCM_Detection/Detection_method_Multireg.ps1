<#
.SYNOPSIS
    Checks multiple reg keys
.DESCRIPTION
    Tests multiple reg keys and returns based on true/false values.
    
    To detect a product, remove the "!" from in front of it in the 
    final if/else, otherwise the script will be trying to detect the 
    absence of the key.

    Similarly, add a "!" do return a true value on an absence.
.NOTES
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   18/08/2023
#>

# define app detection keys
$UninstallRegx86    = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
$UninstallRegx64    = $UninstallRegx86.Replace('\Wow6432Node','')
$MsKey              = $UninstallRegx64.Replace('\Windows\CurrentVersion\Uninstall','')
$OfficeKey1         = Test-Path -path "$UninstallRegx64\ProPlus2021Volume - en-us"
$officeKey2         = Test-path -path "$MsKey\Office\ClickToRun\Configuration"
$projectKey         = Test-path -path "$UninstallRegx64\ProjectPro2021Volume - en-us"
$visioKey           = Test-path -path "$UninstallRegx64\VisioPro2021Volume - en-us"
$LyncKey            = Test-path -path "$MsKey\Office\16.0\Lync\InstallRoot"

# Check architecture version
$Platform           = Get-ItemPropertyValue -path "$MsKey\Office\ClickToRun\Configuration\" -name Platform

# Check correct architecture
$Arch               = if ($Platform -eq "x64") {$True}

#Check office reg keys exist and Lync/Project/Visio does not
if ($officeKey1 -and $officekey2 -and $Arch -and !($projectKey) -and !($visioKey) -and !($LyncKey)) {
    "Installed"
} else {
    ""
}
