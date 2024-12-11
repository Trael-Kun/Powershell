<#
 .SYNOPSIS
    Scrape for links on a page & download each linked file
 .DESCRIPTION
    Scrapes Webpage at $Url for links that match $Filter, then downloads them via BITS transfer.
#>
param(
    [string]$Exclude,
    [switch]$Raw,
    [Parameter(Mandatory)]
    [string]$Url,
    [string]$Destination,
    [string]$Filter
)

$Files = ((Invoke-WebRequest -Uri $Url).Links | Where-Object innerHTML -like $Filter).href

Foreach ($File in $Files) {
    if (!($Spaces)) {
        $FileName = $File.replace('%20',' ')
        $Filename = $FileName.replace('%27',"'")
        $Filename = $FileName.replace('%2c',",")
    } else {
        $FileName = $File
    }
    if ($File -notlike "*$Exclude*") {
        Write-Host "Downloading $FileName" -ForegroundColor Green
        Start-BitsTransfer -Source "$URL/$File" -Destination "$Destination\$FileName"
    } else {
        Write-Host "Excluding $FileName" -ForegroundColor Red
    }
}
