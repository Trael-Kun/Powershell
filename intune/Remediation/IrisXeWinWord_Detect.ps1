# Variables
$UpdateVer = '31.0.101.4972'
$GetDriver = Get-WmiObject win32_pnpsigneddriver |Where-Object{$_.devicename -eq 'Intel(R) Iris(R) Xe Graphics'} | Select-Object driverversion
$DriverVer = $GetDriver.DriverVersion

# Check
if ($DriverVer -ge $UpdateVer) {
    "Installed"
}
else {
    ""
}