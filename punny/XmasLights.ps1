function Get-Light {
if ($Bott % 2 -eq 0) {
    $Col = 'Red'
    $Light = '·'
  } else {
    $Col = 'Green'
    $Light = '.'
  }
}
#Start
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
