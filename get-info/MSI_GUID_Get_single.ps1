<#
    get an MSI GUID fast
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   06/11/2024
#>
param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )
$Providers = ('msi',
    #'msu',
    #'chocolatey',
    #'nuget",
    'PowerShellGet',
    'psl',
    'Programs')
(Get-Package -ProviderName msi,Programs,chocolatey,nuget -Name $Name).FastPackageReference
