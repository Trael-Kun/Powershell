<#
    Semi-auto patching
.DESCRIPTION
    Cuts down on manual patching efforts

.NOTES
    Written by    Bill Wilson
    Date          24-02-2025
#>

param {
    [Parameter(Mandatory=$true)]
    [string]$ServerList,                                                                                                        #list of servers
    [string]$SourceDir                                                                                                          #directory containging .cab files, could have been grabbed by SCCM's ADRs
}

function Write-Count{
    param(
        [string]$ObjectDescription,                                                                                             #what's getting written in the Write-Host
        [string]$Object,                                                                                                        #what's getting counted
        [switch]$Positive,                                                                                                      #for good results, defaults to bad colors
        [switch]$Report                                                                                                         #if you want to list the results
    )
    if ($Positive){
        $Fground = 'Green'
        $Bground = 'DarkGreen'
    } else {
        $Fground = 'Red'
        $Bground = 'DarkRed'
    }
    $Space
    Write-Host "Total $($ObjectDescription): $($Object.Count)" -ForegroundColor White -BackgroundColor $Bground
    if ($Report) {
        Write-Host $Object -ForegroundColor $Fground
    }
}

function Add-Cabs {
    $CabStart   = Get-Date -Format "dd/mm/yy HH:MM:ss"
    $CTemp      = "C:\$Temp"
    $CabCount   = 0
    $Cabs       = (Get-ChildItem -Path $CTemp -Recurse -Filter *.cab) | Sort-Object -Property LastWriteTime                     #find.cab files
    Write-Count -ObjectDescription '.cab files' -Object $Cabs.Count -Positive
    Write-Host ".Cab process started $CabStart" -ForegroundColor Cyan -BackgroundColor DarkCyan
    foreach ($Cab in $Cabs) {                                                                                                   #this should extract the KB number
        $CabCount++
        Write-Progress -Activity Installing .cabs -Status $Cab.Name -PercentComplete (($CabCount/$Cabs.Count) * 100) -ParentId 1 -Id 2
        $CabCheck = (($Cab.Name).Split('-') | Select-String -Pattern kb*).ToString()                                                   #we've got the KB, we don't need to keep looking
        if (!((Get-HotFix -Id $CabCheck -ErrorAction SilentlyContinue) -or $Fails -contains $CabCheck)) {                       #this checks if the KB has already been applied
            $Space
            Write-Host "Adding $CabCheck ($CabCount of $($Cabs.Count))"
            Write-Host "Started $(Get-Date -Format "dd/mm/yy HH:MM:ss")"     -ForegroundColor DarkGreen -BackgroundColor Green  #sometimes these take a while, so it's good to log when they start
            Add-WindowsPackage -PackagePath $Cab.FullName -Online -NoRestart -ErrorAction SilentlyContinue                      #add it
            $Oops = $error[0].Exception
            if (!($Oops -in $FailedMsgs)) {                                                                                     #if it flicks a 0x800f081e error, the .cab is for a different OS
                $Fails = $Fails + ([Pscustomobject]@{Server=$Good; KB=$CabCheck; Error=$Oops})
                Write-Host $error[0]                                          -ForegroundColor Red  -BackgroundColor DarkRed
                Write-Host "$Cabcheck"                                        -ForegroundColor Gray -BackgroundColor DarkRed -NoNewline
                Write-Host " not applicable ($CabCount of $($Cabs.Count))"    -ForegroundColor Red  -BackgroundColor DarkRed
            } else {
                Write-Host "Finished $(Get-Date -Format "dd/mm/yy HH:MM:ss")" -ForegroundColor DarkGreen -BackgroundColor Green #mark when it's finished
            }
        } else {
            $Space                                                                                                              #mark it as already installed
            Write-Host "$CabCheck already present ($CabCount of $($Cabs.Count))" -ForegroundColor Yellow -BackgroundColor DarkYellow
        }
    }
    $Space
    Write-Host "Removing local files"
    Remove-Item -Path $CTemp -Recurse -Force                                                                                    #delete the local .cab folder
    $CabSpan = New-Timespan -Start $CabStart
    $Space
    Write-Host ".Cab process finished $(Get-Date -Format "dd/mm/yy HH:MM:ss")"  -ForegroundColor Cyan -BackgroundColor DarkCyan
    Write-Host "Process on $Good took $CabSpan"                                 -ForegroundColor Cyan -BackgroundColor DarkCyan
}

#Variables
$Start          = Get-Date -Format "dd/mm/yy HH:MM:ss"
$Domain         = ".$(((Get-CimInstance -ClassName Win32_ComputerSystem).Domain).Split('.')[0])"                                #so you can remove the domain nmame from an CSV list from SCCM reporting
$CabFiles       = Get-ChildItem -Path $SourceDir -Filter *.cab -Recurse                                                         #count how many files are on the source dir
$Space          = Write-Output ''                                                                                               #makes to easier to see gaps in output
$FailedMsgs     = 'Add-WindowsPackage failed. Error Code = 0x800f081e',                                                         #error mesage for .cab installs for wrong OS
                  'Add-WindowsPackage failed. Error Code = 0x80070490'                                                          #error mesage for .cab installs for a component that was damaged or lost during an update
$Fails          = @()                                                                                                           #array for errored .cab installs
$Online         = @()                                                                                                           #array for online servers
$Offline        = @()                                                                                                           #array for offline servers
$CabCount       = 0
$ServerCount    = 0

Write-Host "Script started $Start" -ForegroundColor DarkCyan -BackgroundColor Cyan
Write-Count -ObjectDescription 'servers' -Object $ServerList                                                                    #How many servers are in our list?
$Space

#Test Connection
foreach ($Server in $ServerList) {
    if ($Server -match "*.$Domain") {                                                                                           #remove the domain name from servername, e.g. Server01-Test.Domain.Local
        $Server = $Server -replace "*.$Domain*"
    }
    if (Test-Connection -ComputerName $Server -ErrorAction SilentlyContinue) {                                                  #is it online?
        $Online = $Online + $Server
    } else {
        $Offline = $Offline + $Server
    }
}                                                                                                                               #display results
Write-Count -ObjectDescription 'servers offline' -Object $Offline -Report
Write-Count -ObjectDescription 'servers online'  -Object $Online  -Report -Positive
if ($Offline.Count -eq $Servers.Count -or $Online.Count -lt 1) {                                                                #if nothing's online, we're done
    $Space
    Write-Host 'No servers online' -ForegroundColor Red
    Write-Host 'Ending Script'
    exit
}

#Test Path
$DirGood    = @()
$DirBad     = @()
foreach ($Dir in $Online) {                                                                                                     #see if you can see the C:\
    "Testing path access"
    if (Test-Path "\\$($Dir)\c$" -ErrorAction SilentlyContinue) {
        $DirGood = $DirGood + $Dir
    } else {
        $DirBad  = $DirBad  + $Dir
    }
}                                                                                                                               #display the results
Write-Count -ObjectDescription 'inaccessible folders' -Object $DirBad  -Report
Write-Count -ObjectDescription 'accessible folders'   -Object $DirGood -Report -Positive
if ($DirBad.Count -eq $Servers.Count -or $DirGood.Count -lt 1) {
    $Space
    Write-Host 'No folders accessible' -ForegroundColor Red
    Write-Host 'Ending Script'
    exit
}

#Copy Files 
$Temp = 'Temp\Cab'
foreach ($Good in $DirGood) {
    $ServerCount++
    Write-Progress -Activity 'Processing' -status $Good -PercentComplete (($ServerCount/$ServerList.count) * 100) -Id 1
    $DestDir = "\\$($Good)\c$\$Temp"
    $Space
    Write-Host "Copying $($CabFiles.count) files to $DestDir" -ForegroundColor Grey -BackgroundColor Black
    try { Copy-Item -Path $CabDir -Destination $DestDir -Recurse -Force                                                         #let's copy files
        try{                                                                                                                    #can we connect remotely?
            Write-Output "Connecting to $Good"
            $G = New-PSSession -ComputerName $Good -ThrottleLimit 1
            Invoke-Command -Session $G -Scriptblock {Add-Cabs}
            Exit-PSSession
        } catch {                                                                                                               #no? Can we send a remote command?
            Write-Host "Unable to connect to server $Good" -ForegroundColor Red
            try{
                Write-Output "Sending command to $Good"
                Invoke-Command -ComputerName $Good -ScriptBlock Add-Cabs 
            } catch {
                Write-Host "Unable to send command to server $Good" -ForegroundColor Red
                $DirBad = $DirBad + $Good
            }
        }
    } catch {
        Write-Host "Unable to connect to $DestDir"      -ForegroundColor Black -BackgroundColor Red
        $DirBad = $DirBad + $Good
    }
}
$Space
Write-Host "Script finished $(Get-Date -Format "dd/mm/yy HH:MM:ss")"                -ForegroundColor DarkCyan -BackgroundColor Cyan
Write-Host "Script took $(New-TimeSpan -Start $Start)"  -ForegroundColor DarkCyan -BackgroundColor Cyan
