function Select-NotCDrive {
    param(
        [string]$DriveName
    )
    if ($null -ne $DriveName) { #preferred drive
        if (Get-PSDrive -Name $DriveName){
            $Drv = $DriveName
        }
    } elseif (-not(Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Root -ne "C:\"})) { #if only C available
        $Drv = $env:SystemDrive
    } else { #select 1st available not-C drive
        $Drv = (Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Root -ne "C:\" -and -$null -ne $_.Free} | Select-Object -First 1).Name + ':' 
    }
}
