while ($Xmas -lt 10) {
  if ($Xmas % 2 -eq 0) {
    $Col = 'Red'
    $Light = '·'
  } else {
    $Col = 'Green'
    $Light = '.'
  }
  Write-Host $Light -NoNewLine -ForegroundColor $Col
  $Xmas++
}
