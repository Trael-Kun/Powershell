<# https://www.advanceduninstaller.com/Citrix-Workspace-1912-4237dbc31619c8685c1da2e0ec111c12-application.htm
https://community.spiceworks.com/how_to/126700-how-to-get-the-uninstall-string-for-a-program-from-the-windows-registry-via-powershell
#>

<#
$Blattem = @(
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

Set-Location -Path HKLM:\

# Uninstall from x86
$regPaths86 = Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*\"
ForEach ($regPath86 in $regPaths86) {
    if ((Get-ItemProperty -Path $regPath86 -Name 'Publisher' -ErrorAction SilentlyContinue) -match "Citrix") {
        $Uninst86 = Get-ItemProperty -Path $regPath86 -Name 'UninstallString' | Select-Object -Property UninstallString
        $Uninst86.UninstallString
    }
}

# Unintall from x64
$regPaths64 = Get-ChildItem "HKLM:\SOFTWARE\Classes\Installer\Products\*\"
foreach ($regPath64 in $regPaths64) {
    if ((Get-ItemProperty -Path $regPath64 -Name 'Publisher') -match "Citrix") {
        $Uninst64 = Get-ItemProperty -Path $regPath64 -Name 'UninstallString' | Select-Object -Property UninstallString
        $Uninst64.UninstallString
    }
}

# Remove Erronius RegKeys
$regClasses = Get-ChildItem "HKLM:\SOFTWARE\Classes\Installer\Products\*\"
ForEach ($regClass in $regClasses) {
    if ((Get-ItemProperty -Path $regClass -Name 'ProductName') -match "Citrix") {
        Remove-Item $regClass -Recurse
    }
}

# Kill it for realsies
Remove-Item -Path "${env:ProgramFiles(x86)}\Citrix" -Recurse -Force
