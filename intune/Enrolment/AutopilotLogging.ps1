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
            $DateTime = [DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss UTC')
            Write-Output $Message
            Add-Content -Path $LogFile -Value "$DateTime	|	$Message"  -Force
        }
    } else {
        Write-Host "Log File Not Set" -ForegroundColor Red
        Write-Output $Message
    }
}

$Domain         = 'ReallyRealCompany.com'

##Gather Info
#Task sequence variables
$tsenv  = New-Object -COMObject Microsoft.SMS.TSEnvironment
$GroupTag       = $tsenv.Value('GroupTag')
$LogFile        = $tsenv.Value('LogFile')
$PcName         = $tsenv.Value('_SMSTSMachineName')
$Serial         = $tsenv.Value('Serial')
$Manufacturer   = $tsenv.Value('Manufacturer')
$Model          = $tsenv.Value('Model')
$BiosVer        = $tsenv.Value('BiosVer')

#Drives
$Drive = Get-WmiObject -Class Win32_LogicalDisk -ComputerName LOCALHOST | Where-Object {$_. DeviceID -eq 'C:'} | Select-Object DeviceID, {[int]($_.Size /1GB)}, {[int]($_.FreeSpace /1GB)}

#Time Variables
$LocalTime =    Get-Date -Format "yyyy-MM-dd HH:mm:ss LOCAL"
$UtcTime =      [DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss UTC')
$UtcOffset =    Get-Date -Format "%K"

#Users
$UserList = @()
$Users = (Get-ChildItem $env:SystemDrive\Users).name
foreach ($User in $Users) {
    $ThisUser = [adsisearcher]"(samaccountname=$User)"
    $PrincipalName = ($ThisUser.FindOne().Properties.UserPrincipalName)
    if ($PrincipalName -like "*@$Domain") {
        $UserList += $PrincipalName
        #$ThisUser.FindOne().Properties.mail
    } else {
        Write-Host "$PrincipalName cannot be a primary account"
    }
}

#Does Grouptag exist?
if ($null -eq $GroupTag -or $GroupTag -eq "") {
    $TagTest    = $false
} else {
    $TagTest    = $true
}

# Write to log
Write-Log -NoDate "AutoPilot Hardware Hash Task Sequence"
Write-Log -NoDate "Local Time:		$LocalTime"
Write-Log -NoDate "UTC Time:		$UtcTime"
Write-Log -NoDate "Offset:			$UtcOffset"
Write-Log -NoDate ""
Write-Log -NoDate "##Device Details"
Write-Log -NoDate "Device Name:		$PcName"
Write-Log -NoDate "Serial No:		$Serial"
Write-Log -NoDate "Make:			$Manufacturer"
Write-Log -NoDate "Model:			$Model"
Write-Log -NoDate "BIOS Version:	$BiosVer"
if ($TagTest) {
    Write-Log -NoDate "Group Tag:		$GroupTag"
} else {
    Write-Log -NoDate "Group Tag:		N/A"
}
Write-Log -NoDate ""
Write-Log -NoDate "##Drive Info"
Write-Log -NoDate "Drive Size:		$($Drive.'[int]($_.Size /1GB)')GB"
Write-Log -NoDate "Free Space:		$($Drive.'[int]($_.FreeSpace /1GB)')GB"
Write-Log -NoDate ""
Write-Log -NoDate "##User List"
foreach ($Principal in $UserList) {
    Write-Log -NoDate "User:			$Principal"
}
