 <#Search GPO for string

from https://dailysysadmin.com/KB/Article/2304/search-all-gpos-in-a-domain-for-some-text/
 Adapted by Bill 14/09/2021;
 Modified by Bill 14/09/2021; Added .csv export
#>

## Set Variables
# Define where output file is stored
$logdir = "c:\temp\logs\"
# Name output file
$logfile  = "GPO_Search_$String_$(get-date -format yymmdd_hhmmtt).csv"
# Get the string we want to search for 
$string = Read-Host -Prompt "What string do you want to search for?" 
# Set the domain to search for GPOs 
$DomainName = $env:USERDNSDOMAIN

# Find all GPOs in the current domain 
write-host "Finding all the GPOs in $DomainName" 
Import-Module grouppolicy 
$allGposInDomain = Get-GPO -All -Domain $DomainName 
[string[]] $MatchedGPOList = @()

# Look through each GPO's XML for the string 
Write-Host "Starting search...." 
foreach ($gpo in $allGposInDomain) { 
    $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml 
    if ($report -match $string) { 
        write-host "********** Match found in: $($gpo.DisplayName) **********" -foregroundcolor "Green"
        $MatchedGPOList += "$($gpo.DisplayName)";
    } # end if 
    else { 
        Write-Host "No match in: $($gpo.DisplayName)" 
    } # end else 
} # end foreach
write-host "`r`nResults: **************" -foregroundcolor "Yellow"
foreach ($match in $MatchedGPOList) { 
    write-host "Match found in: $($match)" -foregroundcolor "Green"
}

# create log directory
if (Test-Path -Path $logdir){
    Write-Host "Logging to $logdir"
    }
else {
    New-Item -ItemType "directory" -Path $logdir -Force
    Write-Host "$logdir created"
    Write-Host "Logging to $logdir"
    }

# Tell User where log is
if (Test-Path -Path $logdir){
    Write-Host "Logged to " -NoNewline
    Write-Host "$logdir$logfile`r`n" -ForegroundColor Green
    }
else {
    Write-Host "Failed to write .csv file`r`n" -ForegroundColor Red
    }
