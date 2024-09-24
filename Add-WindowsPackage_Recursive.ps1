<#
.DESCRIPTION
Add-WindowsPackage for all .cab files in the directory
Written by Bill
24/09/24
#>
$CabPath = 
$Cabs = (Get-ChildItem -Path $CabPath -Recurse -Filter *.cab) | Sort-Object -Property LastWriteTime
foreach ($Cab in $Cabs) {
	$CabCheck = $($Cab.Name).Substring(12,9)
	if (!(Get-HotFix -Id $CabCheck)) {
		#cmd /c "DISM /Online /Add-Package /PackagePath:`"$Cab`""
		Write-Host "Adding $($Cab.FullName)" -ForegroundColor White -BackgroundColor DarkGreen
		Write-Host ".Cab Date $($Cab.LastWriteTime)" -ForegroundColor Green -BackgroundColor DarkGreen
		Add-WindowsPackage -PackagePath $Cab.FullName -Online -NoRestart
	}
}
