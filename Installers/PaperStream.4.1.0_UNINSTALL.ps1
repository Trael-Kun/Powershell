# Uninstall PStream
# Written by Bill Wilson (https://github.com/Trael-Kun) 02/09/24 
#https://www.reddit.com/r/PowerShell/comments/f6auww/find_uninstall_string_from_program_name/
function Remove-AppByRegEntry {
    param (
        [string] $AppName,
        [switch] $NoVisibility
    )
    if ($NoVisibility) {
        $Vis = 'qn'
    } else {
        $Vis = 'qb'
    }
    $AppCheck = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match $AppName } | Select-Object -Property DisplayName,UninstallString
foreach ($App in $AppCheck) {
    if (($App.UninstallString).EndsWith('}')) {
        $Uninst = $App.UninstallString
        $Uninst = (($Uninst -split ' ')[1] -replace '/I','/X') + " /$Vis"
        Start-Process msiexec.exe -ArgumentList $Uninst -Wait -NoNewWindow
    }
}
}
$Processes = (Get-Process -Name PFU*).ProcessName
foreach ($Process in $Processes) {
    Stop-Process -Name $Process -Force
}
Remove-AppByRegEntry -AppName PaperStream
$PscRmvExe = "$env:windir\PaperStreamCaptureUninstall.exe"
if (Test-Path $PscRmvExe) {
    Write-Host 'Removing PaperStream Capture'
    Start-Process -FilePath $PscRmvExe -Wait
}
Write-Host 'Removing Software Operation Panel'
Remove-AppByRegEntry -AppName 'Software Operation Panel' -NoVisibility
