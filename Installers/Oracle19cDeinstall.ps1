<#
Oracle Client 19c 32-bit deinstall
.SYNOPSIS
Installs Oracle 19c (x86)
.DESCRIPTION
Process as follows;
    - Tests for presence of deinstaller files
        - if present, runs deinstaller
        - if not present, open install files & run deinstaller
.NOTES
Author: Bill Wilson
Created: 12/04/2024

#>
function Write-Log {
    param (
        [string] $Msg
    )
    Write-Output "$Msg"
    if ($Log) {
        Add-Content -Path $LogFile -Value "$(Get-Date) |    $Msg"
        Start-Sleep -Seconds 1
    }
}

Start-Transcript -Path "$env:WinDir\Logs\OracleDeinstallTranscript.log" -Append -Force

$ScriptPath =   split-path -parent $MyInvocation.MyCommand.Definition
$LogFile =      "$env:WinDir\Logs\Ora86Install.log"
$OraTemp =      "$env:programdata\Ora86"
$OraHome =      "$env:SystemDrive\Oracle32\Product\19c\Client_1"
$Deinstall =    "$OraHome\deinstall"
$Zip =          "Oracle19cx86.zip"
$CmdFile =      'deinstall.cmd'
$RSP =          'deinstall_OraClient19Home1_32bit.rsp'

##START SCRIPT
Write-Host "Start Script"

# Check for .rsp on c:
if (Test-Path "$Deinstall\$RSP") {
    Start-Process -FilePath "$Deinstall\$CmdFile"  -Wait -NoNewWindow
}
else {
    # Check for OraTemp on C:
    if (Test-Path -Path $OraTemp) {
        #If it's there, remove it
        Remove-Item -Path $OraTemp -Recurse -Force
    }
    # Unpack .zip
    Expand-Archive -Path "$ScriptPath\$Zip" -DestinationPath $OraTemp -Force
    # Start Deinstall
    Start-Process -FilePath "$OraTemp\$CmdFile" -Wait -NoNewWindow
}

Write-Log -Msg "Script End"
Stop-Transcript
##END SCRIPT
