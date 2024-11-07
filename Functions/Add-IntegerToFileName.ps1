function Add-IntegerToFileName {
    <#
    .SYNOPSIS
        Automatically checks for the existence of a file, and if file is present will append a number to the end of a new filename.
    .NOTES
        Author: Bill Wilson
        Date:   29/10/2024
        References;
         https://forums.powershell.org/t/create-filename-incrementing-number/11042/9
         https://collectingwisdom.com/powershell-get-file-extension/
    #>
    param(
        [string]$OutputFile
    )
    if ($OutputFile -notlike "*.???") {
        Write-Host ''
        Write-Host "Invalid file path - please enter full path to file" -ForegroundColor Red
    } else {
        do {
            if (Test-Path $OutputFile) {
                Write-Output "$OutputFile exists, creating new file."
            
                #split the file path into segments
                $OutputDir      = Split-Path -Path $OutputFile -Parent
                $OutputFileName = Split-Path -Path $OutputFile -Leaf
                $FileExt        = [System.IO.Path]::GetExtension($OutputFile)
                $OutputFileBase = $OutputFileName.Replace("$FileExt",'')
            
                #look for files
                $Files = (Get-ChildItem -Path $OutputDir -Filter "$OutputFileBase*$FileExt").FullName
            
                if ($Files) {
                    #Report how many files are found, because I'm a grammar nazi
                    if ($Files.Count -eq 1) {
                        $Fileses = 'file'
                    } else {
                        $Fileses = 'files'
                    }
                    Write-Output "Found $($Files.Count) existing $Fileses"
                
                    #remove the filename and making it a integer, so only a number is returned
                    $Numbers = ((Split-Path -Path $Files -Leaf).Replace("$FileExt",'')).Replace("$OutputFileBase",'')
                    $Numerous = @()
                    foreach ($Number in $Numbers) {
                    $Number = $Number.ToString().PadLeft(5,'0')
                    Write-Host "Number is '$number'"
                        if (($null -eq $Number) -or ($Number -eq '')) {
                            $Numerous += '0'
                        } else {
                            $NumNum = '{0:d5}' -f $Number
                            $Numerous += ($NumNum)
                        }
                    }
                
                    #Take the number and then increment by 1
                    [int]$Max = ($Numerous | Sort-Object -Descending | Select-Object -First 1)
                    $Max ++
                    Write-Output "The next number is $Max"
                
                    #Use padding to pad zeros up to 5 characters
                    $File = "$OutputFileBase{0}$FileExt" -f $Max.ToString().PadLeft(5,'0')
                    "Incrementing $Max to generate file $File"
                    $OutputFile = Join-Path -Path $OutputDir -ChildPath $File
                } 
            } else {
                Write-Output "$OutputFile not found, OK to create."
            }       
        } until (!(Test-Path $OutputFile))
    } Return $OutputFileNew
}
