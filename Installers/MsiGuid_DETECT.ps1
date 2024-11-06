<#
    GUID Detection
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   06/11/2024
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$Guid
)
if (Get-CimInstance -Class win32_product | Where-Object{$_.IdentifyingNumber -eq $Guid}) {
    exit 0
} else {
    exit 1
}
