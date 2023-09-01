<#
Script Name:    NAA User Cessation - Archive AD User Account
Version:        3.1
Author:         Jonathan Stefaniak (I can assure you it wasn't)
Created:        22/08/2019
Modified By:    Bill Wilson
Reviewed By:	
Reviewed On:	
Purpose:    1) Remove Group Memberships
			2) Remove & Archive Home Drive
			3) Update Description
			4) Disable Account
			5) Move account to Disabled OU

------------------------------------------------
CHANGELOG
Modified 22/03/2022 by Bill:    Adapted variables to work independantly of .hta file
Modified 29/03/2022 by Bill:    Fine tuning variables;
                                Changed OU to company.int/Disabled Items/Disabled Accounts/Standard Users
Modified 17/04/2023 by Bill:    Tidied Formatting
                                Commented out\replaced unneeded Variables
                             

#>

Clear-Host
$strDivider = "--------------------------------------------"

Write-Host "User Cessation - Archive AD User Account"
Write-Host $strDivider

#Script variable definitions
 #$strOutLocation = "C:\Temp\Cessation"
 #$profileDrive = $env:userprofile.substring(0,2)
 #$strOutLocation = "$profileDrive\Temp\Cessation"
 $strOutLocation = "$env:SYSTEMDRIVE\Temp\Cessation"
 $strLogLocation = "$strOutLocation\Logs"
 $strErrorLog = "$strLogLocation\Cessation_ArchiveAD_errors.txt"

<# DISABLED - USED FOR .HTA VERSION
    Import-CSV -Path "$strOutLocation\cessation_AD_Input.csv" | foreach-object {
    $strUserName = $_.samaccountname
    $FQDN = $_.fqdn
    $strReqNumber = $_.RequestNumber
    $strHomeDirectory = $_.homeDirectory
    }
#>

 ## Set Username
    Write-Host ' input target Username :' -NoNewline -ForegroundColor Yellow -BackgroundColor DarkRed
    Write-Host ' ' -NoNewline
    $strUserName = Read-Host
    $FQDN = $strUserName
 ## Set REQ number 
    Write-Host ' input Ticket number      :' -NoNewline -ForegroundColor DarkRed -BackgroundColor Yellow
    Write-Host ' ' -NoNewline
    $REQ = Read-Host
    # Add prefix to REQno.
    if ($REQ -match '^REQ') {
        $strReqNumber = "$REQ"
        }
        elseif ($REQ -match '^INC') {
        $strReqNumber = "$REQ"
        }
    elseif ($REQ -notmatch '^REQ') {
        $strReqNumber = "REQ$REQ"
        }

 # Set Out File
 $strOutFile = $strLogLocation + "\$strUserName-$strReqNumber.txt"
 
 # Check if Admin user
 $admin = $fqdn.endswith('_admin')

 # Set Disabled OU
    if ($admin -match 'False') {
        $strDisabledOU = "OU=Standard Users,OU=Disabled Accounts,OU=Disabled Items,DC=company,DC=int"
        $strDisabledOUfName = "company.int/Disabled Items/Disabled Accounts/Standard Users"
    }
    elseif ($admin -match 'True') {
        $strDisabledOU = "OU=Admin Users,OU=Disabled Accounts,OU=Disabled Items,DC=company,DC=int"
        $strDisabledOUfName = "company.int/Disabled Items/Disabled Accounts/Admin Users"
    }
 # Set Dates
    $strDate = Get-Date
    $strDateFormatted = Get-Date -UFormat "%Y%m%d"

 # Get AD Properties
    $User = Get-ADUser -Identity "$FQDN" -Properties HomeDrive, HomeDirectory, ScriptPath, Name
    $strHomeDirectory = $User.homeDirectory

 # Set Lockfile (to ensure only one user performing this cessation)
    $lockFile = "$strOutLocation\Cessation_AD.lck"

    $WarningPreference = "continue"

    if (!(Test-Path $strLogLocation)) {
        New-Item -Path "$strOutLocation" -Name "Logs" -ItemType "directory" | Out-NULL
    }


    If ($User -eq $Null) {
        #User object cannot be found
        Write-Host "User '$strUserName' does not exist." -ForegroundColor Red
        Write-Host "Script exiting.."
        Write-Host "SCRIPT EXECUTION COMPLETE - No Changes Were Made"
        Write-Host "SCRIPT EXECUTION COMPLETE - No Changes Were Made"
    }
    else {
        #User object exists
        Write-Host "CONFIRM ACTION - Are you sure you want to cessate AD user object for " -NoNewline
        Write-Host ""$User.Name"" -NoNewline -ForegroundColor Green
        Write-Host "'" -NoNewline -ForegroundColor White
        Write-Host "$strusername" -NoNewline -ForegroundColor Red
        Write-Host "'?(Y/N)" -NoNewline -ForegroundColor White
        Write-Host " " -NoNewline
        $strConfirm = Read-Host 

        #Ensure user has confirmed they want to run this script against the supplied user object
        if($strConfirm -eq "Y") {
            #User object is enabled in AD
	    	Write-Host $strDivider
		    Write-Host "Script running..."

            #Write session info to log file
            $strLogContent = $strDivider
            $strLogContent = $strLogContent + "`r`n" + "Ticket Reference " + $strReqNumber
            $strLogContent = $strLogContent + "`r`n" + "Archival process 'Cessation_AD.ps1' started by: " + [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
            $strLogContent = $strLogContent + "`r`n" + $strDate
            $strLogContent = $strLogContent + "`r`n" + $strDivider
		    write-host $strLogContent
            $strLogContent | Out-File -FilePath $strOutFile -Append

            $User | Out-File -FilePath $strOutFile -Append
        
            #Update AD account description to indicate date, initiator, and ticket for action
            Try {
                $strLogContent = "Cessation - $strDateFormatted - $strReqNumber - Actioned by " + [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
                $User | Set-ADUser -Description $strLogContent
                $strLogContent = "[COMPLETED] Updated Description to `"$strLogContent`""
                Write-Host $strLogContent -ForegroundColor Green
            }
            catch {
                $strLogContent = "[WARNING] Error occurred updating Description"
                Write-Host $strLogContent -ForegroundColor Yellow
                $_ > $strErrorLog
            }
        $strDivider | Out-File -FilePath $strOutFile -Append
        $strLogContent | Out-File -FilePath $strOutFile -Append
        
        #Clear profile HomeDirectory, ScriptPath, telephone, addresses etc.
        $strScriptPath = $User.ScriptPath
        try {
            $User | Set-ADUser -Clear HomeDrive, HomeDirectory, ScriptPath
            $strLogContent = "[COMPLETED] Cleared HomeDrive, HomeDirectory and ScriptPath attributes"
            Write-Host $strLogContent -ForegroundColor Green
        }
        catch {
            $strLogContent = "[WARNING] Error occurred clearing HomeDirectory & ScriptPath attributes"
            Write-Host $strLogContent -ForegroundColor Yellow
            $_ > $strErrorLog
        }
        write-host $strDivider
        $strLogContent = $strLogContent + "`r`n" + $strDivider
        $strLogContent | Out-File -FilePath $strOutFile -Append

        #Get list of & remove user from all AD groups user is a member of
        $Groups = (Get-ADUser -Identity $strUserName -Properties memberOf).memberOf

        #Continue if user is a member of any AD groups
        if($Groups -ne $null) {
            $Groups | Get-ADGroup | Select-Object name | Sort-Object name | Out-File -FilePath $strOutFile -Append
            foreach ($groupName in $groups) {
                write-host $groupName
            }
            try {
                Remove-ADPrincipalGroupMembership -Identity $strUserName -MemberOf $Groups -Confirm:$False
                $strLogContent = "[COMPLETED] User removed from the AD groups listed above"
                Write-Host $strLogContent -ForegroundColor Green
            }
            catch {
                $strLogContent = "[WARNING] Error occurred removing user from groups"
                Write-Host $strLogContent -ForegroundColor Yellow
                $_ > $strErrorLog
            }
            #$strLogContent = $groupsList + "`r`n" + $strLogContent
        }
        else {
            $strLogContent = "[SKIPPED] User not a member of any principal AD groups"
            Write-Host $strLogContent -ForegroundColor Gray
        }
        write-host $strDivider
        $strLogContent = $strLogContent + "`r`n" + $strDivider
        $strLogContent | Out-File -FilePath $strOutFile -Append

        #Rename & Move H-drive to _DISABLED-ACCOUNTS file share
        if(($strHomeDirectory -ne $null) -and ($strHomeDirectory -ne "")) {
            #Test if H-Drive folder exists
            if(test-path $strHomeDirectory -Pathtype Container) {
                #H-Drive path exists
                $strHDriveArchive = $strHomeDirectory -Replace $strUsername, "_DISABLED-ACCOUNTS"				
				$strEndHomePath = $strHDriveArchive + "\" + $strUserName
                Try {
                    #move $strHomeDirectory $strHDriveArchive
					Move-Item -Path $strHomeDirectory -Destination $strHDriveArchive
					if (!(Test-Path $strHomeDirectory)) {
						if (Test-Path $strEndHomePath) {
							$strLogContent = "[COMPLETED] H-Drive folder archived to " + $strHDriveArchive
							Write-Host $strLogContent -ForegroundColor Green
						}
						else {
							$strLogContent = "[WARNING] H-Drive missing"
							Write-Host $strLogContent -ForegroundColor Yellow
							$strLogContent = strLogContent + "`r`n" + "From: " + $strHomeDirectory + "`r`n" + "To: " + $strEndHomePath
						}
					}
					else{
						$strLogContent = "[WARNING] H-Drive still exists in original location " + $strHomeDirectory
						Write-Host $strLogContent -ForegroundColor Yellow
						if (Test-Path $strEndHomePath) {
							write-host "[WARNING] H-Dive also exists in destination " + $strEndHomePath -ForegroundColor Yellow
							$strLogContent = $strLogContent + "`r`n" + "[WARNING] H-Dive also exists in destination " + $strEndHomePath
						}
					}
                }
                catch {
                    $strLogContent = "[WARNING] Error occurred move H-Drive folder to " + $strHDriveArchive
                    Write-Host $strLogContent -ForegroundColor Yellow
                    $_ > $strErrorLog
                }
            }
            else {
                #H-Drive path does not exist
                $strLogContent = "[SKIPPED] H-Drive path invalid - folder could not be archived (" + $strHDriveArchive + ")"
                Write-Host $strLogContent -ForegroundColor Gray
            }
            
        }
        else {
            $strLogContent = "[SKIPPED] Home Directory empty"
            write-host $strLogContent  -ForegroundColor Gray
        }
        write-host $strDivider
        $strLogContent = $strLogContent + "`r`n" + $strDivider
        $strLogContent | Out-File -FilePath $strOutFile -Append

        #Disable user if enabled
		if($User.Enabled) {
            try {
			    Disable-ADAccount -Identity $FQDN
			    $strLogContent = "[COMPLETED] AD user object disabled"
                write-host $strLogContent -ForegroundColor Green
            }
            catch {
                $strLogContent = "[WARNING] Error disabling account"
                write-host $strLogContent -ForegroundColor Yellow
                $_ > $strErrorLog
            }
			
		}
		else {
            $strLogContent = "[SKIPPED] AD user object already disabled"
            write-host $strLogContent -ForegroundColor Gray
		}
        $strLogContent | Out-File -FilePath $strOutFile -Append

        try {
            $User | Move-ADObject -TargetPath $strDisabledOU
            $strLogContent = "[COMPLETED] AD user object moved to " + $strDisabledOUfName
            write-host $strLogContent -ForegroundColor Green
        }
        catch {
            $strLogContent = "[WARNING] Error moving account to " + $strDisabledOUfName
            write-host $strLogContent -ForegroundColor Yellow
            $_ > $strErrorLog
        }
        write-host $strDivider
        $strLogContent = $strLogContent + "`r`n" + $strDivider
        $strLogContent | Out-File -FilePath $strOutFile -Append
    }
    else {
        #Script aborted by user
        Write-Host $strDivider
        Write-Host "Script exiting.."
        Write-Host "SCRIPT EXECUTION COMPLETE - No Changes Were Made"
    }
}

if (Test-Path $lockFile) {
    Try {
        remove-item -path $lockFile
    }
    catch {
        
    }
}

Start-Sleep 20
