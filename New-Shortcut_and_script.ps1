<#
.SYNOPSIS
    Create shortcut & scripts for _rksadmin

.DESCRIPTION
    - Creates a script to display a user prompt for _TrimAdmin account
    - Creates VBS wrapper to suppress powershell window popups    
    - Creates a shortcut to the VBS on the user's desktop

.NOTES
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date: 06/06/2024

    -Replaces old shortcut from ; 
        (%WinDir%\System32\runas.exe /user:domain\%username%_TrimAdmin@naa.gov.au "%ProgramFiles%\Micro Focus\Content Manager\TRIM.exe")

.REFERENCES

#>

param (
    [switch] $Log
)

## Functions
function Write-Log {
    param (
        [string] $Msg
    )
    Write-Output "$Msg"
    if ($Log) {
        Add-Content -Path $LogFile -Value "$(Get-Date) |    $Msg"
        Start-Sleep -Seconds 1
    }
}

## Variables
$CmPath =                       "Micro Focus\Content Manager\TRIM.exe"
$ScriptsDir =                   "$env:ProgramData\Scripts"
$LogFile =                      "$ScriptsDir\Logs\TrimAdminScript.log"
$ScriptPath =                   "$ScriptsDir\RunAsTrimAdmin"
$ps1Path =                      "$ScriptPath\RunAsTrimAdmin.ps1"
$VbsPath =                      "$ScriptPath\RunAsTrimAdmin.vbs"
$LnkFile =                      'Trim Admin.lnk'
$StartMenu =                    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Content Manager"
$LnkPath =                      "$env:Public\Desktop"

# Check trim.exe location
if (Test-Path "$env:ProgramFiles\$CmPath") {
    $TrimPath =                 "$env:ProgramFiles\$CmPath"
} elseif (Test-Path "${env:ProgramFiles(x86)}\$CmPath") {
    $TrimPath =                 "${env:ProgramFiles(x86)}\$CmPath\TRIM.exe"
}
Write-Log -Msg "trim.exe path is $TrimPath"

if (!(Test-Path $ScriptPath)) {
    Write-Log -Msg "Creating $ps1Path"
    New-Item -Path $ScriptPath -ItemType Directory -Force
}
Write-Log -Msg "Creating $ps1Path"
######################
# start .ps1 Content #
######################
Set-Content -Path $ps1Path -Value '
<#
.SYNOPSIS
    Run Trim.exe as admin

.DESCRIPTION
    Checks for Content Manager install, then opens 
    a text box to allow password entry. The password 
    and username (pulled from the $env:UserName 
    variable, appended with _rksadmin) are then piped 
    to open trim.exe with the admin account.

.NOTES
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date: 06/06/2024
#>

## Variables
$Domain =                                       "domain"
$UserName =                                     "$Domain\$($env:UserName)_TrimAdmin@naa.gov.au"
$CmPath =                                       "Micro Focus\Content Manager\TRIM.exe"

#Check for .exe path
if (Test-Path "$env:ProgramFiles\$CmPath") {
    $ExePath =                                  "$env:ProgramFiles\$CmPath"
}
elseif (Test-Path "${env:ProgramFiles(x86)}\$CmPath") {
    $ExePath =                                  "${env:ProgramFiles(x86)}\$CmPath"
}

#Prep Dialogue Box
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Gets thems creds
function Show-CredentialsDialog {

    # Form box
    $form =                                     New-Object Windows.Forms.Form
    $form.Text =                                "Trim Admin Login"
    $form.Size =                                New-Object Drawing.Size(300,200)
    $form.StartPosition =                       "CenterScreen"

    # Password Labels
    $labelPassword =                            New-Object Windows.Forms.Label
    $labelPassword.Text =                       "Password:"
    $labelPassword.Size =                       New-Object Drawing.Size(260,20)
    $labelPassword.Location =                   New-Object Drawing.Point(10,40)
    $form.Controls.Add($labelPassword)

    # Password Entry Field
    $textBoxPassword =                          New-Object Windows.Forms.TextBox
    $textBoxPassword.Size =                     New-Object Drawing.Size(260,20)
    $textBoxPassword.Location =                 New-Object Drawing.Point(10,60)
    $textBoxPassword.UseSystemPasswordChar =    $true                           # Set to True to mask password
    $form.Controls.Add($textBoxPassword)
    
    # OK Button
    $buttonOK =                                 New-Object Windows.Forms.Button
    $buttonOK.Text =                            "OK"
    $buttonOK.Size =                            New-Object Drawing.Size(75,23)
    $buttonOK.Location =                        New-Object Drawing.Point(195,130)
    $buttonOK.DialogResult =                    [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($buttonOK)
    $form.AcceptButton =                        $buttonOK
    $result =                                   $form.ShowDialog()

    # If user enters data, set variables
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return @{ Username = $Username; Password = $textBoxPassword.Text }
    } else {
        return $null
    }
}

# Open Dialogue box
$credentials =                                  Show-CredentialsDialog
 
if ($null -ne $credentials) {
    Start-Process "$ExePath" -Credential (New-Object System.Management.Automation.PSCredential ($credentials.Username, (ConvertTo-SecureString $credentials.Password -AsPlainText -Force))) -NoNewWindow
}
' -Force
######################
#  end .ps1 Content  #
######################

Write-Log -Msg "Creating $VbsPath"
######################
#  start VBS Wrapper #
######################
Set-Content -Path $VbsPath -Value '
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell -WindowStyle Hidden -File ""%ProgramData%\Scripts\RunAsTrimAdmin\RunAsTrimAdmin.ps1""", 0
Set objShell = Nothing
' -Force
######################
#   end VBS Wrapper  #
######################

Write-Log -Msg "Creating $LnkPath"
######################
#   start Shortcut   #
######################
$LnkDirs =                      ($LnkPath,$StartMenu)
foreach ($Path in $LnkDirs) {
    $WshShell =                 New-Object -ComObject WScript.Shell
    $Lnk =                      $WshShell.CreateShortcut("$Path\$LnkFile")
    $Lnk.TargetPath =           $VbsPath
    $Lnk.IconLocation =         $TrimPath
    $Lnk.Save()
}

######################
#   end  Shortcut    #
######################

Write-Log -Msg "Script Finished"
