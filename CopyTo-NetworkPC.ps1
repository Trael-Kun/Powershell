<#
.SYNOPSIS
    Copy a single file to multiple PCs

.DESCRIPTION
    Copies a single file from a location accessible from the local PC and copies it to a location on a remote 
    PC using different credentials.
    The location on the remote PC is mounted as a network drive with supplied credentials during copying, and is then unmounted

.NOTES
    Author:     Bill Wilson     https://github.com/Trael-Kun
    Created:    02/01/24

    References: 
    https://stackoverflow.com/questions/612015/copy-item-with-alternate-credentials
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-psdrive?view=powershell-7.4
    https://lazyadmin.nl/powershell/new-psdrive/
    https://stackoverflow.com/questions/38442196/powershell-how-to-user-input-array-cycling-through-it-and-then-closing-out-at
    https://stackoverflow.com/questions/40009297/net-use-in-powershell-without-specifying-drive
    https://community.spiceworks.com/topic/1330191-powershell-remove-all-text-after-last-instance-of
#>

Function Write-Log {
    #https://www.sharepointdiary.com/2019/06/create-log-file-in-powershell-script.html
    [CmdletBinding()]
    param ([Parameter(Mandatory=$true)] [string] $Message, [Parameter(Mandatory=$false)] [string] $Output, [Parameter(Mandatory=$false)] [string] $Colour)

    Try {        
        #Frame Log File with Current Directory and date
        $LogFile = $LocalLog
        #Add Content to the Log File
        $TimeStamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss:fff tt")
        $Line = "$TimeStamp - $Message"
        Add-content -Path $Logfile -Value $Line
        #Write to host?
        if ($Output -eq $true) {
            #Apply colour to Write-Host?
            if ($Colour -eq $null){
                Write-Host "$Message"
            }
            else {
                Write-Host "$Message" -ForegroundColor $Colour
            }
        }
    }
    Catch {
        Write-Host -f Red "Error:" $_.Exception.Message 
    }
}

# Logging
 #Get the current date for logging
 $LogDate = (Get-Date).tostring("yyyyMMdd")
 $StartTime = Get-Date
 #Set Log location
 $LocalLog = "$env:SystemDrive\Temp\NetworkCopy_$LogDate.txt"
 $LogDir = $LocalLog.Substring(0, $LocalLog.LastIndexOf('\'))
 #Check path exists, and make it if it doesn't
 if (!(Test-Path "$LogDir")) {
     New-Item -Path $LogDir -ItemType "directory"
 }

# Output Colours
 $Action = 'Yellow'
 $Success = 'Green'
 $Fail = 'Red'

# Header
 Write-Host 'Copy a single file to multiple computers' -ForegroundColor Magenta
 Write-Host "Writes logs to $LocalLog"
 Write-Log -Message "SCRIPT START $StartTime" -Output $false
 Write-Log -Message ' ' -Output $false

# PC IDs
 #Keep prompting for another until they just press enter
 $PCs = @()
 $PCs = do  { 
     $PC = Read-Host 'Enter remote computer, or blank to finish'
     $PC
 } while ($PC -ne '')
 Write-Host ''
 Write-Log -Message 'Computer List:' -Output $false
  #foreach ($PC in $PCs) {
    Write-Log -Message "$PCs" -Output $false
 #}

# Get Credentials
 #Stored it previously as $Credential?
 if ($Credential -ne $Null) {
     $Cred = $Credential
 }
 #Stored it previously as $Cred?
 if ($Cred -eq $null){
     Write-Host 'Enter credentials to access remote PCs' -ForegroundColor $Action
     Write-Host ''
     $Cred = Get-Credential
 }
 $User = $Cred.GetNetworkCredential().UserName
 Write-Log -Message "User: $User" -Output $false

# File & folder paths
 #Where your file/s at?
 Write-Host 'Source file directory path (Local or UNC, including file extension):' -ForegroundColor $Action -NoNewLine
 $SourcePath = Read-Host
 Write-Log -Message "Source file: $SourcePath" -Output $false
 $SourceDir = $SourcePath.Substring(0, $SourcePath.LastIndexOf('\'))
 $SourceFile = $SourcePath -replace '.*\\'
 #File Destination, it'll be the same on all PCs
 Write-Host 'Destination path on remote PC (e.g. C:\Temp):' -ForegroundColor $Action -NoNewLine
 $DestDir = Read-Host
 Write-Host ""
 #Set correct format for remote PC path (i.e. "\\server01\C$\")
 $DestPath = $DestDir.Replace(':','$')
 
# Now do the thing
Write-Log -Message 'Starting Process' -Output $false
foreach ($Asset in ($PCs | Select-Object -SkipLast 1)) { #skip the last entry, because it's blank
    if ($Asset.length -ne '0') { #is there an input?
        #Check name syntax
        if ($Asset -match '^VM') { #does it stat with "VM"?
        $PCname = "$Asset"
        }
        elseif ($Asset -match '^LAP') { #does it stat with "LAP"?
            $PCname = "$Asset"
        }
        elseif ($Asset -match '^CAF') { #does it stat with "CAF"? 
            $PCname = "$Asset"
        }
        elseif ($Asset -match '^WKS') {#does it stat with "WKS"?
            $PCname = "$Asset"
        }
        elseif ($Asset -notmatch '^WKS') { #if it's none of the above, assume it's WKS
            $PCname = "WKS$Asset"
        }
        
        Write-Log -Message "Connecting to $PCname" -Output $true -Colour $Action
        #Set remote PC as network drive
         $Dest = "\\$PCname\$DestPath"
         Write-Log -Message "Destination is $Dest" -Output $True -Colour $Success
        #does the destination exist?
        if (!(Test-Path $Dest)) { #if not, make it
            Write-Log -Message "Destination not found, creating $Dest" -Output $true -Colour $Action
            $DestRoot = $DestPath.Split('\')[0]
            New-SmbMapping -RemotePath "\\$PCname\$DestRoot" -UserName $User -Password $Cred.GetNetworkCredential().password
            New-Item -Path $Dest -ItemType "directory" -Force
            Remove-SmbMapping -RemotePath "\\$PCname\$DestRoot" -Force
        }

        # "New-SmbMapping" method
        #Map the drive
        Write-Log "Mapping $Dest as network drive" -Output $true -Colour $Action
        New-SmbMapping -RemotePath $Dest -UserName $User -Password $cred.GetNetworkCredential().password
        
        if (Test-Path "$Dest") { #Check that it worked
            Write-Log -Message "$Dest mounted" -Output $true -Colour $Success
            $Destination = Join-Path -Path $Dest -ChildPath $SourceFile
            #Do the copy
            Write-Log -Message "Copying $SourcePath to $Destination" -Output $true -Colour $Action
            Copy-Item -Path $SourcePath -Destination "$Destination" -Force
            Start-Sleep 2
            
            if (Test-Path "$Destination") { #yay, it copied!
                Write-Log -Message "Copied to $Destination" -Output $true -Colour $Success
            }
            
            else { #oh noes, it didn't copy
                Write-Log -Message "$Destination failed to write" -Output $true -Colour $Fail
            }
        }
        else { #oh noes, it didn't mount
            Write-Log -Message "$Dest failed to mount" -Output $true -Colour $Fail
        }

        #unmount the network drive, get ready for the next one
        Write-Log -Message 'Removing mapped drive' -Output $true -Colour $Action
        Start-Sleep 2
        Remove-SmbMapping -RemotePath $Dest -Force
        if (Get-SmbMapping -RemotePath $Dest -erroraction ignore ) { #aw man, it's still mounted
            Write-Log -Message "$Dest not unmounted" -Output $true -Colour $Fail
        }
        else { #woot, it unmounted
            Write-Log -Message "$Dest unmounted" -Output $true -Colour $Success
        }
    }
    Write-Log -Message "END $PCname" -Output $false
    Write-Log -Message " " -Output $false
}

#Clear PC list
Clear-Variable 'PCs'
