<#
 .SYNOPSIS
    Scrape a webpage for links & download each matching file

 .DESCRIPTION
    Scrapes the webpage at the specified URL for links matching the supplied
    filter patterns, then downloads each matching file. Downloads are retried
    on failure and validated using file size and optional SHA-256 integrity
    checking.

    If the Destination parameter refers to an existing directory, a subfolder
    is created automatically based on the source URL name.

    A -DryRun mode is supported to show what actions would be taken without
    creating directories or downloading files.

 .PARAMETER Urls
    One or more source webpages containing downloadable links.

    Each URL is fetched and processed independently. When multiple URLs are
    supplied, destination folders are resolved separately for each source.

 .PARAMETER DestPath
    Destination folder or parent directory for downloaded files.

    If the specified path already exists and is a directory, a subfolder is
    automatically created based on the source URL name.

 .PARAMETER Filters
    One or more wildcard patterns used to select downloadable files.

    Only links matching at least one of the supplied patterns will be
    considered for download.

 .PARAMETER Exclude
    Optional wildcard patterns used to exclude matching files.

    If a link matches both a Filters pattern and an Exclude pattern, it is
    skipped.

 .PARAMETER ExpectedSha256
    Optional expected SHA-256 hash value for downloaded files.

    When supplied, downloaded files are validated against this hash after
    transfer. If an existing file already matches this hash, it is skipped
    unless the Force parameter is specified.

    This parameter applies the same hash to all downloaded files and is
    primarily intended for single-file downloads.

 .PARAMETER FileHashes
    Optional per-file SHA-256 hash mapping.

    Accepts a hashtable mapping filenames to their expected SHA-256 hashes.
    When a downloaded file matches a key in this map, its corresponding hash
    is used for validation.

    Files not present in the map are downloaded without hash validation unless
    ExpectedSha256 is also provided.

    If both FileHashes and ExpectedSha256 are specified, FileHashes takes
    precedence for matching filenames.

 .PARAMETER DryRun
    Shows what actions would be performed without making any changes.

    When enabled, no directories are created and no files are downloaded.

 .PARAMETER Force
    Forces files to be re-downloaded even if existing files appear valid.

    When used with SHA-256 validation, existing files are not trusted and are
    always replaced.

 .PARAMETER Raw
    Disables URL decoding for filenames.

    When specified, filenames are used exactly as provided in the source
    webpage without URL decoding.

 .PARAMETER RetryCount
    Number of times to retry a failed download operation.

    Retries occur after the initial attempt if an error is encountered during
    download or validation. The default value is 3.

 .EXAMPLE
    PS C:\Temp\Scripts> .\LinkScrapeAndDownload.ps1 `
        -Url https://archive.blehblehbleh.com/audiobooks/bstoker_dracula `
        -Filters *128kb.mp3 `
        -Destination C:\Downloads\Dracula

    Downloads all matching 128kb MP3 files into C:\Downloads\Dracula.
    Existing files are overwritten unless a matching SHA-256 hash is provided.

 .EXAMPLE
    PS C:\Temp\Scripts> .\LinkScrapeAndDownload.ps1 `
        -Url https://dontpanic.biz/radio/hitchhikers `
        -Filters *.mp3 `
        -Destination C:\Downloads

    Creates C:\Downloads\hitchhikers and downloads all MP3 files
    into that folder.

 .EXAMPLE
    PS C:\Temp\Scripts> .\LinkScrapeAndDownload.ps1 `
        -Url https://download.all.the.iso.edu/seriously `
        -Filters *.iso `
        -Destination C:\Downloads\ISOs `
        -RetryCount 5

    Downloads all ISO files, retrying each file up to five times if failures
    occur during transfer or validation.

 .EXAMPLE
    PS C:\Temp\Scripts> .\LinkScrapeAndDownload.ps1 `
        -Url https://samwiseistheprotagonist.org/fantasy/lotr `
        -Filters *.flac `
        -Destination D:\Media `
        -DryRun

    Shows which files would be downloaded and where they would be
    placed, without creating directories or downloading any files.

 .EXAMPLE
    PS C:\Temp\Scripts> .\LinkScrapeAndDownload.ps1 `
        -Url https://onebigiso.net/artifacts/single-big-file `
        -Filters *.iso `
        -Destination D:\ISOs `
        -Sha256 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef `
        -Force

    Re-downloads the file even if an existing file matches the supplied
    SHA-256 hash.

 .EXAMPLE
    PS C:\Temp\Scripts> .\LinkScrapeAndDownload.ps1 `
        -Url https://yohoho.org/music/artist/album `
        -Filters *.flac `
        -Destination D:\Media `
        -FileHashes @{
            'track01.flac' = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            'track02.flac' = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
        }

    Downloads FLAC files and validates each file against its corresponding
    SHA-256 hash when provided.

 .LINK
    https://github.com/Trael-Kun/Powershell/blob/main/LinkScrapeAndDownload.ps1

 .NOTES
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   12/12/2024

    After 31/03/2026 developed with assistance from Microsoft Copilot

    Help Version History:
      1.0 (12/12/2024)
        Initial public release.

      1.1 (31/03/2026)
        Added filename hardening to prevent path traversal and unintended subdirectory 
        creation when saving downloaded files.
        -------------------------------------------
        Used Copilot to make script more efficient (removed that massive URL conversion table)

      1.2 (01/04/2026)
        Added optional per-file SHA-256 hash mapping support via the FileHashes parameter, 
        allowing individual files to be validated against distinct expected hashes while 
        preserving existing ExpectedSha256 behaviour.
#>

# Requires -Version 2.0
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

try {
    if (-not $Host.UI.RawUI -or
        -not $Host.UI.RawUI.BufferSize -or
        -not $Host.UI.RawUI.CursorPosition) {
        $ProgressPreference = 'SilentlyContinue'
    }
} catch {
    $ProgressPreference = 'SilentlyContinue'
}

param(
    [Parameter(Mandatory,
        HelpMessage='URLs to be scraped')]
    [Alias('Urls')]
    [string[]]$Urls,

    [Parameter(Mandatory,
        HelpMessage='Destination path for downloaded files')]
    [Alias('Dest')]
    [string]$DestPath,

    [Parameter(Mandatory,
        HelpMessage='Filter for specific file types or names. Accepts wildcards')]
    [Alias('Filter')]
    [string[]]$Filters,

    [Parameter(
        HelpMessage='Filter to exclude specific file types or names. Accepts wildcards')]
    [Alias('Excl')]
    [string[]]$Exclude,

    [Parameter(
        HelpMessage='Allows for hash verification with a preexisting SHA-256 hash')]
    [Alias('ExpectedHash')]
    [string]$ExpectedSha256,

    [Parameter(
        HelpMessage='Allows for hash verification with a hash table of preexisting SHA-256 hashes')]
    [hashtable]$FileHashes,

    [Parameter(
        HelpMessage='Runs the script without creating files or folders. Allows checking that parameters are correct')]
    [Alias('WhatIf')]
    [switch]$DryRun,

    [Parameter(
        HelpMessage='Overwrites existing files')]
    [switch]$Force,

    [Parameter(
        HelpMessage='Disables name reformatting')]
    [switch]$Raw,

    [Parameter(
        HelpMessage='Number of additional times the script will attempt a failed download. Defaults to 3')]
    [Alias('Retries')]
    [int]$RetryCount = 3
)

########################################################################
## Private Functions (Helpers), formalwear only
########################################################################
function _Decode-UrlString {
    <#
     .SYNOPSIS
        Creates a human-readable string from a URL (i.e. gets rid of the %20) 
    #>
    param(
        [Parameter(
            HelpMessage='Text to decode')]    
        [string]$Text
    )
    try {
        Add-Type -AssemblyName System.Web -ErrorAction Stop
        [System.Web.HttpUtility]::UrlDecode($Text)
    }
    catch {
        [System.Uri]::UnescapeDataString($Text)
    }
}

function _Invoke-WithRetry {
    <#
     .SYNOPSIS
        Execute an operation and retry it on failure.
    #>
    param(
        [Parameter(
            HelpMessage='The script block to run')]
        [scriptblock]$Action,
        [Parameter(
            HelpMessage='Number of additional attempts')]
        [int]$MaxRetries
    )

    $Attempt = 0
    while ($true) {
        try { #run the script block
            & $Action
            return
        }
        catch {
            if ($Attempt -ge $MaxRetries) { #if you've done it enough times, stop
                throw
            }
            #try again
            $Attempt++
            Write-Warning "Retry $Attempt of $MaxRetries failed; retrying..."
        }
    }
}

function _Download-File {
    <#
     .SYNOPSIS
        Chooses download protocol
    #>
    param(
        [Parameter(
            HelpMessage='source of the download file')]
        $Source,
        [Parameter(
        HelpMessage='Where the downloaded file will go to')]
        $Destination
    )
    if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
        try { #try to download with BITS
            Write-Host "Downloading "
            Write-Host $Source      -NoNewline -ForegroundColor $ColPath
            Write-Host " to "       -NoNewline
            Write-Host $Destination -NoNewline -ForegroundColor $ColPath
            Start-BitsTransfer -Source $Source -Destination $Destination -ErrorAction Stop
            return
        } catch {
        }
    }
    #if BITS failed, try this
    $wc = New-Object System.Net.WebClient
    try { 
        $wc.DownloadFile($Source,$Destination) 
    } finally { 
        #clear the download
        $wc.Dispose() 
    }
}

function _Validate-Download {
    <#
     .SYNOPSIS
        Compares the size of the downloaded file to the source file
    #>
    param(
        [Parameter(
            HelpMessage='source of the downloaded file')]
        $Source,
        [Parameter(
            HelpMessage='where the downloaded file went'
        )]
        $Destination
    )
    #check the file source size
    $Head = Invoke-WebRequest -Uri $Source -Method Head -UseBasicParsing -ErrorAction SilentlyContinue
    #compare it to the destination size
    if ($Head -and $Head.Headers['Content-Length']) {
        if ((Get-Item $Destination).Length -ne [int64]$Head.Headers['Content-Length']) {
            throw "Size mismatch"
        }
    }
}

function _Get-SHA256 {
    <#
     .SYNOPSIS
        Calculates the SHA-256 hash of file.
     .DESCRIPTION
        Reads the specified file from disk and computes its SHA-256 cryptographic
        hash. The resulting hash is returned as a lowercase hexadecimal string.

        This function is used to verify file integrity after download and to
        validate existing files against known hash values.
     .NOTES
        uses the .NET System.Security.Cryptography.SHA256 class & reads the file 
        as a stream to minimise memory usage.

        Copilot did this bit, I'm not nearly clever enough.
    #>
    param(
        [Parameter(
            HelpMessage='Path to the file')]
        $Path
    )
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $s = [System.IO.File]::OpenRead($Path)
    try {
        ($sha.ComputeHash($s) | ForEach-Object { $_.ToString('x2') }) -join ''
    } finally {
        #clean up
        $s.Dispose()
        $sha.Dispose()
    }
}

########################################################################
## Variables
########################################################################

# Reporting collections
$Success   = @()
$Skipped   = @()
$Failed    = @()
$HashFail  = @()

# Text colours
$ColGood = 'Green'
$ColWarn = 'Yellow'
$ColBad  = 'Red'
$ColPath = 'Blue'
$ColUrl  = 'Cyan'
$ColText = 'White'

########################################################################
## Main loop
########################################################################

Write-Host 'Starting script'    -ForegroundColor $ColText

$UrlIndex = 0

foreach ($Url in $Urls) {
    $UrlIndex++

    #open progress bar
    Write-Progress `
        -Id 0 `
        -Activity 'Scraping URLs' `
        -Status "Scanning $Url" `
        -PercentComplete (($UrlIndex / $Urls.Count) * 100)

    Write-Host "Scraping "                  -ForegroundColor $ColText
    Write-Host $Url             -NoNewline  -ForegroundColor $ColUrl

    #Check if the destination exists
    $ResolvedDest = $DestPath
    if (Test-Path $ResolvedDest -PathType Container) {
        $Name = (_Decode-UrlString (($Url -replace '[\?#].*$','').TrimEnd('/') -split '/' | Select-Object -Last 1))
        $Name = $Name -replace '[<>:"/\\|?*]', '_'
        $ResolvedDest = Join-Path $ResolvedDest $Name
    }
    #If not, create it.
    if (-not (Test-Path $ResolvedDest) -and -not $DryRun) {
        Write-Host "Creating path "             -ForegroundColor $ColText
        Write-Host $ResolvedDest    -NoNewline  -ForegroundColor $ColWarn
        New-Item -ItemType Directory -Path $ResolvedDest -Force | Out-Null
    }

    #Get the webpage
    Write-Progress `
        -Id 1 `
        -ParentId 0 `
        -Activity 'Fetching Links' `
        -Status $Name

    Write-Host "Fetching links"
    $Response = Invoke-WebRequest -Uri $Url -UseBasicParsing
    $Hrefs = [regex]::Matches($Response.Content,'href\s*=\s*["'']([^"'']+)["'']','IgnoreCase') | ForEach-Object { $_.Groups[1].Value }
    $Hrefs = $Hrefs | Where-Object {$_ -and $_ -notmatch '^(mailto:|javascript:|#)'}

    #Compare filters to links, figure out which ones we need
    
    $Files = @()
    $FilterIndex = 0

    foreach ($Filter in $Filters) {
        $FilterIndex ++

        Write-Progress `
        -Id 1 `
        -ParentId 0 `
        -Activity 'Filtering' `
        -Status $Filter `
        -PercentComplete (($FilterIndex / $Filters.Count) * 100)

        $Files += $Hrefs | Where-Object { $_ -like $Filter }
    }

    #don't double-up on file names
    Write-Host $Files.Count                 -NoNewline -ForegroundColor $ColGood
    Write-Host " file links. "              -NoNewline -ForegroundColor $ColText
    $Files = $Files | Sort-Object -Unique
    Write-Host $($Files.Count)              -NoNewline -ForegroundColor $ColGood
    Write-Host " unique values found"       -NoNewline -ForegroundColor $ColText

    $FileCount = $Files.Count
    $FileIndex = 0
    foreach ($File in $Files) {
        $FileIndex++

        #generate file name
        $DecodedName = if ($Raw) { 
            $File 
        } else { 
            _Decode-UrlString $File 
        }
        $FileName     = [System.IO.Path]::GetFileName($DecodedName)
        $DestFilePath = Join-Path $ResolvedDest $FileName
        $Source       = ([System.Uri]::new([System.Uri]$Url, $File)).AbsoluteUri
        
        #get hash values
        $PerFileHash = $null
        if ($FileHashes -and $FileHashes.ContainsKey($FileName)) {
            $PerFileHash = $FileHashes[$FileName]
        }
        $HashToUse = if ($PerFileHash) { 
            $PerFileHash 
        } else { 
            $ExpectedSha256 
        }
        if (-not $Force -and $HashToUse -and (Test-Path $DestFilePath)) {
            if ((_Get-SHA256 $DestFilePath).ToLower() -eq $HashToUse.ToLower()) {
                Write-Host "Skipping $FileName" -ForegroundColor $ColWarn
                $Skipped += "$Url :: $FileName"
                continue
            }
        }

        #if it's a dry run, we should be good
        if ($DryRun) {
            Write-Host "Skipping $FileName" -ForegroundColor $ColWarn
            $Skipped += "$Url :: $FileName"
            continue
        }

        #otherwise it's time to download
        _Invoke-WithRetry -MaxRetries $RetryCount -Action {
            #if the file exists, blat it
            if (Test-Path $DestFilePath) {
                Write-Host "Removing local $FileName" -ForegroundColor $ColWarn
                Remove-Item $DestFilePath -Force
            }
            #Download the file
            Write-Host "Downloading $FileName" -ForegroundColor $ColGood
            Write-Progress `
                -Id 1 `
                -ParentId 0 `
                -Activity 'Downloading' `
                -Status $FileName `
                -PercentComplete (($FileIndex / $FileCount) * 100)

            _Download-File $Source $DestFilePath

            #perform hash check
            Write-Host "Checking file hash"
            Write-Progress `
            -Id 1 `
            -ParentId 0 `
            -Activity 'Hashcheck' `
            -Status $FileName `
            -PercentComplete (($FileIndex / $FileCount) * 100)

            _Validate-Download $Source $DestFilePath
            if ($HashToUse) {
                if ((_Get-SHA256 $DestFilePath).ToLower() -ne $HashToUse.ToLower()) {
                    $HashFail += "$Url :: $FileName"
                    Write-Warning -Message "SHA-256 mismatch" -ErrorAction Continue
                    throw "SHA-256 mismatch"
                }
            }           
            # If we get here, the download succeeded
            Write-Host $FileName                     -ForegroundColor $ColPath
            Write-Host " downloaded"    -NoNewline   -ForegroundColor $ColGood
            $Success += "$Url :: $FileName"
        } catch {
            Write-Host $FileName                     -ForegroundColor $ColPath
            Write-Host " failed"        -NoNewline   -ForegroundColor $ColBad
            $Failed  += "$Url :: $FileName"
        }
    }
    #close Download bar
    Write-Progress `
        -Id 1 `
        -Completed
}
#close progress bar
Write-Progress `
    -Id 0 `
    -Completed

########################################################################
## Summary
########################################################################
Write-Host "`n============= Summary =============" -ForegroundColor Magenta
if ($Success) {
    Write-Host "Successful downloads:"          -ForegroundColor $ColGood       -BackgroundColor Dark$ColGood
    $Success
}
if ($Skipped) {
    Write-Host "Excluded files:"                -ForegroundColor $ColWarn       -BackgroundColor Dark$ColWarn
    $Skipped
}
if ($Failed) {
    Write-Host "Failed downloads:"              -ForegroundColor $ColBad        -BackgroundColor Dark$ColBad
    $Failed
}
if ($HashFail) {
    Write-Host "Hash verification failures:"    -ForegroundColor Dark$ColBad    -BackgroundColor $ColBad
    $HashFail
}

#we're done
Write-Host "`nAll URLs processed."

# END SCRIPT
