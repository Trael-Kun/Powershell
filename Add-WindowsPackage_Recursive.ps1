<#
.SYNOPSIS
 Add-WindowsPackage for all .cab files in the directory
.NOTES
 Author: Bill Wilson (https://github.com/Trael-Kun)
 Date:	24/09/24
#>
param (
	[Parameter(mandatory)}
	[string]$CabPath
 )
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
