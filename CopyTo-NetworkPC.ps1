<#
copy a file from local folder to remote PC with different credentials

Bill
02/01/24

https://stackoverflow.com/questions/612015/copy-item-with-alternate-credentials
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-psdrive?view=powershell-7.4
#>

#Computers
$PCs = @(
    "W001",
    "W002",
    "W042",
    "W104",
    "L246"
)
#Credentials
$Cred = Get-Credential
#Folder where your file/s at
$SourceDir = "C:\Temp"
#File name, use "" for full directory
$SourceFile = "Words.txt"
#Drive letter
$DriveLetter = "J"

foreach ($PC in $PCs) {
    $Dest   = "\\$PC\c$\Temp"
    New-PSDrive -Name $Drive -PSProvider FileSystem -Root $Dest -Credential $cred -Persist
    Copy-Item -Path $Source\$SourceFile -Destination "$DriveLetter:\$SourceFile"
        if (Test-Path "$DriveLetter:\$SourceFile") {
            Write-Host "Copied to $PC"
        }
        else { 
            write-host "$PC copy failed" }
   Get-PSDrive $DriveLetter |  Remove-PSDrive
}
