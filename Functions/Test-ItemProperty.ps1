function Test-ItemProperty {
  param (
    [string]$Path,
    [string]$PropertyName
  )
 ($null -ne (Get-ItemProperty -Path $Path).$Property)
}
