function Remove-AppByRegEntry {
    param (
        [string] $AppName,
        [switch] $NoVisibility,
        [switch] $ForceRestart
    )
    $AppCheck = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' | Get-ItemProperty | Where-Object {$_.DisplayName -match $AppName } | Select-Object -Property DisplayName,UninstallString
    if ($NoVisibility) {
        $Vis = 'quiet' #No UI
    } else {
        $Vis = 'passive' #Basic UI
    }
    if ($ForceRestart) {
        $Restart = 'ForceRestart'
    } else {
        $Restart = 'NoRestart'
    }
foreach ($App in $AppCheck) {
    if (($App.UninstallString).EndsWith('}')) {
        $Uninst = $App.UninstallString
        $Uninst = (($Uninst -split ' ')[1] -replace '/I','/X') + " /$Vis /$Restart"
        Write-Output "Removing $($App.DisplayName)"
        Start-Process msiexec.exe -ArgumentList $Uninst -Wait -NoNewWindow
    }
}
}
