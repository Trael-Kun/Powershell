<#
https://www.advanceduninstaller.com/Citrix-Workspace-1912-4237dbc31619c8685c1da2e0ec111c12-application.htm
https://community.spiceworks.com/how_to/126700-how-to-get-the-uninstall-string-for-a-program-from-the-windows-registry-via-powershell
https://stackoverflow.com/questions/15511809/how-do-i-get-the-value-of-a-registry-key-and-only-the-value-using-powershell
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convert-string?view=powershell-5.1
https://java2blog.com/get-current-directory-powershell
#>

<#
Data from https://www.advanceduninstaller.com/Citrix-Workspace-1912-4237dbc31619c8685c1da2e0ec111c12-application.htm
'C:\Program Files (x86)\Citrix'

'HKCR:\Installer\Assemblies\C:|Program Files (x86)|Citrix|ICA Client|XPSPrintHelper.exe'
'HKLM:\SOFTWARE\Classes\Installer\Products\8C683B051473FB04A947EDD085AAA036'
'HKLM:\SOFTWARE\Classes\Installer\Products\A35F3EFD189A75C45AD972BCED072EDF'
'HKLM:\SOFTWARE\Classes\Installer\Products\CE80B7999A3382F459FADAB41E8D7B15'
'HKLM:\SOFTWARE\Classes\Installer\Products\D880B2C77CE88EA4190264E92DFAFC1A'
'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\CitrixOnlinePluginPackWeb'

'HKLM:\SOFTWARE\Classes\Installer\Products\8C683B051473FB04A947EDD085AAA036\ProductName'
'HKLM:\SOFTWARE\Classes\Installer\Products\A35F3EFD189A75C45AD972BCED072EDF\ProductName'
'HKLM:\SOFTWARE\Classes\Installer\Products\CE80B7999A3382F459FADAB41E8D7B15\ProductName'
'HKLM:\SOFTWARE\Classes\Installer\Products\D880B2C77CE88EA4190264E92DFAFC1A\ProductName'
'HKLM:\System\CurrentControlSet\Services\CWAUpdaterService\ImagePath'
'HKLM:\System\CurrentControlSet\Services\entryprotectdrv\ImagePath'
'HKLM:\System\CurrentControlSet\Services\epinject6\ImagePath'
'HKLM:\System\CurrentControlSet\Services\epinjectsvc\DLL 000'
'HKLM:\System\CurrentControlSet\Services\epinjectsvc\DLL 001'
'HKLM:\System\CurrentControlSet\Services\epinjectsvc\ImagePath'
)
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

# Stop Services
Stop-Service -Name 'CWAUpdaterService'
$Services =  Get-Service | Where-Object {$_.DisplayName -match "Citrix"}
foreach ($Service in $Services) {
    Stop-Service -Name $Service.Name
}

# Stop Processes
$Processes = Get-Process | Where-Object {$_.description -like '*citrix*'} | Select-Object ProcessName
foreach ($Process in $Processes) {
    Stop-Process -Name $Process.ProcessName -Force
}

# Remove Citrix Folder
Remove-Item -Path "${env:ProgramFiles(x86)}\Citrix" -Recurse -Force

# Uninstall from x86
Uninstall-GUID -regKey "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*\" -regName 'Publisher' -RegMatch 'Citrix'
# Uninstall from x64
Uninstall-GUID -regKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*\" -regName 'Publisher' -RegMatch 'Citrix'

# Remove Erronius RegKeys
$CurrentDir = Get-Location
Set-Location -Path HKLM:\
$regClasses = Get-ChildItem "HKLM:\SOFTWARE\Classes\Installer\Products\*\"
ForEach ($regClass in $regClasses) {
    if ((Get-ItemProperty -Path $regClass -Name 'ProductName') -match "Citrix") {
        Remove-Item $regClass -Recurse
    }
    Set-Location $CurrentDir
}

# Kill it for realsies
Remove-Item -Path "${env:ProgramFiles(x86)}\Citrix" -Recurse -Force
