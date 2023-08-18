$value = Get-ItemProperty -Path 'HKCU:\Software\Micro Focus\Content Manager\OfficeAddins'  -Name 'UseNativeUI'

if ($value -eq $null -or $value.UseNativeUI -ne 1) { exit 1 }

else { exit 0 }