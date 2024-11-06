<#
        Get MSI GUID FAST
        Author: Bill Wilson (https://github.com/Trael-Kun)
        Date:   06/11/2024
#>
Get-Package -ProviderName msi,programs | Select Name, Version, FastPackageReference
