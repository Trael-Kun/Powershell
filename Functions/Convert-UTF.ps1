function Convert-UTF {
    param(
    [ValidateNotNullorEmpty()]
    [string]$Files
    )

    $FileProg   = 0
    $FileCount  = $Files.Count
    $CharMap    = (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Trael-Kun/Powershell/refs/heads/main/Data/charmap.csv').Content | ConvertFrom-Csv
    $CharCount  = $CharMap.Count

    foreach ($File in $Files) { 
        Write-Progress -Activity 'Processing Filenames' -PercentComplete (($FileProg/$FileCount)*100) -Id 1
        
        $CharProg = 0
        foreach ($Char in $CharMap) {   #if the name contains UTF-8 or Windows-1252 character mapping, replace with corresponding character
            $Utf8       = $Char.UTF
            $Win1252    = $Char.Windows
            $Character  = $Char.Character
            #increase progress counter
            $CharProg   = $CharProg++
            Write-Progress -Activity 'Formatting Filename' -PercentComplete (($CharProg/$CharCount)*100) -Id 2 -ParentId 1
            if ($File -like "*$($Char.UTF)*") {
                Write-Progress -Activity "Replacing `"$Utf8`" with `"$Character`"" -Id 3 -ParentId 2 -Completed
                $FileName = $Filename.replace($Utf8,$Character)
            } elseif ($File -like "*$($Char.Windows)*") {
                Write-Progress -Activity "Replacing `"$Win1252`" with `"$($Char.Character)`"" -Id 3 -ParentId 2 -Completed
                $FileName = $Filename.replace($Win1252,$Character)
            }
        }
    }
}
