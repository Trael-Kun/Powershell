<#
.SYNOPSIS
    Copy a file to multiple PCs from Jumpbox

.DESCRIPTION
    Copies a single file from a location accessible from the local PC and copies it to a location on a remote 
    PC using different credentials.
    The location on the remote PC is mounted as a network drive during copying, and is then unmounted so that 
    the drive letter can be reused for the next loop.

.NOTES
    Author:     Bill Wilson https://github.com/Trael-Kun
    Created:    02/01/24

    References: 
    https://stackoverflow.com/questions/612015/copy-item-with-alternate-credentials
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-psdrive?view=powershell-7.4
    https://lazyadmin.nl/powershell/new-psdrive/
    https://stackoverflow.com/questions/38442196/powershell-how-to-user-input-array-cycling-through-it-and-then-closing-out-at
    https://stackoverflow.com/questions/40009297/net-use-in-powershell-without-specifying-drive
#>

# Header
Write-Host "Copy a single file to multiple computers" -ForegroundColor Green
Write-Host ""

# PC Numbers
# Keep prompting for another until they just press enter
$PCs = do  { 
    $PC = Read-Host "Enter remote computer, or blank to finish" -ForegroundColor Yellow
    $PC
} while ($PC -ne '')
Write-Host ""

#Get Credentials
Write-Host "Enter credentials to access remote PCs" -ForegroundColor Yellow
Write-Host ""
$Cred = Get-Credential

#Folder where your file/s at
$SourceDir = Read-Host "Source directory path" -ForegroundColor Yellow
Write-Host ""

#File name, use "" for full directory
$SourceFile = Read-Host "Source Filename" -ForegroundColor Yellow
Write-Host ""
#Join paths
$SourcePath = Join-Path -Path $SourceDir -ChildPath $SourceFile

#Hard-coded drive letter as storing as a variable is causing issues
$DestDir = Read-Host "Destination path on remote PC (e.g. C:\Temp)" -ForegroundColor Yellow
Write-Host ""

#Get the drive letter
$DestPath = $DestDir.Replace(':','$')

# Now do the thing
foreach ($Asset in ($PCs | Select-Object -SkipLast 1)) {
    if ($Asset.length -ne '0') {
        if ($Asset -match '^VM') {
            $PCname = "$Asset"
        }
        elseif ($Asset -match '^LAP') {
            $PCname = "$Asset"
        }
        elseif ($Asset -match '^CAF') {
            $PCname = "$Asset"
        }
        elseif ($Asset -match '^WKS') {
            $PCname = "$Asset"
        }
        # if it's none of the above, function will assume it's WKS
        elseif ($Asset -notmatch '^WKS') {
            $PCname = "WKS$Asset"
        }
    #Set remote PC as network drive
    $Dest = "\\$PCname\$DestPath"
    Write-Host "Destination is $Dest" -ForegroundColor Green
    $Destination = Join-Path -Path $Dest -ChildPath $SourceFile
    #New-SmbMapping method
    Write-Host "Mapping $dest as network drive"
    New-SmbMapping -RemotePath $Dest -UserName $cred.UserName -Password $cred.GetNetworkCredential().password
        if (Test-Path "$Dest") {
            Write-Host "$Dest mounted" -ForegroundColor Green
            Write-Host "Copying $SourcePath to $Destination"
            Copy-Item -Path $SourcePath -Destination "$Destination" -Force
            Start-Sleep 2
            if (Test-Path "$Destination") {
                Write-Host "Copied to $Destination" -ForegroundColor Green
            }
            else {
                Write-error "$Destination failed to write"
            }
        }
        else {
            Write-error "$Dest failed to mount"
        }
        #unmount the network drive, get ready for the next one
        Write-Host "Removing mapped drive" -ForegroundColor Yellow
        Start-Sleep 2
        Remove-SmbMapping -RemotePath $Dest -Force
    }
}
