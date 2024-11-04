function Add-IntegerToFileName {
    <#
    .SYNOPSIS
        Automatically checks for the existence of a file, and if file is present will append a number to the end of a new filename.
    .NOTES
        Author: Bill Wilson
        Date 29/10/2024
        References;
        https://forums.powershell.org/t/create-filename-incrementing-number/11042/9
        https://collectingwisdom.com/powershell-get-file-extension/
    #>
    param(
        [string]$OutputFile
    )
    if (Test-Path $OutputFile) {
        Write-Log "$OutputFile exists, creating new file"
        #split the file path
        $OutputDir      = Split-Path -Path $OutputFile -Parent
        $OutputFileName = Split-Path -Path $OutputFile -Leaf
        $FileExt = [System.IO.Path]::GetExtension($OutputFile)
        #look for files
        $Files = Get-ChildItem -Path ("{0}\{1}*" -f $OutputDir, $OutputFileName) 
        if ($Files) {
            #Create custom column by removing the F and making it a integer, so only a number is returned
            $Numbers = $Files | Select-Object @{Name="Number";Expression={[int]$_.BaseName.Replace($OutputFileName, "")}}
            "Found {0} existing files" -f $Files.Count
            #Take the number, sort descending, get the first value and then increment by 1
            $Max = ($Numbers | Sort-Object -Property Number -Descending | Select-Object -First 1 -ExpandProperty Number) + 1
            "The next number is {0}" -f $Max
            #Use padding to pad zeros up to 5 characters
            $File = "$OutputFileName{0}.$FileExt" -f $Max.ToString().PadLeft(5,'0')
            "Incrementing {0} to generate file {1}" -f $Max, $File
            $OutputFile = Join-Path -Parent $OutputDir -ChildPath $OutputFileName
        }
    } else {
        "$OutputFile not found, OK to create."
    }
}
