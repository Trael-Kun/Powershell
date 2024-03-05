New-Item -Path "HKCU:\Software\Micro Focus\Content Manager" -Name OfficeAddins -Force
New-ItemProperty -Path "HKCU:\Software\Micro Focus\Content Manager\OfficeAddins" -Name UseNativeUI -PropertyType DWord -Value 1
