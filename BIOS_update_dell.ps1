<#
.Title
DELL_BIOS_UPDATE.PS1

.DESCRIPTION
	This script runs at the start of the SOE install task sequence, within Windows PE to update the BIOS of DELL computers, if necessary, and reboot, if necessary.
	
CREATION DATE: 19/01/2018

.NOTES
 These BIOSs contain mitigations for the Intel MEI, Meltdown and Spectre vulnerabilities.
 DELL Exit Codes:
 0 - Successful
 1 - Unsuccessful
 2 - Reboot Required
 3 - Same Version
 4 - Not Enough Battery Charge.

 CHANGE HISTORY:
 AUTHOR				    DATE        		DESCRIPTION	          	          
--------------------------------------------------------------------------------------------------
 Kieren Hearne		  19/01/2018		  Creation		                      
 Bill Wilson       05/01/2022      Updated .exe and models
 Bill Wilson       03/06/2022      Updated .exe
 Bill Wilson       18/07/2022      Updated .exe, Added Opti7000 & Prec6060 
 Bill Wilson       15/08/2022      Updated .exe, added Opti7090
 Bill Wilson       13/10/2022      Updated .exe
 Bill Wilson       15/11/2022      Updated .exe
 Bill Wilson       16/12/2022      Updated .exe, Added Optiplex 7070 Ultra
 Bill Wilson       15/03/2023      Updated .exe
 Bill Wilson       21/03/2023      Updated .exe
 Bill Wilson       07/06/2023      removed plain text password & replaced with TS variable (INC0059700)
                                   Added Resolve-Path to reduce need for manual updating
 Bill Wilson       11/08/2023      Updated Prec5820 Tower .exe name

#>

###################################################################################################
# START OF SCRIPT
###################################################################################################

$SCRIPTDIR = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location -Path $SCRIPTDIR

###################################################################################################
# TASK - GET BATTERY EXISTANCE AND AMOUNT OF BATTERY CHARGE REMAINING
###################################################################################################

[int]$HasBattery = (Get-WmiObject -Class win32_battery).Availability
[int]$ChargeRemaining = (Get-WmiObject -Class win32_battery).EstimatedChargeRemaining

###################################################################################################
# FUNCTION - GENERATE WINDOWS.FORMS POPUP
###################################################################################################

Function Generate-Form {

  Add-Type -AssemblyName System.Windows.Forms    

  # Build Form
  $objForm = New-Object System.Windows.Forms.Form
  $objForm.Topmost = $True
  $objForm.StartPosition = "CenterScreen"
  $objForm.Text = "Battery Charge Insufficient"
  $objForm.Size = New-Object System.Drawing.Size(300,100)
  $objForm.ControlBox = $false
    
  # Add Label
  $objLabel = New-Object System.Windows.Forms.Label
  $objLabel.Location = New-Object System.Drawing.Size(5,10) 
  $objLabel.Size = New-Object System.Drawing.Size(300,80)
  $objLabel.Text = "The current battery charge ($ChargeRemaining%) is insufficient to successfully perform a BIOS update on this computer. Pausing until battery charge equals 60%." 
  $objForm.Controls.Add($objLabel)

  # Show the form...
  $objForm.Show()| Out-Null

  # Pause for 20 seconds...
  Start-Sleep -Seconds 20

  # Close the form...
  $objForm.Close() | Out-Null
}

###################################################################################################
# TASK - IF THE BATTERY IS LESS THAN 90% CHARGED, WAIT UNTIL IT IS
###################################################################################################

If ($HasBattery -ne 0 -AND $ChargeRemaining -le 60){
DO
{
Start-Sleep -s 20
[int]$ChargeRemaining = (Get-WmiObject -Class win32_battery).EstimatedChargeRemaining
Generate-Form
} Until ($ChargeRemaining -ge 60)
}

###################################################################################################
# TASK - DETERMINE MODEL NUMBER AND THEN UPDATE THE APPROPRIATE BIOS
###################################################################################################

# Create an object to access the task sequence environment
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
# Set TS value to variable
$BiosPwd = $tsenv.Value("BiosPwd")
# Get Computer Model
$MODEL = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object Model).Model

# Resolve-Path will fill matching .exe files, as long as old ones are removed
If ($MODEL -match 'OptiPlex 7000') {
  $ExePath = Resolve-Path ".\OptiPlex_7000_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
  }
If ($MODEL -match 'OptiPlex 7040') {
  $ExePath = Resolve-Path ".\OptiPlex_7040_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'OptiPlex 7060') {
  $ExePath = Resolve-Path ".\OptiPlex_7060_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'OptiPlex 7070') {
  $ExePath = Resolve-Path ".\OptiPlex_7070_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'OptiPlex 7070 Ultra') {
  $ExePath = Resolve-Path ".\OptiPlex_7070_Ultra_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'OptiPlex 7080') {
  $ExePath = Resolve-Path ".\OptiPlex_7080_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'OptiPlex 7090') {
  $ExePath = Resolve-Path ".\OptiPlex_7090_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Latitude 5400') {
  $ExePath = Resolve-Path ".\Latitude_5X00_Precision_3540_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Latitude 5410') {
  $ExePath = Resolve-Path ".\Latitude_5X10_Precision_3550_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Latitude 5420') {
  $ExePath = Resolve-Path ".\Latitude_5420_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Latitude E5470') {
  $ExePath = Resolve-Path ".\Latitude_E5x70_Precision_3510_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Precision 3650 Tower') {
  $ExePath = Resolve-Path ".\Precision_3650_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Precision 3660') {
  $ExePath = Resolve-Path ".\Precision_3660_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Precision Tower 5810') {
  $ExePath = Resolve-Path ".\T5810*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Precision 5820') {
  $ExePath = Resolve-Path ".\M33X_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Precision Tower 7910') {
  $ExePath = Resolve-Path ".\T7910*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}
If ($MODEL -match 'Precision 7920 Tower') {
  $ExePath = Resolve-Path ".\7X20T_*.exe"
  $ExitCode = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode
}

###################################################################################################
# TASK - PASS REBOOT TRUE FALSE TO SCCM
###################################################################################################

If ($ExitCode -eq 2) {
  #Write-Host "YES"
  $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
  $tsenv.Value('BIOSReboot') = "TRUE"
}
Else {
  #Write-Host "NO"
  $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
  $tsenv.Value('BIOSReboot') = "FALSE"
}

###################################################################################################
# END OF SCRIPT
###################################################################################################
