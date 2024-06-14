param (
    [string]$Licence,                                                                                                  #licence code
    [string]$Config,                                                                                                   #COPY to copy files, SET to set content, or $null to attempt copy then set
    [string]$LogFile,                                                                                                  #logfile location override
    [switch]$NoCR,                                                                                                     #don't install CrystalReports (if deployed as prereq)
    [switch]$Log                                                                                                       #logging on
)

function Write-Log {
    param (
        [string] $Msg
    )
    Write-Output "$Msg"
    if ($Log) {
        Add-Content -Path $LogFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss:fff') |    $Msg"
        Start-Sleep -Seconds 1
    }
}

#Variables
$LogDir =               "$env:WinDir\Logs\KeySecure"                                                                    #path to logs
if (!(Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force
    Write-Log "$LogDir created"
}
if (!($LogFile))        {$LogFile = "$LogDir\KeySecurePwsh.log" }                                                       #name of log file
Start-Transcript -Path "$LogDir\KeySecurePwsh.log" -Append -Force -IncludeInvocationHeader -Verbose
$ScriptPath =           split-path -parent $MyInvocation.MyCommand.Definition                                           #Parent directory
#Preinstall
$SetupDir =             "$ScriptPath\Setup"                                                                             #path to setup files
$KsSetup =              "$SetupDir\Setup.exe"                                                                           #Keysecure install exe
$KsVer =                '1.3.5.2e'                                                                                      #KeySecure Version
$CicDir =               'CIC Technology\KeySecure'                                                                      #child path of KeySecure install
$TargetDir =            "$env:ProgramFiles\$CicDir"                                                                     #Keysecure install path
if (!($NoCR)) {
    $CrMsi =            (Get-ChildItem -Path "$($SetupDir)\Crystal Reports for .NET Framework 4.0" -Filter "*.msi")     #Seach for CrystalReports install file, because I'm too lazy to type the whole string
    $CrSetup =          $CrMsi.VersionInfo.Filename                                                                     #CrystalReports install file
    $CrVer =            '13.0.5.891'                                                                                    #CrystalReports Version
}
#Post-Install
$ConfigDir =            "$ScriptPath\Config"                                                                            #path to config files to be copied
$LnkDir =               "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"                                        #StartMenu path
$CicLnk =               "$LnkDir\CIC Technology"

if ($Log) {
    Write-Log "Script Path is $ScriptPath"
    Write-Log "Logging to $LogFile"
    if (!($NoCR)) { Write-Log "Crystal Reports Setup is $CrSetup"}
    Write-Log "KeySecure Setup file is is $KsSetup"
    Write-Log "Target path is $TargetDir"
}

##Start Script

#Install Crystal Reports
if (!($NoCR)) {
    Write-Log -Msg "Installing Crystal Reports $CrVer for .NET Framework 4.0"
    Write-Log "MsiExec.exe /i `"$CrSetup`" /qn /norestart /L* `"$LogDir\CrystalReports$CrVer.log`""
    Start-Process -FilePath 'MsiExec.exe' -ArgumentList "/i `"$CrSetup`" /qn /norestart /L* `"$LogDir\CrystalReports$CrVer.log`"" -Wait -NoNewWindow
}

#Install Client Only KeySafe With License
Write-Log -Msg "Installing KeySecure $KsVer to $TargetDir"
Write-Log "$KsSetup /qb /norestart /L* `"$LogDir\KeySecure$KsVer.log`" PIDKEY=*****-*****-*****-*****-***** INSTALLCLIENTSERVER=$false TARGETDIR=`"$TargetDir`""
Start-Process -FilePath "$KsSetup" -ArgumentList "/qb /norestart /L* `"$LogDir\KeySecure$KsVer.log`" PIDKEY=$LICENCE INSTALLCLIENTSERVER=$false TARGETDIR=`"$TargetDir`"" -Wait -NoNewWindow

##Copy Config
Write-Log -Msg 'Applying Configuration'
#Check where it's installed
if (Test-Path "$TargetDir") {
    $KsDir =            "$TargetDir"
} elseif (Test-Path "$env:SystemDrive\$CicDir") {
    $KsDir =            "$env:SystemDrive\$CicDir"
} elseif (Test-Path "$env:LocalAppData\$CicDir") {
    $KsDir =            "$env:LocalAppData\$CicDir"
} elseif (Test-Path "${env:ProgramFiles(x86)}\$CicDir") {
    $KsDir =            "${env:ProgramFiles(x86)}\$CicDir"
} elseif (Test-Path "$env:ProgramFiles\$CicDir") {
    $KsDir =            "$env:ProgramFiles\$CicDir"
} else {
    Write-Log -Msg "Unable to locate KeySecure install"
    exit 1
}

if ($KsDir -ne $TargetDir) {
    Write-Log "Install path $KsDir, NOT $TargetDir"
    Write-Warning "Install path is NOT $TargetDir"
} else {
    Write-Log -Msg "Install Directory is $KsDir"
}

if ($Config -ne 'COPY' -or $Config -ne 'SET') {                                                                         #do both
    #Copy files
    Write-Log -Msg "Copying config files to $KsDir"
    $Configurations =   Get-ChildItem -Path $ConfigDir -Filter "*.Config"
    foreach ($Configuration in $Configurations) {
        Write-Log -Msg "Copying $KsDir\$($Configuration.Name)"
        Copy-Item -Path "$($Configuration.FullName)" -Destination $KsDir -Force
        #if (!(Test-Path -Path "$KsDir\CICSynchronisationService.exe.config")) {
        foreach ($Configuration in $Configurations) {
            if (Get-FileHash -Path "$(($Configuration.Fullname).hash)" -ne (Get-FileHash -Path "$KsDir\$(($Configuration.Name).hash)")) {
                Write-Log -Msg "Setting configuration for $KsDir\$($Configuration.Name)"
                Get-Content -Path "$($Configuration.Fullname)" | Set-Content -Path "$KsDir\$($Configuration.Name)"
            }
        }
    }
} elseif ($Config -eq 'COPY') {                                                                                         #copy files
    Write-Log -Msg "Copying config files to $KsDir"
    Get-ChildItem -Path $ConfigDir -Filter "*.config" | Copy-Item -Destination $KsDir -Force
} elseif ($Config -eq 'SET') {                                                                                          #set content
    $Configurations =   Get-ChildItem -Path $ConfigDir -Filter "*.Config"
    foreach ($Configuration in $Configurations) {
        Write-Log -Msg "Setting configuration for $KsDir\$($Configuration.Name)"
        Get-Content -Path "$($Configuration.Fullname)" | Set-Content -Path "$KsDir\$($Configuration.Name)"
    }
}

Write-Log -Msg 'Script finished'
Stop-Transcript
#End Script
