<#
ODBC DSN Detection
.SYNOPSIS
Detects missing ODBC DSNs for Oracle 19c x86
.NOTES
Author: Bill Wilson
Created: 05/06/2023
Last Edit: 10/07/2023

References:
https://learn.microsoft.com/en-us/powershell/module/wdac/get-odbcdriver?view=windowsserver2022-ps
https://stackoverflow.com/questions/38313529/how-do-i-check-if-all-the-returned-values-are-true/38313607#38313607
#>

#Check for Oracle 19c x86 install
if (Test-Path -Path C:\Oracle32\Product\19c\Client_1 -PathType Container)
    {
    # Get the list of predefined ODBC DSNs
    $dsnNames = Get-OdbcDsn -DsnType System -Platform 32-bit | Select-Object -ExpandProperty Name

    # Check if the predefined DSNs exist
    $DSNs = @("DSN1", "DSN2", "DSN3_SQL")

        foreach ($dsn in $DSNs) {
            if ($dsnNames -contains $dsn) {
                EXIT 1
            }
            else {
            EXIT 0
            }
        }
        else {
            EXIT 0
        }
    }