<#
.SYNOPSIS
    Logs details of devices for Autopilot enrolments.

.DESCRIPTION
    Logs device details, designed to aid Autopilot enrolment as part of an SCCM task sequence.
    Logs the following;
        - Time Script was run (Local, UTC & notes time difference)
        - Device Name
        - Device Serial Number
        - Device Manufacturer
        - Device Model
        - BIOS Version
        - Intune Group Tag
        - Total C: Drive Size
        - Free C: Drive Space
        - User accounts present on device

.NOTES
    Author: Bill Wilson
    Date:   25/10/2024
#>
param (
    [switch]$Wmi #gathers device info from wmi instead of TS variables
)
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Message,
        [Parameter(Mandatory=$false)]
        [switch]$NoDate
    )
    if ($LogFile) {
        if ($NoDate) {
            Write-Output $Message
            Add-Content -Path $LogFile -Value "$Message" -Force
        
        } else {
            $DateTime   = [DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss UTC')
            Write-Output $Message
            Add-Content -Path $LogFile -Value "$DateTime	|	$Message"  -Force
        }
    } else {
        Write-Host "Log File Not Set" -ForegroundColor Red
        Write-Output $Message
    }
}
function Test-Variable {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VarVal,
        [string]$VarName
    )
    if ($VarVal) {
        Write-Log -NoDate "$VarName`:	$VarVal"
    } else {
        Write-Log -NoDate "$VarName`:	NOT FOUND"
    }
}

$Domain       = 'company.com'

#Task sequence variables
$tsenv  = New-Object -COMObject Microsoft.SMS.TSEnvironment
$LogFile      = $tsenv.Value('LogFile')

# Write to log
Write-Log 'START'
Write-Log -NoDate ''
Write-Log -NoDate 'AutoPilot Hardware Hash Task Sequence'
#Time Variables
$LocalTime    = Get-Date -Format "yyyy-MM-dd HH:mm:ss LOCAL"
Write-Log -NoDate "Local Time:	$LocalTime"
$UtcTime      = [DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss UTC')
Write-Log -NoDate "UTC Time:	$UtcTime"
$UtcOffset    = Get-Date -Format "%K"
Write-Log -NoDate "Offset:	$UtcOffset"
Write-Log -NoDate ''

#Device Info
Write-Log -NoDate '##Device Details'
if ($Wmi) {
    $Bios         = Get-CimInstance -Class Win32_Bios
    $Sys          = Get-CimInstance -Class Win32_ComputerSystem
    $PcName       = $Sys.Name
    $Serial       = $Bios.SerialNumber
    $Manufacturer = $Sys.Manufacturer
    $BiosVer      = $Bios.SMBIOSBIOSVersion
    $Model        = $Sys.Model
    $GroupTag     = $tsenv.Value('GroupTag')
} else {
    $PcName       = $tsenv.Value('_SMSTSMachineName')
    $Serial       = $tsenv.Value('Serial')
    $Manufacturer = $tsenv.Value('Manufacturer')
    $Model        = $tsenv.Value('Model')
    $BiosVer      = $tsenv.Value('BiosVer')
    $GroupTag     = $tsenv.Value('GroupTag')
}
Test-Variable -VarVal $PcName       -VarName 'Device Name'
Test-Variable -VarVal $Serial       -VarName 'Serial No'
Test-Variable -VarVal $Manufacturer -VarName 'Make'
Test-Variable -VarVal $Model        -VarName 'Model'
Test-Variable -VarVal $BiosVer      -VarName 'BIOS Version'
Test-Variable -VarVal $GroupTag     -VarName 'Group Tag'
Write-Log -NoDate ''

#Drives
Write-Log -NoDate '##Drive C: Info'
$Drive        = Get-CimInstance -Class Win32_LogicalDisk -ComputerName LOCALHOST | Where-Object {$_. DeviceID -eq 'C:'} | Select-Object {[int]($_.Size /1GB)}, {[int]($_.FreeSpace /1GB)}
Test-Variable -VarVal "$($Drive.'[int]($_.Size /1GB)')GB"       -VarName 'Drive Size'
Test-Variable -VarVal "$($Drive.'[int]($_.FreeSpace /1GB)')GB"  -VarName 'Free Space'
Write-Log -NoDate ''

#Users
$UserList     = @()
$Users        = (Get-ChildItem $env:SystemDrive\Users).Name
foreach ($User in $Users) {
    $ThisUser       = [adsisearcher]"(samaccountname=$User)"
    $PrincipalName  = ($ThisUser.FindOne().Properties.UserPrincipalName)
    if ($PrincipalName -like "*@$Domain") {
        $UserList   += $PrincipalName
        Write-Host "$PrincipalName added" -ForegroundColor Green
    } else {
        Write-Host "$PrincipalName cannot be a primary account" -ForegroundColor Red -BackgroundColor Black
    }
}
Write-Log     -NoDate '##User List'
foreach ($Principal in $UserList) {
    Test-Variable -VarVal $Principal    -VarName 'User'
}
Write-Log -NoDate ''

Write-Log 'END'
