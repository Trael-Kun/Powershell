function Get-MsiGuidFast {
    <#
        GUID Detection FAST
        Author: Bill Wilson (https://github.com/Trael-Kun)
        Date:   06/11/2024
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Guid
    )
    if (Get-Package -ProviderName msi | Where-Object{$_.FastPackageReference -eq $Guid}) {
        exit 0
    } else {
        exit 1
    }
}
