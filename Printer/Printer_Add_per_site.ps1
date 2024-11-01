<#
.SYNOPSIS
Finds all printers on specific print server & installs them

.DESCRIPTION
Pulls installed printers with Get-printer, them uses the value of \\XXX-PRINT01\FollowMe to
extract & define office location. Then installs ALL printers from the print server.

.EXAMPLE

.NOTES
AUTHOR:     Bill Wilson
Created:    31/08/2023

References:
https://learn.microsoft.com/en-us/powershell/module/printmanagement/add-printer
#>

$ACTprint   = 'CBR-PRINT01'
$NSWprint   = 'SYD-PRINT01'
$QLDprint   ='BRIS-PRINT01'
$NTprint    = 'DAR-PRINT01'
$VICprint1  = 'MEL-PRINT01'
$VICprint2  = 'MEL-PRINT02'
$WAprint    = 'PER-PRINT01'
$TASprint   = 'HOB-PRINT01'
$SAprint    = 'ADE-PRINT01'
$UKprint    = 'LON-PRINT01'

# Find installed Printers
$GetPrint = Get-Printer | Format-List

# Find office location
if ($GetPrint -match $ACTprint) {
    $PrintServ = $ACTprint
} elseif ($GetPrint -match $NSWprint) {
    $PrintServ = $NSWprint
} elseif ($GetPrint -match $QLDprint) {
    $PrintServ = $QLDprint
} elseif ($GetPrint -match $NTprint) {
    $PrintServ = $NTprint
} elseif ($GetPrint -match $VICprint1) {
    $PrintServ = $VICprint1
} elseif ($GetPrint -match $VICprint2) {
    $PrintServ = $VICprint2
} elseif ($GetPrint -match $WAprint) {
    $PrintServ = $WAprint
} elseif ($GetPrint -match $TASprint) {
    $PrintServ = $TASprint
} elseif ($GetPrint -match $SAprint) {
    $PrintServ = $SAprint
} elseif ($GetPrint -match $UKprint) {
    $PrintServ = $UKprint
} else {
    EXIT 1
}

# Find all printers on print server
$Printers = Get-Printer -ComputerName \\$PrintServ | Format-table Name

# Install each printer found
foreach ($Printer in $Printers)
Add-Printer -ConnectionName \\$PrintServ\$Printer

# End Script
