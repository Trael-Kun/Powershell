<#
.SYNOPSIS
    Remove-OutlookForWindows
.DESCRIPTION
    Adds RegKey to all applicable accounts to disable 
    "Try New Outlook" toggle in Outlook, then uninstalls 
    the APPX (if installed, obvs)
.NOTES
By Bill
20/04/2023

Run as admin, or the -Allusers in Get-AppxPackage won't work
#>

#Disable "New Outlook" Toggle
#Path for Regkey
$RegPath = "Software\policies\Microsoft\Office\16.0\Outlook\Options\General"
#Get required HKEY_USERS
$Users = Get-ChildItem Registry::Hkey_users -Exclude *Classes

foreach ($User in $Users.name) {
    #set full regpath
    $UserPath = "Registry::$User\$RegPath"
    #test regpath
    if (Test-Path $UserPath) {
        #if it's there, create the DWORD
        New-ItemProperty -Path $UserPath -Name HideNewOutlookToggle -PropertyType DWord -Value 1
    }
}

#Remove the App if it's installed
Get-AppxPackage -AllUsers -Name *OutlookForWindows* | Remove-AppxPackage -ErrorAction SilentlyContinue
