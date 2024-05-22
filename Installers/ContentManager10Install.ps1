<#
.Synopsis
Content Manager 10 installer
.Description

.NOTES
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Created 22/05/2024
    
References;
    CM10.1_Install.pdf
    CM10.1_Updating_Using_MSPs.pdf
#>
$TrimVer = 10.1.5.1054
$TrimCheck = ((Get-ChildItem -Path C:\ -Filter 'Trim.exe' -Recurse -ErrorAction SilentlyContinue).FullName | Get-ItemProperty).VersionInfo.FileVersion

$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$InstallDir="$ProgramFiles\Micro Focus\Content Manager\"
$LnkDir="$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Content Manager"

<# --------------------------------
:: MSI specific switches
:: --------------------------------#>
$INSTALLMODE='/passive'
$RESTARTMODE='/norestart'

<# --------------------------------
:: Standard dataset details
:: --------------------------------
:: Are now located within the ClientDatasetConfig.xml file
#>

<# --------------------------------
:: Office integrations. Outlook is typically always left on while the rest depends on the 
:: organisation, hence the seperation.
:: Note: It is recommended to control these addons via Group Policy as this is by far
::	 the more reliable method. These settings have no certainty to work correctly.
:: --------------------------------#>
$OFFICEON=1
$OUTLOOKON=1

<# --------------------------------
:: Desktop Icons switch it's recommended to keep off (0). Leaving on (1) will result in 3 icons being 
:: placed on the desktop. It's better to install none and then utilise group policy to deploy an 
:: organisation specific icon.
:: --------------------------------#>
$DESKTOPICONS=0

<# --------------------------------
:: HPRMLINK defines which application is launched when you open the TR5 extension. 
:: TRIM = RM8 Client, DSK = RM8 Desktop
:: --------------------------------#>
$HPRMLINK='DSK'

if ($TrimCheck -lt 10) {
    #Install TRIM Core Software
    Start-Process -FilePath "%MSIinst%" -ArgumentList "/i `"$ScriptPath\CM_Client_x64.msi`" $INSTALLMODE $RESTARTMODE INSTALLDIR=`"$InstallDir`" TRIM_DSK=`"$DESKTOPICONS`" TRIMREF=`"$HPRMLINK`" WORD_ON=`"$OFFICEON`" EXCEL_ON=`"$OFFICEON`" POWERPOINT_ON=`"$OFFICEON`" PROJECT_ON=`"$OFFICEON`" OUTLOOK_ON=`"$OUTLOOKON`"" -Wait -NoNewWindow
}
elseif ($null -eq $TrimCheck) {
    #Install TRIM Core Software
    Start-Process -FilePath "%MSIinst%" -ArgumentList "/i `"$ScriptPath\CM_Client_x64.msi`" $INSTALLMODE $RESTARTMODE INSTALLDIR=`"$InstallDir`" TRIM_DSK=`"$DESKTOPICONS`" TRIMREF=`"$HPRMLINK`" WORD_ON=`"$OFFICEON`" EXCEL_ON=`"$OFFICEON`" POWERPOINT_ON=`"$OFFICEON`" PROJECT_ON=`"$OFFICEON`" OUTLOOK_ON=`"$OUTLOOKON`"" -Wait -NoNewWindow
}
elseif ($TrimCheck -le $TrimVer) {
    #Install TRIM Patch (if required)
    Start-Process -FilePath "%MSIinst%" -ArgumentList "/p `"$ScriptPath\Patch\CM_Client_x64.msp`" INSTALLDIR=`"$InstallDir`" /qb $RESTARTMODE" -Wait -NoNewWindow
}
elseif ($TrimCheck -ge $TrimVer) {
    Installed
    exit 0
}

Copy-Item -Path "$ScriptPath\CMClientConfig.xml" -Destination "$InstallDir\CMClientConfig.xml" -Force

#Remove Unwanted Shortcuts
Remove-Item -Path "$LnkDir\Content Manager*.lnk" -Exclude "*Desktop*","*User*" -

#END of installation
