<# KB0050732
https://www.edugeek.net/forums/scripts/190833-powershell-script-profile-removal.html
https://www.alkanesolutions.co.uk/2021/06/15/how-to-use-test-path-for-hkey-users/
https://pscustomobject.github.io/powershell/PowerShell-Export-Registry-Key/
#>

param(
    [Parameter(manditory=$True)]$UserName
)

# Find Profile SID
$Profile = Get-WmiObject -ComputerName $env:ComputerName Win32_UserProfile -filter "LocalPath like '%\\$UserName' "

# Rename User Folder, just in case
Rename-item -Path "$env:SystemDrive\Users\$UserName" -NewName "$env:SystemDrive\Users\$($UserName).old" -Force



# If SID does not exist
if ((Test-Path -path "Registry::HKU\$($profile.SID)") -eq $False) {
    # import NTuser.NAT
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c reg.exe import `"$env:SystemDrive\Users\$UserName\NTuser.DAT`"" -Wait -Passthru
}
# if SID does exist
else {
#Backup Registry
Invoke-Command  {reg export "HKU\$($profile.SID)" C:\Users\$UserName\Reg_Backup.reg }

#Delete SID Key
Remove-Item -Path "Registry::HKU\$($profile.SID)" -Force
}
#shutdown /r /t 0
Restart-Computer
