# Kiosk User Force-apply
$PublicUser		= 'KioskUser0'  #intune
$FullName		= 'Public User'
try {	#create User
    New-LocalUser -Name $PublicUser -FullName $FullName -NoPassword -PasswordNeverExpires -UserMayNotChangePassword -AccountNeverExpires
}
catch {	#if powershell does not have the LocalUser module
    cmd /c "net user $PublicUser /expires:never /fullname:$FullName /passwordreq:no /passwordchg:no /times:M-Su,5:00-23:00 /add"
}
#get user SID
$SID	= (Get-WmiObject win32_useraccount | Select-Object name,sid | Where-Object name -match $PublicUser).sid


<#########
RegEdit
##########>
$HKCU			= "Registry::hku\$SID\SOFTWARE"
$HKLM			= 'HKLM:\SOFTWARE'
$CurrentVersion		= 'Microsoft\Windows\CurrentVersion'
$NtCurrentVersion	= 'Microsoft\Windows NT\CurrentVersion'
$Policies		= 'Policies\Microsoft'

# Settings page lockdown (Ease of Access)
# Ease of Access is Accessibility; https://learn.microsoft.com/en-us/windows/uwp/launch-resume/launch-settings-app#ease-of-access
# I've split these up to make them easier to read.
$Settings1			= 'about;dateandtime;windowsupdate'
$EaseOfAccess1		= 'easeofaccess-audio;easeofaccess-closedcaptioning;easeofaccess-highcontrast;easeofaccess-display;easeofaccess-keyboard;easeofaccess-magnifier'
$EaseOfAccess2		= 'easeofaccess-mouse;easeofaccess-mousepointer;easeofaccess-narrator;easeofaccess-speechrecognition;easeofaccess-cursor;easeofaccess-visualeffects'
$AllowSettingsPages	= "showonly:$Settings1;$EaseOfAccess1;$EaseOfAccess2"

$RegEdits = @(
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\PasswordLess\Device"; 						Property="DevicePasswordLessBuildVersion";	Type='DWord';	Value=1				}	#autologin https://learn.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\Winlogon"; 							Property='AutoAdminLogon';			Type='DWord';	Value=1				}	#autologin https://learn.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\Winlogon"; 							Property='DefaultUserName';			Type='string';	Value=$PublicUser		}	#autologin https://learn.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\Winlogon"; 							Property='DefaultPassword';			Type='string';	Value=''			}	#autologin https://learn.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\Winlogon"; 							Property='AutoLogonSID';			Type='string';	Value=$SID			}	#autologin https://learn.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\Winlogon";	 						Property='LastUsedUsername';			Type='string';	Value=$PublicUser		}	#autologin https://learn.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\Winlogon"; 							Property='EnableFirstLogonAnimation';		Type='DWord';	Value=0				}	
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\Winlogon"; 							Property='DisableLockWorkstation';		Type='DWord';	Value=0				}	
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\Policies\System"; 						Property='dontdisplaylastusername';		Type='DWord';	Value=1				}	#autologin https://learn.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
	@{Action='Add';		Path="$HKLM\$NtCurrentVersion\Policies\System"; 						Property='NoConnectedUser';			Type='DWord';	Value=1				}	#block MS accounts https://www.tenforums.com/tutorials/97556-allow-block-microsoft-accounts-windows-10-a.html
#	@{Action='Add';		Path="$HKLM\Microsoft\PolicyManager\default\Settings\AllowYourAccount";	 			Property='value';				Type='DWord';	Value=0				}	#grey out MS login in settings
#	@{Action='Add';		Path="$HKLM\Microsoft\PolicyManager\default\Settings\AllowWorkplace"; 				Property='value';				Type='DWord';	Value=0				}	#grey out MS login in settings
	@{Action='Add';		Path="$HKLM\$Policies\Windows\WindowsCopilot"; 							Property='TurnOffWindowsCopilot';		Type='DWord';	Value=1				} 	#Disable Windows Copilot https://medium.com/@dbilanoski/how-to-tuesdays-getting-rid-of-that-pesky-windows-copilot-feature-everybody-is-getting-these-days-923df14c3345
    	@{Action='Add';		Path="$HKLM\$Policies\Windows\Windows Search"; 							Property='EnableDynamicContentInWSB';		Type='DWord';	Value=0				} 	#Disable Disable Copilot Search Bar https://medium.com/@dbilanoski/how-to-tuesdays-getting-rid-of-that-pesky-windows-copilot-feature-everybody-is-getting-these-days-923df14c3345
	@{Action='Add';		Path="$HKLM\$Policies\Edge"; 									Property='HubsSidebarEnabled';			Type='DWord';	Value=0				} 	#Disable Copilot Edge Side Application https://medium.com/@dbilanoski/how-to-tuesdays-getting-rid-of-that-pesky-windows-copilot-feature-everybody-is-getting-these-days-923df14c3345
	@{Action='Add';		Path="$HKLM\$Policies\WindowsStore";	 							Property='RequirePrivateStoreOnly';		Type='DWord';	Value=1				}	#disable Store https://cloudinfra.net/block-microsoft-store-apps-using-intune-except-winget/
	@{Action='Add';		Path="$HKLM\$Policies\Windows Defender Security Center\Systray";	 			Property='HideSystray';				Type='DWord';	Value=1				}	#hide Windows Security https://www.elevenforum.com/t/add-or-remove-windows-security-notification-icon-in-windows-11.7800/#Four
#	@{Action='Add';		Path="$HKLM\$CurrentVersion\Policies"; 								Property='SettingsPageVisibility';		Type='string';	Value=$AllowSettingsPages	}	#System Settings menu restrictions; https://www.windowscentral.com/how-hide-specific-settings-pages-windows-11#hide_settings_regedit_windows11
	@{Action='Add';		Path="$HKLM\$CurrentVersion\Policies\System"; 							Property='NoConnectedUser';			Type='DWord';	Value=3				}	#block MS accounts https://www.tenforums.com/tutorials/97556-allow-block-microsoft-accounts-windows-10-a.html
	@{Action='Add';		Path="$HKLM\$CurrentVersion\Policies\System"; 							Property='DefaultLogonDomain';			Type='string';	Value=$env:ComputerName		}	#default domain to local https://admx.help/?Category=Windows_10_2016&Policy=Microsoft.Policies.CredentialProviders::DefaultLogonDomain
	@{Action='Remove';	Path="$HKLM\$CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}";	Property=$null;					Type=$null;	Value=$null			}	#remove "Gallery" (can be used to open Store) https://gist.github.com/docentYT/1ae471f3c5a1cfdf52e717eaf150508d
	@{Action='Add';		Path="$HKCU\$CurrentVersion\Explorer";	 							Property='NoFolderOptions';			Type='DWord';	Value=1				}	#disable "folder options" https://winaero.com/how-to-disable-folder-options-in-windows-10/
	@{Action='Add';		Path="$HKCU\$CurrentVersion\Explorer\AutoComplete";	 					Property='AutoSuggest';				Type='string';	Value='No'			}	#disable File Explorer address bar history https://www.reddit.com/r/Windows11/comments/13m0naz/disable_file_explorer_address_bar_history/
	@{Action='Add';		Path="$HKCU\$CurrentVersion\Explorer\Advanced"; 						Property='ShowSuperHidden';			Type='DWord';	Value=0				}	#disable show hidden https://superuser.com/questions/1151844/how-to-toggle-show-hide-hidden-files-in-windows-through-command-line#:~:text=Type%20%E2%80%9Cregedit%E2%80%9C%2C%20then%20press,files%2C%20folders%2C%20and%20drives.
	@{Action='Add';		Path="$HKCU\$CurrentVersion\Explorer\Advanced"; 						Property='Hidden';				Type='DWord';	Value=0				}	#disable show hidden https://superuser.com/questions/1151844/how-to-toggle-show-hide-hidden-files-in-windows-through-command-line#:~:text=Type%20%E2%80%9Cregedit%E2%80%9C%2C%20then%20press,files%2C%20folders%2C%20and%20drives.
	@{Action='Add';		Path="$HKCU\$CurrentVersion\Explorer\Advanced"; 						Property='HideFileExt';				Type='DWord';	Value=1				}	#hide file extensions https://www.elevenforum.com/t/show-or-hide-file-name-extensions-for-known-file-types-in-windows-11.898/#Four
#	@{Action='Remove';	Path="$HKCU\$CurrentVersion\Explorer\taskband";							Property=$null;					Type=$null;	Value=$null			}	#remove ALL taskbar shortcuts? https://answers.microsoft.com/en-us/windows/forum/all/command-line-remove-taskbar-icons/4a036518-1e1b-4909-a563-4a74ff34bad7
	@{Action='Add';		Path="$HKCU\$Policies\Windows\WindowsCopilot"; 							Property='TurnOffWindowsCopilot';		Type='DWord';	Value=1				}	#disable CoPilot https://www.xda-developers.com/how-disable-microsoft-copilot/
	@{Action='Add';		Path="$HKCU\Microsoft\Office\16.0\Common\signin";						Property='signinoptions';			Type='DWord';	Value=3				}	#disable Office Sign-in https://forums.anandtech.com/threads/tutorial-disable-the-cloud-sign-in-option-on-office-2019.2574888/
)

foreach ($RegEdit in $RegEdits) {
    if ($($RegEdit.Action) -eq 'Remove' ) {						#does it need to be removed?
        if ($null -eq $RegEdit.Property) {						#is it a key?
        Remove-Item -Path $RegEdit.Path -Recurse -Force					#remove the whole key
        } else {									#is it a property?
            Remove-ItemProperty -Path $RegEdit.Path -Name $RegEdit.Property -Force	#remove the property
        }
    }
    $Setting	= Get-ItemProperty -Path $RegEdit.Path  -Name $RegEdit.Property -ErrorAction SilentlyContinue
    if ($null -eq $Setting) {																														#if path not exist
        $Parent	= Split-Path -Path $RegEdit.Path -Parent																							#get 1st part of path
        $Leaf	= Split-Path -Path $RegEdit.Path -Leaf																								#get last part of path
        New-Item -Path $Parent -Name $Leaf -Force -ErrorAction Continue																				#create the path
        New-ItemProperty -Path $RegEdit.Path -Name $RegEdit.Property -PropertyType $RegEdit.Type -Value $RegEdit.Value -Force -ErrorAction Continue #create the item
    } elseif ($($Setting.$($RegEdit.Property)) -ne $RegEdit.Value)  {																				#if exists, but has wrong value
        Set-ItemProperty -Path $RegEdit.Path -Name $RegEdit.Property -Value $RegEdit.Value -Force -ErrorAction Continue								#set correct value
    }
}

<####################
##Not required if PublicUser can't log out
#Hide logins https://learn.microsoft.com/en-us/answers/questions/1281830/how-to-remove-user-account-from-windows-logon-scre
New-Item -Path "$HKLM\$NtCurrentVersion\Winlogon\SpecialAccounts" -Name UserList -Force														#create the path
$Users	= (Get-LocalUser).name																												#get list of users
foreach ($User in $Users) {
    if ($User -ne $PublicUser){																												#for everyone except $PublicUser
        New-ItemProperty -Path "$HKLM\$NtCurrentVersion\Winlogon\SpecialAccounts\UserList" -Name $User -PropertyType DWord -Value 0 -Force #add them to the VIP list
    }
}
#####################>

## Shortcuts
$StartMenu		= "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$DesktopDir		= "$env:Public\Desktop"
$Lnks			= 'Word','Excel','PowerPoint','Microsoft Edge'
# pin shortcuts to the taskbar? #https://learn.microsoft.com/en-us/answers/questions/1309489/powershell-commands-for-pinneditem-item-to-taskbar
$shell			= New-Object -ComObject Shell.Application
$taskbarPath	= [System.IO.Path]::Combine([Environment]::GetFolderPath('ApplicationData'), 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar')
foreach ($Lnk in $Lnks) {
    if (!(Test-Path "$DesktopDir\$Lnk.lnk")) {
        $LnkPath = "$StartMenu\$Lnk.lnk"
        Copy-Item -Path $LnkPath -Destination $DesktopDir -Force
        $shell.Namespace($taskbarPath).Self.InvokeVerb('pindirectory', "$LnkPath")
    }
}
Copy-Item -Path "$env:SystemDrive\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\File Explorer.lnk" -Destination $DesktopDir -Force

## SchedTasks
$ScriptsDir			= "$env:ProgramData\Scripts"
$SchedAuthor			= 'Bill'
$SchedPath			= '\Pwsh\'
$SchedSet			= New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfIdle -IdleDuration 00:20:00 -Hidden

function Register-PsTask {
	<#
	.SYNOPSIS
	Registers a scheduled task to run a powershell script
	
	.DESCRIPTION
	Long description
	
	.EXAMPLE
	$Trig = New-ScheduledTaskTrigger -AtLogOn
	$CUser = New-ScheduledTaskPrincipal -UserId $env:USERNAME -Id "Author" -RunLevel Highest
	$TaskSet = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfIdle -IdleDuration 00:20:00 -Hidden
	Register-PsTask -Ps1Path "$env:ProgramData\Scripts\HelloWorld.ps1" -TaskName "Hello World" -TaskDescription "Says hello" -TaskAuthor "Barry Bluejeans" -TaskPath '\TEST\' -TaskTrigger $Trig -TaskSettings $TaskSet -TaskPrincipal $CUser
	#>
	param (
		[string]$Ps1Path,
		[string]$TaskName,
		[string]$TaskDescription,
		[string]$TaskAuthor,
		[string]$TaskPath,
		[string]$TaskTrigger,
		[string]$TaskSettings,
		[string]$TaskPrincipal

	)
	#set Description
	if ($null -eq $TaskDescription) {
		$TaskDescription	= $TaskName
	}
	#format Task Name
	$TaskName			= $TaskName.Replace(' ','')
	$TaskAction			= New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -File $Ps1Path"
	#register Task
	Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -TaskPath $TaskPath -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Settings $TaskSettings -Force
	#add Author
	$Task				= Get-ScheduledTask $TaskName
	$Task.Author		= $TaskAuthor
	$Task | Set-ScheduledTask
}
# Nightly Reboot
$ScriptPath				= "$ScriptsDir\NaaNightlyReboot\Reboot-Nightly.ps1"
$SchedName				= 'Nightly Reboot'
$SchedTrigger			= New-ScheduledTaskTrigger -Daily -At 3:00am -RandomDelay (New-TimeSpan -Minutes 30)
$SchedPrincipal			= New-ScheduledTaskPrincipal -GroupId "SYSTEM" -Id "Author" -RunLevel Highest
Register-PsTask -Ps1Path $ScriptPath -TaskName $SchedName -TaskDescription 'Reboot @3am' -TaskPath $SchedPath -TaskAuthor $SchedAuthor -TaskTrigger $SchedTrigger -TaskPrincipal $SchedPrincipal -TaskSettings $SchedSet
# Clear User Folders
$ScriptPath				= "$ScriptsDir\Kiosk\Kiosk_Clear-UserFolders_FORCE.ps1"
$SchedName				= 'Clear User Folders'
$SchedTrigger				= New-ScheduledTaskTrigger -Daily -At 1:00am -RandomDelay (New-TimeSpan -Minutes 30)
$SchedPrincipal				= New-ScheduledTaskPrincipal -UserId $PublicUser -Id "Author" -RunLevel Highest
Register-PsTask -Ps1Path $ScriptPath -TaskName $SchedName -TaskDescription 'Clears contents ' -TaskPath $SchedPath -TaskAuthor $SchedAuthor -TaskTrigger $SchedTrigger -TaskPrincipal $SchedPrincipal -TaskSettings $SchedSet

## TimeZones AU
#set tzutil variables
$CurrentTz	= (Get-TimeZone).Id					#Grab the current timezone
$AEST		= "AUS Eastern Standard Time"		#Syd/Mel/Cbr time
$TAS		= "Tasmania Standard Time"			#Hob time
$DAR		= "AUS Central Standard Time"		#Dar time
$ADE		= "Cen. Australia Standard Time"	#Ade Time
$PER		= "W. Australia Standard Time"		#Per time
$BRIS		= "E. Australia Standard Time"		#Bri time
$UTC		= "UTC"								#Universal Co-Ordinated Time

$IpList = @(
    @{Office="ACT";     TimeZone=$AEST;   IP="10.1.*"}
    @{Office="NSW";     TimeZone=$AEST;   IP="10.2.*"}
    @{Office="VIC";     TimeZone=$AEST;   IP="10.3.*"}
    @{Office="WA";      TimeZone=$PER;    IP="10.4.*"}
    @{Office="VIC";     TimeZone=$AEST;   IP="10.5.*"}
    @{Office="QLD";     TimeZone=$BRIS;   IP="10.6.*"}
    @{Office="NT";      TimeZone=$DAR;    IP="10.7.*"}
    @{Office="TAS";     TimeZone=$TAS;    IP="10.8.*"}
    @{Office="SA";      TimeZone=$ADE;    IP="10.9.*"}
    @{Office="LON";     TimeZone=$UTC;    IP="10.10.*"}
)
Write-Host "Current TimeZone is $($CurrentTz)"
#check adapter is running
if ($(Get-NetAdapter -Physical | Where-Object status -eq "Up").name -like "$AdapterName*") {                            #Is it on Ethernet?
    $IPv4 = (Get-NetAdapter -Physical -Name "$AdapterName*" | Get-NetIPAddress).IPv4Address                             #find local IP (v4 only)
    if ((Get-DnsClient | Where-Object InterfaceAlias -like "$AdapterName*").ConnectionSpecificSuffix -eq $DnsSuffix) {  #Is it on the right DNS?
        Write-Host "Comparing $($IP.Office)"
        foreach ($IP in $IpList){
            if ($IPv4 -like $IP.IP) {                                                                                   #check timezone match value in array
                if ($CurrentTz -ne $IP.TimeZone) {                                                                      #Is that already the timezone?
                    Write-Host "Setting TimeZone to $($IP.TimeZone)"
                    Set-TimeZone -Name $IP.TimeZone
                    break                                                                                               #if found, stop
                }
                else {                                                                                                  #TZ already correct
                    Write-Host "TimeZone already set to $CurrentTz" 
                    exit 0
                }
            }
        }
    }
}
