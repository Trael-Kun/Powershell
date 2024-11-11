# define app detection keys
$UninstallRegx86    = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
$UninstallRegx64    = $UninstallRegx86.Replace('\Wow6432Node','')
$OfficeKey1         = Test-Path -path "$UninstallRegx64\ProPlus2021Volume - en-us"
$officeKey2         = Test-path -path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
$projectKey         = Test-path -path "$UninstallRegx64\ProjectPro2021Volume - en-us"
$visioKey           = Test-path -path "$UninstallRegx64\VisioPro2021Volume - en-us"
$LyncKey            = Test-path -path "HKLM:\SOFTWARE\Microsoft\Office\16.0\Lync\InstallRoot"
# Check architecture version
$Platform           = Get-ItemPropertyValue -path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration\" -name Platform
# Check correct architecture
$Arch               = if ($Platform -eq "x64") {$True}

#Check office reg keys exist and Lync/Project/Visio does not
if ($officeKey1 -and $officekey2 -and $Arch -and !($projectKey) -and !($visioKey) -and !($LyncKey)) {
    "Installed"
} else {
    ""
}
