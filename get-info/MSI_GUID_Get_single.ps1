<#
    get an MSI GUID fast
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   06/11/2024
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$Name
)
$ProviderNames = @()
$Providers = (
    'msi',
    'msu',
    'chocolatey',
    'nuget',
    'PowerShellGet',
    'psl',
    'Programs'
)
$ProviderList = (Get-PackageProvider).Name
$ProviderNames = $Providers | Where-Object { $_ -in $ProviderList }
Get-Package -ProviderName $ProviderNames -Name $Name | Select-Object -Property Name,Version,FastPackageReference
