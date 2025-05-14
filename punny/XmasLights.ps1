<#
Bill Wilson (https://github.com/Trael-Kun)
13/05/25
#>
function Clear-HostLight {
    #https://www.reddit.com/r/PowerShell/comments/a3pval/comment/ebbditq
    Param (
        [Parameter(Position=1)]
        [int32]$Count=1
    )
    $CurrentLine  = $Host.UI.RawUI.CursorPosition.Y
    $ConsoleWidth = $Host.UI.RawUI.BufferSize.Width
    $i = 1
    for ($i; $i -le $Count; $i++) {
        [Console]::SetCursorPosition(0,($CurrentLine - $i))
        [Console]::Write("{0,-$ConsoleWidth}" -f " ")
    }
    [Console]::SetCursorPosition(0,($CurrentLine - $Count))
}
$a = $true
while ($true) {
    $Loop = 0
    if ($a) {
        $a = $false
    } else { $a = $true}
    while ($Loop -lt 10) {
        if ($a) {
            $Color1 = 'Red'
            $Light1 = '·'
            $Color2 = 'Green'
            $Light2 = '.'
        } else {
            $Color1 = 'Green'
            $Light1 = '.'
            $Color2 = 'Red'
            $Light2 = '·'
        }
        $Loop++
        Write-Host "$Light1 " -NoNewLine -ForegroundColor $Color1 
        Write-Host "$Light2 " -NoNewLine -ForegroundColor $Color2
    }
    Write-host ''
    Start-Sleep -Seconds 1
    Clear-HostLight -Count 1
}
<#Start
$Size = 10
$Top = 0
while ($Top -lt $Size) {
  Get-Light
  Write-Host "$Light " -NoNewLine -ForegroundColor $Col
  $Top++
}
Write-Host ''
$Space = (' ')*($Size - 2)
$Side = 0
while ($Side -lt $Size) {
  Get-Light
  Write-Host ($Light + $Space + $Light) -ForegroundColor $Col
  $Side++
}
Write-Host ''
$Bott = 0
while ($Bott -lt $Size) {
  Get-Light
  Write-Host "$Light " -NoNewLine -ForegroundColor $Col
  $Bott++
}
Write-Host ''
#End
#>
