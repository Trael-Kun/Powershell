<#
Adapted from https://www.danielengberg.com/detect-text-file-content-using-powershell-detection-method-sccm/

Application:    
Version:        
Engineer:       
Date:           
#>

#Define strings and their location. Also include the filename.
$String1 = ""
$String1Location = ""
$String2 = ""
$String2Location = ""
$String3 = ""
$String3Location = ""
# Detect presence of String1 in String1 Location
try {
    $String1Exists = Get-Content $String1Location -ErrorAction Stop
}
catch {
}
# Detect presence of String2 in String2 Location
try {
    $String2Exists = Get-Content $String2Location -ErrorAction Stop
}
catch {
}
# Detect presence of String3 in String3 Location
try {
    $String3Exists = Get-Content $String3Location -ErrorAction Stop
}
catch {
}
if (($String1Exists -match $String1) -and ($String2Exists -match $String2) -and ($String3Exists -match $String3)) {
    Write-Host "Installed"
}
else {
}