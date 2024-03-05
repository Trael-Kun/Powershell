<# 
Remove all 32-bit ODBC DSNs
.SYNOPSIS
Removes all 32-bit ODBC DSNs
.NOTES
Author: Bill Wilson
Created: 17/07/2023
Last Edit: 17/07/2023

References
https://learn.microsoft.com/en-us/powershell/module/wdac/remove-odbcdsn?view=windowsserver2022-ps
#>


Remove-OdbcDsn -Name "*" -DsnType "System" -Platform "32-bit"
