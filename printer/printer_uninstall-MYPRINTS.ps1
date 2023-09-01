# Get all MyPrints printers
$Printer = Get-Printer -Name "myprints*"
# remove printers
Remove-Printer -InputObject $Printer
