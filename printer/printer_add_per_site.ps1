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

$Shares = @(
    'CBR-PRINT01',  #ACT Print Server
    'SYD-PRINT01',  #NSW Print Server
    'BRIS-PRINT01', #QLD Print Server
    'DAR-PRINT01',  #NT Print Server
    'MEL-PRINT01',  #Vic Print Server 1
    'MEL-PRINT02',  #Vic Print Server 2
    'PER-PRINT01',  #WA Print Server
    'HOB-PRINT01',  #Tas Print Server
    'ADE-PRINT01',  #SA Print Server
    'LON-PRINT01'   #UK Print Server
)

# Find installed Printers
foreach ($Share in $Shares) {
    if ($Share -match $(Get-Printer | Format-List).ComputerName ) {
        $NetPrinters = Get-Printer -ComputerName \\$Share | Format-table Name
        foreach ($NetPrinter in $NetPrinters) {
            Add-Printer -ConnectionName \\$PrintServer\$Printer
        }
        break
    }
}
