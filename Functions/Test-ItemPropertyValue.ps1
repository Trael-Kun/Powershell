function Test-ItemPropertyValue {
  param (
    [string]$Path,
    [string]$Name,
    [string]$Value
  )
  if ((Get-ItemPropertyValue -Path $Path -Name $Name) -eq $Value) {
    Return $true
  } else {
    Return $false
  }
}
