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
    $CTemp = "C:\$Temp"
    $Cabs = (Get-ChildItem -Path $CTemp -Recurse -Filter *.cab) | Sort-Object -Property LastWriteTime                           #find.cab files
    
    foreach ($Cab in $Cabs) {
        $CabCheck = $($Cab.Name).Substring(12,9)                                                                                #this should extract the KB number
        if (!((Get-HotFix -Id $CabCheck -ErrorAction SilentlyContinue) -or $0x800f081es -contains $CabCheck)) {                 #this checks if the KB has already been applied
            $Space
            Write-Host "Adding $CabCheck"
            Write-Host "Started $(Get-Date -Format "dd/mm/yy HH:MM:ss")" -ForegroundColor DarkGreen -BackgroundColor Green      #sometimes these take a while, so it's good to log when they start
            Add-WindowsPackage -PackagePath $Cab.FullName -Online -NoRestart -ErrorAction SilentlyContinue                      #add it
            if (!($error[0].Exception -match $FailedMsg)) {                                                                     #if it flicks a 0x800f081e error, the .cab is for a different OS
                $0x800f081es = $0x800f081es + $CabCheck
                Write-Host $FailedMsg             -ForegroundColor Red  -BackgroundColor DarkRed
                Write-Host "$Cabcheck"            -ForegroundColor Gray -BackgroundColor DarkRed -NoNewline
                Write-Host ' not applicable'      -ForegroundColor Red  -BackgroundColor DarkRed
                Write-Host 'CBS_E_NOT_APPLICABLE' -ForegroundColor Red
            } else {
                Write-Host "Finished $(Get-Date -Format "dd/mm/yy HH:MM:ss")" -ForegroundColor Green -BackgroundColor DarkGreen #mark when it's finished
            }
        } else {
            $Space
            Write-Host "$CabCheck already present" -ForegroundColor Yellow -BackgroundColor DarkYellow                          #mark it as already installed
        }
    }
    Remove-Item -Path $CTemp -Recurse -Force                                                                                    #delete the local .cab folder
}

#Variables
$Domain         = ".$(((Get-CimInstance -ClassName Win32_ComputerSystem).Domain).Split('.')[0])"                                #so you can remove the domain nmame from an CSV list from SCCM reporting
$CabFiles       = Get-ChildItem -Path $SourceDir -Filter *.cab -Recurse                                                         #count how many files are on the source dir
$Space          = Write-Output ''                                                                                               #makes to easier to see gaps in output
$FailedMsg      = 'Add-WindowsPackage failed. Error Code = 0x800f081e'                                                          #error mesage for .cab installs for wrong OS
$0x800f081es    = @()                                                                                                           #array for errored .cab installs
$Online         = @()                                                                                                           #array for online servers
$Offline        = @()                                                                                                           #array for offline servers
Write-Count -ObjectDescription 'servers' -Object $ServerList                                                                    #How many servers are in our list?
$Space

#Test Connection
foreach ($Server in $ServerList) {
    if ($Server -match "*$Domain") {                                                                                            #remove the domain name from servername, e.g. Server01-Test.Domain.Local
        $Server = $Server -replace $Domain
    }
    if (Test-Connection -ComputerName $Server -ErrorAction SilentlyContinue) {                                                  #is it online?
        $Online = $Online + $Server
    } else {
        $Offline = $Offline + $Server
    }
}                                                                                                                               #display results
Write-Count -ObjectDescription 'servers offline' -Object $Offline -Report
Write-Count -ObjectDescription 'servers online'  -Object $Online  -Report -Positive
if ($Offline.Count -eq $Servers.Count -or $Online.Count -lt 1) {                                                                #if nmothing's online, we're done
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
    $DestDir = "\\$($Good)\c$\$Temp"
    $Space
    Write-Host "Copying $($CabFiles.count) files to $DestDir" -ForegroundColor Grey -BackgroundColor Black
    try { Copy-Item -Path $CabDir -Destination $DestDir -Recurse -Force                                                         #let's copy files
        try{                                                                                                                    #can we connect remotely?
            Write-Output "Connecting to $Good"
            Enter-PSSession $Good
            Add-Cabs
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
        Write-Host "Unable to connect to $DestDir" -ForegroundColor Black -BackgroundColor Red
        $DirBad = $DirBad + $Good
    }
}
$Space
