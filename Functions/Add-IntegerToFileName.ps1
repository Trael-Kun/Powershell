function Add-IntegerToFileName {
    <#
    .SYNOPSIS
        Automatically checks for the existence of a file, and if file is present will append a 
        number to the end of a new filename.
    .DESCRIPTION
        Scans destination folder for existing files with the same base name, and if found will create 
        a new name appended with leading zeros (default value is 5). For example, if File.txt is found, 
        the newly generated filename will be "File00001.txt", and if "File00001".txt is found the new name 
        will be "File00002.txt", etc.
        This will also occur with files with ANY numbers before the file extension, for example "File2.txt" 
        would output a new filename of "File00003.txt"
    .PARAMETER OutputFile
        Specifies the path to the file to be checked. Be sure to enter the full file path with extension.
    .PARAMETER Zeros
        Defines the number of digits to add to the file name. Defaults to 5 (e.g. File00001.txt)
    .EXAMPLE
        C:\PS> Add-IntegerToFileName -OutputFile C:\Temp\File.txt
        Searches for files in C:\Temp with names like "File.txt", "File1.txt", "File003.txt", etc.
        If found, creates a new file name the the highest number found +1, i.e. "File00001.txt"
    .EXAMPLE
        C:\PS> Add-IntegerToFileName -OutputFile C:\Temp\File3.txt
        Searches for files in C:\Temp with names like "File.txt", "File1.txt", "File003.txt", etc.
        If found, creates a new file name the the highest number found +1, i.e. "File00004.txt"
    .EXAMPLE
        C:\PS> Add-IntegerToFileName -OutputFile C:\Temp\File.txt -Zeros 3
        Searches for files in C:\Temp with names like "File.txt", "File1.txt", "File003.txt", etc.
        If found, creates a new file name the the highest number found +1, i.e. "File001.txt"
    .NOTES
        Author: Bill Wilson
        Date:   29/10/2024
        References;
         https://forums.powershell.org/t/create-filename-incrementing-number/11042/9
         https://collectingwisdom.com/powershell-get-file-extension/
         https://stackoverflow.com/questions/9788492/powershell-extract-file-name-and-extension
    #>
    param(
        [Parameter(Mandatory=$true,
        HelpMessage='File path to check')]
        [string]$OutputFile,
        [Parameter(Mandatory=$false,
        HelpMessage='Number of digits for the number segment of the name')]
        [int]$Zeros
    )
    #check for file extension
    if (($OutputFile -notlike "*.??") -or ($OutputFile -notlike "*.???") -or ($OutputFile -notlike "*.????")) {
        Write-Host ''
        Write-Host "Invalid file path - please enter full path to file" -ForegroundColor Red
    } else {
        do { #keep doing until a file name is found that doesn't exist
            if (Test-Path $OutputFile) {
                Write-Output "$OutputFile exists, creating new file."
                if ($null -eq $Zeros) { #if variable isn't defined, default to 5
                    $Zeros = 5
                }

                #split the file path into segments for easier processing
                $OutputFileInfo = Get-Item $OutputFile                              #Get file info
                $OutputDir      = Split-Path -Path $OutputFileInfo.FullName -Parent #Get folder path
                $OutputFileName = Split-Path -Path $OutputFileInfo.FullName -Leaf   #Get file name
                $FileExt        = $OutputFileInfo.Extension                         #Get file extension
                $OutputFileBase = $OutputFileInfo.BaseName                          #Get file base name
                #redundancy to make sure the above worked (constrained language mode is a @!#?@!)
                if ($null -eq $FileExt) {   
                    $FileExt        = [System.IO.Path]::GetExtension($OutputFileInfo)
                    $OutputFileBase = $OutputFileName.Replace("$FileExt",'')
                }
            
                #look for files (incl. wildcard to look for existing numbered files)
                $Files = (Get-ChildItem -Path $OutputDir -Filter "$OutputFileBase*$FileExt").FullName
            
                if ($Files) {
                    #report how many files are found
                    if ($Files.Count -eq 1) {   #because I'm a grammar nazi
                        $Fileses = 'file'
                    } else {
                        $Fileses = 'files'
                    }
                    Write-Output "Found $($Files.Count) existing $Fileses"
                
                    #remove the filename and making it a integer, so only a number is returned
                    $Numbers = ((Split-Path -Path $Files -Leaf).Replace("$FileExt",'')).Replace("$OutputFileBase",'')
                    $Numerous = @()
                    foreach ($Number in $Numbers) {
                    $Number = $Number.ToString().PadLeft($Zeros,'0')    #pad with zeros
                        if (($null -eq $Number) -or ($Number -eq '')) { #drop a zero into array if no number exists
                            $Numerous += '0'
                        } else {                                        #drop the number into array
                            $NumNum = "{0:d$Zeros}" -f $Number
                            $Numerous += ($NumNum)
                        }
                    }
                
                    #take the highest number and then increment by 1
                    [int]$Max = ($Numerous | Sort-Object -Descending | Select-Object -First 1)
                    $Max ++
                    Write-Output "The next number is $Max"
                
                    #pad with zeros up to $Zeros characters
                    $File = "$OutputFileBase{0}$FileExt" -f $Max.ToString().PadLeft($Zeros,'0')
                    "Incrementing to $Max`: File will be named $File"
                    #assemble new file path
                    $OutputFile = Join-Path -Path $OutputDir -ChildPath $File
                } 
            } else { #no file found, go ahead
                Write-Host "$OutputFile not found, OK to create." -ForegroundColor Green
            }       
        } until (!(Test-Path $OutputFile))
    } Return $OutputFileNew
}
