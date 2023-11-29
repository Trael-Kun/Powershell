### Lists the MSI install & update codes (GUIDs) of software installed on the specified PC and outputs it as a CSV file

## Script info
$VERSION = "0.5.8"
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name

<#
 Adapted from https://stackoverflow.com/questions/46637094/how-can-i-find-the-upgrade-code-for-an-installed-msi-file/46637095#46637095
 Written by Bill Wilson 15/07/2021

 Modified by Bill 05/08/2021; Adjusted $PCname input
 Modified by Bill 30/08/2021; Tidied formatting
 Modified by Bill 01/09/2021; Added Version & Vendor to report 
                            ; Added WKS & LAP recognition to $PCname
 Modified by Bill 13/09/2021; Added colouring to log file output notification
                            ; Added file check at end of script
                            ; Added counter
 Modified by Bill 14/09/2021; Added opening descriptive
 Modified by Bill 21/10/2021; Added VM & CAF recognition to $PCname (just in case)
                            ; Added $VERSION
 Modified by Bill 01/11/2021; Modified title/opening descriptive
 Modified by Bill 02/11/2021; Added DO loop back to asset entry
                            ; Added file info to top of script
 Modified by Bill 03/11/2021; Replaced Get-WmiObject with Get-CimInstance to ensure futureproofing
                            ; Added "if" loop to adjust $wmipackages variable if run locally
 Modified by Bill 21/10/2022; Changed $Logdir from local PC to remote PC
 Modified by Bill 01/11/2022; Added exit command
 Modified by Bill 02/11/2022; Modified colour scheme for compatibility
 Modified by Bill 28/11/2022; Added box to opening descriptive
                            ; Added further comments
 Modified by Bill 30/01/2023; Added Test-Connection to ensure target is online
                            ; Added Logging to local PC (C:\Temp\logs)
 Modified by Bill 02/02/2023; Added "O" as override for PC name entry
                            ; Added $PCprefix to allow flexibility of application
 Modified by Bill 09/02/2023; Added detection for empty $Asset
 Modified by Bill 23/02/2023; changed Override mode text for improved clarity
 Modified by Bill 16/03/2023; Tidied commenting, changed user text for clarity
                            ; Adjusted IF structure for log files
                            ; Added progress bar
 Modified by Bill 20/04/2023; Removed "VM*" from PCname options
 Modified by Bill 30/08/2023; Added "PC" to PCname options (inserts local PC name)
 Modified by Bill 22/11/2023; Added extra check to remove ping on local PC
 Modified by Bill 29/11/2023; Refined local PC check
#>

# Opening Descriptive with box
Write-Host " " -NoNewline
Write-Host "`r`n Script Path: $ScriptPath\$ScriptName  " -ForegroundColor Green
Write-Host " " -NoNewline
Write-Host " I–––––––––––––––––––––––––––––––––––––––––––––––––––I " -ForegroundColor Black -BackgroundColor White
Write-Host " " -NoNewline
Write-Host " |" -NoNewline -ForegroundColor Black -BackgroundColor White
Write-Host "                 MSI GUID Finder                   " -NoNewLine -ForegroundColor DarkRed -BackgroundColor White
Write-Host "| " -ForegroundColor Black -BackgroundColor White
Write-Host " " -NoNewline
Write-Host " | A script to fetch GUIDs of MSI installed programs | " -ForegroundColor Black -BackgroundColor White
Write-Host " " -NoNewline
Write-Host " |                 Version $VERSION                     | " -ForegroundColor Black -BackgroundColor White
Write-Host " " -NoNewline
Write-Host " I–––––––––––––––––––––––––––––––––––––––––––––––––––I " -ForegroundColor Black -BackgroundColor White
Write-Host ""

## Start Script
DO {
        ## Set Variables
        #################

        # Asset No. Input
        Write-Host " " -NoNewline
        Write-Host ' input target PC Name or WKS Asset No. (or' -NoNewline -ForegroundColor DarkYellow -BackgroundColor Black
        Write-Host ' EXIT' -NoNewline -ForegroundColor Yellow -BackgroundColor Black
        Write-Host ' to stop) :' -NoNewline -ForegroundColor DarkYellow -BackgroundColor Black
        Write-Host ' ' -NoNewline
        $Asset = Read-Host

        ## Set Computer Name
        ####################
        # Add prefix to asset no.
        if ($Asset -eq "") {
            Write-Host ""
            Write-Host " " -NoNewline
            Write-Host " No name or asset entered " -ForegroundColor White -BackgroundColor Red
            Write-Host ""
        }
        else {
            if ($Asset -match 'exit') {
                EXIT
            }
            elseif ($Asset -eq 'o') {
                Write-Host " " -NoNewline
                Write-Host ' OVERRIDE MODE ' -ForegroundColor Red -BackgroundColor Yellow
                Write-Host " " -NoNewline
                Write-Host ' input target PC Name :' -NoNewline -ForegroundColor DarkYellow -BackgroundColor Black
                Write-Host ' ' -NoNewline
                $PCname = Read-Host
            }
            elseif ($Asset -match 'PC') {
                $PCname = "$env:ComputerName"
            }
            elseif ($Asset -match '^WKS') {
                $PCname = "$Asset"
            }
            elseif ($Asset -notmatch '^WKS') {
                $PCname = "WKS$Asset"
            }
            # Define where output file is stored
            $locallogdir = "$env:SystemDrive\temp\logs\"
            $targlogdir = "\\$PCname\c$\temp\logs\"
            # Name output file
            $logfile  = "$PCname-MSI-codes_$(get-date -format yymmdd_hhmmtt).csv"

            ######################
            ## Check if PC is online
            if ($PCname -eq $env:ComputerName) {
                $PCping = $true
           }
           else {
                $PCping = Test-Connection -ComputerName $PCname -Count 1 -Quiet
           }
        
            if ($PCping -eq $true) {

                ## Get data
                ###################
                # Get Install Info
                Write-Host " Getting MSI GUIDs for " -NoNewline
                Write-Host "$PCname" -NoNewLine -ForegroundColor Green
    
                # Check if local or remote PC
                $Step = 0
                Write-Progress -Activity 'Gathering GUIDs' -Status 'Getting MSI info' -PercentComplete ($Step++)
                if ($PCname -ne $env:computername) {
                    #$wmipackages = Get-CimInstance -Class win32_product -ComputerName $PCname
                    $wmipackages = Get-WmiObject -Class win32_product -ComputerName $PCname
                }
                else {
                    $wmipackages = Get-CimInstance -Class win32_product
                    #$wmipackages = Get-WmiObject -Class win32_product -ComputerName $PCname
                }

                # Select relevant values
                Write-Progress -Activity 'Gathering GUIDs' -Status 'Filtering Values' -PercentComplete ((($Step++) / $wmipackages.count) *100)
                $wmiproperties = Get-CimInstance -Query "SELECT ProductCode,Value FROM Win32_Property WHERE Property='UpgradeCode'"
    
                # create log directory
                if ($PCname -ne $env:ComputerName) {
                    if (Test-Path -Path $targlogdir) {
                        Write-Host "Logging to $targlogdir"
                        }
                    else {
                        New-Item -ItemType "directory" -Path $targlogdir -Force
                        Write-Host "$targlogdir created"
                        Write-Host "Logging to $targlogdir"
                        New-Item -ItemType "directory" -Path $locallogdir -Force
                        Write-Host "$locallogdir created"
                        Write-Host "Logging to $locallogdir"
                    }
                }
                else {
                    if (Test-Path -Path $locallogdir) {
                        Write-Host "Logging to $locallogdir"
                    }
                    else {
                        New-Item -ItemType "directory" -Path $locallogdir -Force
                        Write-Host "$locallogdir created"
                        Write-Host "Logging to $locallogdir"
                    }
                }
                

                # Set Data Table
                $packageinfo = New-Object System.Data.Datatable
                [void]$packageinfo.Columns.Add("Name")
                [void]$packageinfo.Columns.Add("ProductCode")
                [void]$packageinfo.Columns.Add("UpgradeCode")
                [void]$packageinfo.Columns.Add("Version")
                [void]$packageinfo.Columns.Add("Vendor")

                # add blanks for no upgrade code
                foreach ($package in $wmipackages) {
                    Write-Progress -Activity 'Gathering GUIDs' -Status 'Formatting Output' -PercentComplete ((($Step++) / $wmipackages.count) *100)
                    $foundupgradecode = $false #Assume no upgrade code is found
                    foreach ($property in $wmiproperties) {
                        if ($package.IdentifyingNumber -eq $property.ProductCode) {
                            [void]$packageinfo.Rows.Add($package.Name,$package.IdentifyingNumber, $property.Value, $package.Version, $package.Vendor)
                            $foundupgradecode = $true
                            break
                        }
                    }
                    if(-Not ($foundupgradecode)) { 
                    # No upgrade code found, add product code to list
                    [void]$packageinfo.Rows.Add($package.Name,$package.IdentifyingNumber, "") 
                    }   
                }
 
                ## Format Output
                Write-Progress -Activity 'Gathering GUIDs' -Status 'Formatting Output'  -PercentComplete 90
                $packageinfo | Sort-Object -Property Name | Format-table ProductCode, Name, Vendor, Version, UpgradeCode

                # Export to log
                Write-Progress -Activity 'Gathering GUIDs' -Status 'Logging Output' -PercentComplete 100
                $packageinfo | Export-Csv $targlogdir$logfile
                if ($PCname -ne $env:ComputerName){
                    $packageinfo | Export-Csv $targlogdir$logfile
                    $packageinfo | Export-Csv "$locallogdir$logfile"
                }
                else {
                    $packageinfo | Export-Csv "$locallogdir$logfile"
                }

                ## Summary
                ############
                #count
                $installed = $wmipackages.Count
                Write-Host "Found $installed GUIDs"

                # Tell User where log is
                if (Test-Path -Path "$targlogdir$logfile") {
                    if (Test-Path -path "$locallogdir$logfile") {
                        Write-Host "Logged to " -NoNewline
                        Write-Host "$targlogdir$logfile`r`n" -ForegroundColor Green
                        Write-Host "Logged to " -NoNewline
                        Write-Host "$locallogdirlogdir$logfile`r`n" -ForegroundColor Green
                    }
                    else {
                    Write-Host "Logged to " -NoNewline
                    Write-Host "$targlogdir$logfile`r`n" -ForegroundColor Green
                       }
                }
                elseif (Test-Path -Path "$locallogdir$logfile"){
                    Write-Host "Logged to " -NoNewline
                    Write-Host "$locallogdir$logfile`r`n" -ForegroundColor Green
                }
                else {
                    Write-Host "Failed to write .csv file`r`n" -ForegroundColor Red
                }
            Write-Progress -Activity 'Gathering GUIDs' -Status 'Complete' -PercentComplete 100
            }
            else {
            Write-Host " "
            Write-Host " " -NoNewline
            Write-Host " Target computer" -ForegroundColor White -BackgroundColor Red -NoNewline
            Write-Host " $PCname" -ForegroundColor Green -BackgroundColor Red -NoNewline
            Write-Host " unavailable! " -ForegroundColor White -BackgroundColor Red
            Write-Host " "
            }
        }
} while ($true -eq $true)
## End Script
