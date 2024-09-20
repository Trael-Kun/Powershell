<#
.SYNOPSIS
    Get-OutlookForWindows
.DESCRIPTION
    checks for RegKey to all applicable accounts to disable 
    "Try New Outlook" toggle in Outlook, then checks for the APPX
.NOTES
By Bill
20/04/2023

Run as admin, or the -Allusers in Get-AppxPackage won't work
#>

#Path for Regkey
$RegPath = "Software\policies\Microsoft\Office\16.0\Outlook\Options\General"
#Get required HKEY_USERS
$Users = Get-ChildItem Registry::Hkey_users -Exclude *Classes

foreach ($User in $Users.name) {
    #set full regpath
    $UserPath = "Registry::$User\$RegPath"
    #test regpath
    if (Test-Path $UserPath) {
        #check the itemproperty
        $DWORD = Get-ItemProperty -Path $UserPath -Name HideNewOutlookToggle
        if ($null -eq $DWORD -or $DWORD -ne 1) {
            exit 1
        }
    }
}

#is the app installed?
if (Get-AppxPackage -AllUsers -Name *OutlookForWindows*) {
    exit 1
} else {
    exit 0
}
