function Test-ItemPropertyValue {
  param (
    [string]$Path,
    [string]$Name,
    [string]$Value
  )
  ((Get-ItemPropertyValue -Path $Path -Name $Name) -eq $Value)
}
