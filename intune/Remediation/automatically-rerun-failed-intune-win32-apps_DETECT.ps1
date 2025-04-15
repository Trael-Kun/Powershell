<# https://powerstacks.com/automatically-rerun-failed-intune-win32-apps/
    .SYNOPSIS
     DETECTTION SCRIPT
    Detects failed Win32 app installations from Intune.

    .DESCRIPTION
    This script identifies failed Win32 app installations from Intune by searching the registry.
    It returns a list of failed app installations.

    .NOTES
    Author: John Marcum (PJM)
    Date: July 25, 2024
    Contact: https://x.com/MEM_MVP

    .REVISION NOTES
    Version: 1.1
    - Added ability to map user object ID to username.
    - Implemented a better registry search function.
    - Added handling for specific MSI error codes.
#>

# Start Logging
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\App_Failure_Detection_$timestamp.log"


#### BEGIN FUNCTIONS ####

<#
    .SYNOPSIS
    Retrieves the failed Win32 app states from the Intune registry.
    
    .DESCRIPTION
    This function searches the Intune Win32 apps registry key for subkeys containing an EnforcementStateMessage property.
    It extracts the error codes from these properties and identifies failed installations.

    .OUTPUTS
    PSCustomObject representing the failed app states.
#>
function Get-FailedWin32AppStates {
    $win32AppsKeyPath = 'HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps'
    $appSubKeys = Get-ChildItem -Path $win32AppsKeyPath -Recurse

    $failedStates = @()
    foreach ($subKey in $appSubKeys) {
        $enforcementStateMessage = Get-ItemProperty -Path $subKey.PSPath -Name EnforcementStateMessage -ErrorAction SilentlyContinue
        if ($enforcementStateMessage) {
            if ($enforcementStateMessage.EnforcementStateMessage -match '"ErrorCode":(-?\d+|null)') {
                $errorCode = $matches[1]
                if ($errorCode -ne "null") {
                    $errorCode = [int]$errorCode
                    if (($errorCode -ne 0) -and ($errorCode -ne 3010) -and ($errorCode -ne $null)) {
                        $failedStates += [PSCustomObject]@{
                            SubKeyPath = $subKey.PSPath
                            ErrorCode  = $errorCode
                        }
                    }
                }
            }
        }
    }

    return $failedStates
}

#### SCRIPT ENTRY POINT ####

# Get the failed Win32 app states
$failedStates = Get-FailedWin32AppStates

# Output the result
if ($failedStates.Count -gt 0) {
    Write-Host "Failed"
    Stop-Transcript
    exit 1
}
else {
    Write-Host "No failures detected."
    Stop-Transcript
    exit 0
}
