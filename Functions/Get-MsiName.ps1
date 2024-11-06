function Get-MsiName {
    <#
        Find installs per name
        Author: Bill Wilson (https://github.com/Trael-Kun)
        Date:   06/11/2024
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )
    if (Get-CimInstance -Class win32_product | Where-Object{$_.Name -eq $Name}) {
        exit 0
    } else {
        exit 1
    }
}
