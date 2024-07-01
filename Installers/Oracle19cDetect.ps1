function Write-Log {
    param (
        [string] $Msg
    )
    Write-Output "$Msg"
    Add-Content -Path $LogFile -Value "$(Get-Date) |    $Msg" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds $Sec
}
function Write-ErrorLog {
    param (
    [string]$Msg,
    [string]$Cat
)
Write-Error -Message "$Msg" -Category $Cat
Add-Content -Path $LogFile -Value "$(Get-Date) |    $Msg" -ErrorAction SilentlyContinue
Start-Sleep -Seconds $Sec
}
function Stop-Script {
    Write-Log "End Script"
    Add-Content -Path $LogFile -Value "###################" -ErrorAction SilentlyContinue
}
function Add-Checks {
    $Checks ++
}
function Write-Checks {
    Write-Log "$Checks/$CheckVerify checks successful"
}

$LogFile =      "$env:WinDir\Logs\Ora86Install.log"                 #Log file, duh
$OraDir =       "$env:SystemDrive\Oracle32\Product\19c\Client_1"    #Oracle install directory
$OraFile =      "$OraDir\network\admin\TNSNAMES.ORA"                #File to check
$OraHome =      'OraClient19Home1_32bit'                            #Oracle home name
$WowKey =       'HKLM:\SOFTWARE\WOW6432Node'                        #base reg key
$RegKey1 =      "$WowKey\ODBC\ODBC.INI"                             #1st regkey set to check
$RegKey2 =      "$WowKey\ORACLE\KEY_$OraHome"                       #2nd regkey set to check
$DSNs =         (                                                   #DSN names
                    'DSN1',
                    'DSN2',
                    'DSN3'
                )
$Paths =        (                                                   #further regkeys to check
                    "$RegKey1\$($DSNs[0])",
                    "$RegKey1\$($DSNs[1])",
                    "$RegKey1\$($DSNs[2])",
                    $OraFile
                )
$Sec =          0                                                   #sleep duration
$CheckVerify =  8                                                   #how many checks need to succeed

##Start Script
Write-Log "Start Script"

#Clear $Checks
$Checks =        0

#Look for DSNs
foreach ($DSN in $DSNs) {
    if (Get-OdbcDsn -Name $DSN -ErrorAction SilentlyContinue) {
        Write-Log "DSN `"$DSN`" found"
        $Checks ++
        Write-Checks
    } else {
        Write-Log "DSN `"$DSN`" not found"
        Write-Checks
    }
}

#Look for Paths
foreach ($Path in $Paths) {
    if ($Path) {
        Write-Log -Msg "Path `"$Path`" found"
        $Checks ++
        Write-Checks
    } else {
        Write-Log -Msg "Path `"$Path`" not found"
        Write-Checks
    }
}

#Look for Oracle Reg Key
if ((Get-ItemProperty -Path "$RegKey2" -Name 'ORACLE_HOME_NAME').ORACLE_HOME_NAME -eq "$OraHome") {
    Write-Log -Msg "Registry Key `"$RegKey2`" found"
    $Checks ++
    Write-Checks
} else {
    Write-Log -Msg "Registry Key `"$RegKey2`" not found"
    Write-Checks
}

#Confirm all checks complete
if ($Checks -eq $CheckVerify) {
    Start-Sleep -Seconds $Sec
    Write-Log -Msg "Oracle install complete ($Checks\$CheckVerify checks successful)"
    Stop-Script
    exit 0
} elseif ($Checks -gt $CheckVerify) {
    Write-ErrorLog -Msg "$Checks\$CheckVerify checks successful" -Cat InvalidResult
    Stop-Script
    exit 13
} elseif ($Checks -lt $CheckVerify) {
    Start-Sleep -Seconds $Sec
    Write-ErrorLog -Msg "Oracle install incomplete ($Checks\$CheckVerify checks successful)" -Cat NotInstalled
    Stop-Script
    exit 1603
}
