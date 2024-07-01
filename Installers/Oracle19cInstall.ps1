
<#
Oracle Client 19c 32-bit install
.SYNOPSIS
Installs Oracle 19c (x86)
.DESCRIPTION
Process as follows;
    - Removes any pre-existing temp files
    - Unzips Oracle 19c Custom Installer to temp files
    - Runs installer (with waitloop)
        - If waitloop fails, removes temp files
    - Removes uneeded links
    - copies across .ora config files
    - Removes potential duplicat DSNs
    - Adds required DSNs
    - Copies across Uninstall files
    - Removes temp files
.NOTES
Author: Bill Wilson
Created: 12/04/2024

16/04/24    Added step to remove existing OraTemp (if previous install fails, tempfiles are not deleted)
16/05/24    Added .ora Get-Content\Set-Content for robustness

The waitloop section was developed in my batch file version, as 
the Oracle client installer opens one process, then almost 
immediately begins a second one. The closing of the first process 
kicked the script on without waiting for the install to complete, 
so by pointing to a log file and waiting for it to say "I'm done" 
it keeps the whole thing ticking along.

I felt very clever when I found that log file.

#>

param(
    [switch] $Log
)

function Write-Log {
    param (
        [string] $Msg
    )
    Write-Output "$Msg"
    if ($Log) {
        Add-Content -Path $LogFile -Value "$(Get-Date) |    $Msg"
        Start-Sleep -Seconds $Sec
    }
}

function Remove-OraTemp {
    Remove-Item -Path $OraTemp -Recurse -Force
}

Start-Transcript -Path "$env:WinDir\Logs\OracleInstallTranscript.log" -Append -Force

# Directories & Files
$ScriptPath =   split-path -parent $MyInvocation.MyCommand.Definition
$LnkDir =       "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$LogFile =      "$env:WinDir\Logs\Ora86Install.log"
$OraHome =      "$env:SystemDrive\Oracle32\Product\19c\Client_1"
$OraTemp =      "$env:programdata\Ora86"
$Setup =        "$OraTemp\Setup.exe"
$RSP =          "$OraTemp\Custom_client32.rsp"
$DotOraSrc =    "$OraTemp\Network\Admin"
$DotOraDest =   "$OraHome\Network\Admin"
$DotOraTNS =    'TNSNAMES.ORA'
$DotOraSql =    'sqlnet.ora'
$Zip =          "Oracle19cx86.zip"

# ODBC driver
$ODBCDrv =      'Oracle in OraClient19Home1_32bit'
$DsnType =      'System'
$DSNs =          ('DNS3','DSN2','DSN3')
# 32/64-bit
$Platform =     '32-bit'
# Waitloop variables
$LogDir =       "${env:ProgramFiles(x86)}\Oracle\Inventory\logs"
$LogFileShh =   "silentInstall*.log"
$LogFileInst =  "installActions*.log"
$LogText =      '*The installation of Oracle Client 19c was successful.*'
$Sec =          1
$Count =        1800

##START SCRIPT
Write-Log "Start Script"

if (Test-Path $OraTemp) {                           #Check for outdated install files
    #Delete Temp Files
    Write-Log -Msg "Clearing old install files"
    Remove-OraTemp
}

if (Test-Path $OraHome) {                           # If there's existing .bak files, Oracle installer will fail
    Write-Log -Msg "Cleaning up .bak files"
    $Baks = Get-ChildItem -Path $OraHome -Filter ".bak"
    foreach ($Bak in $Baks) {
        Write-Log -Msg "Removing $Bak"
        Remove-Item -Path $Bak.Fullname -Force
    }
}

# Unzip installer
Write-Log -Msg "Unzipping installer"
Expand-Archive -Path "$ScriptPath\$Zip" -DestinationPath $OraTemp -Force
# Start install
Write-Log -Msg "Starting Installer"
Start-Process -FilePath $Setup -Wait -ArgumentList "-Silent","-NoConfig","-NoWait","-ResponseFile $RSP" -WindowStyle Hidden
Start-Sleep 10

:Countdown while ($Count -ge 0) {                   # wait for install to complete - detects on logfile (LogShh)
    $LogCheck = Get-ChildItem -Path $LogDir -Filter $LogFileShh | Get-Content
    if ($LogCheck -notlike $LogText) {              # does the logfile contain the text?
        $Count--
        Start-Sleep -Seconds $Sec
        Write-Host $Count
    }
    elseif ($LogCheck -like $LogText) {
        Write-Log -Msg $LogText.Replace('*','')
        break Countdown
    }
}
if ($Count -le 0) {                                 # if countdown runs out, install failed
    Write-Log -Msg "Install has timed out"
    Write-Log -Msg "Removing install files"
    Remove-OraTemp
    exit 1
}

#Add the install log content to our log
Write-Log "Transferring Oracle install log contents"
Add-Content -Path $LogFile -Value "####### Start OraLog Contents"
Start-Sleep -Seconds $Sec
Get-ChildItem -Path $LogDir -Filter $LogFileInst | Get-Content | Add-Content -Path $LogFile
Start-Sleep -Seconds $Sec
Add-Content -Path $LogFile -Value "####### End OraLog Contents"
Start-Sleep -Seconds $Sec

# Copy .ORA config files
Write-Log -Msg "Copying .ora files"
Copy-Item -Path $DotOraSrc -Filter "*.ora" -Destination $DotOraDest -Force
if (!(Test-Path -Path DotOraDest\TNSNAMES.ORA)) {   #did the copy work? If not, let's create new files with the correct content. 
    Write-Log ".ora file copy failed."
    $TnsNames = Get-Content -Path "$DotOraSrc\$DotOraTNS"
    Write-Log -Msg "Creating $DotOraTNS"
    New-Item -Path "$DotOraDest\$DotOraTNS" -Value $TNSNAMES -ItemType File -Force
    $SqlNet =   Get-Content -Path "$DotOraSrc\$DotOraSql"
    Write-Log -Msg "Creating $DotOraSql"
    New-Item -Path "$DotOraDest\$DotOraSql" -Value $SqlNet -ItemType File -Force
}

# Remove existing DSNs
Write-Log -Msg "Checking for existing DSNs"
foreach ($DSN in $DSNs) {
    if (Get-OdbcDsn -Name $DSN -ErrorAction SilentlyContinue) {
        Write-Log "Removing $DSN"
        Remove-OdbcDsn -Name $DSN   -DsnType $DsnType -Platform $Platform -ErrorAction Continue
    }
}

# Add new DSNs
Write-Log -Msg "Adding new DSNs"
Write-Log "Adding $($DSNs[0])"
Add-OdbcDsn -Name $DSNs[0]  -DriverName $ODBCDrv        -DsnType $DsnType -Platform "$Platform" -SetPropertyValue @("Server=SERVER1")
Write-Log "Adding $($DSNs[1])"
Add-OdbcDsn -Name $DSNs[1]  -DriverName $ODBCDrv        -DsnType $DsnType -Platform "$Platform" -SetPropertyValue @("Server=SERVER1")
Write-Log "Adding $($DSNs[2])"
Add-OdbcDsn -Name $DSNs[2]  -DriverName 'Driver2'    -DsnType $DsnType -Platform "$Platform" -SetPropertyValue @("Server=SERVER2", "Database=DB1")

# Copy deinstall files
Write-Log -Msg "Copying deinstallation files"
Copy-Item -Path "$OraTemp\deinstall*" -Destination "$OraHome\deinstall" -Force

# delete Start Menu links
Write-Log -Msg "Removing unrequired shortcuts"
Get-ChildItem -Path $LnkDir -Filter "Oracle -*" | Remove-Item -Recurse -Force

# Delete Temp Files
Write-Log -Msg "Clearing old install files"
Remove-OraTemp

Write-Log -Msg "Script End"
Add-Content -Path $LogFile -Value "########################################"
Stop-Transcript
##END SCRIPT
