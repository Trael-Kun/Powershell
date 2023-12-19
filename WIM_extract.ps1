
<#
.SYNOPSIS
Extracts .wim for specified Windows version

.DESCRIPTION
Extracts .wim for specified Windows version
Defaults to Windows 11 Enterprise

.PARAMETER ISO
Specifies path to target .iso file

.PARAMETER WimDest
Specifies path to destination .wim file

.NOTES
References
https://serverfault.com/questions/968495/how-can-an-iso-image-be-mounted-to-a-specified-drive-letter-in-powershell
https://learn.microsoft.com/en-us/powershell/module/dism/export-windowsimage
https://stackoverflow.com/questions/18780956/suppress-console-output-in-powershell

#>

param (
    # Specifies path to target .iso file
    [Parameter(Mandatory)]
    [string]
    $ISO,
    # Specifies path to destination .wim file
    [Parameter(Mandatory)]
    [string]
    $WimDest
)

#Set Variables
$WinEdition = 'Windows 11 Enterprise'

## Start Script
Write-Host ""
Write-Host "Script is set to extract " -NoNewline
Write-Host "$WinEdition" -ForegroundColor Magenta

# Check .ISO exists
if ((Test-Path -Path "$ISO") -eq $true) {
    # Check syntax of $ISOpath
    if ($ISO -notlike "*.ISO") {
        $ISOget = Get-ChildItem -Path "$ISO" -Filter "*win*.ISO" | Select-Object -First 1
        #ISOfile is file name
        $ISOfile = $ISOget.Name
        #ISOtarget is full path
        $ISOtarget = $ISOget.FullName
        #ISOpath is directory path
        $ISOpath = $ISOget.DirectoryName
    }
    else {
        #ISOtarget is full path
        $ISOtarget = $ISO
        #ISOfile is file name
        $ISOfile = $ISO -split "(\\)" | Select-Object -Last 1
        #ISOpath is directory path
        $ISOpath = $ISO.Replace("$ISOfile", "")
    }
    # Mount .ISO and find correct .wim
    Write-Host ""
    Write-Host "Mounting $ISOtarget" -ForegroundColor DarkYellow
    $ISOmount = Mount-DiskImage -ImagePath "$($ISOtarget)" | Get-Volume
    
    if ($null -eq $ISOmount.DriveLetter) {
        Write-Error ".ISO not mounted"
        exit 1
    }
    else {
        Write-Host ""
        Write-Host "$ISOfile mounted as $($ISOmount.DriveLetter)" -ForegroundColor Green
    }
    $WimTarget = "$($ISOpath.DriveLetter):\sources\install.wim"

    Write-Host ""
    Write-Host "Finding install.wim" -ForegroundColor DarkYellow
    if ((Test-Path -Path $WimTarget) -eq $false){
        Write-Error "Unable to locate install.wim - please check .ISO is mounted"
        exit 1
    }
    else {
        Write-Host ""
        Write-Host "$WimTarget found"-ForegroundColor Green
    }
    Write-Host ""
    Write-Host "Getting image index" -ForegroundColor DarkYellow
    $WinEd = Get-WindowsImage -ImagePath "$WimTarget" -Name "$WinEdition"
    Write-Host ""
    Write-Host "Image index is $($WinEd.ImageIndex)" -ForegroundColor Green
    # Check syntax of $WimDest
    if ($WimDest -notlike "*.wim") {
        $DateTime = Get-Date -Format "%y%M%dHHmm"
        $WimOut = "$WimDest\$DateTime.wim"
    }
    else {
        $WimOut = $WimDest
    }

    # Export image
    Write-Host ""
    Write-Host "Exporting Image" -ForegroundColor DarkYellow
    Export-WindowsImage -SourceImagePath "$WimTarget" -SourceIndex $WinEd.ImageIndex -DestinationImagePath "$WimOut" | Out-Null
    if ((Test-Path -Path $WimOut) -eq $true) {
        Write-Host ""
        Write-Host ".wim file extracted to $WimOut" -ForegroundColor Green
    }
    
    # Dismount .iso
    Write-Host ""
    Write-Host "Dismounting $ISOfile" -ForegroundColor DarkYellow
    Dismount-DiskImage -ImagePath $ISOfile | Out-Null
    if ((Test-Path -Path $ISOpath.DriveLetter) -eq $false) {
        Write-Host ""
        Write-Host "$ISOfile dismounted" -ForegroundColor Green
    }
    else {
        Write-Error "Unable to dismount drive $($ISOpath.DriveLetter)"
    }
}
# if .iso doesn't exist
else {
    Write-Error -Message "Unable to find path $ISO, please try again" -Category ObjectNotFound
}
