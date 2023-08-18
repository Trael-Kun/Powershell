<#
Dell Peripheral Manager Remediation
.SYNOPSIS
Uninstalls Dell Peripheral Manager
.NOTES
Author: Bill Wilson
Created: 21/07/2023
Last Edit: 21/07/2023

References:
https://silentinstallhq.com/dell-peripheral-manager-silent-install-how-to-guide/
#>

$SETUP = "$env:ProgramFiles\Dell\Dell Peripheral Manager\Uninstall.exe"
$ARGLIST = "/S"

Start-Process -FilePath $SETUP -Wait -ArgumentList $ARGLIST