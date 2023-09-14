<#
Teams Total Uninstall (Teamsplosion)
Written by Bill 09/03/2023

Uninstalls Teams Machine-Wide Installer and per-user Teams installs

Cache removal & "preventteamsinstall" registry value from https://adamtheautomator.com/uninstall-microsoft-teams/
Registry Lookup from https://stackoverflow.com/questions/15511809/how-do-i-get-the-value-of-a-registry-key-and-only-the-value-using-powershell

Changelog
----------
Engineer    Date           Change
__________________________________
Bill        04/03/2023     Removed unused variables as they were causing errors
                           Added cmd /c to teams uninstall as the argumentswere beaking the command
                           Added Complete removal from Appdata
                           
#>

# Set Variables
    
# Stop Teams
Stop-Process -Name 'Teams' -Force -ErrorAction SilentlyContinue

# Uninstall Teams Machine-Wide Installer
Start-Process msiexec.exe -Wait -ArgumentList "/x {731F6BAA-A986-45A4-8936-7C3AAAAA760B} /qn"

# Get User Uninstall Strings
$UserKeys = Get-ChildItem "Registry::HKEY_USERS"
    ForEach ($UserKey in $UserKeys) {
        $Key = "Registry::$UserKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams"
        $Value = "QuietUninstallString"
        $UnInstall = (Get-ItemProperty -ErrorAction SilentlyContinue -Path $Key -Name $Value).$value
        cmd /c $UnInstall
}

# Remove the all users' Teams cache
Get-ChildItem -Path "$env:systemdrive\Users\*\AppData\Roaming\Microsoft\Teams\*" -Directory |
	Where-Object Name -in ('application cache','blob_storage','databases','GPUcache','IndexedDB','Local Storage','tmp') |
	ForEach {Remove-Item $_.FullName -Recurse -Force}

# Failing that, remove the whole thing (based on detectiond of .dead file)
If ((Test-Path "$env:systemdrive\Users\*\AppData\Local\Microsoft\Teams\.dead") -eq $False) {
    Remove-Item "$env:systemdrive\Users\*\AppData\*" -include *teams*, *squirrel* -Recurse -Force
    }
ElseIf ((Test-Path "$env:systemdrive\Users\*\AppData\Local\Microsoft\Teams\.dead") -eq $True) {
    Get-ChildItem "$env:systemdrive\Users\*\AppData\*" -Include .dead -Recurse -Force -ErrorAction SilentlyContinue | Export-Csv -Path "$env:windir\Logs\TeamsRemovalDeadFile.csv"
    }
Else {
    }

# Add Regkey to prevent Teams installs
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\common\officeupdate" -Name PreventTeamsInstall -PropertyType String -Value 1
