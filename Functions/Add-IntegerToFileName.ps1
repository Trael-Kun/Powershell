function Add-IntegerToFileName {
    <#
    .SYNOPSIS
        Automatically checks for the existence of a file, and if file is present will append a 
        number to the end of a new filename.
    .DESCRIPTION
        Scans destination folder for existing files with the same name, and if found will create 
        a new name appended with leading zeros (default value is 5). 
    .NOTES
        Author: Bill Wilson
        Date:   29/10/2024
        References;
         https://forums.powershell.org/t/create-filename-incrementing-number/11042/9
         https://collectingwisdom.com/powershell-get-file-extension/
         https://stackoverflow.com/questions/9788492/powershell-extract-file-name-and-extension
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$OutputFile,
        [Parameter(Mandatory=$false)]
        [int]$Zeros
    )
    if ($OutputFile -notlike "*.???") {
        Write-Host ''
        Write-Host "Invalid file path - please enter full path to file" -ForegroundColor Red
    } else {
        do {
            if (Test-Path $OutputFile) {
                Write-Output "$OutputFile exists, creating new file."
                if ($null -eq $Zeros) {
                    $Zeros = 5
                }
                #split the file path into segments for easier processing
                $OutputFileInfo = Get-Item $OutputFile
                $OutputDir      = Split-Path -Path $OutputFileInfo.FullName -Parent
                $OutputFileName = Split-Path -Path $OutputFileInfo.FullName -Leaf
                $FileExt        = [System.IO.Path]::GetExtension($OutputFileInfo)
                $OutputFileBase = $OutputFileName.Replace("$FileExt",'')
                if ($null -eq $FileExt) {   #Redundancy to make sure the above worked (constrained language mode is a @!#?@!)
                    $FileExt        = $OutputFileInfo.Extension
                    $OutputFileBase = $OutputFileInfo.BaseName
                }
            
                #look for files (wildcard to look for existing numbered files)
                $Files = (Get-ChildItem -Path $OutputDir -Filter "$OutputFileBase*$FileExt").FullName
            
                if ($Files) {
                    #report how many files are found, because I'm a grammar nazi
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
                    $Number = $Number.ToString().PadLeft($Zeros,'0')
                    Write-Host "Number is '$number'"
                        if (($null -eq $Number) -or ($Number -eq '')) {
                            $Numerous += '0'
                        } else {
                            $NumNum = "{0:d$Zeros}" -f $Number
                            $Numerous += ($NumNum)
                        }
                    }
                
                    #Take the highest number and then increment by 1
                    [int]$Max = ($Numerous | Sort-Object -Descending | Select-Object -First 1)
                    $Max ++
                    Write-Output "The next number is $Max"
                
                    #Use padding to pad zeros up to 5 characters
                    $File = "$OutputFileBase{0}$FileExt" -f $Max.ToString().PadLeft($Zeros,'0')
                    "Incrementing to $Max`: File will be named $File"
                    $OutputFile = Join-Path -Path $OutputDir -ChildPath $File
                } 
            } else {
                Write-Host "$OutputFile not found, OK to create." -ForegroundColor Green
            }       
        } until (!(Test-Path $OutputFile))
    } Return $OutputFileNew
}
