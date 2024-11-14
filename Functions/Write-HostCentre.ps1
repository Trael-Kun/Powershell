function Write-HostCenter {
    <#
    .SYNOPSIS
        Writes text on the centre of the window
    .NOTES
        Author: Not Bill
        References:
            https://stackoverflow.com/questions/48621267/is-there-a-way-to-center-text-in-powershell
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message
    ) 
    Write-Host (
        "{0}{1}" -f (
            ' ' * (
                (
                    [Math]::Max(
                            0, $Host.UI.RawUI.BufferSize.Width / 2
                        ) - [Math]::Floor(
                        $Message.Length / 2
                    )
                )
            )
        ), $Message
    ) 
}
