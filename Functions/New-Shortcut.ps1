function New-Shortcut {
    param (
        [string] $LnkPath,                                              # Folder for new shortcut
        [string] $LnkFile,                                              # Filename for new shortcut, ending in .lnk
        [string] $LnkTarget,                                            # What the shortcut takes you to
        [string] $LnkIcon                                               # Icon for the shortcut, if different to the default
    )
    if ($LnkFile -notmatch '.lnk$') {                                   # check FileName for .lnk filetype
        $LnkFile +='.lnk'                                               # if not, add it
    }
    $Path               = Join-Path -Path $LnkPath -ChildPath $LnkFile  # join path & filename for shortcut
    $WshShell           = New-Object -ComObject WScript.Shell           # create shortcut object
    $Lnk                = $WshShell.CreateShortcut("$Path")             # set .lnk path
    $Lnk.TargetPath     = $LnkTarget                                    # set target
    if ($null -ne $LnkIcon) {                                           # if LnkIcon has a value
        $Lnk.IconLocation   = $LnkIcon                                  # set icon
    }
    $Lnk.Save()                                                         # create shortcut
}
