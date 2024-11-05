<#
GNU Kieren Hearne
.SYNOPSIS
 DELL_BIOS_UPDATE.PS1

.DESCRIPTION
	This script runs at the start of the SOE install task sequence, within Windows PE to update the BIOS of DELL computers, if necessary, and reboot, if necessary.

.NOTES
 These BIOSs contain mitigations for the Intel MEI, Meltdown and Spectre vulnerabilities.
 DELL Exit Codes:
 0 - Successful
 1 - Unsuccessful
 2 - Reboot Required
 3 - Same Version
 4 - Not Enough Battery Charge.
 
 CREATION DATE: 19/01/2018
 CHANGE HISTORY:
 AUTHOR				    DATE        		DESCRIPTION	          	          
--------------------------------------------------------------------------------------------------
 Kieren Hearne    19/01/2018      Creation		                      
 Bill Wilson      05/01/2022      updated .exe and models
 Bill Wilson      03/06/2022      updated .exe
 Bill Wilson      18/07/2022      updated .exe, Added Opti7000 & Prec6060 
 Bill Wilson      15/08/2022      updated .exe, added Opti7090
 Bill Wilson      13/10/2022      updated .exe
 Bill Wilson      15/11/2022      updated .exe
 Bill Wilson      16/12/2022      updated .exe, Added Optiplex 7070 Ultra
 Bill Wilson      15/03/2023      updated .exe
 Bill Wilson      21/03/2023      updated .exe
 Bill Wilson      07/06/2023      removed plain text password & replaced with TS variable (INC0059700)
                                  added Resolve-Path to reduce need for manual updating
 Bill Wilson      11/08/2023      updated Prec5820 Tower .exe name
 Bill Wilson      01/11/2024      changed repeated if statements to a single foreach referring to a table
                                  added table of models & paths
                                  changed Generate-Form to Format-Form to conform with Approved Verbs for PowerShell Commands
                                    (https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.4)
                                  formatting changes
#>

###################################################################################################
# FUNCTION - GENERATE WINDOWS.FORMS POPUP
###################################################################################################
Function Format-Form {
  Add-Type -AssemblyName System.Windows.Forms    
  # Build Form
  $objForm                = New-Object System.Windows.Forms.Form
  $objForm.Topmost        = $true
  $objForm.StartPosition  = 'CenterScreen'
  $objForm.Text           = 'Battery Charge Insufficient'
  $objForm.Size           = New-Object System.Drawing.Size(300,100)
  $objForm.ControlBox     = $false
  # Add Label
  $objLabel               = New-Object System.Windows.Forms.Label
  $objLabel.Location      = New-Object System.Drawing.Size(5,10) 
  $objLabel.Size          = New-Object System.Drawing.Size(300,80)
  $objLabel.Text          = "The current battery charge ($ChargeRemaining%) is insufficient to successfully perform a BIOS update on this computer. Pausing until battery charge equals 60%." 
  $objForm.Controls.Add($objLabel)
  # Show the form...
  $objForm.Show() | Out-Null
  # Pause for 20 seconds...
  Start-Sleep -Seconds 20
  # Close the form...
  $objForm.Close() | Out-Null
}

###################################################################################################
# START OF SCRIPT
###################################################################################################
$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location -Path $ScriptDir

###################################################################################################
# TASK - GET BATTERY EXISTANCE AND AMOUNT OF BATTERY CHARGE REMAINING
###################################################################################################
[int]$HasBattery      = (Get-WmiObject -Class win32_battery).Availability
[int]$ChargeRemaining = (Get-WmiObject -Class win32_battery).EstimatedChargeRemaining

###################################################################################################
# TASK - IF THE BATTERY IS LESS THAN 90% CHARGED, WAIT UNTIL IT IS
###################################################################################################
if ($HasBattery -ne 0 -AND $ChargeRemaining -le 60){
  DO {
    Start-Sleep -s 20
    [int]$ChargeRemaining = (Get-WmiObject -Class win32_battery).EstimatedChargeRemaining
    Format-Form
  } Until ($ChargeRemaining -ge 60)
}

###################################################################################################
# TASK - DETERMINE MODEL NUMBER AND THEN UPDATE THE APPROPRIATE BIOS
###################################################################################################
# Create an object to access the task sequence environment
$tsenv      = New-Object -ComObject Microsoft.SMS.TSEnvironment
# Set TS value to variable
$BiosPwd    = $tsenv.Value("BiosPwd")
# Get Computer Model
$Model      = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object Model).Model
$ModelList  = @(  #ExePath is first part of the bios update file name with a wiidcard where the version number would be
  [pscustomobject]@{Model='OptiPlex 7000'       ; ExePath="OptiPlex_7000_*"}
  [pscustomobject]@{Model='OptiPlex 7020'       ; ExePath="OptiPlex_7020_*"}
  [pscustomobject]@{Model='OptiPlex 7040'       ; ExePath="OptiPlex_7040_*"}
  [pscustomobject]@{Model='OptiPlex 7060'       ; ExePath="OptiPlex_7060_*"}
  [pscustomobject]@{Model='OptiPlex 7070'       ; ExePath="OptiPlex_7070_*"}
  [pscustomobject]@{Model='OptiPlex 7070 Ultra' ; ExePath="OptiPlex_7070_Ultra_*"}
  [pscustomobject]@{Model='OptiPlex 7080'       ; ExePath="OptiPlex_7080_*"}
  [pscustomobject]@{Model='OptiPlex 7090'       ; ExePath="OptiPlex_7090_*"}
  [pscustomobject]@{Model='Latitude 5400'       ; ExePath="Latitude_5X00_Precision_3540_*"}
  [pscustomobject]@{Model='Latitude 5410'       ; ExePath="Latitude_5X10_Precision_3550_*"}
  [pscustomobject]@{Model='Latitude 5420'       ; ExePath="Latitude_5420_*"}
  [pscustomobject]@{Model='Latitude E5470'      ; ExePath="Latitude_E5x70_Precision_3510_*"}
  [pscustomobject]@{Model='Precision 3650 Tower'; ExePath="Precision_3650_*"}
  [pscustomobject]@{Model='Precision 3660'      ; ExePath="Precision_3660_*"}
  [pscustomobject]@{Model='Precision Tower 5810'; ExePath="T5810*"}
  [pscustomobject]@{Model='Precision 5820'      ; ExePath="M33X_*"}
  [pscustomobject]@{Model='Precision Tower 7910'; ExePath="T7910*"}
  [pscustomobject]@{Model='Precision 7920 Tower'; ExePath="7X20T_*"}
  [pscustomobject]@{Model='Precision 7920 Tower'; ExePath="7X20T_*";}
  [pscustomobject]@{Model='Wyse 5070'           ; ExePath="Wyse_5070_*";}

)

# Find the correct .exe
foreach ($Make in $ModelList) {
  if ($Make.Model -eq $Model) {
    # Resolve-Path will fill matching .exe files, as long as old ones are removed
    $ExePath  = Resolve-Path ".\$($Make.ExePath).exe"
  }
}

# Run the command
$ExitCode     = (Start-Process -FilePath ".\Flash64W.exe" -ArgumentList /b="$ExePath",/s,/p=$BiosPwd -Wait -PassThru).ExitCode

###################################################################################################
# TASK - PASS REBOOT TRUE FALSE TO SCCM
###################################################################################################
if ($ExitCode -eq 2) {
  #Write-Host "YES"
  $tsenv  = New-Object -COMObject Microsoft.SMS.TSEnvironment
  $tsenv.Value('BIOSReboot') = $true
}
else {
  #Write-Host "NO"
  $tsenv  = New-Object -COMObject Microsoft.SMS.TSEnvironment
  $tsenv.Value('BIOSReboot') = $false
}

###################################################################################################
# END OF SCRIPT
###################################################################################################
