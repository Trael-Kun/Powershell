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
foreach ($Provider in $Providers) {
    if ($Provider -in $ProviderList) {
        $ProviderNames = $ProviderNames += $Provider
    }
}
Get-Package -ProviderName $ProviderNames -Name $Name | Select-Object -Property Name,Version,FastPackageReference
