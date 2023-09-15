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
        [Parameter(Mandatory)]
        [string]$regKey
        [string]$regName
        [string]$regMatch
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
