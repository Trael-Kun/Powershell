# Find PNPutil
Write-Host "Getting PNPutil location"
$PNPutil = Get-ChildItem -Path $env:SystemDrive\ -Recurse -Filter 'PNPutil.exe' | Select-Object -First 1
Write-Host $PNPutil.FullName

# Remove old driver
Write-Host "Getting old driver name"
$InfName = Get-WmiObject win32_pnpsigneddriver | Where-Object{$_.devicename -eq 'Intel(R) Iris(R) Xe Graphics'} | Select-Object InfName
Write-Host $InfName.InfName
#$($PNPutil.FullName) /delete-driver $($InfName.InfName) /uninstall /force
#cmd.exe /c "$($PNPutil.FullName) /delete-driver $($InfName.InfName) /uninstall /force"
Write-Host "Deleting faulty driver"
$DeleteDriver = "'/delete-driver', $($InfName.InfName), '/uninstall', '/force'"
$AddDriver = "'/add-driver', $_.FullName, '/install'"
Start-Process $($PNPutil.FullName) -ArgumentList $DeleteDriver -Wait -NoNewWindow

# Install new driver
Write-Host "Installing new drivers"
Get-ChildItem -Path "\\server\IrisXe\31.0.101.4972" -Recurse -Filter "*.inf" | ForEach-Object { Start-Process $($PNPutil.FullName) -ArgumentList $AddDriver  -Wait -NoNewWindow }