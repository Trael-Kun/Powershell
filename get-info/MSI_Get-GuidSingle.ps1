<#
.SYNOPSIS
    get an MSI GUID fast
.NOTES    
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   06/11/2024
    References;
        https://www.sapien.com/blog/2014/11/18/removing-objects-from-arrays-in-powershell/
        https://www.tutorialspoint.com/how-to-retrieve-the-msi-package-product-code-using-powershell
#>
param (
    [Parameter(Mandatory=$true,
        HelpMessage='Name of the program to search. Accepts * as a wildcard.')]
    [string]$Name,
    [Parameter(Mandatory=$false,
        HelpMessage='Switch to activate "Do You Want To Install" prompt for absent providers')]
    [switch]$Install
)
# create empty array
$ProviderNames = @()
# List providers you want to search, comment out unneeded
$Providers = (
    'msi',
    #'msu',
    'chocolatey',
    'nuget',
    'PowerShellGet',
    #'psl',
    'Programs'
)
# get installed providers
$ProviderList = (Get-PackageProvider).Name
# 
if ($Install) {
    $ProviderNames = $ProviderList
} else {
    $ProviderNames = $Providers | Where-Object { $_ -in $ProviderList }
}
Get-Package -ProviderName $ProviderNames -Name $Name | Select-Object -Property Name,Version,FastPackageReference
