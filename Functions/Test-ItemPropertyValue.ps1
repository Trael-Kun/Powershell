function Test-ItemPropertyValue {
 <#
    .SYNOPSIS
        Checks item property value, or checks value is not $null. Useful for checking registry.
    .NOTES
        Author: Bill Wilson
        Date 04/11/2024
    #>
    param (
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [string]$Name,
    [Parameter(Mandatory=$false)]
    [string]$Value
    )
    if ($null -ne $Value) {
    ($null -ne (Get-ItemPropertyValue -Path $Path -Name $Name))
    } else {
    ((Get-ItemPropertyValue -Path $Path -Name $Name) -eq $Value)
    }
}
