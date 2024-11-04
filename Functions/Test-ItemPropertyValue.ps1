function Test-ItemPropertyValue {
  param (
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [string]$Name,
    [Parameter(Mandatory=$false)]
    [string]$Value,
    [switch]$Exist
  )
  if ($Exist) {
    ($null -ne (Get-ItemPropertyValue -Path $Path -Name $Name))
  } else {
    ((Get-ItemPropertyValue -Path $Path -Name $Name) -eq $Value)
  }
}
