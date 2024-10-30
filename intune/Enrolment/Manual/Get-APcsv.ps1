[CmdletBinding()]
param(
    [Parameter(Mandatory=$False)] [String] $Version = "3.5"
)

& "$PSScriptRoot\Get-WindowsAutoPilotInfo_$Version.ps1" -OutputFile "$PSScriptRoot\AutopilotData.csv" -Append
Stop-Computer -Force
