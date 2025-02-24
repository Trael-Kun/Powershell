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
    [string]$ServerList,    #list of servers
    [string]$SourceDir      #directory containging .cab files, could have been grabbed by SCCM's ADRs
}

function Write-Count{
    param(
        [string]$ObjectDescription,
        [string]$Object,
        [switch]$Positive,
        [switch]$Report
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
    $Cabs = (Get-ChildItem -Path $CTemp -Recurse -Filter *.cab) | Sort-Object -Property LastWriteTime
    foreach ($Cab in $Cabs) {
        $CabCheck = $($Cab.Name).Substring(12,9)
        if (!((Get-HotFix -Id $CabCheck -ErrorAction SilentlyContinue) -or $0x800f081es -contains $CabCheck)) {
            $Space
            Write-Host "Adding $CabCheck"
            Write-Host "Started $(Get-Date -Format "dd/mm/yy HH:MM:ss")" -ForegroundColor DarkGreen -BackgroundColor Green
            Add-WindowsPackage -PackagePath $Cab.FullName -Online -NoRestart -ErrorAction SilentlyContinue
            if (!($error[0].Exception -match $FailedMsg)) {
                $0x800f081es = $0x800f081es + $CabCheck
                Write-Host $FailedMsg             -ForegroundColor Red  -BackgroundColor DarkRed
                Write-Host "$Cabcheck"            -ForegroundColor Gray -BackgroundColor DarkRed -NoNewline
                Write-Host ' not applicable'      -ForegroundColor Red  -BackgroundColor DarkRed
                Write-Host 'CBS_E_NOT_APPLICABLE' -ForegroundColor Red
            } else {
                Write-Host "Finished $(Get-Date -Format "dd/mm/yy HH:MM:ss")" -ForegroundColor Green -BackgroundColor DarkGreen
            }
        } else {
            $Space
            Write-Host "$CabCheck already present" -ForegroundColor Yellow -BackgroundColor DarkYellow
        }
    }
    Remove-Item -Path $CTemp -Recurse -Force
}

#Variables
$Domain         = ".$(((Get-CimInstance -ClassName Win32_ComputerSystem).Domain).Split('.')[0])"
$CabFiles       = Get-ChildItem -Path $SourceDir -Filter *.cab -Recurse
$Space          = Write-Output ''
$FailedMsg      = 'Add-WindowsPackage failed. Error Code = 0x800f081e'
$0x800f081es    = @()
$Online         = @()
$Offline        = @()
Write-Count -ObjectDescription 'servers' -Object $ServerList
$Space

#Test Connection
foreach ($Server in $ServerList) {
    if ($Server -match "*$Domain") {
        $Server = $Server -replace $Domain
    }
    if (Test-Connection -ComputerName $Server -ErrorAction SilentlyContinue) {
        $Online = $Online + $Server
    } else {
        $Offline = $Offline + $Server
    }
}
Write-Count -ObjectDescription 'servers offline' -Object $Offline -Report
Write-Count -ObjectDescription 'servers online'  -Object $Online  -Report -Positive
if ($Offline.Count -eq $Servers.Count -or $Online.Count -lt 1) {
    $Space
    Write-Host 'No servers online' -ForegroundColor Red
    Write-Host 'Ending Script'
    exit
}

#Test Path
$DirGood    = @()
$DirBad     = @()
foreach ($Dir in $Online) {
    "Testing path access"
    if (Test-Path "\\$($Dir)\c$" -ErrorAction SilentlyContinue) {
        $DirGood = $DirGood + $Dir
    } else {
        $DirBad  = $DirBad  + $Dir
    }
}
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
    try { Copy-Item -Path $CabDir -Destination $DestDir -Recurse -Force
        try{ 
            Write-Output "Connecting to $Good"
            Enter-PSSession $Good
            Add-Cabs
        } catch {
            Write-Host "Unable to connect to server $Good" -ForegroundColor Red
            try{
                Write-Output "Sending command to $Good"
                Invoke-Command -ComputerName $Good -ScriptBlock Add-Cabs
            } catch {
                Write-Host "Unable to send commands to server $Good" -ForegroundColor Red
                $DirBad = $DirBad + $Good
            }
        }
    } catch {
        Write-Host "Unable to connect to $DestDir" -ForegroundColor Black -BackgroundColor Red
        $DirBad = $DirBad + $Good
    }
}
$Space
