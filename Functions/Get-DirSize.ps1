<#
 .DESCRIPTION
  Get the size of a directory in human-readable units
 .NOTES
  Written by Bill 06/03/2026
  References;
   https://en.wikipedia.org/wiki/Units_of_information#Units_derived_from_bit
#>
function Get-DirSize {
    param (
        [Parameter(Mandatory)]
        [string] $Path
    )
    #declare data sizes
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
    [array]::reverse($DataMeasures) #flip the array so we get the most appropriate measurement first

    #run through measurements until it is >=1
    foreach ($Measure in $DataMeasures) {
        $Global:DirSize = $Size / $Measure.Val
        if ($DirSize -ge 1) {
            [string]$String = [math]::Round($DirSize,1) + $Measure.Name
            Write-Output "Path is $String" 
        }
    }
    #if it's not one of the above it's imbossible huge
    if ($DirSize -le 1) {
        Write-Output 'Path size is impossibly huge. What are you even doing?'
    }
}
