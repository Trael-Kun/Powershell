<#
 .DESCRIPTION
  Sets reg key to unblur background when bringing up the Windows login screen
.NOTES
  Written by Bill 06/03/2026
#>

Function Write-1Line {
    param ( 
        [Parameter(Mandatory)]
            [Alias('Message',"Msg")]
            [string]$Msg,
            [ValidateSet(
                'DarkMagenta',
                'DarkYellow',
                'Gray',
                'DarkGray',
                'Blue',
                'Green',
                'Cyan',
                'Red',
                'Magenta',
                'Yellow',
                'White')]
            [Alias('Colour','Color','Col')]
            [string]$Colour,
            [switch]$End
    )

    if ($Col -and $End) {
        Write-Host $Msg            -ForegroundColor $Colour
    } elseif ($End) {
        Write-Host $Msg
    } elseif ($Col) {
        Write-Host $Msg -NoNewline -ForegroundColor $Colour
    } else {
        Write-Host $Msg -NoNewline
    }
}

$Yel = 'Yellow'
$Blu = 'Blue'

Function New-RegKey {
    <#
     .SYNOPSIS
        Create new regkey & property in specified location
    .DESCRIPTION
        Creaters new reg key in location, or updates the value to match the specified value.
    .PARAMETER ValueOn
        Specifies a value to activate the feature used by the Registry key.
    .PARAMETER ValueOff
        Specifies a value to deactivate the feature used by the Registry key.
    .PARAMETER Hive
        Specifies the registry hive to access/create. Accepts format HKLM:\ or Registry::HKEY_LOCAL_MACHINE
    .PARAMETER Name
        Specifies the name of the registry key to be created.
    .PARAMETER PropertyType
        Specifies the type of registry key. Accepts only the following inputs; 'String','ExpandString','Binary','DWord','MultiString','Qword','Unknown'
    .EXAMPLE
        C:\PS> New-RegKey -Hive 'HKLM:\SOFTWARE\RealSoftwareCo' -Name 'RealRegKey' -PropertyType String -ValueOn 'true'
        Tests for a reg key in HKLM:\SOFTWARE\RealSoftwareCo named RealRegKey with a value of true. Creates it if it does not exist, or changes the value if it does not match.
    .EXAMPLE
        C:\PS> New-RegKey -Hive 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\RealSoftwareCo' -Name 'RealRegKey' -PropertyType String -ValueOn 'true' -ValueOff 'false'
        Tests for a reg key in HKLM:\SOFTWARE\RealSoftwareCo named RealRegKey with a value of true. Creates it if it does not exist, or changes the value if it does not match.
    .EXAMPLE
        C:\PS> New-RegKey -Hive 'HKLM:\SOFTWARE\RealSoftwareCo' -Name 'RealRegKey' -PropertyType String -ValueOn 'true' -ValueOff 'false' -Off
        Tests for a reg key in HKLM:\SOFTWARE\RealSoftwareCo named RealRegKey with a value of false. Creates it if it does not exist, or changes the value if it does not match.
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

    

    $HiveStart = Split-Path -Path $Hive -Parent #start of hive path
    $HiveEnd   = Split-Path -Path $Hive -Leaf   #end of hive path
    
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
            Write-1Line "Creating "
            Write-1Line $Hive -Col $Yel -End

            New-Item    -Path $HiveStart `
                        -Name $HiveEnd `
                        -Force `
                        -ErrorAction Stop | `
                        Out-Null

            Write-1Line "Setting "
            Write-1Line "$Hive\$Name"    -Col $Yel
            Write-1Line " to "
            Write-1Line "$PropertyType " -Col $Blu
            Write-1Line $Value           -Col $Yel -End

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
            Write-1Line $Hive            -Col $Yel
            Write-1Line " found. Setting "
            Write-1Line "$Hive\$Name"    -Col $Yel
            Write-1Line " to "
            Write-1Line $Value           -Col $Yel -End

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

New-RegKey  -ValueOn '1' `
            -Hive 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
            -Name 'DisableAcrylicBackgroundOnLogon' `
            -PropertyType DWord

#End Script
