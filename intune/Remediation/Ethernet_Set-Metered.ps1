<# 
.SYNOPSIS   :  PowerShell script to set Ethernet connection as metered or not metered

.AUTHOR     :  Michael Pietroforte

.SITE       :  https://4sysops.com/archives/set-windows-10-ethernet-connection-to-metered-with-powershell/
#>

#We need a Win32 class to take ownership of the Registry key
$definition = @"
using System;
using System.Runtime.InteropServices; 

namespace Win32Api
{

    public class NtDll
    {
        [DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")]
        public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled);
    }
}
"@ 

Add-Type -TypeDefinition $definition -PassThru | Out-Null
[Win32Api.NtDll]::RtlAdjustPrivilege(9, $true, $false, [ref]$false) | Out-Null

#Setting ownership to Administrators
$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost",[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
$acl = $key.GetAccessControl()
$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
$key.SetAccessControl($acl)

#Giving Administrators full control to the key
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ([System.Security.Principal.NTAccount]"Administrators","FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

#Setting Ethernet as metered or not metered
$path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost"
$name = "Ethernet"
$metered = Get-ItemProperty -Path $path | Select-Object -ExpandProperty $name

Clear
if ($metered -eq 1) {
    $SetMetered = Read-Host "Ethernet is currently not metered. Set to metered? (y/n)"
    if ($SetMetered -eq "y") {
        New-ItemProperty -Path $path -Name $name -Value "2" -PropertyType DWORD -Force | Out-Null
        Write-Host "Ethernet is now set to metered."
    } else {
        Write-Host "Nothing was changed."
    }
} elseif ($metered -eq 2) {
    $SetMetered = Read-Host "Ethernet is currently metered. Set to not metered? (y/n)"
    if ($SetMetered -eq "y") {
        New-ItemProperty -Path $path -Name $name -Value "1" -PropertyType DWORD -Force | Out-Null
        Write-Host "Ethernet is now set as not metered."
     } else {
        Write-Host "Nothing was changed."
     }
}