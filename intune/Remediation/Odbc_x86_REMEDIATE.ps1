<#
ODBC DSN Remediation
.SYNOPSIS
Adds missing ODBC DSNs for 32-bit Oracle
.NOTES
Author: Bill Wilson
Created: 05/06/2023
Last Edit: 10/07/2023

References:
https://www.andersrodland.com/working-with-odbc-connections-in-powershell/
https://learn.microsoft.com/en-us/powershell/module/wdac/add-odbcdsn
https://learn.microsoft.com/en-us/powershell/module/wdac/remove-odbcdsn
#>

#Remove DSNs
Remove-OdbcDsn -Name "SPARPROD_PROD" -DsnType "System" -Platform "32-bit"
Remove-OdbcDsn -Name "ARCH03_ARCHIVES" -DsnType "System" -Platform "32-bit"
Remove-OdbcDsn -Name "DSN3_SQL" -DsnType "System" -Platform "32-bit"

#Add DSNs
Add-OdbcDsn -Name DSN1 -DriverName "Oracle in OraClient19Home1_32bit" -DsnType System -Platform 32-bit -SetPropertyValue @("Server=Server01")
Add-OdbcDsn -Name DSN2 -DriverName "Oracle in OraClient19Home1_32bit" -DsnType System -Platform 32-bit -SetPropertyValue @("Server=Server01")
Add-OdbcDsn -Name DSN3_SQL -DriverName "SQL Server" -DsnType System -Platform 32-bit -SetPropertyValue @("Server=Server02", "Database=Payroll")
