# Find installed FollowMe printers
$printer = Get-CimInstance -Class Win32_Printer -Filter "Name like 'FollowMe%'"
# set Followme as default
Invoke-CimMethod -InputObject $printer -MethodName SetDefaultPrinter
