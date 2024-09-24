<#
.DESCRIPTION
Add-WindowsPackage for all .cab files in the directory
Written by Bill
24/09/24
#>
$CabPath = 
$Cabs = (Get-ChildItem -Path $CabPath -Recurse -Filter *.cab) | Sort-Object -Property LastWriteTime
foreach ($Cab in $Cabs.FullName) {
	#cmd /c "DISM /Online /Add-Package /PackagePath:`"$Cab`""
 Write-Host "Adding $Cab" -ForegroundColor Green
 Add-WindowsPackage -PackagePath $Cab -Online -NoRestart
}
