## Check for Microsoft Visual C++ 2010 x86 Redistributable (Registry Detection Method)
$VC2010x86 = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty | Where-Object {$_.DisplayName -like 'Microsoft Visual C++ 2010*x86 Redistributable*' } | Select-Object -Property DisplayName, DisplayVersion, PSChildName
$VC2010x86.DisplayVersion
$VC2010x86.PSChildName

## Create Text File with Microsoft Visual C++ 2010 x86 Redistributable Registry Detection Method
$FilePath = "C:\Windows\Temp\VC2010_x86_Detection_Method.txt"
New-Item -Path "$FilePath" -Force
Set-Content -Path "$FilePath" -Value "If([Version](Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$($VC2010x86.PSChildName)','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($VC2010x86.PSChildName)' -Name DisplayVersion -ea SilentlyContinue) -ge '$($VC2010x86.DisplayVersion)') {"
Add-Content -Path "$FilePath" -Value "Write-Host `"Installed`""
Add-Content -Path "$FilePath" -Value "Exit 0"
Add-Content -Path "$FilePath" -Value "}"
Add-Content -Path "$FilePath" -Value "else {"
Add-Content -Path "$FilePath" -Value "Exit 1"
Add-Content -Path "$FilePath" -Value "}"
Invoke-Item $FilePath