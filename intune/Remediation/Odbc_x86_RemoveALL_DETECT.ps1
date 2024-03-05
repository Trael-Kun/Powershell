<#
Oracle 19c x86 Detection
.SYNOPSIS
Detects Oracle 19c x86 installation
.NOTES
Author: Bill Wilson
Created: 17/07/2023
Last Edit: 17/07/2023

References:
https://learn.microsoft.com/en-us/powershell/module/wdac/get-odbcdriver?view=windowsserver2022-ps
https://stackoverflow.com/questions/38313529/how-do-i-check-if-all-the-returned-values-are-true/38313607#38313607
#>

#Check for Oracle 19c x86 install
if (Test-Path -Path C:\Oracle32\Product\19c\Client_1 -PathType Container) {
    EXIT 1
    }
else {
    EXIT 0
    }
