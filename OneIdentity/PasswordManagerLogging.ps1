<# 
 SSPR Logging Activate
 Written by Bill
 10/12/25
 References;
 https://support.oneidentity.com/password-manager/kb/4302632/how-to-enable-logging-in-password-manager
#>
$Reboot    = $false
$LogKey    = 'HKLM:\SOFTWARE\One Identity\Password Manager\Logging'
$LogString = 'LogLevel'
$LogValOn  = 'All'
$LogValOff = 'Off'
$Prop      = 'String'
$LogFolder = 'LogFolder'
$LogPath   = "$env:SystemDrive\Temp\Logs"

Function New-RegKey {
    <#
    .NOTES
        Author: Bill Wilson
        Date:   30/09/2025
    #>
    param (
        [Parameter(HelpMessage='Value that makes the Registry Key active')]
        [string]$ValueOn,
        [Parameter(HelpMessage='Value that makes the Registry Key inactive')]
        [string]$ValueOff,
        [Parameter(HelpMessage='Use switch Off to specify whether to use VauleOn or ValueOff. Default is On')]
        [switch]$Off,
        [Parameter(Mandatory=$true,HelpMessage='Registry Hive. Accepts format HKLM:\ or Registry::HKEY_LOCAL_MACHINE')]
            [string]$Hive,
        [Parameter(Mandatory=$true,HelpMessage='Registry Key name.')]
            [string]$Name,
        [Parameter(Mandatory=$true,HelpMessage='Registry Key type.')]
        [ValidateSet('String','ExpandString','Binary','DWord','MultiString','Qword','Unknown')]
            [string]$PropertyType
    )

    $HiveStart = Split-Path -Path $Hive -Parent #starting part of hive path
    $HiveEnd   = Split-Path -Path $Hive -Leaf   #last part of hive path
    
    #Unless we're turning it off
    if ($Off) {
        $Value = $ValueOff
    } else {
        $Value = $ValueOn
    }
    
    #Test for existing value
    $GetVal = Get-ItemPropertyValue -Path $Hive `
                                    -Name $Name `
                                    -ErrorAction SilentlyContinue
    if (!($GetVal)) {
        try {
            Write-Host "Creating "      -NoNewline
            Write-Host $Hive                        -ForegroundColor Yellow
            New-Item    -Path $HiveStart `
                        -Name $HiveEnd `
                        -Force `
                        -ErrorAction Stop | `
                        Out-Null
            Write-Host "Setting "       -NoNewline
            Write-Host "$Hive\$Name"    -NoNewline -ForegroundColor Yellow
            Write-Host " to "           -NoNewline
            Write-Host "$PropertyType " -NoNewline -ForegroundColor Blue
            Write-Host $Value                      -ForegroundColor Yellow
            New-ItemProperty -Path $Hive `
                             -Name $Name `
                             -PropertyType $PropertyType `
                             -Value $Value `
                             -ErrorAction Stop | `
                             Out-Null
        } catch {
            if ($Error[0].CategoryInfo.Category -eq 'PermissionDenied') {
                Write-Host "Unable to write to registry with current permissions. Please elevate and try again." -ForegroundColor Red
            } else {
                Write-Host 'an error occurred' -ForegroundColor Red
            }
        }
    } elseif ($GetVal -ne $Value) {
        try {
            Write-Host $Hive                -NoNewline  -ForegroundColor Yellow
            Write-Host " found. Setting "   -NoNewline
            Write-Host "$Hive\$Name"        -NoNewline  -ForegroundColor Yellow
            Write-Host " to "               -NoNewline 
            Write-Host $Value                           -ForegroundColor Yellow
            Set-ItemProperty -Name $Name `
                             -Path $Hive `
                             -Value $Value `
                             -ErrorAction Stop | `
                             Out-Null
        } catch {
            if ($Error[0].CategoryInfo.Category -eq 'PermissionDenied') {
                Write-Host "Unable to write to registry with current permissions. Please elevate and try again." -ForegroundColor Red
            } else {
                Write-Host 'an error occurred' -ForegroundColor Red
            }
        }
    }
}

if ($null -eq (Get-ItemPropertyValue -Path $LogKey -Name $LogString -ErrorAction SilentlyContinue)) {
    New-RegKey -Hive $LogKey -Name $Logstring -ValueOn $LogValOn   -PropertyType $Prop
    New-RegKey -Hive $LogKey -Name $LogFolder -ValueOn $LogPath    -PropertyType $Prop
} else {
    New-RegKey -Hive $LogKey -Name $Logstring -ValueOff $LogValOff -PropertyType $Prop -Off
}

if ($Reboot) {
    Restart-Computer -Delay 30
}
