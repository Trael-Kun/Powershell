#set variables
$Bios = Get-WmiObject win32_bios
$CurrentVer = '1.20.1'

#Compare installed BIOS ver to Current BIOS Ver
        if ($bios.SMBIOSBIOSVersion -ge $CurrentVer) {
            $IsCurrent = 'Installed'
        }
        else {
        }
write-host $IsCurrent