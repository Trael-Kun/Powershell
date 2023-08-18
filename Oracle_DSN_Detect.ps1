<#
ODBC DSN Detection
.SYNOPSIS
Detects missing ODBC DSNs
.NOTES
Author: Bill Wilson
Created: 05/06/2023
Last Edit: 06/06/2023

References:
https://learn.microsoft.com/en-us/powershell/module/wdac/get-odbcdriver?view=windowsserver2022-ps
https://stackoverflow.com/questions/38313529/how-do-i-check-if-all-the-returned-values-are-true/38313607#38313607
#>

##Set Variables
# DSNs
$Dsn1 = 'DSN1'
$Dsn2 = 'DSN2_SQL'
$Dsn3 = 'DSN3'
$Server1 = 'Server01'
$Server2 = 'Server02'
$Server3 = 'Server03'
$OraHome = 'Oracle in OraClient19Home1_32bit'
$SqlSrv = 'SQL Server'
# Other Settings
$DsnType = 'System'
$Platform = '32-bit'

#Get DSN info
$DSNs= Get-OdbcDsn -DsnType $DsnType -Platform $Platform | Select-Object -Property Name,DriverName,Platform,DsnType,Status

#Query ODBC DSN Names
foreach ($DSN in $DSNs) {
    if ($DSN.name -eq $Dsn1) {
        $DSN.Status = $True
    }
    elseif ($DSN.name -eq $Dsn2) {
        $DSN.Status = $True
    }
    elseif ($DSN.name -eq $Dsn3) {
        $DSN.Status = $True
    }
    else {
    }
}

#If missing DSN Entrie, check further
if ($DSNs.Status -contains $NULL) {
    #Set Variables
    ##Reg Variables
    $RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\OracleRemExecServiceV2'
    $RegName = 'DisplayName'
    $RegTest = Get-ItemProperty -Path $RegPath -Name $RegName
    ##TNSANMES Variables
    $OraPath = "$env:SystemDrive\Oracle32\Product\19c\Client_1\network\admin\TNSNAMES.ORA"
    $OraTest = Select-String -Path "$OraPath" -pattern 'company.int'

    #Check for Reg Key
    if ($RegTest.DisplayName -eq 'OracleRemExecServiceV2') {
        Write-host "Registry Key found"
        $RegVal = $True
    }
    else {
        Write-Host 'ERROR: Registry Key not found' -ForegroundColor Red
        $RegVal = $False
    }

    #Check for correct TNSNAMES.ORA file
    if ($null -ne $OraTest) {
        Write-Host "TNSNAMES.ORA verified"
        $19c = $true
    }
    elseif (Test-Path $OraPath) {
        Write-Host "ERROR: Incorrect TSNAMES.ORA file" -ForegroundColor Red
        $19c = $false
    }
    else {
        Write-Host  "ERROR: Oracle 19 not installed" -ForegroundColor Red
        $19c = $null
    }

    #Spacer
    Write-Host ""

    # Final Output
    if (($19c -eq $true) -and ($RegVal -eq $true)) {
        Write-Host "ERROR: ODBC DNS missing" -ForegroundColor Red
        Write-Host "Adding ODBC DNS entries..." -ForegroundColor Green
        Add-OdbcDsn -Name $Dsn1 -DriverName $OraHome -DsnType $DsnType -Platform $Platform -SetPropertyValue @("Server=$Server1") -ErrorAction SilentlyContinue
        Add-OdbcDsn -Name $Dsn2 -DriverName $SqlSrv -DsnType $DsnType -Platform $Platform -SetPropertyValue @("Server=$Server2", "Database=DB1") -ErrorAction SilentlyContinue
        Add-OdbcDsn -Name $Dsn3 -DriverName $OraHome -DsnType $DsnType -Platform $Platform -SetPropertyValue @("Server=$Server3") -ErrorAction SilentlyContinue
        Write-Host "DNS Entries added - please run script again"
    }
    elseif (($19c -eq $true) -and ($RegVal -eq $false)) {
        Write-Host "ERROR: Oracle not installed" -ForegroundColor Red
        Write-Host "Check Oracle install"
    }
    elseif (($null -eq $19c) -and ($RegVal -eq $false)) {
        Write-Host "ERROR: Oracle not installed" -ForegroundColor Red
        Write-Host "Please install Oracle"
    }
    elseif (($19 -eq $false) -and ($RegVal -eq $true)) {
        Write-Host "ERROR: Oracle not installed" -ForegroundColor Red
        Write-Host "Check TSNAMES.ORA"
        }
        else {
        }
}
else {
    Write-Host "Oracle Installed" -ForegroundColor Green
}
