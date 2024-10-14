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
Specifies path to input .iso file

.PARAMETER WimOut
Specifies path to output .wim file

.NOTES
Author: Bill Wilson
https://github.com/Trael-Kun

References
https://serverfault.com/questions/968495/how-can-an-iso-image-be-mounted-to-a-specified-drive-letter-in-powershell
https://learn.microsoft.com/en-us/powershell/module/dism/export-windowsimage
https://stackoverflow.com/questions/18780956/suppress-console-output-in-powershell
https://stackoverflow.com/questions/64454231/powershell-read-host-to-select-an-array-index
https://debug.to/1435/how-to-change-color-of-read-host-in-powershell
https://petri.com/create-numbered-output-lists-with-powershell/
#>

param (
    # Specifies path to input .iso file
    [Parameter(Mandatory,HelpMessage='Path to target Windows .ISO file. This can be a full file path or directory only (script will select 1st .ISO found)')]
    [string]$Iso,
    # Specifies path for output .wim file
    [Parameter(Mandatory,HelpMessage='Destination for output .wim file. This can be a full file path or directory only.')]
    [string]$WimOut,
    [Parameter(Mandatory=$false,HelpMessage='Enable Logging')]
    [switch]$Log
)

if ($Log) {
    $LogFile =  "$env:windir\Logs\Wim_Extract.log"
    Start-Transcript -Path $LogFile -IncludeInvocationHeader -Append -Force
}
$Sec = 2
# dismount ISO function
function Dismount-ISO {
    Write-Host ""
    Write-Host 'Dismounting file "' -ForegroundColor $Process -NoNewline
    Write-Host "$IsoFile" -ForegroundColor $ProcVar -NoNewline
    Write-Host '"' -ForegroundColor $Process
    Dismount-DiskImage -ImagePath $IsoTarget | Out-Null
    if (!(Test-Path -Path $IsoMount.DriveLetter)) {     # if successfully ejected
        Write-Host ""
        Write-Host 'File "' -ForegroundColor $Result -NoNewline
        Write-Host "$IsoFile" -ForegroundColor $ResultVar -NoNewline
        Write-Host '" dismounted' -ForegroundColor $Result
        Start-Sleep $Sec
        Write-Host ""
    }
    elseif ((Test-Path -Path $IsoMount.DriveLetter)) {  # if not ejected
        Write-Host ""
        Write-Host "Unable to dismount " -ForegroundColor $ErrorResult -NoNewline
        Write-Host "$IsoFile" -ForegroundColor $ErrorVar -NoNewline
        Write-Host " from " -ForegroundColor $ErrorResult -NoNewline
        Write-Host "$($IsoMount.DriveLetter)" -ForegroundColor $ErrorVar -NoNewline
        Write-Host ", please eject manually" -ForegroundColor $ErrorResult
        Start-Sleep $Sec
        Write-Host ""
    }
}

# wim path split
function Get-WimPath {
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]
        $WimOut
    )
    # WimFile is end of WimOut path
    $WimFile =      $WimOut -split "(\\)" | Select-Object -Last 1
    # WimPath is directory path
    $WimPath =      $WimOut.Replace("$WimFile", "")
    $WimPath | Out-Null
}
function Write-BadInput {
    param (
        [Parameter(Mandatory)]
        [string]$InputString,
        [string]$BInput,
        [String]$SelectionType
    )
    Write-Error "Invalid input: $InputString" -Category InvalidData
    Write-Host "Bad input received (" -ForegroundColor $ErrorResult -NoNewline
    Write-Host "$InputString" -ForegroundColor $ErrorVar -NoNewline
    Write-Host "), please type only a valid $BInput from the $SelectionType" -ForegroundColor $ErrorResult
    Start-Sleep $Sec
    Reset-Variables
}
function Reset-Variables {
    $global:i=0
    $BadInput = $true
}

# colours
    # process text
    $Process =      "DarkYellow"
    $ProcVar =      "Yellow"
    # result Text
    $Result =       "Green"
    $ResultVar =    "Blue"
    # prompt
    $Prompt =       "DarkMagenta"
    $UserInput =    "Red"
    # errors
    $ErrorResult =  "Red"
    $ErrorVar =     "DarkRed"
#

# remove extranious quotes from parameters
if ($Iso -match "`"*`"") {
    $Iso = $Iso.Replace('"','')
}
if ($WimOut -match "`"*`"") {
    $WimOut = $WimOut.Replace('"','')
}

<# Start Script #>
Reset-Variables

# check ISO exists
if ((Test-Path -Path "$Iso")) {                     # Does the ISO exist?
    # check syntax of $Iso Path
    if ($Iso -notlike "*.ISO") { # if $Iso is only dir path
        while ($true) {
            Reset-Variables
            $IsoCheck = Get-ChildItem -Path $Iso -filter *win*.iso | Select-Object -Property Name,Fullname
            $IsoCheck | Select-Object @{Name="Item";Expression={$global:i++;$global:i}}, Name -OutVariable menu | Format-Table -AutoSize
            $IsoR = $(Write-Host "Please select file index (number), or type " -ForegroundColor $Prompt -NoNewline) + $(Write-Host '0' -ForegroundColor $UserInput -NoNewline) + $(Write-Host ' or ' -ForegroundColor $Prompt -NoNewline)  + $(Write-Host 'Q' -ForegroundColor $UserInput -NoNewline) + $(Write-Host " to quit: " -ForegroundColor $Prompt -NoNewline) + $(Read-Host)
            if ($IsoR -eq 0 -or $IsoR -eq 'q') {
                Write-Host 'Quitting' -ForegroundColor $Process
                exit 0
            } elseif ($IsoR -gt $IsoGet.Count) { #Is that number too high?
                $BadInput = $true
            } else {
                $IsoGet = $Menu | Where-Object ($_.item -eq $IsoR)
                #IsoTarget is full path
                $IsoTarget =    $IsoGet.FullName
                #IsoFile is file name
                $IsoFile =      $IsoGet.Name
                break
            }
            if ($BadInput) {                                    # loop back if bad input
                Write-BadInput -InputString $IsoR -BInput 'number' -SelectionType 'Item column'
            }
        } else {    # if full .ISO path
            #IsoTarget is full path
            $IsoTarget =    $Iso
            #IsoFile is file name
            $IsoFile =      $Iso -split "(\\)" | Select-Object -Last 1
            break
        }
    }

    #Clear variable in case you're running this again
    Reset-Variables

    # mount .ISO
    Write-Host ""
    Write-Host 'Mounting "'  -ForegroundColor $Process -NoNewline
    Write-Host "$IsoTarget" -ForegroundColor $ProcVar -NoNewline
    Write-Host '"...'  -ForegroundColor $Process
    $IsoMount = Mount-DiskImage -ImagePath "$($IsoTarget)" | Get-Volume
    Start-Sleep $Sec
    # check for drive letter assignment
    #can't find it
    if ($null -eq $IsoMount.DriveLetter) {
        Write-Error ".ISO not mounted" -Category ObjectNotFound
        Start-Sleep $Sec
        exit 1
    } else { # found it!
        Write-Host ""
        Write-Host 'File "' -ForegroundColor $Result -NoNewline
        Write-Host "$IsoFile" -ForegroundColor $ResultVar -NoNewline
        Write-Host '" mounted as "' -ForegroundColor $Result -NoNewline
        Write-Host "$($IsoMount.DriveLetter):" -ForegroundColor $ResultVar -NoNewline
        Write-Host '"' -ForegroundColor $Result
        Start-Sleep $Sec
    }
    # find the .wim
    $WimTarget = "$($IsoMount.DriveLetter):\sources\install.wim"
    Write-Host ""
    Write-Host 'Searching for "' -ForegroundColor $Process -NoNewline
    Write-Host "$WimTarget" -ForegroundColor $ProcVar -NoNewline
    Write-Host '"...' -ForegroundColor $Process
    Start-Sleep $Sec
    # look for $WimTarget
    # can't find it
    if (!(Test-Path -Path $WimTarget)) {
        Write-Error "Unable to locate install.wim - please check .ISO is mounted"
        Dismount-ISO
        Write-Host ""
        exit 1
    } else { # found it!
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
        $Index =                $(Write-Host "Please select image index (number), or type " -ForegroundColor $Prompt -NoNewline) + $(Write-Host '0' -ForegroundColor $UserInput -NoNewline) + $(Write-Host ' or ' -ForegroundColor $Prompt -NoNewline)  + $(Write-Host 'Q' -ForegroundColor $UserInput -NoNewline) + $(Write-Host " to quit: " -ForegroundColor $Prompt -NoNewline) + $(Read-Host)
        $BadInput =             $true                       # assume the input is bad until proven otherwise
        if ($Index -eq '0' -or $Index -eq 'Q') {            # if 0 or Q entered, dismount & exit loop
            Dismount-ISO
            exit 1
        } elseif ($Index -match '^\d+$') {                  # make sure $Index is only a numeral
            # convert variables to integers for comparison
            $IndexTop =         [int]$IndexList.Count
            $IndexSelection =   [int]$Index
            if ($IndexSelection -le $IndexTop) {            # test if the input is numeric and is in range
                # remove bad input tag & get image details
                $BadInput =     $false
                Write-Host ""
                Write-Host "Getting image details..."
                $WinEd = Get-WindowsImage -ImagePath "$WimTarget" -Index "$Index"
                Start-Sleep $Sec
                # confirm selection
                Write-Host ""
                Write-Host 'Index "' -ForegroundColor $Result -NoNewline
                Write-Host "$Index" -ForegroundColor $ResultVar -NoNewline
                Write-Host '" selected, image edition is "' -ForegroundColor $Result -NoNewline
                Write-Host "$($WinEd.ImageName)" -ForegroundColor $ResultVar -NoNewline
                Write-Host '"' -ForegroundColor $Result
                if ($WinEd.ImageName[-1] -eq 'N') {
                    Write-Host ""
                    Write-Host 'ATTENTION:'  -ForegroundColor $ErrorResult -NoNewline
                    Write-Host ' Windows edition is "'-ForegroundColor $ProcVar -NoNewline
                    Write-Host 'N' -ForegroundColor $ErrorVar -NoNewline
                    Write-Host '" (Not with Media Player).' -ForegroundColor $ProcVar
                    Write-Host '           Please ensure ' -ForegroundColor $ProcVar -NoNewline
                    Write-Host 'N' -ForegroundColor $ErrorVar -NoNewline
                    Write-Host ' is desired version.' -ForegroundColor $ProcVar
                }
                Write-Host ""
                $Confirm =      $(Write-Host "Do you want to proceed (" -ForegroundColor $Prompt -NoNewline) + $(Write-Host "Y" -ForegroundColor $UserInput -NoNewline) + $(Write-Host "/" -ForegroundColor $Prompt -NoNewline) + $(Write-Host "N" -ForegroundColor $UserInput -NoNewline) + $(Write-Host ")? " -ForegroundColor $Prompt -NoNewline) + $(Read-Host)
                # if yes, escape loop
                if ($Confirm -eq 'y' -or $Confirm -eq 'yes') {
                    break
                }
            }
        }
        if ($BadInput) {                                    # loop back if bad input
            Write-BadInput -InputString $Index -BInput 'number' -SelectionType 'ImageIndex column'
        }
    }
    Reset-Variables
    # check syntax of $WimOut
    # if $WimOut not a .wim file, set the file name
    if ($WimOut -notlike "*.wim") {                                             # if $WimOut isn't .wim, let's name the file
        if (Test-Path $WimOut) {                                                # does $WimOut exist?
            $DateTime =     Get-Date -Format "%y%MM%ddHHmm"
            $WinName =      ($WinEd.ImageName).Replace(' ','.')
            $WimOut =       "$WimOut\$WinName.$DateTime.wim"
        } else {                                                                # if not, would you like to make it?
            Write-Host ""
            Write-Host "Output path " -ForegroundColor $ErrorResult -NoNewline
            Write-Host "$WimOut"  -ForegroundColor $ErrorVar -NoNewline
            Write-Host " not found." -ForegroundColor $ErrorResult
            Start-Sleep $Sec
            # prompt $Wimout creation
            Write-Host ""
            $Confirm =      $(Write-Host 'Create directory "' -ForegroundColor $Prompt -NoNewline) + $(Write-Host "$WimOut" -ForegroundColor $ResultVar -NoNewline) + $(Write-Host '" (' -ForegroundColor $Prompt -NoNewline) + $(Write-Host "Y" -ForegroundColor $UserInput -NoNewline) + $(Write-Host "/" -ForegroundColor $Prompt -NoNewline) + $(Write-Host "N" -ForegroundColor $UserInput -NoNewline) + $(Write-Host ")? " -ForegroundColor $Prompt -NoNewline) + $(Read-Host)
            if ($Confirm -eq 'y' -or $Confirm -eq 'yes') {                      #Yes
                Get-WimPath
                New-Item -Path "$WimPath" -ItemType Directory -Force
            } else {                                                            # quit
                Dismount-ISO
                exit 1
            }
        }
    } elseif ($WimOut -like "*.wim") {                                          # if $WimOut is .wim, carry on
        Get-WimPath
        if (Test-Path $WimPath) {                                               # required path exists
            $WimOut = $WimOut
        } else {                                                                # if not, you wanna make it?
            Write-Host ""
            Write-Host "Output path " -ForegroundColor $ErrorResult -NoNewline
            Write-Host "$WimPath"  -ForegroundColor $ErrorVar -NoNewline
            Write-Host " not found." -ForegroundColor $ErrorResult
            Start-Sleep $Sec
            $Confirm =      $(Write-Host 'Create directory "' -ForegroundColor $Prompt -NoNewline) + $(Write-Host "$WimPath" -ForegroundColor $ResultVar -NoNewline) + $(Write-Host '" (' -ForegroundColor $Prompt -NoNewline) + $(Write-Host "Y" -ForegroundColor $UserInput -NoNewline) + $(Write-Host "/" -ForegroundColor $Prompt -NoNewline) + $(Write-Host "N" -ForegroundColor $UserInput -NoNewline) + $(Write-Host ")? " -ForegroundColor $Prompt -NoNewline) + $(Read-Host)
            if ($Confirm -eq 'y' -or $Confirm -eq 'yes') {                      # create output directory
                Write-Host ""
                Write-Host "Creating " -ForegroundColor $Process -NoNewline
                Write-Host "$WimPath" -ForegroundColor $ProcVar -NoNewline
                Write-Host "..." -ForegroundColor $Process
                New-Item -Path $WimPath -ItemType Directory -Force
            } else {                                                            # quit
                Dismount-ISO
                exit 1
            }
        }
    }
    # export image
    Write-Host ""
    Write-Host "Exporting Image..." -ForegroundColor $Process
    Export-WindowsImage -SourceImagePath "$WimTarget" -SourceIndex $WinEd.ImageIndex -DestinationImagePath "$WimOut" | Out-Null
    if ((Test-Path -Path $WimOut)) {                                            # check .wim has written to $WimOut
        Write-Host ""
        Write-Host 'Image extracted to "' -ForegroundColor $Result -NoNewline
        Write-Host "$WimOut" -ForegroundColor $ResultVar -NoNewline
        Write-Host '"' -ForegroundColor $Result
        Start-Sleep $Sec
    } else {                                                                    # nope, can't find it
        Write-Error "$WimOut not found" -Category ObjectNotFound
        Write-Host "Unable to write to " -ForegroundColor $ErrorResult -NoNewline
        Write-Host "$WimOut" -ForegroundColor $ErrorVar -NoNewline
        Write-Host ", please check permissions and try again" -ForegroundColor $ErrorResult
        Start-Sleep $Sec
    }
    
    Dismount-ISO                                                                # dismount .iso

} else {                                                                        # if .iso doesn't exist
    Write-Host ""
    Write-Error -Message "$Iso not found" -Category ObjectNotFound
    Write-Host ""
    Write-Host "Unable to find " -ForegroundColor $ErrorResult -NoNewline
    Write-Host "$Iso" -ForegroundColor $ErrorVar -NoNewline
    Write-Host ", please check file path" -ForegroundColor $ErrorResult
    Start-Sleep $Sec
}

if ($Log) {
    Stop-Transcript
}
<# End Script #>
