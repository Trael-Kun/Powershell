$ScanDir = Test-Path "C:\SCANNER"
if ($ScanDir -eq $True) {
    exit 1
}
else {
    exit 0
}