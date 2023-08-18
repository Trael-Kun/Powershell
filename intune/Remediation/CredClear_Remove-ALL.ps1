#cmd /c "for /F "tokens=1,2 delims= " %G in ('cmdkey /list ^| findstr Target') do cmdkey /delete %H"
$Creds = cmdkey /list | Select-String "Target:*"
#Remove Credentials
foreach ($Cred in $Creds) {
    Write-Host "Removing Credential for $Cred"
    cmdkey /delete:$Cred
    }