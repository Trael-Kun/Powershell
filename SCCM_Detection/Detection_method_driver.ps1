$GPUname="*quadro*"
$Driverver="30.0.14.7141"
$wmipackages=Get-WmiObject Win32_PnPSignedDriver| select devicename, driverversion | where {$_.devicename -like $GPUname}

if ($wmipackages.DeviceName -like $GPUname) {
    if ($wmipackages.driverVersion -eq $Driverver) {
    Write-Host 'Installed' 
    }
    else {}
}