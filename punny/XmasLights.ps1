$Size = 10
$Top = 0
while ($Top -lt $Size) {
  if ($Top % 2 -eq 0) {
    $Col = 'Red'
    $Light = '·'
  } else {
    $Col = 'Green'
    $Light = '.'
  }
  Write-Host $Light -NoNewLine -ForegroundColor $Col
  $Top++
}
$Space = (' ')*8
$Side = 0
while ($Side -lt $Size) {
  if ($Side % 2 -eq 0) {
    $Col = 'Red'
    $Light = '·'
  } else {
    $Col = 'Green'
    $Light = '.'
 }
 Write-Host ($Light + $Space + $Light) -ForegroundColor $Col
 $Side++
}
$Bott = 0
while ($Bott -lt $Size) {
  if ($Bott % 2 -eq 0) {
    $Col = 'Red'
    $Light = '·'
  } else {
    $Col = 'Green'
    $Light = '.'
  }
  Write-Host $Light -NoNewLine -ForegroundColor $Col
  $Bott++
}
Write-Host ''
