<#
Dell Peripheral Manager Detection
.SYNOPSIS
Detects Dell Peripheral Manager Detection
.NOTES
Author: Bill Wilson
Created: 21/07/2023
Last Edit: 21/07/2023
#>

if (Test-Path "$env:ProgramFiles\Dell\Dell Peripheral Manager\Uninstall.exe") {
    EXIT 1
}
else {
    EXIT 0
}
