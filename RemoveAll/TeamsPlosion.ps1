<#
Teams Total Uninstall (Teamsplosion)
Written by Bill 09/03/2023

Uninstalls Teams Machine-Wide Installer and per-user Teams installs

https://adamtheautomator.com/uninstall-microsoft-teams/
https://stackoverflow.com/questions/15511809/how-do-i-get-the-value-of-a-registry-key-and-only-the-value-using-powershell
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convert-string?view=powershell-5.1
https://java2blog.com/get-current-directory-powershell

Changelog
----------
Engineer    Date           Change
__________________________________
Bill        04/03/2023     Removed unused variables as they were causing errors
                           Added cmd /c to teams uninstall as the argumentswere beaking the command
                           Added Complete removal from Appdata
Bill        15/09/2023     Added Uninstall-GUID function
                           
#>

function Uninstall-GUID {
    <#

    .SYNOPSIS
        Runs uninstall of MSI programs from GUID strings extracted from the registry

    .DESCRIPTION
        Uninstall-GUID is a function that searches for a GUIDs from uninstall strings in
        the registry, then runs msiexec to remove them. Useful for removing all programs
        from a specific publisher of multiple installs of the same program.

    .PARAMETER regKey
        The path to the Registry Key that contains the GUID. Can accept wildcards.

    .PARAMETER regName
        The name of the Value to search for, e.g. DisplayName, DisplayVersion, Publisher

    .PARAMETER regMatch
        The string to match in the Value; e.g. Citrix, Microsoft, Norton, 1.0.5

    .EXAMPLE
        Uninstall-GUID -regKey "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*\" -regName "DisplayName" -RegMatch 'Teams'

    .EXAMPLE
        Uninstall-GUID -regKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*\" -regName "Publisher" -RegMatch 'Citrix'

    .NOTES
        Author:     Bill Wilson
        Website:    https://github.com/Trael-Kun/

    #>
    param (
        [Parameter(Mandatory=$true,HelpMessage="Enter the Registry Key to search")] [string[]]$regKey,
        [Parameter(Mandatory=$true,HelpMessage="Enter the Registry Value to search against")]$regName,
        [Parameter(Mandatory=$true,HelpMessage="Enter the string to search against")]$regMatch
    )
    
    # take note of the current directory so we can come back later
    $CurrentDir = Get-Location
    # Let's go to the registry, otherwise this won't work
    Set-Location -Path HKLM:\
    # Get all of the registry keys
    $regPaths = Get-ChildItem $regKey
    # First, get the Uninstall string from the 32-bit registry
    ForEach ($regPath in $regPaths) {
        if ((Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) -match $regMatch) {
            $Uninst = Get-ItemProperty -Path $regPath -Name 'UninstallString' | Select-Object -Property UninstallString
            # Then extract the GUID because for some reason the uninstall string is showing as "msiexec.exe /i"
            $GUID = $Uninst.UninstallString | Convert-String -Example "MsiExec.exe /I{731F6BAA-A986-45A4-8936-7C3AAAAA760B} = {731F6BAA-A986-45A4-8936-7C3AAAAA760B}"
            # Now run the uninstaller
            Start-Process -FilePath "$env:windir\system32\msiexec.exe" -ArgumentList "/x $GUID /qn" -Wait
        }
    }
    # Go back to the starting directory
    Set-Location -Path "$CurrentDir"
}

### Start Script

## Stop Teams
Stop-Process -Name 'Teams' -Force -ErrorAction SilentlyContinue

## Uninstall Teams Machine-Wide Installer
# Scan 32-Bit Registry
Uninstall-GUID -regKey "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*\" -regName "DisplayName" -RegMatch 'Teams'
# Now let's do it again in the 64-bit registry;
Uninstall-GUID -regKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*\" -regName "DisplayName" -RegMatch 'Teams'

## Get User Uninstall Strings from Registry
$UserKeys = Get-ChildItem "Registry::HKEY_USERS"
    ForEach ($UserKey in $UserKeys) {
        $Key = "Registry::$UserKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams"
        $Value = "QuietUninstallString"
        $UnInstall = (Get-ItemProperty -ErrorAction SilentlyContinue -Path $Key -Name $Value).$value
        # Now run 'em
        cmd /c $UnInstall
}

## Remove the all users' Teams cache
Get-ChildItem -Path "$env:systemdrive\Users\*\AppData\Roaming\Microsoft\Teams\*" -Directory |
	Where-Object Name -in ('application cache','blob_storage','databases','GPUcache','IndexedDB','Local Storage','tmp') |
	ForEach {Remove-Item $_.FullName -Recurse -Force}

## Failing that, remove the whole thing (based on detectiond of .dead file)
If ((Test-Path "$env:systemdrive\Users\*\AppData\Local\Microsoft\Teams\.dead") -eq $False) {
    Remove-Item "$env:systemdrive\Users\*\AppData\*" -include *teams*, *squirrel* -Recurse -Force
    }
ElseIf ((Test-Path "$env:systemdrive\Users\*\AppData\Local\Microsoft\Teams\.dead") -eq $True) {
    Get-ChildItem "$env:systemdrive\Users\*\AppData\*" -Include .dead -Recurse -Force -ErrorAction SilentlyContinue | Export-Csv -Path "$env:windir\Logs\TeamsRemovalDeadFile.csv"
    }
Else {
    }

## Add Regkey to prevent future Teams installs
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\common\officeupdate" -Name PreventTeamsInstall -PropertyType String -Value 1
