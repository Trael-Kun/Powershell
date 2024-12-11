<#
 .SYNOPSIS
    Scrape for links on a page & download each linked file
 .DESCRIPTION
    Scrapes Webpage at $Url for links that match $Filter, then downloads them via BITS transfer.
 .EXAMPLE
    PS> .\LinkScraperDownload.ps1 -URL https://archive.org/download/dracula_ks_1608_librivox -Filter *128kb.mp3 -Destination C:\Downloads\Drac
 .EXAMPLE
    PS> .\LinkScraperDownload.ps1 -URL https://archive.org/download/hitchhikers-guide-to-the-galaxy-bbcr4 -Filter *.mp3 -Destination C:\Downloads\Hitchhickers -Raw
 .NOTES
    Testing in PWSH 7 failing
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   12/12/2024
#>
param(
    [switch]$Raw,          #disables filename conversion
    [Parameter(Mandatory)]
    [string]$Url,          #URL of the page for the download links
    [string]$Destination,  #Where the files will be saved to
    [string]$Filter        #which files to download. Accepts wildcards
)

$Files = ((Invoke-WebRequest -Uri $Url).Links | Where-Object innerHTML -like $Filter).href

Foreach ($File in $Files) {
    if ($Raw) {
        $FileName = $File
    } else {
        $FileName = $File.replace('%20',' ')
        $Filename = $FileName.replace('%27',"'")
        $Filename = $FileName.replace('%2c',",")        
    }
    if ($File -notlike "*$Exclude*") {
        Write-Host "Downloading $FileName" -ForegroundColor Green
        Start-BitsTransfer -Source "$URL/$File" -Destination "$Destination\$FileName"
    } else {
        Write-Host "Excluding $FileName" -ForegroundColor Red
    }
}
