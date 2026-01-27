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
