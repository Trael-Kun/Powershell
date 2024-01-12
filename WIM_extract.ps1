<#
.SYNOPSIS
Extracts a.wim for specified Windows version

.DESCRIPTION
Extracts a single .wim for specified Windows edition from an ISO file.
This script:
    
    - Finds specified ISO
    - Mounts ISO and gets drive letter
    - Finds and lists Windows editions
    - Extracts and renames selected edition
    - Dismounts ISO

...all in fabulous Technicolour

.PARAMETER ISO
Specifies path to target .iso file

.PARAMETER WimDest
Specifies path to destination .wim file

.NOTES
Author: Bill Wilson
https://github.com/Trael-Kun

References
https://serverfault.com/questions/968495/how-can-an-iso-image-be-mounted-to-a-specified-drive-letter-in-powershell
https://learn.microsoft.com/en-us/powershell/module/dism/export-windowsimage
https://stackoverflow.com/questions/18780956/suppress-console-output-in-powershell
https://stackoverflow.com/questions/64454231/powershell-read-host-to-select-an-array-index
https://debug.to/1435/how-to-change-color-of-read-host-in-powershell

#>

param (
    # Specifies path to input .iso file
    [Parameter(Mandatory,HelpMessage='Path to target Windows .ISO file')]
    [string]
    $ISO,
    # Specifies path for output .wim file
    [Parameter(Mandatory,HelpMessage='Destination to save .wim file to')]
    [string]
    $WimDest
)

# dismount ISO function
function Dismount-ISO {
    Write-Host ""
    Write-Host 'Dismounting file "' -ForegroundColor $Process -NoNewline
    Write-Host "$IsoFile" -ForegroundColor $ProcVar -NoNewline
    Write-Host '"' -ForegroundColor $Process
    Dismount-DiskImage -ImagePath $IsoTarget | Out-Null
    # if successfully ejected
    if (!(Test-Path -Path $IsoMount.DriveLetter)) {
        Write-Host ""
        Write-Host 'File "' -ForegroundColor $Result -NoNewline
        Write-Host "$IsoFile" -ForegroundColor $ResultVar -NoNewline
        Write-Host '" dismounted' -ForegroundColor $Result
        Start-Sleep 1
        Write-Host ""
    }
    # if not ejected
    elseif ((Test-Path -Path $IsoMount.DriveLetter)) {
        Write-Host ""
        Write-Host "Unable to dismount " -ForegroundColor $ErrorResult -NoNewline
        Write-Host "$IsoFile" -ForegroundColor $ErrorVar -NoNewline
        Write-Host " from " -ForegroundColor $ErrorResult -NoNewline
        Write-Host "$($IsoMount.DriveLetter)" -ForegroundColor $ErrorVar -NoNewline
        Write-Host ", please eject manually" -ForegroundColor $ErrorResult
        Start-Sleep 1
        Write-Host "" -ForegroundColor 
    }
}

# colours
    # process text
    $Process = "DarkYellow"
    $ProcVar = "Yellow"
    # result Text
    $Result = "Green"
    $ResultVar = "Blue"
    # prompt
    $Prompt = "DarkMagenta"
    $UserInput = "Red"
    # errors
    $ErrorResult = "Red"
    $ErrorVar = "DarkRed"


## Start Script

# check $ISO exists
if ((Test-Path -Path "$ISO")) {
    # check syntax of $ISOpath
    # if $ISO is only dir path
    if ($ISO -notlike "*.ISO") {
        $IsoGet = Get-ChildItem -Path "$ISO" -Filter "*win*.ISO" | Select-Object -First 1
        #IsoFile is file name
        $IsoFile = $IsoGet.Name
        #IsoTarget is full path
        $IsoTarget = $IsoGet.FullName
        #IsoPath is directory path
    }
    # if full .ISO path
    else {
        #IsoTarget is full path
        $IsoTarget = $ISO
        #IsoFile is file name
        $IsoFile = $ISO -split "(\\)" | Select-Object -Last 1
        #IsoPath is directory path
    }

    # mount .ISO
    Write-Host ""
    Write-Host 'Mounting "'  -ForegroundColor $Process -NoNewline
    Write-Host "$IsoTarget" -ForegroundColor $ProcVar -NoNewline
    Write-Host '"...'  -ForegroundColor $Process
    $IsoMount = Mount-DiskImage -ImagePath "$($IsoTarget)" | Get-Volume
    Start-Sleep 1
    
    # check for drive letter assignment
    if ($null -eq $IsoMount.DriveLetter) {
        Write-Error ".ISO not mounted" -Category ObjectNotFound
        Start-Sleep 1
        exit 1
    } else {
        Write-Host ""
        Write-Host 'File "' -ForegroundColor $Result -NoNewline
        Write-Host "$IsoFile" -ForegroundColor $ResultVar -NoNewline
        Write-Host '" mounted as "' -ForegroundColor $Result -NoNewline
        Write-Host "$($IsoMount.DriveLetter):" -ForegroundColor $ResultVar -NoNewline
        Write-Host '"' -ForegroundColor $Result
        Start-Sleep 1
    }

    # find the .wim
    $WimTarget = "$($IsoMount.DriveLetter):\sources\install.wim"
    Write-Host ""
    Write-Host 'Searching for "' -ForegroundColor $Process -NoNewline
    Write-Host "$WimTarget" -ForegroundColor $ProcVar -NoNewline
    Write-Host '"...' -ForegroundColor $Process
    Start-Sleep 1

    # look for $WimTarget
    if (!(Test-Path -Path $WimTarget)) {
        Write-Error "Unable to locate install.wim - please check .ISO is mounted"
        Dismount-ISO
        Write-Host ""
        exit 1
    }
    else {
        Write-Host ""
        Write-Host '"' -ForegroundColor $Result -NoNewline
        Write-Host "$WimTarget"-ForegroundColor $ResultVar -NoNewline
        Write-Host '" found' -ForegroundColor $Result
    }

    # find available edtions
    Write-Host ""
    Write-Host "Getting image list..." -ForegroundColor $Process
    $IndexList = Get-WindowsImage -ImagePath "$WimTarget" | Select-Object -Property ImageIndex,ImageName

    # start loop until index is correct and confirmed
    while ($true) {

        # show options
        $IndexList | Format-Table
        $Index = $(Write-Host "Please select image index (number), or type " -ForegroundColor $Prompt -NoNewline) + $(Write-Host '0' -ForegroundColor $UserInput -NoNewline) + $(Write-Host ' or ' -ForegroundColor $Prompt -NoNewline)  + $(Write-Host 'Q' -ForegroundColor $UserInput -NoNewline) + $(Write-Host " to quit: " -ForegroundColor $Prompt -NoNewline) + $(Read-Host)
        
        # assume the input is bad until proven otherwise
        $BadInput = $true

        # if 0 or Q entered, exit loop
        if ($Index -eq '0' -or $Index -eq 'Q') {
            Dismount-ISO
            exit 1
        }

        # make sure $Index is only a numeral
        elseif ($Index -match '^\d+$') {

            # convert variables to integers for comparison
            $IndexTop = [int]$IndexList.Count
            $IndexSelection = [int]$Index
            
            # test if the input is numeric and is in range
            if ($IndexSelection -le $IndexTop) {
                $BadInput = $false
                Write-Host ""
                Write-Host "Getting image details..."
                $WinEd = Get-WindowsImage -ImagePath "$WimTarget" -Index "$Index"
                Start-Sleep 1
                
                # confirm selection
                Write-Host ""
                Write-Host 'Index "' -ForegroundColor $Result -NoNewline
                Write-Host "$Index" -ForegroundColor $ResultVar -NoNewline
                Write-Host '" selected, image edition is "' -ForegroundColor $Result -NoNewline
                Write-Host "$($WinEd.ImageName)" -ForegroundColor $ResultVar -NoNewline
                Write-Host '"' -ForegroundColor $Result
                Write-Host ""
                $Confirm = $(Write-Host "Do you want to proceed (" -ForegroundColor $Prompt -NoNewline) + $(Write-Host "Y" -ForegroundColor $UserInput -NoNewline) + $(Write-Host "/" -ForegroundColor $Prompt -NoNewline) + $(Write-Host "N" -ForegroundColor $UserInput -NoNewline) + $(Write-Host ")? " -ForegroundColor $Prompt -NoNewline) + $(Read-Host)
                
                # if yes, escape loop
                if ($Confirm -eq 'y' -or $Confirm -eq 'yes') {
                    break
                }
            }
        }

        # loop back if bad input
        if ($BadInput) {
            Write-Error "Invalid input: $Index" -Category InvalidData
            Write-Host "Bad input received (" -ForegroundColor $ErrorResult -NoNewline
            Write-Host "$Index" -ForegroundColor $ErrorVar -NoNewline
            Write-Host "), please type only a valid number from the ImageIndex column" -ForegroundColor $ErrorResult
            Start-Sleep 3
        }
    }
    
    # check syntax of $WimDest
    # if $WimDest not a .wim file, set the file name
    if ($WimDest -notlike "*.wim") {
        if (Test-Path $WimDest) {
            $DateTime = Get-Date -Format "%y%M%dHHmm"
            $WimOut = "$WimDest\Win.$($WinEd.EditionID).$DateTime.wim"
        }
        else {
            
        }
    }
    # if $WimDest is .wim carry on
    elseif ($WimDest -like "*.wim") {
        # WimFile is "filename.wim"
        $WimFile = $WimDest -split "(\\)" | Select-Object -Last 1
        # WimPath is directory path
        $WimPath = $WimDest.Replace("$WimFile", "")
        if (Test-Path $WimPath) {
            $WimOut = $WimDest
        }
    }

    # export image
    Write-Host ""
    Write-Host "Exporting Image..." -ForegroundColor $Process
    Export-WindowsImage -SourceImagePath "$WimTarget" -SourceIndex $WinEd.ImageIndex -DestinationImagePath "$WimOut" | Out-Null

    # check .wim has written to $WimOut
    if ((Test-Path -Path $WimOut)) {
        Write-Host ""
        Write-Host 'Image extracted to "' -ForegroundColor $Result -NoNewline
        Write-Host "$WimOut" -ForegroundColor $ResultVar -NoNewline
        Write-Host '"' -ForegroundColor $Result
        Start-Sleep 1
    }
    else {
        Write-Error "$WimOut not found" -Category ObjectNotFound
        Write-Host "Unable to write to " -ForegroundColor $ErrorResult -NoNewline
        Write-Host "$WimOut" -ForegroundColor $ErrorVar -NoNewline
        Write-Host ", please check permissions and try again" -ForegroundColor $ErrorResult
        Start-Sleep 3
    }
    
    # dismount .iso
    Dismount-ISO
}

# if .iso doesn't exist
else {
    Write-Host ""
    Write-Error -Message "$ISO not found" -Category ObjectNotFound
    Write-Host ""
    Write-Host "Unable to find " -ForegroundColor $ErrorResult -NoNewline
    Write-Host "$ISO" -ForegroundColor $ErrorVar -NoNewline
    Write-Host ", please check file path" -ForegroundColor $ErrorResult
    Start-Sleep 2
}
