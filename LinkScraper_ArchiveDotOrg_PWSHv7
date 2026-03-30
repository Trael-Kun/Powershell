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
    .\ArchiveSkim.ps1 `
      -Urls https://archive.org/download/dracula_ks_1608_librivox `
      -Filters *.mp3 `
      -Destination C:\Downloads\Dracula
#>

# ---------------- Version Check ----------------

if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "This script requires PowerShell 7.0 or newer. Detected $($PSVersionTable.PSVersion)"
}

# ---------------- Parameters ----------------

param(
    [Parameter(Mandatory, HelpMessage = 'Enter one or more Archive.org download URLs')]
    [string[]]$Urls,

    [Parameter(Mandatory, HelpMessage = 'Enter the destination directory')]
    [string]$Destination,

    [Parameter(Mandatory, HelpMessage = 'Enter one or more wildcard filters (e.g. *.mp3, *.flac)')]
    [Alias('Filter')]
    [string[]]$Filters,

    [string]$Exclude,
    [switch]$Raw
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------- Helpers ----------------

function Get-ArchiveFilesXml {
    param([string]$BaseUrl)

    $item = $BaseUrl.TrimEnd('/') | Split-Path -Leaf
    $xmlUrl = "$BaseUrl/${item}_files.xml"

    try {
        [xml](Invoke-WebRequest -Uri $xmlUrl.Content)
    } catch {
        Write-Warning "Unable to retrieve _files.xml for $item"
        return $null
    }
}

function Get-ItemLinks {
    param(
        [string]$Url,
        [string[]]$Filters
    )

    $html = (Invoke-WebRequest -Uri $Url).Content

    $links =
        Select-String -InputObject $html -Pattern 'href="([^"]+)"' -AllMatches |
        ForEach-Object { $_.Matches.Groups[1].Value }

    foreach ($filter in $Filters) {
        $links | Where-Object { $_ -like $filter }
    }
}

# ---------------- Setup ----------------

if (-not (Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
}

$Failed   = @()
$Skipped  = @()
$HashFail = @()

# ---------------- Main Processing ----------------

foreach ($Url in $Urls) {

    Write-Host "`nProcessing Archive.org item:" -ForegroundColor Magenta
    Write-Host "  $Url" -ForegroundColor Cyan

    $Files = Get-ItemLinks -Url $Url -Filters $Filters | Sort-Object -Unique

    if (-not $Files) {
        Write-Warning "No matching files found."
        continue
    }

    $FilesXml = Get-ArchiveFilesXml -BaseUrl $Url
    $ShaLookup = @{}

    if ($FilesXml) {
        foreach ($file in $FilesXml.files.file) {
            if ($file.sha1) {
                $ShaLookup[$file.name] = $file.sha1
            }
        }
    }

    $Count = $Files.Count
    $Index = 0

    foreach ($File in $Files) {
        $Index++
        Write-Progress `
            -Activity "Downloading from Archive.org" `
            -Status "$Index of $Count" `
            -PercentComplete (($Index / $Count) * 100)

        $RawName = [System.IO.Path]::GetFileName($File)
        $FileName = if ($Raw) {
            $RawName
        } else {
            [System.Web.HttpUtility]::UrlDecode($RawName)
        }

        if ($Exclude -and $FileName -like "*$Exclude*") {
            Write-Host "Excluded: $FileName" -ForegroundColor Yellow
            $Skipped += "$Url :: $FileName"
            continue
        }

        $SourceUrl = if ($File -match '^https?://') {
            $File
        } else {
            "$Url/$File"
        }

        $DestPath = Join-Path $Destination $FileName

        Write-Host "[$Index/$Count] Downloading $FileName" -ForegroundColor Green

        try {
            Invoke-WebRequest -Uri $SourceUrl -OutFile $DestPath
        } catch {
            Write-Host "Download failed: $FileName" -ForegroundColor Red
            $Failed += "$Url :: $FileName"
            continue
        }

        if ($ShaLookup.ContainsKey($RawName)) {
            $Expected = $ShaLookup[$RawName]
            $Actual   = (Get-FileHash -Path $DestPath -Algorithm SHA1).Hash.ToLower()

            if ($Actual -eq $Expected) {
                Write-Host "Verified (SHA1)" -ForegroundColor Cyan
            } else {
                Write-Host "HASH MISMATCH!" -ForegroundColor Red
                Write-Host "Expected: $Expected"
                Write-Host "Actual  : $Actual"
                $HashFail += "$Url :: $FileName"
            }
        }
        else {
            Write-Warning "No checksum available for $FileName"
        }
    }
}

# ---------------- Summary ----------------

Write-Host "`n============= Summary =============" -ForegroundColor Magenta

if ($Skipped) {
    Write-Host "Excluded files:" -ForegroundColor Yellow
    $Skipped
}

if ($Failed) {
    Write-Host "Failed downloads:" -ForegroundColor Red
    $Failed
}

if ($HashFail) {
    Write-Host "Hash verification failures:" -ForegroundColor Red
    $HashFail
}

Write-Host "All done." -ForegroundColor Magenta
