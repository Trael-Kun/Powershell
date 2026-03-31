<#
.SYNOPSIS
    Download and verify files from one or more Archive.org items.

.DESCRIPTION
    Scrapes one or more Archive.org download pages, filters links by name,
    downloads matching files, and verifies their integrity using the
    Archive.org _files.xml manifest.

    Verification is performed using SHA1 hashes published by Archive.org.
    If a checksum is not available for a file, verification is skipped.

    Designed for PowerShell 7+ and cross-platform use.

.PARAMETER Urls
    One or more Archive.org download URLs.

.PARAMETER Destination
    Local directory where files will be downloaded.

.PARAMETER Filters
    One or more wildcard filters (e.g. *.mp3, *.flac).

.PARAMETER Exclude
    Optional wildcard pattern to exclude files.

.PARAMETER Raw
    Use raw (URL-encoded) filenames without decoding.

.EXAMPLE
    .\LinkScraper_ArchiveDotOrg_PWSHv7.ps1 `
      -Urls https://archive.org/download/hitchhikers-guide-to-the-galaxy-bbcr4 `
      -Filters *.mp3 `
      -Destination C:\Downloads\Hitchhikers

.EXAMPLE
    .\LinkScraper_ArchiveDotOrg_PWSHv7.ps1 `
      -Urls @( 
       'https://archive.org/download/dracula_ks_1608_librivox',
       'https://archive.org/download/Lord_of_the_rings_Fellowship_of_the_Ring_-_BBC')
       -Filters *Track01* `
       -Destination D:\Audio\ArchiveDownloads
.EXAMPLE
    .\LinkScraper_ArchiveDotOrg_PWSHv7.ps1 `
      -Urls @(
        'https://archive.org/details/steamboat-willie_1928',
        'https://archive.org/details/the-addams-family__season-1')
       -Filters *.mp4 `
       -Destination C:\Downloads
.NOTES
    Written by Bill Wilson 30/03/26
    References;
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_powershell_editions?view=powershell-7.5
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.5
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.6

    Developed with assistance from Microsoft Copilot — https://www.microsoft.com/copilot
#>

## Version Check 
if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "This script requires PowerShell 7.0 or newer. Detected $($PSVersionTable.PSVersion)"
}

## Parameters
param(
    [Parameter(Mandatory,
        HelpMessage = 'Enter one or more Archive.org download URLs')]
    [string[]]$Urls,

    [Parameter(Mandatory,
        HelpMessage = 'Enter the destination directory')]
    [Alias('Dest')]
    [string]$Destination,

    [Parameter(Mandatory,
        HelpMessage = 'Enter one or more wildcard filters (e.g. *.mp3, *.flac)')]
    [Alias('Filter')]
    [string[]]$Filters,

    [Parameter(
        HelpMessage = 'Exclude files whose filename matches this wildcard pattern')]
    [Alias('Excl')]
    [string]$Exclude,

    [Parameter(
        HelpMessage = 'Set destination file name to mirror URL (e.g. "The%20Lord%20of%20the%20Rings%20-%20Disc%201.mp3" vs "The Lord of the Rings - Disc 1.mp3")')]
    [switch]$Raw
)

#Set strict error handling to catch bugs & avoid silent failure
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

## Helpers
function Get-ArchiveFilesXml {
    param(
        [string]$BaseUrl
    )
    #get name of item
    $Item = $BaseUrl.TrimEnd('/') | Split-Path -Leaf
    #set xml file
    $XmlUrl = "$BaseUrl/${Item}_files.xml"
    #get xml file
    try {
        [xml](Invoke-WebRequest -Uri $XmlUrl).Content
    } catch {
        Write-Warning "Unable to retrieve _files.xml for $Item"
        return $null
    }
}

function Get-ItemLinks {
    param(
        [string]$Url,
        [string[]]$Filters
    )
    #scrape HTML
    $Html = (Invoke-WebRequest -Uri $Url).Content
    #pull links
    $Links =
        Select-String -InputObject $Html -Pattern 'href="([^"]+)"' -AllMatches |
        ForEach-Object { $_.Matches.Groups[1].Value }
    #filter links
    foreach ($Filter in $Filters) {
        $Links | Where-Object { $_ -like $Filter }
    }
}

## Setup
#if destination doesn't exist, make it
if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
}

#create empty arrays
$Success  = @()
$Failed   = @()
$Skipped  = @()
$HashFail = @()

## Start
foreach ($Url in $Urls) {
    # destination folder per-item
    $ItemName        = $Url.TrimEnd('/') | Split-Path -Leaf
    $ItemDestination = Join-Path $Destination $ItemName
    
    #ProgressBar
    Write-Progress `
     -Id 0 `
     -Activity "Processing Archive.org items" `
     -Status $ItemName `
     -PercentComplete (($Urls.IndexOf($Url) + 1) / $Urls.Count * 100)

    #Create dest if it doesn't exist
    if (-not (Test-Path $ItemDestination)) {
        New-Item -ItemType Directory -Path $ItemDestination -Force | Out-Null
    }

    #Filter Items
    Write-Host "`nProcessing Archive.org item:" -ForegroundColor Magenta
    Write-Host "  $Url" -ForegroundColor Cyan
    $Files = Get-ItemLinks -Url $Url -Filters $Filters | Sort-Object -Unique

    #if there are no items that match filters
    if (-not $Files) {
        Write-Warning "No matching files found."
        continue
    }

    #Get xml for hash comparison
    $FilesXml = Get-ArchiveFilesXml -BaseUrl $Url
    $ShaLookup = @{}

    if ($FilesXml) {
        foreach ($File in $FilesXml.files.file) {
            if ($File.sha1) {
                $ShaLookup[$File.name] = $File.sha1
            }
        }
    }

    #Do math
    $Count = $Files.Count
    $Index = 0

    #Process Files
    foreach ($File in $Files) {
        $Index++

        #Decode the file URL to human-readable (removes all the %20)
        $RawName  = [System.IO.Path]::GetFileName($File)
        $FileName = if ($Raw) {
            $RawName
        } else {
            #This is a cool thing, I used to have a big table for this
            [System.Web.HttpUtility]::UrlDecode($RawName)
        }

        #Don't get excluded files
        if ($Exclude -and $FileName -like "*$Exclude*") {
            Write-Host "Excluded: $FileName" -ForegroundColor Yellow
            $Skipped += "$Url :: $FileName"
            continue
        }

        #Ensure SourceUrl is always a fully-qualified URL
        $SourceUrl = if ($File -match '^https?://') {
            $File
        } else {
            "$Url/$File"
        }

        #set destination path
        $DestPath = Join-Path $ItemDestination $FileName

        #Download the file
        Write-Progress `
            -Id 1 `
            -ParentId 0 `
            -Activity "Downloading files" `
            -Status "$Index of $Count" `
            -PercentComplete (($Index / $Count) * 100)

        Write-Host "[$Index/$Count] [$ItemName] Downloading $FileName" -ForegroundColor Green
        try {
            Invoke-WebRequest -Uri $SourceUrl -OutFile $DestPath
            $Success += $FileName
        } catch {
            Write-Host "Download failed: $FileName" -ForegroundColor Red
            $Failed  += "$Url :: $FileName"
            continue
        }

        #Hash verification
        if ($ShaLookup.ContainsKey($RawName)) {
            $Expected = $ShaLookup[$RawName]
            $Actual   = (Get-FileHash -Path $DestPath -Algorithm SHA1).Hash.ToLower()

            if ($Actual -eq $Expected) {
                Write-Host "Verified (SHA1)" -ForegroundColor Cyan
            } else {
                Write-Host "HASH MISMATCH!" -ForegroundColor Red -BackgroundColor DarkRed
                Write-Host "Expected: "     -NoNewline
                Write-Host $Expected        -ForegroundColor Green
                Write-Host "Actual  : "     -NoNewline
                Write-Host $Actual          -ForegroundColor Red
                $HashFail += "$Url :: $FileName"
            }
        } else {
            Write-Warning "No checksum available for $FileName"
        }
    }
    #Close progress bar 1
    Write-Progress -Id 1 -Completed
}
#Close progress bar 0
Write-Progress -Id 0 -Completed

## Summary
Write-Host "`n============= Summary =============" -ForegroundColor Magenta
if ($Success) {
    Write-Host "Succeeded downloads:"       -ForegroundColor Green -BackgroundColor DarkGreen
    $Success
}
if ($Skipped) {
    Write-Host "Excluded files:"            -ForegroundColor Yellow -BackgroundColor DarkYellow
    $Skipped
}
if ($Failed) {
    Write-Host "Failed downloads:"          -ForegroundColor Red -BackgroundColor DarkRed
    $Failed
}
if ($HashFail) {
    Write-Host "Hash verification failures:" -ForegroundColor DarkRed -BackgroundColor Red
    $HashFail
}

Write-Host "All done." -ForegroundColor Magenta
#END SCRIPT
