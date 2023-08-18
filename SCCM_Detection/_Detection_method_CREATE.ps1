<# Create Detection Method #>

<#
Write-Host "Enter Application Display Name: "
$DisplayName = Read-Host

## Registry Detection Method
    $RegDetect = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty | Where-Object {$_.DisplayName -like "$DisplayName" } | Select-Object -Property DisplayName, DisplayVersion, PSChildName
    $RegDetect.DisplayVersion
    $RegDetect.PSChildName
## Create Text File with Registry Detection Method
    $RegFilePath = "C:\Temp\REG_Detection_Method.txt"
    New-Item -Path "$RegFilePath" -Force
    Set-Content -Path "$RegFilePath" -Value "If([Version](Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$($RegDetect.PSChildName)','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($RegDetect.PSChildName)' -Name DisplayVersion -ea SilentlyContinue) -ge '$($RegDetect.DisplayVersion)') {"
    Add-Content -Path "$RegFilePath" -Value "Write-Host `"Installed`""
    Add-Content -Path "$RegFilePath" -Value "Exit 0"
    Add-Content -Path "$RegFilePath" -Value "}"
    Add-Content -Path "$RegFilePath" -Value "else {"
    Add-Content -Path "$RegFilePath" -Value "Exit 1"
    Add-Content -Path "$RegFilePath" -Value "}"
    Invoke-Item $RegFilePath

## MSI Detection Method
    $MSIDetect = Get-WMIobject Win32_Product -Filter "name = ""$DisplayName"""
## Create Text File with Registry Detection Method
    $MSIFilePath = "C:\Temp\MSI_Detection_Method.txt"
    New-Item -Path "$MSIFilePath" -Force
    Set-Content -Path "$MSIFilePath" -Value "If((Get-Wmiobject Win32_Product -filter ""IdentifyingNumber = '$($MSIDetect.IdentifyingNumber)'"") -ge (""Version = '$($MSIDetect.Version)'""))  {"
    Add-Content -Path "$MSIFilePath" -Value "Write-Host `"Installed`""
    Add-Content -Path "$MSIFilePath" -Value "Exit 0"
    Add-Content -Path "$MSIFilePath" -Value "}"
    Add-Content -Path "$MSIFilePath" -Value "else {"
    Add-Content -Path "$MSIFilePath" -Value "Exit 1"
    Add-Content -Path "$MSIFilePath" -Value "}"
    Invoke-Item $MSIFilePath

    #>