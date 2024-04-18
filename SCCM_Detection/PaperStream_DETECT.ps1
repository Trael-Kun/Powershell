##Variables
#CurrentVersion
$PsNew = 4.0.0.10
$SopNew = 4.32.0.6
$TwainNew = 3.30.0.1314
#AppNames
$PsApp = 'PaperStream Capture'
$SopApp = 'Software Operation Panel'
$TwainApp = 'PaperStream IP (TWAIN)'
#Paths
$Regpaths = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
#Reg Entries
$PStream = Get-ChildItem $Regpaths | Where-Object { $_.GetValue('DisplayName') -eq $PsApp } | Select-Object -First 1
$SOP = Get-ChildItem $Regpaths | Where-Object { $_.GetValue('DisplayName') -eq $SopApp }
$ChooChoo = Get-ChildItem $Regpaths | Where-Object { $_.GetValue('DisplayName') -eq $TwainApp }
#Versions
$PsVer = Get-ItemProperty -Path Registry::$($PStream.Name)
$SOPVER = Get-ItemProperty -Path Registry::$($SOP.Name)
$TwainVer = Get-ItemProperty -Path Registry::$($ChooChoo.Name)

if ($PsVer -eq $PsNew) {
    if ($SopVer -eq $SopNew) {
        if ($TwainVer -eq $TwainNew) {
            Write-Host 'Installed'
            exit 0
        }
    }
} else {
    Write-Host 'Failed'
    exit 1
}
