function Write-DirSize {
  <#
  Writes the size of the specified directory in  human-readable format
  Written by Bill, 28/01/2026
  References;
    https://4sysops.com/archives/do-the-math-with-powershell/
    https://www.reddit.com/r/PowerShell/comments/s2s2vw/running_through_an_array_twice_once_forward_and/
  #>
    param (
        [Parameter(Mandatory)]
        [string] $Path
    )
    
    [int64] $Size = (Get-ChildItem -Path $Path -File -Recurse | Measure-Object -Property Length -Sum).Sum
    $DataMeasures = @(
        [PSCustomObject]@{Name = 'bit';        Abbv = 'b';  Val = (1 / 8)                 }
        [PSCustomObject]@{Name = 'nybble';     Abbv = 'nb'; Val = 0.5                     }
        [PSCustomObject]@{Name = 'byte';       Abbv = 'B';  Val = 1                       }
        [PSCustomObject]@{Name = 'kilobyte';   Abbv = 'KB'; Val = 1KB                     }
        [PSCustomObject]@{Name = 'megabyte';   Abbv = 'MB'; Val = 1MB                     }
        [PSCustomObject]@{Name = 'gigabyte';   Abbv = 'GB'; Val = 1GB                     }
        [PSCustomObject]@{Name = 'terabyte';   Abbv = 'TB'; Val = 1TB                     }
        [PSCustomObject]@{Name = 'petabyte';   Abbv = 'PB'; Val = 1PB                     }
        [PSCustomObject]@{Name = 'exabyte';    Abbv = 'EB'; Val = ([Math]::Pow(1024,6))   }
        [PSCustomObject]@{Name = 'zettabyte';  Abbv = 'ZB'; Val = ([Math]::Pow(1024,7))   }
        [PSCustomObject]@{Name = 'yottabyte';  Abbv = 'YB'; Val = ([Math]::Pow(1024,8))   }
        [PSCustomObject]@{Name = 'ronnabyte';  Abbv = 'RB'; Val = ([Math]::Pow(1024,9))   }
        [PSCustomObject]@{Name = 'quettabyte'; Abbv = 'QB'; Val = ([Math]::Pow(1024,10))  }
    )
    [array]::reverse($DataMeasures)

    foreach ($Measure in $DataMeasures) {
        $Global:DirSize = $Size / $Measure.Val
        if ($DirSize -ge 1) {
            [string]$String = [math]::Round($DirSize,1) + $Measure.Name
            Write-Output "Path is $String" 
        }
    }
    if ($DirSize -le 1) {
        Write-Output 'Path size is impossibly huge. What are you even doing?'
    }
}
