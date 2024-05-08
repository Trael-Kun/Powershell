function New-Shortcut {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Target,
        [string]$File
    )
    $WshShell = New-Object -ComObject WScript.Shell
    $Lnk = $WshShell.CreateShortcut("$File")
    $Lnk.TargetPath = $Target
    $Lnk.Save()
}
