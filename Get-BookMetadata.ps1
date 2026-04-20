<#
 .SYNOPSIS
    Enriches a CSV file of ISBNs with metadata from OpenLibrary.org

 .DESCRIPTION
    This script reads a CSV file containing ISBN values, queries the Open Library
    Books API for each ISBN, and outputs a new CSV file containing publishing
    metadata including title, authors, publisher, publication date, subjects,
    page count, and all known ISBN-10 and ISBN-13 identifiers.

    The script supports both ISBN-10 and ISBN-13 inputs, including ISBN-10 values
    with an 'X' check digit. Input ISBNs are normalised automatically.

    Progress is displayed while processing, and the script handles missing or
    incomplete metadata gracefully.

 .PARAMETER InputCsv
    The path to the input CSV file. The CSV must contain a column named 'ISBN'.

 .PARAMETER OutputCsv
    The path to the output CSV file that will be created with enriched metadata.

 .INPUTS
    System.String

 .OUTPUTS
    A CSV file written to disk containing enriched book metadata.

 .EXAMPLE
    PS> .\Get-BookMetadata.ps1

    Reads books.csv from the current directory and writes
    books_with_publishing_info.csv with enriched data.

 .EXAMPLE
    PS> .\Get-BookMetadata.ps1 -InputCsv "C:\Temp\MyBooks.csv" OutputCsv = "C:\Temp\MyBooks_Enriched.csv"

    Uses custom input and output file paths declared in the script.

 .EXAMPLE
    PS> .\Get-BookMetadata.ps1 mybooks.csv enriched.csv

 .EXAMPLE
    PS> Set-Location C:\Temp
    PS> .\Get-BookMetadata.ps1

    Uses default values in ScriptFolder (.\books.csv, books_with_publishing_info.csv)

 .NOTES
    Author:     Bill Wilson
    Created:    2026-04-20
    Requires:   PowerShell 5.1 or later
    API Used:   https://openlibrary.org/developers/api
    License:    Public Domain / Internal Use

    Created with assistance from Microsoft Copilot, because I'm lazy sometimes

 .LINK
    https://github.com/Trael-Kun/Powershell/blob/main/Get-BookMetadata.ps1
    https://openlibrary.org/developers/api
#>

[CmdletBinding()]
param (
    [Parameter(
        Mandatory = $false,
        Position  = 0,
        HelpMessage = "Path to the input CSV file containing an 'ISBN' column."
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $InputCsv = "books.csv",

    [Parameter(
        Mandatory = $false,
        Position  = 1,
        HelpMessage = "Path to the output CSV file that will be created."
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $OutputCsv = "books_with_publishing_info.csv"
)

#Import the ISBN list
$Books = Import-Csv $InputCsv
$Total = @($Books).Count
$Index = 0

#Prepare result collection
$Results = @()

##START
foreach ($Book in $Books) {
    #Count up
    $Index++

    #Format ISBN (ISBN-10, ISBN-13, X supported)
    $Isbn = ($Book.ISBN -replace '[^0-9Xx]', '').ToUpper()
    $PercentComplete = ($Index / $Total) * 100
    Write-Progress `
        -Activity "Looking up ISBNs" `
        -Status "Processing $Index of $Total (ISBN: $Isbn)" `
        -PercentComplete $PercentComplete

    if (-not $Isbn) {
        continue
    }

    #URL to search
    $Uri = "https://openlibrary.org/api/books?bibkeys=ISBN:$Isbn&format=json&jscmd=data"

    try {
        #Lets get the rest of the info
        Write-Host "Searching for $Isbn..." -ForegroundColor Green
        $Response = Invoke-RestMethod -Uri $Uri -Method Get -ErrorAction Stop
        $Key  = "ISBN:$Isbn"
        $Data = $Response.$Key

        if ($Data) {
            #prep variables
            $Isbn10s = $null
            $Isbn13s = $null

            if ($Data.identifiers) {
                #get ISBN varients
                $Isbn10s = $Data.identifiers.isbn_10 -join "; "
                $Isbn13s = $Data.identifiers.isbn_13 -join "; "
            }
            #fill data
            $Results += [PSCustomObject]@{
                ISBN         = $Isbn
                Title        = $Data.title
                Authors      = ($Data.authors     | ForEach-Object { $_.name }) -join "; "
                Publisher    = ($Data.publishers  | ForEach-Object { $_.name }) -join "; "
                PublishDate  = $Data.publish_date
                Subjects     = ($Data.subjects    | ForEach-Object { $_.name }) -join "; "
                PageCount    = $Data.number_of_pages
                Isbn10s      = $Isbn10s
                Isbn13s      = $Isbn13s
            }
        } else {
            #nope, no record for that one
            Write-Warning "Failed to retrieve data for ISBN $Isbn"
            $Results += [PSCustomObject]@{
                ISBN         = $Isbn
                Title        = $null
                Authors      = $null
                Publisher    = $null
                PublishDate  = $null
                Subjects     = $null
                PageCount    = $null
                Isbn10s      = $null
                Isbn13s      = $null
            }
        }
    } catch {
        #nope, no record for that one
        Write-Warning "Failed to retrieve data for ISBN $Isbn"
        $Results += [PSCustomObject]@{
            ISBN         = $Isbn
            Title        = $null
            Authors      = $null
            Publisher    = $null
            PublishDate  = $null
            Subjects     = $null
            PageCount    = $null
            Isbn10s      = $null
            Isbn13s      = $null
        }
    }
}

#close up progress bar
Write-Progress `
    -Activity "Looking up ISBNs" `
    -Completed

#write results to csv
$Results | Export-Csv $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Host "Output written to $OutputCsv" -ForegroundColor Green
##END SCRIPT
