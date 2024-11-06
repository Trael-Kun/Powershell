function Get-MsiVendor {
    <#
        Find installs per vendor
        Author: Bill Wilson (https://github.com/Trael-Kun)
        Date:   06/11/2024
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Vendor
    )
    if (Get-CimInstance -Class win32_product | Where-Object{$_.Vendor -eq $Vendor}) {
        exit 0
    } else {
        exit 1
    }
}
