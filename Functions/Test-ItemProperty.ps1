function Test-ItemProperty {
 <#
    .SYNOPSIS
        Automatically checks for the existence of a file property. Useful for checking registry.
    .NOTES
        Author: Bill Wilson
        Date 04/11/2024
    #>
  param (
    [string]$Path,
    [string]$PropertyName
  )
 ($null -ne (Get-ItemProperty -Path $Path).$PropertyName)
}
